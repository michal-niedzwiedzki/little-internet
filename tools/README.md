# Workstation and node tools

## Restore SSH after reflashing

Run this from the repo root on your Mac or Linux workstation once the Pis have
booted and joined management Wi-Fi:

```bash
./tools/reset-ssh.sh
```

This handles `pi@pi-foo-01.local`, `pi@pi-foo-02.local`, and
`pi@pi-foo-dhcp.local` in sequence. It backs up your workstation's
`~/.ssh/known_hosts`, removes each target's old host key with `ssh-keygen -R`,
installs your public key with `ssh-copy-id`, and checks that key login works.
It preserves unrelated host entries, your local key pair, and other authorized
keys on the Pis. It does not change the Pis' network or lesson state.

SSH asks you to accept each new host fingerprint and enter the Pi's password
when needed (`little-internet` on the stock image). Use this after a known
reflash: removing a host key means trusting that host's identity again.
The script reports `READY` for each successful Pi, continues if one fails, and
exits unsuccessfully if any still need attention.

Preview it, choose a different key, or target a subset/custom hostnames:

```bash
./tools/reset-ssh.sh --dry-run
./tools/reset-ssh.sh -i ~/.ssh/my_lab_key
./tools/reset-ssh.sh --agent
./tools/reset-ssh.sh pi@pi-foo-02.local pi@pi-foo-dhcp.local
./tools/reset-ssh.sh pi@192.168.1.42
```

`A_HOST`, `B_HOST`, and `C_HOST` override the default targets; positional hosts
replace the whole list. Bare hostnames use the `pi` account. The script uses
direct hostnames or IPv4 addresses on port 22, bypassing SSH config aliases and
overrides so the host entry it resets matches the connection it checks. It only
removes the exact names supplied: if you also SSH by IP, pass those addresses
separately to refresh their entries.

Use `--known-hosts /path/to/file` if you keep your lab's host keys in a separate
file. The script uses that file for both the reset and subsequent connections.

Run without `sudo`. You need `ssh`, `ssh-keygen`, and `ssh-copy-id` installed
locally. By default it uses `~/.ssh/id_ed25519`, falling back to
`~/.ssh/id_rsa`, then to keys available through your SSH agent (`SSH_AUTH_SOCK`,
including a password manager's agent). `--agent` skips local key discovery.
When the agent offers several keys, the script asks you to pick one; a dry run
previews the first key. Only the selected public key is copied. Temporary public
identity files select the matching private key in the agent and are removed on
exit; private keys stay in the agent.

`-i` accepts either the private key path or a `.pub` file, including a public key
whose private half lives only in your agent. Unlock the agent before running.
If you have no key pair or agent, create a key with `ssh-keygen -t ed25519`. For a
passphrase-protected key, load it with `ssh-add ~/.ssh/id_ed25519` so the final
noninteractive login check can use it. For a custom key outside SSH's default
paths, also use `ssh -i /path/to/key pi@hostname.local` for later logins, or add
it to your normal SSH configuration.

## Tools that run on the Pis

- [Status OLED](./status-oled/): boot-time identity display.
- [OLED test](./oled-test/): smoke tests for the panel.
- [ARP OLED](./arp-oled/): live ARP-state viewer.
- [tsharkie](./tsharkie/): live packet rows with capture recording.
