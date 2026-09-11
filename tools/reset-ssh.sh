#!/usr/bin/env bash
# Run on the workstation after reflashing the lab Pis.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tools/reset-ssh.sh [--dry-run] [--agent | -i KEY] [--known-hosts FILE] [[user@]host ...]

Refresh saved host keys, install your public key, and verify SSH on each Pi.
Defaults: A_HOST=pi@pi-foo-01.local, B_HOST=pi@pi-foo-02.local,
          C_HOST=pi@pi-foo-dhcp.local. Positional hosts replace all defaults.

  -i KEY      Local private key or public key (default: local pair, then SSH agent)
  --agent     Choose a key from SSH_AUTH_SOCK even if a local pair exists
  --known-hosts FILE  Host-key file (default: ~/.ssh/known_hosts)
  --dry-run   Show commands without changing SSH settings or connecting
  -h, --help  Show this help

Use direct hostnames or IPv4 addresses on port 22; SSH config aliases and
overrides are not used. Run without sudo. SSH asks for the new host fingerprint
and each Pi's password as needed. Only public keys are copied.
EOF
}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
run() {
  printf '  '
  printf '%q ' "$@"
  printf '\n'
  if ! "$dry_run"; then "$@"; fi
}

dry_run=false
key=''
use_agent=false
key_dir=''
cleanup() { if [[ -n "$key_dir" ]]; then rm -rf "$key_dir"; fi; }
trap cleanup EXIT
known_hosts="$HOME/.ssh/known_hosts"
hosts=()
while (( $# )); do
  case "$1" in
    --dry-run) dry_run=true; shift ;;
    --agent) use_agent=true; key=''; shift ;;
    -i)
      (( $# >= 2 )) || die '-i requires a key path'
      key="$2"; use_agent=false; shift 2 ;;
    --known-hosts)
      (( $# >= 2 )) || die '--known-hosts requires a file path'
      known_hosts="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; hosts+=("$@"); break ;;
    -*) die "Unknown option: $1" ;;
    *) hosts+=("$1"); shift ;;
  esac
done

if (( ${#hosts[@]} == 0 )); then
  hosts=("${A_HOST:-pi@pi-foo-01.local}" "${B_HOST:-pi@pi-foo-02.local}"
         "${C_HOST:-pi@pi-foo-dhcp.local}")
fi
# Validate the whole list before touching known_hosts. Keep these direct targets
# deliberately simple so the name removed is also the name SSH looks up.
for target in "${hosts[@]}"; do
  [[ "$target" =~ ^([a-zA-Z0-9_][a-zA-Z0-9_.-]*@)?[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] ||
    die "Use a direct hostname or IPv4 address, optionally user@host: $target"
done

for command in ssh ssh-keygen ssh-copy-id; do
  command -v "$command" >/dev/null || die "Install $command on your workstation first."
done
if [[ -z "$key" ]] && ! "$use_agent"; then
  for candidate in "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_rsa"; do
    if [[ -r "$candidate" && -r "$candidate.pub" ]]; then key="$candidate"; break; fi
  done
fi
if [[ -z "$key" ]]; then
  agent_keys=()
  if command -v ssh-add >/dev/null && agent_output="$(ssh-add -L 2>/dev/null)"; then
    while IFS= read -r agent_key; do
      [[ -n "$agent_key" ]] && agent_keys+=("$agent_key")
    done <<< "$agent_output"
  fi
  (( ${#agent_keys[@]} )) || die 'No local key pair or SSH agent keys found. Unlock/load your SSH agent, use -i KEY, or create a key with ssh-keygen -t ed25519.'
  printf 'Available SSH agent keys:\n'
  for (( index=0; index<${#agent_keys[@]}; index++ )); do
    printf '  %s) ' "$((index + 1))"
    printf '%s\n' "${agent_keys[$index]}" | ssh-keygen -l -f -
  done
  choice=1
  if (( ${#agent_keys[@]} > 1 )) && ! "$dry_run"; then
    [[ -t 0 ]] || die 'Multiple agent keys available. Run in a terminal to choose one, or supply its public key with -i FILE.pub.'
    read -r -p 'Key to install [1]: ' choice
    choice="${choice:-1}"
    [[ "$choice" =~ ^[1-9][0-9]*$ && ${#choice} -le 6 ]] || die 'Invalid key number.'
    (( choice <= ${#agent_keys[@]} )) || die 'Invalid key number.'
  fi
  selected_public_key="${agent_keys[$((choice - 1))]}"
  printf 'Using SSH agent key %s%s\n' "$choice" "$(if "$dry_run"; then printf ' (preview)'; fi)"
elif [[ "$key" == *.pub && ! -r "${key%.pub}" ]]; then
  [[ -r "$key" ]] || die "Cannot read public key: $key"
  selected_public_key="$(cat "$key")"
fi

if [[ -n "${selected_public_key:-}" ]]; then
  # OpenSSH accepts a public IdentityFile to select its matching agent key.
  # ssh-copy-id expects both names to exist; neither file contains a private key.
  key_dir="$(mktemp -d "${TMPDIR:-/tmp}/little-internet-ssh.XXXXXXXX")"
  key="$key_dir/identity"
  (umask 077; printf '%s\n' "$selected_public_key" > "$key"; cp "$key" "$key.pub")
fi
key="${key%.pub}"
[[ "$key" = /* ]] || key="$PWD/$key"
[[ -r "$key" && -r "$key.pub" ]] || die "Need a readable key pair: $key and $key.pub"
ssh-keygen -l -f "$key.pub" >/dev/null || die "Invalid public key: $key.pub"

[[ -n "$known_hosts" ]] || die '--known-hosts requires a nonempty file path'
[[ "$known_hosts" = /* ]] || known_hosts="$PWD/$known_hosts"
[[ -d "$(dirname "$known_hosts")" ]] || die "Host-key directory does not exist: $(dirname "$known_hosts")"
printf 'Refresh SSH for: %s\n' "${hosts[*]}"
printf 'Public key: %s.pub\n' "$key"
if [[ -f "$known_hosts" ]]; then
  if "$dry_run"; then
    printf 'Would back up %s before removing entries.\n' "$known_hosts"
  else
    # ssh-keygen's .old backup is replaced on every -R; retain one full snapshot.
    backup="$(mktemp "$known_hosts.before-reset.XXXXXXXX")"
    cp -p "$known_hosts" "$backup"
    printf 'Saved host-key backup: %s\n' "$backup"
  fi
fi

# Fresh, direct connections: a shared ControlMaster session would not prove the
# new key works. Use the same host-key file for removal, installation, and check.
ssh_opts=(-F /dev/null -o "UserKnownHostsFile=\"$known_hosts\""
          -o CheckHostIP=no -o ConnectTimeout=10 -o ConnectionAttempts=1
          -o ControlMaster=no -o ControlPath=none -o IdentitiesOnly=yes)
failures=0
for target in "${hosts[@]}"; do
  [[ "$target" == *@* ]] || target="pi@$target"
  host="${target##*@}"
  printf '\n%s\n' "$target"
  if [[ -f "$known_hosts" ]]; then
    if ! run ssh-keygen -f "$known_hosts" -R "$host"; then
      printf 'FAIL %s: could not remove the saved host key.\n' "$target" >&2
      failures=$((failures + 1)); continue
    fi
  fi
  if ! run ssh-copy-id -i "$key.pub" "${ssh_opts[@]}" -o StrictHostKeyChecking=ask "$target"; then
    printf 'FAIL %s: key installation failed; check Wi-Fi, hostname, and password.\n' "$target" >&2
    failures=$((failures + 1)); continue
  fi
  if ! run ssh "${ssh_opts[@]}" -i "$key" -o StrictHostKeyChecking=yes \
      -o BatchMode=yes -o PreferredAuthentications=publickey "$target" true; then
    if [[ -n "$key_dir" ]]; then
      printf 'FAIL %s: key login failed; unlock your SSH agent and make sure the selected key is available.\n' "$target" >&2
    else
      printf 'FAIL %s: key login failed. For a passphrase-protected key, run ssh-add %q and retry.\n' "$target" "$key" >&2
    fi
    failures=$((failures + 1)); continue
  fi
  if ! "$dry_run"; then printf 'READY %s\n' "$target"; fi
done

printf '\n'
if "$dry_run"; then
  printf 'Dry run complete; no SSH settings changed or connections made.\n'
elif (( failures )); then
  printf '%s of %s hosts need attention. Rerun with just those hosts to retry.\n' "$failures" "${#hosts[@]}" >&2
  exit 1
else
  printf 'All %s hosts are ready for key-based SSH.\n' "${#hosts[@]}"
fi
