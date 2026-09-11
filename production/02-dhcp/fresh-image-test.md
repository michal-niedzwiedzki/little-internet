# Fresh-image diary test — PR #24

Use this file for rough observations and sharp edges while following
[diary.md](diary.md). Record what happened before fixing it; we can then update
the diary or image without mixing the new run with the original observations.
No hardware verification is recorded yet.

## Candidate and starting state

- PR: https://github.com/ngrok/little-internet/pull/24
- PR head: `50b0343c8bfb978abb1a1358e35c6ea28ec05eba`
- Successful image build: https://github.com/ngrok/little-internet/actions/runs/34491541652
- Workflow artifact: `v0.5.3-7-g64ce9be-little-internet.img.xz`
- Artifact ID: `10158242213`
- This is the PR candidate, not the published v0.5.3 image. PR builds use a
  merge checkout, so the version suffix need not match the branch head.
- Downloaded `.img.xz` SHA-256: **record after download**
- Test date: **fill in**
- Same candidate flashed on all three Pis: **unverified**
- Hostnames: `pi-foo-01`, `pi-foo-02`, `pi-foo-dhcp`
- Wi-Fi SSH, first-boot provisioning, and OLEDs: **unverified**
- Starting Ethernet topology and switch state: **record**
- Capture filenames/directory for this run: **record**

To record the image checksum on the Mac, run `shasum -a 256` followed by the
actual downloaded `.img.xz` path. Do not record Wi-Fi passwords here.

## How to approach this pass

Follow the diary as written, starting with Ethernet unplugged. Use Wi-Fi for
management. Keep the experimental switch disconnected from a home-router LAN
so another DHCP server cannot answer the clients. Let the diary introduce
server configuration and address preferences at their intended moments.

The switch may remember its own management lease across Pi reflashes; record
its traffic without trying to make it match the old transcript. Initial client
addresses, transaction IDs, frame numbers, and timing can differ from the old
captures. Compare the behavior and fields that establish the result.

Use new capture names, such as
`lesson-02_dhcp_pi-foo-01-pr24-take01.pcapng`. tsharkie overwrites a reused
filename. Keep failed attempts as well as successful ones, and use the new
filenames and frame numbers when inspecting them with tshark.

## Things to observe

- Before starting: Wi-Fi SSH works; tsharkie and dhclient are installed; the
  image already selects NetworkManager's dhclient backend. Record any manual
  repair instead of silently reproducing setup from the old run.
- Switch/manual-address section: does creating `eth` actually activate it?
  If ping fails, save `nmcli connection show --active` and
  `ip -4 addr show dev eth0` before applying a workaround. Explicit activation
  is an open question in the written instructions.
- DHCP server section: capture starts before the trigger; unaddressed server
  behavior and logs are observed before adding `.254`; assignment follows.
- Preferences section: a fresh exchange carries the desired address in option
  50, the server's decision is visible, and the client/OLED agrees with
  `ip -4 addr show dev eth0`. Use NetworkManager throughout.
- Final assembly: cleared lease state, retained preferences/server address,
  full DORA for both clients, one expected IPv4 address per client, and ping.
- Throughout: terminal count/pacing, capture permissions, live display and
  saved capture readability, missing commands, unexpected prompts, and unclear
  instructions all count as useful findings.

## Findings

Copy this small entry for each sharp edge. Rough notes are enough; leave the
result unresolved if we have not checked it yet.

### Finding: short description

- Diary heading / step:
- Pi and starting state:
- Expected:
- Actual:
- Exact command and output:

```text
Paste the relevant raw output here.
```

- Capture filename and relevant frames, if any:
- Workaround tried, if any (record after preserving the failure):
- Result / proposed correction:
- Status: open

## Completion

- Steps completed:
- Remaining blockers or deviations:
- Captures ready to archive:
- Candidate ready for review/merge: **not yet verified**

A successful CI build alone is not a successful hardware walkthrough. The
later tagged release is another build and needs its own artifact check.
