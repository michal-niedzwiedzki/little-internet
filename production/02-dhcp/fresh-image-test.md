# Fresh-image diary test — PR #24

Use this file for rough observations and sharp edges while following
[diary.md](diary.md). Record what happened before fixing it; we can then update
the diary or image without mixing the new run with the original observations.
Hardware observations and recovery tests are recorded below. All 17 available
captures are now in [the verified archive](evidence/captures/2026-09-11-pr24/README.md).

## Candidate and starting state

- PR: [https://github.com/ngrok/little-internet/pull/24](https://github.com/ngrok/little-internet/pull/24)
- PR head: `50b0343c8bfb978abb1a1358e35c6ea28ec05eba`
- Successful image build: [https://github.com/ngrok/little-internet/actions/runs/34491541652](https://github.com/ngrok/little-internet/actions/runs/34491541652)
- Workflow artifact: `v0.5.3-7-g64ce9be-little-internet.img.xz`
- Artifact ID: `10158242213`
- This is the PR candidate, not the published v0.5.3 image. PR builds use a
merge checkout, so the version suffix need not match the branch head.
- Downloaded `.img.xz` SHA-256: `e0434890addceab35dad9e1e7b5dcddec9cbad3daebcc2455d1c6258ceee2025` (local downloaded image; see archive image.json)
- Test date: 2026-09-11
- Same candidate flashed on all three Pis: **unverified**
- Hostnames: `pi-foo-01`, `pi-foo-02`, `pi-foo-dhcp`
- Wi-Fi SSH works during coaching; Pi 01 OLED/address agreement confirmed. Initial provisioning steps were performed by Joel, not independently observed.
- Starting Ethernet topology and switch state: **record**
- Capture filenames/directory for this run: [17 files indexed here](evidence/captures/2026-09-11-pr24/README.md); originals under `/home/pi/cap/` on each Pi.

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

### Finding: need neovim installed by default

- Diary heading / step: A quick tour through dnsmasq configuration
- Expected: neovim is not installed
- Actual: neovim should be installed
- Workaround tried, if any (record after preserving the failure): i did it myself
- Result / proposed correction: add installing neovim to the Pi image
- Status: open

### Finding: the switch took 10.10.0.1 (i think), then 10.10.0.2

- Diary heading / step: A quick tour through dnsmasq configuration

- Capture filename and relevant frames, if any: lesson-02-dry-run_dhcp_pi-foo-dhcp.pcapng
- Workaround tried, if any (record after preserving the failure): It's not a breaking thing, just a curiosity and worth double checking to see if that's indeed what happened
- Status: open

### Finding: truncating dnsmasq.leases leaves the other leases in uncertain territory

- Diary heading / step: You can just ask for what you want
- Pi and starting state: pi-foo-02 is on .8, and I want to switch it to .2. That works, but once 
- Expected: I would expect the other devices to ask for new leases right away
- Actual: The devices retain their existing IPs. It's unclear which IP the switch now has, since it got .2 before, but .2 is for pi-foo-02. Do they both have it? Isn't the whole point of DHCP to keep that from happening?

- Capture filename and relevant frames, if any: lesson-02-dry-run_nm-request_pi-foo-dhcp.pcapng
- Status: open

### Finding: end to end failure!

- Diary heading / step: Ready for an end-to-end rip?
- Pi and starting state:
- Expected: I've gone through the steps to reset 01 and 02, along with the dhcp server, but now when I plug them in, nothing happens
- Capture filename and relevant frames, if any: lesson-02-dry-run_e2e_pi-foo-01.pcapng
- Workaround tried, if any (record after preserving the failure): I tried running the process again, but that didn't help. Something is broken here.
- Result / proposed correction:
- Status: open

## Completion

- Steps completed:
- Remaining blockers or deviations:
- Captures ready to archive:
- Candidate ready for review/merge: **not yet verified**

A successful CI build alone is not a successful hardware walkthrough. The
later tagged release is another build and needs its own artifact check.

## Coached investigation — 2026-09-11

Joel ran the hardware commands and pasted observations in chat. The assistant
read documentation and coached one checkpoint at a time; it did not operate
the Pis. This is a troubleshooting record, not new diary/video material.

### Client activation after the reset

Pi 01 had `UP,LOWER_UP` but no IPv4 address on eth0. NetworkManager reported
`disconnected`, despite eth-dhcp targeting eth0 with autoconnect=yes and
ipv4.method=auto. Logs showed a successful lease at 09:55:58, deliberate
user-requested deactivation at 10:16:11, and subsequent cable connections
without a new activation sequence.

Explicit `sudo nmcli connection up eth-dhcp` on Pi 01 produced DORA with
transaction 0xe59ffa61 (frames 1, 3, 4, 5), followed by an ARP announcement.
Joel pasted an address listing showing exactly one eth0 IPv4 address,
10.10.0.1/24, and confirmed the OLED matched. Pi 02 was also disconnected;
Joel reports explicit activation produced full DORA and .2, but that output
was closed before it could be pasted.

This supports the documented behavior that `nmcli connection down` blocks the
profile from automatic reconnection until an unblocking action. The reset
instructions missed this state. See
[NetworkManager's connection down documentation](https://networkmanager.dev/docs/api/latest/nmcli.html).
Manual recovery is verified; a corrected cable-triggered reset remains to be
tested. Do not mark plug-in-only end-to-end repeatability verified yet.

### Duplicate .2 on the switch and Pi 02

Pi 01's initial neighbor listing contained only the server at .254. Joel ran
`sudo arping -b -I eth0 -c 5 10.10.0.2`; all five broadcasts received replies
from both Pi 02 and the switch. Representative contiguous output:

```text
Unicast reply from 10.10.0.2 [B8:27:EB:7D:E8:EE]  1.140ms
Unicast reply from 10.10.0.2 [3C:78:95:3E:F4:62]  2.254ms
```

The server's entire lease file, pasted by Joel:

```text
1789191514 b8:27:eb:7d:e8:ee 10.10.0.2 pi-foo-02 *
1789191317 b8:27:eb:3a:e2:c8 10.10.0.1 pi-foo-01 *
```

Observed: two devices claimed .2, but the server recorded only Pi 02's lease.
This strongly supports loss of the switch's server-side binding during lease
file truncation while the switch retained its address. The original switch
ACK was not inspected in this investigation. Clearing server records does not
notify clients to release their addresses; clients track lease lifetimes and
renewal themselves ([RFC 2131](https://www.rfc-editor.org/rfc/rfc2131.html#section-4.4.5)).

Joel unplugged Pi 02's Ethernet, preserving Wi-Fi SSH. Repeating the ARP probe
then produced only the switch MAC. A Mac SSH tunnel through Pi 01 to .2:80
opened the switch UI. Its screenshot showed DHCP enabled, IP 10.10.0.2,
mask 255.255.255.0, gateway 10.10.0.254. No replies were observed when probing
.253. Joel assigned the switch .253; three probes then received only the
switch MAC. After reconnecting Pi 02, Joel reported .2 had only Pi 02's MAC.
The intended fix is static switch management outside the .1–.10 pool; the
post-change DHCP toggle and persistence across a switch reboot were not checked.

### Communication after recovery

Joel reported ping worked and pasted this capture excerpt:

```text
 No. |  Time(s) | Source                     | Destination                | Proto    | Info
   1 |    0.000 | 10.10.0.1                  | 10.10.0.2                  | ICMP     | Echo (ping) request  id=0x0005, seq=1/256, ttl=64
   2 |    0.000 | 10.10.0.2                  | 10.10.0.1                  | ICMP     | Echo (ping) reply    id=0x0005, seq=1/256, ttl=64 (request in 1)
   3 |    5.115 | b8:27:eb:3a:e2:c8          | b8:27:eb:7d:e8:ee          | ARP      | Who has 10.10.0.2? Tell 10.10.0.1
   4 |    5.115 | b8:27:eb:7d:e8:ee          | b8:27:eb:3a:e2:c8          | ARP      | 10.10.0.2 is at b8:27:eb:7d:e8:ee
   5 |    5.237 | b8:27:eb:7d:e8:ee          | b8:27:eb:3a:e2:c8          | ARP      | Who has 10.10.0.1? Tell 10.10.0.2
   6 |    5.237 | b8:27:eb:3a:e2:c8          | b8:27:eb:7d:e8:ee          | ARP      | 10.10.0.1 is at b8:27:eb:3a:e2:c8
```

This directly shows one successful echo request/reply pair after recovery.
These new captures have not been copied from the Pis; their exact recovery
filenames still need recording. Image checksum and other completion fields
above remain to be filled from the actual test, not inferred from this repair.


### Revised client reset verified individually on both Pis

After recovery, Joel tested the revised reset with the server running and its
lease file intact. Pi 01's Ethernet was unplugged, and its active connection
list contained only Wi-Fi and loopback. No connection-down command was needed.
The coached preparation was:

```bash
# On the client, with Ethernet unplugged and the profile already inactive:
lease_uuid=$(nmcli -g connection.uuid connection show eth-dhcp)
sudo rm -f "/var/lib/NetworkManager/dhclient-${lease_uuid}-eth0.lease"
sudo nmcli connection modify eth-dhcp connection.autoconnect yes
```

The address preference remains configured. Start a new capture, then reconnect
Ethernet. Do not truncate the server's lease file for this client reset.

Joel explicitly confirmed that plugging Pi 01's cable in was the only trigger;
he did not run connection up. Its capture showed full DORA with transaction
0x820b3d47 and .1. Contiguous first-five-frame excerpt from his pasted output:

```text
   1 |    0.000 | 0.0.0.0                    | 255.255.255.255            | DHCP     | DHCP Discover - Transaction ID 0x820b3d47
   2 |    0.001 | 10.10.0.254                | 10.10.0.1                  | DHCP     | DHCP Offer    - Transaction ID 0x820b3d47
   3 |    0.001 | 0.0.0.0                    | 255.255.255.255            | DHCP     | DHCP Request  - Transaction ID 0x820b3d47
   4 |    0.009 | 10.10.0.254                | 10.10.0.1                  | DHCP     | DHCP ACK      - Transaction ID 0x820b3d47
   5 |    0.048 | b8:27:eb:3a:e2:c8          | ff:ff:ff:ff:ff:ff          | ARP      | ARP Announcement for 10.10.0.1
```

Asked to repeat on Pi 02, Joel reported the same success and pasted full DORA
with transaction 0x837eff5b and .2. Contiguous first-five-frame excerpt:

```text
   1 |    0.000 | 0.0.0.0                    | 255.255.255.255            | DHCP     | DHCP Discover - Transaction ID 0x837eff5b
   2 |    0.001 | 10.10.0.254                | 10.10.0.2                  | DHCP     | DHCP Offer    - Transaction ID 0x837eff5b
   3 |    0.002 | 0.0.0.0                    | 255.255.255.255            | DHCP     | DHCP Request  - Transaction ID 0x837eff5b
   4 |    0.010 | 10.10.0.254                | 10.10.0.2                  | DHCP     | DHCP ACK      - Transaction ID 0x837eff5b
   5 |    0.048 | b8:27:eb:7d:e8:ee          | ff:ff:ff:ff:ff:ff          | ARP      | ARP Announcement for 10.10.0.2
```

For each capture, frames 6–9 (omitted here) show later address announcements
and an ARP exchange with the server. Exact capture filenames remain to record
and the files have not been archived locally.

Result: individual cable-triggered resets now succeed for both clients while
preserving the server's records. The earlier ping established communication
after resolving the duplicate address. This does not establish a new combined
cold-boot run or switch configuration persistence. Full DORA does not require
blanking the server's lease file in this tested setup. The corrected procedure
is recorded here; no diary, image, or PR changes were made during coaching.


### Diary corrections applied — 2026-09-11

At Joel's request, the diary now preserves server lease records in both reset
sections; uses the verified unplug/delete-client-lease/re-enable-autoconnect
sequence for final assembly; and documents static switch management at .253.
The original switch DHCP captures are framed as historical, and their raw rows
are unchanged. B07 retains explicit down/up activation.

Still to validate: transition from an arbitrary existing lease (such as .8) to
a newly configured preference (.2) while retaining the server's existing lease
records. The successful reset tests above reacquired already-preferred
addresses; they do not by themselves validate that different transition.


### Evidence archived and image PR updated — 2026-09-11

All 17 available dry-run/recovery captures were copied from the three Pis,
verified remote-before/local/remote-after by SHA-256, and decoded successfully.
The [archive index](evidence/captures/2026-09-11-pr24/README.md) now provides
filenames, field decodes, and frame references. It supersedes earlier statements
that recovery filenames and the switch's original .2 ACK were unavailable.

The archived preference run offers .8 but ACKs the client's request for .2;
retain that distinction when analyzing the controlled preference test. Packet
rows alone do not establish the server lease-file state before that attempt.

Neovim was added to PR #24 in commit `881a780`; image installation awaits the
new CI artifact and a subsequent `nvim --version` check on that image. Existing
networking results apply to the earlier tested candidate, not to a freshly
booted Neovim build. The workstation SSH-reset utility was added separately;
its hardware execution has not been established by this coaching session.


### Controlled preference transition verified — 2026-09-11

Joel completed this on the existing Pi 02, with Ethernet connected and Wi-Fi
SSH available. No reflash, server restart, or manual server lease-file deletion
was performed. Pi 01 and the switch configuration were left as they were.

Starting state: Pi 02 had exactly 10.10.0.2/24. The server lease file listed
Pi 02 at .2 and Pi 01 at .1. A broadcast ARP probe from Pi 01 for .8 returned
no replies. Joel changed `/etc/NetworkManager/dhclient-eth0.conf` to
`send dhcp-requested-address 10.10.0.8;`, started a capture, and ran:

```bash
sudo nmcli connection down eth-dhcp
lease_uuid=$(nmcli -g connection.uuid connection show eth-dhcp)
sudo rm -f "/var/lib/NetworkManager/dhclient-${lease_uuid}-eth0.lease"
sudo nmcli connection up eth-dhcp
```

Joel confirmed .2 was gone, the interface held only .8, and the server recorded
only .8 for Pi 02. He then changed the preference to .2, started a fresh capture,
and repeated those same commands. He inspected option 50 and `Your (client) IP
address` with `tshark -n -r ... -Y 'dhcp.id == 0x45862853' -O dhcp`.
Finally he confirmed .2 alone on the interface, .2 on the OLED, and only .2 in
the server's record for Pi 02. No raw terminal output for these final state
checks was pasted; these are user-confirmed observations.

Both captures are now archived with matching remote-before/local/remote-after
SHA-256 hashes and complete TSV decodes in the
[controlled-transition archive](evidence/captures/2026-09-11-pr24/README.md#controlled-preference-transition).
Verbatim contiguous DHCP rows from each decoded TSV follow; the header records
the field order. Non-DHCP rows are omitted here and retained in each TSV.

`lesson-02-dry-run_lease-change_pi-foo-02.pcapng`:

```text
frame.number	frame.time_relative	_ws.col.def_src	_ws.col.def_dst	_ws.col.protocol	_ws.col.info	dhcp.id	dhcp.option.dhcp	dhcp.hw.mac_addr	dhcp.option.requested_ip_address	dhcp.ip.your
2	15.971162101	0.0.0.0	255.255.255.255	DHCP	DHCP Discover - Transaction ID 0x65ab3865	0x65ab3865	1	b8:27:eb:7d:e8:ee	10.10.0.8	0.0.0.0
3	15.972348786	10.10.0.254	10.10.0.2	DHCP	DHCP Offer    - Transaction ID 0x65ab3865	0x65ab3865	2	b8:27:eb:7d:e8:ee		10.10.0.2
4	15.972652579	0.0.0.0	255.255.255.255	DHCP	DHCP Request  - Transaction ID 0x65ab3865	0x65ab3865	3	b8:27:eb:7d:e8:ee	10.10.0.8	0.0.0.0
5	15.980055124	10.10.0.254	10.10.0.8	DHCP	DHCP ACK      - Transaction ID 0x65ab3865	0x65ab3865	5	b8:27:eb:7d:e8:ee		10.10.0.8
```

`lesson-02-dry-run_lease-change-again_pi-foo-02.pcapng`:

```text
frame.number	frame.time_relative	_ws.col.def_src	_ws.col.def_dst	_ws.col.protocol	_ws.col.info	dhcp.id	dhcp.option.dhcp	dhcp.hw.mac_addr	dhcp.option.requested_ip_address	dhcp.ip.your
1	0.000000000	0.0.0.0	255.255.255.255	DHCP	DHCP Discover - Transaction ID 0x45862853	0x45862853	1	b8:27:eb:7d:e8:ee	10.10.0.2	0.0.0.0
2	0.001193462	10.10.0.254	10.10.0.8	DHCP	DHCP Offer    - Transaction ID 0x45862853	0x45862853	2	b8:27:eb:7d:e8:ee		10.10.0.8
3	0.001509184	0.0.0.0	255.255.255.255	DHCP	DHCP Request  - Transaction ID 0x45862853	0x45862853	3	b8:27:eb:7d:e8:ee	10.10.0.2	0.0.0.0
4	0.008845945	10.10.0.254	10.10.0.2	DHCP	DHCP ACK      - Transaction ID 0x45862853	0x45862853	5	b8:27:eb:7d:e8:ee		10.10.0.2
```

Result: the controlled .8-to-.2 preference transition is verified with full
DORA and no manual server lease reset. In both directions, the Offer contains
the previous address, while Discover and Request contain the configured new
preference and ACK grants it. This supersedes the earlier pending-test note.
Do not infer that all clients behave this way or that preferences are guaranteed.

Publication follow-up: accommodate this observed alternative in B07's prose.
The diary's September 9 capture actually offers .2 and remains accurate for that
recording; do not rewrite its raw rows to match this new test or describe its
Offer as .8. The earlier suggestion to simply change that description was too
broad. Explain the alternative with this separate capture, or deliberately
replace the example and all matching references together. No diary text was
changed while archiving this test.


### Interpretation corrected after source investigation — 2026-09-11

The controlled transition's packet observations and final state remain valid.
However, the unconditional `send dhcp-requested-address` configuration overrides
the address selected from the Offer when dhclient constructs Request. dnsmasq
accepted the different requested address. This is not the standard SELECTING
behavior, so the successful test does not validate the recipe as a gentle
Discover preference. The proposed diary addition should not be used as written.

The [investigation report](evidence/2026-09-11-preference-investigation/README.md)
records source-backed causation and a Discover-only candidate that remains
untested. Runtime checks were read-only. A test that demonstrates honoring the
server's different Offer, followed by a properly prepared successful preference
case and ordinary renewal, remains before publishing a replacement recipe.
