"""Exercise local host-key changes with real ssh-keygen and no network access.

Run: python3 -m unittest discover -s tools/tests -v
"""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "reset-ssh.sh"


class ResetSSHTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="reset ssh test ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.key = self.root / "identity"
        subprocess.run(
            ["ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", str(self.key)],
            check=True,
        )
        self.public_key = Path(str(self.key) + ".pub").read_text()
        self.known = self.root / "known_hosts"
        self.original = "".join(
            f"{host} {self.public_key}"
            for host in ("pi-foo-01.local", "pi-foo-02.local", "pi-foo-dhcp.local", "unrelated.example")
        )
        self.known.write_text(self.original)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "calls.jsonl"
        # No SSH command reaches the network; key removal and backups stay real.
        for command in ("ssh", "ssh-copy-id"):
            stub = self.bin / command
            stub.write_text(
                "#!/usr/bin/env python3\n"
                "import json, os, pathlib, sys\n"
                "command = pathlib.Path(sys.argv[0]).name\n"
                "with open(os.environ['RESET_SSH_TEST_LOG'], 'a') as log:\n"
                "    log.write(json.dumps([command] + sys.argv[1:]) + '\\n')\n"
                "failed = os.environ.get('RESET_SSH_TEST_FAIL', '')\n"
                "sys.exit(1 if failed == command and 'pi@pi-foo-02.local' in sys.argv else 0)\n"
            )
            stub.chmod(0o755)
        self.env = dict(os.environ, PATH=f"{self.bin}:{os.environ['PATH']}",
                        RESET_SSH_TEST_LOG=str(self.log))
        for name in ("A_HOST", "B_HOST", "C_HOST"):
            self.env.pop(name, None)

    def run_script(self, *args):
        return subprocess.run(
            ["bash", str(SCRIPT), "-i", str(self.key), "--known-hosts", str(self.known), *args],
            env=self.env, capture_output=True, text=True,
        )

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()]

    def test_all_hosts_preserves_unrelated_entries_and_full_backup(self):
        # Hashed known_hosts is common on Linux. Check actual removal, not stubs.
        subprocess.run(["ssh-keygen", "-H", "-f", str(self.known)],
                       check=True, capture_output=True)
        before = self.known.read_bytes()
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stdout.count("READY pi@"), 3)
        backups = list(self.root.glob("known_hosts.before-reset.*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_bytes(), before)
        self.assertEqual(len(self.known.read_text().splitlines()), 1)
        found = subprocess.run(["ssh-keygen", "-F", "unrelated.example", "-f", str(self.known)],
                               capture_output=True)
        self.assertEqual(found.returncode, 0)
        self.assertEqual(len(self.calls()), 6)
        for call in self.calls():
            self.assertIn(f'UserKnownHostsFile="{self.known}"', call)
            if call[0] == "ssh":
                self.assertIn("BatchMode=yes", call)
                self.assertIn("StrictHostKeyChecking=yes", call)
                self.assertIn("ControlPath=none", call)

    def test_dry_run_leaves_files_untouched_and_never_connects(self):
        result = self.run_script("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.known.read_text(), self.original)
        self.assertFalse(self.log.exists())
        self.assertEqual(list(self.root.glob("known_hosts.*")), [])
        self.assertNotIn("READY", result.stdout)

    def test_failures_do_not_skip_remaining_hosts_or_report_all_ready(self):
        for failing_command in ("ssh-copy-id", "ssh"):
            with self.subTest(command=failing_command):
                self.env["RESET_SSH_TEST_FAIL"] = failing_command
                result = self.run_script()
                self.assertEqual(result.returncode, 1)
                self.assertIn("READY pi@pi-foo-dhcp.local", result.stdout)
                self.assertNotIn("READY pi@pi-foo-02.local", result.stdout)
                self.assertIn("1 of 3 hosts need attention", result.stderr)

    def test_positional_host_replaces_defaults_and_supports_public_key_path(self):
        result = self.run_script("-i", str(self.key) + ".pub", "pi-foo-02.local")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.calls()), 2)
        self.assertIn("pi-foo-01.local", self.known.read_text())
        self.assertNotIn("pi-foo-02.local", self.known.read_text())

    def test_invalid_target_fails_before_changes(self):
        result = self.run_script("pi-foo-01.local", "-oProxyCommand=bad")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.known.read_text(), self.original)
        self.assertFalse(self.log.exists())

    def test_missing_key_fails_before_changes(self):
        self.key.unlink()
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.known.read_text(), self.original)
        self.assertFalse(self.log.exists())

    def test_no_known_hosts_file_is_valid_on_first_setup(self):
        self.known.unlink()
        result = self.run_script("pi-foo-01.local")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.calls()), 2)

    def test_public_key_with_private_half_only_in_agent(self):
        self.key.unlink()
        result = self.run_script('-i', str(self.key) + '.pub', 'pi-foo-01.local')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        install, verify = self.calls()
        public_path = Path(install[install.index('-i') + 1])
        identity_path = Path(verify[verify.index('-i') + 1])
        self.assertEqual(str(public_path), str(identity_path) + '.pub')
        self.assertFalse(identity_path.parent.exists(), 'temporary public identities must be cleaned up')

    def mock_agent(self, key_count):
        agent = self.bin / 'ssh-add'
        agent.write_text('#!/bin/sh\ncat <<\'KEYS\'\n' + self.public_key * key_count + 'KEYS\n')
        agent.chmod(0o755)

    def test_agent_fallback_with_one_key(self):
        self.mock_agent(1)
        result = self.run_script('--agent')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('Using SSH agent key 1', result.stdout)
        self.assertEqual(result.stdout.count('READY pi@'), 3)

    def test_multiple_agent_keys_require_selection_before_changes(self):
        self.mock_agent(2)
        result = self.run_script('--agent')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Multiple agent keys available', result.stderr)
        self.assertEqual(self.known.read_text(), self.original)
        self.assertFalse(self.log.exists())

    def test_agent_dry_run_previews_first_key_without_connecting(self):
        self.mock_agent(2)
        result = self.run_script('--agent', '--dry-run')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('Using SSH agent key 1 (preview)', result.stdout)
        self.assertFalse(self.log.exists())
        self.assertEqual(self.known.read_text(), self.original)


if __name__ == "__main__":
    unittest.main()
