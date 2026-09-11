# PR #24 fresh-image test captures — 2026-09-11

Archived from `/home/pi/cap/` on all three Pis after Joel's dry run and coached
recovery. All 19 files decode successfully. For every file, the remote hash
before copying, local hash, and remote hash after copying matched. Originals
remain on the Pis; these are stable copied snapshots, not a claim that every
capture process had been stopped.

[manifest.json](manifest.json) records source paths, sizes, frame counts,
hashes, and decoder version. [SHA256SUMS](SHA256SUMS) checks the original pcapng
files; adjacent TSVs decode every captured frame without filtering. Times are
seconds relative to each capture's first packet. DHCP message types in the TSV
are numeric: 1 Discover, 2 Offer, 3 Request, 5 ACK.

## Candidate

Tested PR head: `50b0343c8bfb978abb1a1358e35c6ea28ec05eba`.
The downloaded image is `v0.5.3-7-g64ce9be-little-internet.img.xz` from
[build 34491541652](https://github.com/ngrok/little-internet/actions/runs/34491541652).
[image.json](image.json) records its local source, size, and checksum. This
identifies the downloaded artifact; flashed card contents were not independently
hashed. The binary image is not stored in Git.

SHA-256: `e0434890addceab35dad9e1e7b5dcddec9cbad3daebcc2455d1c6258ceee2025`

## Findings anchored in the captures

- **The switch did receive .2 from this server.** In the server's initial
  `lesson-02-dry-run_dhcp_pi-foo-dhcp.pcapng`, frames 44/48/49/50 show
  Discover/Offer/Request/ACK for switch MAC 3c:78:95:3e:f4:62 and .2,
  transaction 0x00006a36. No grant of .1 to the switch was found in this file.
  This fills the missing assignment evidence noted during coaching.
- **The same initial server capture shows .1 and .8 for the Pis.** Pi 01 DORA
  is 51/56/57/58; Pi 02 DORA is 60/67/68/69, ending in .8.
- **The preference run has a meaningful Offer/Request difference.** In the
  server's `lesson-02-dry-run_nm-request_pi-foo-dhcp.pcapng`, frames 1/5/6/7
  carry transaction 0x5f7c774f. Discover requests .2, the server offers .8,
  Request asks for .2, and ACK assigns .2. The e2e server capture's transaction
  0x38ee227f (frames 53/60/61/62) shows the same pattern. Do not describe these
  as an Offer of .2. These packets alone do not establish whether the server's
  lease file was preserved before each attempt; the separate controlled test
  below establishes that procedure.
- **The duplicate .2 is captured.** Pi 01's `lesson-02-dry-arping-fix` contains
  four broadcast requests (1/4/7/10), each answered by Pi 02 and the switch.
  This file has 12 frames; Joel's pasted arping terminal output counted five
  probes and ten replies. Keep that coverage difference explicit.
- **Successful client resets:** each client's `lesson-02-dry-run_e2e-retry`
  contains DORA in frames 1–4 and announcement in frame 5. Pi 01's transaction
  is 0x820b3d47 for .1; Pi 02's is 0x837eff5b for .2. These match the coached
  cable-triggered tests with the server's lease file retained.
- **Communication after repair:** each client's e2e ping capture contains
  the matching echo request/reply in frames 1–2, followed by ARP exchanges.

The [test notes](../../../fresh-image-test.md) retain the commands, user reports,
and limits. Switch .253 persistence across power cycling remains unverified.
The controlled preference transition is now verified, as recorded below.

## Files

| Pi | Capture | Frames | Decoded fields |
| --- | --- | ---: | --- |
| pi-foo-01 | [lesson-02-dry-arping-fix_pi-foo-01.pcapng](pi-foo-01/lesson-02-dry-arping-fix_pi-foo-01.pcapng) | 12 | [TSV](pi-foo-01/lesson-02-dry-arping-fix_pi-foo-01.tsv) |
| pi-foo-01 | [lesson-02-dry-run_dhcp_pi-foo-01.pcapng](pi-foo-01/lesson-02-dry-run_dhcp_pi-foo-01.pcapng) | 83 | [TSV](pi-foo-01/lesson-02-dry-run_dhcp_pi-foo-01.tsv) |
| pi-foo-01 | [lesson-02-dry-run_e2e-fix_pi-foo-01.pcapng](pi-foo-01/lesson-02-dry-run_e2e-fix_pi-foo-01.pcapng) | 10 | [TSV](pi-foo-01/lesson-02-dry-run_e2e-fix_pi-foo-01.tsv) |
| pi-foo-01 | [lesson-02-dry-run_e2e-ping_pi-foo-01.pcapng](pi-foo-01/lesson-02-dry-run_e2e-ping_pi-foo-01.pcapng) | 6 | [TSV](pi-foo-01/lesson-02-dry-run_e2e-ping_pi-foo-01.tsv) |
| pi-foo-01 | [lesson-02-dry-run_e2e-retry_pi-foo-01.pcapng](pi-foo-01/lesson-02-dry-run_e2e-retry_pi-foo-01.pcapng) | 9 | [TSV](pi-foo-01/lesson-02-dry-run_e2e-retry_pi-foo-01.tsv) |
| pi-foo-01 | [lesson-02-dry-run_e2e_pi-foo-01.pcapng](pi-foo-01/lesson-02-dry-run_e2e_pi-foo-01.pcapng) | 4 | [TSV](pi-foo-01/lesson-02-dry-run_e2e_pi-foo-01.tsv) |
| pi-foo-01 | [lesson-02-dry-run_link-switch_pi-foo-01.pcapng](pi-foo-01/lesson-02-dry-run_link-switch_pi-foo-01.pcapng) | 66 | [TSV](pi-foo-01/lesson-02-dry-run_link-switch_pi-foo-01.tsv) |
| pi-foo-02 | [lesson-02-dry-run_dhcp_pi-foo-02.pcapng](pi-foo-02/lesson-02-dry-run_dhcp_pi-foo-02.pcapng) | 79 | [TSV](pi-foo-02/lesson-02-dry-run_dhcp_pi-foo-02.tsv) |
| pi-foo-02 | [lesson-02-dry-run_e2e-fix-ping_pi-foo-02.pcapng](pi-foo-02/lesson-02-dry-run_e2e-fix-ping_pi-foo-02.pcapng) | 6 | [TSV](pi-foo-02/lesson-02-dry-run_e2e-fix-ping_pi-foo-02.tsv) |
| pi-foo-02 | [lesson-02-dry-run_e2e-fix_pi-foo-02.pcapng](pi-foo-02/lesson-02-dry-run_e2e-fix_pi-foo-02.pcapng) | 19 | [TSV](pi-foo-02/lesson-02-dry-run_e2e-fix_pi-foo-02.tsv) |
| pi-foo-02 | [lesson-02-dry-run_e2e-retry_pi-foo-02.pcapng](pi-foo-02/lesson-02-dry-run_e2e-retry_pi-foo-02.pcapng) | 9 | [TSV](pi-foo-02/lesson-02-dry-run_e2e-retry_pi-foo-02.tsv) |
| pi-foo-02 | [lesson-02-dry-run_e2e_pi-foo-02.pcapng](pi-foo-02/lesson-02-dry-run_e2e_pi-foo-02.pcapng) | 23 | [TSV](pi-foo-02/lesson-02-dry-run_e2e_pi-foo-02.tsv) |
| pi-foo-02 | [lesson-02-dry-run_link-switch_pi-foo-02.pcapng](pi-foo-02/lesson-02-dry-run_link-switch_pi-foo-02.pcapng) | 65 | [TSV](pi-foo-02/lesson-02-dry-run_link-switch_pi-foo-02.tsv) |
| pi-foo-02 | [lesson-02-dry-run_nm-request_pi-foo-02.pcapng](pi-foo-02/lesson-02-dry-run_nm-request_pi-foo-02.pcapng) | 33 | [TSV](pi-foo-02/lesson-02-dry-run_nm-request_pi-foo-02.tsv) |
| pi-foo-dhcp | [lesson-02-dry-run_dhcp_pi-foo-dhcp.pcapng](pi-foo-dhcp/lesson-02-dry-run_dhcp_pi-foo-dhcp.pcapng) | 83 | [TSV](pi-foo-dhcp/lesson-02-dry-run_dhcp_pi-foo-dhcp.tsv) |
| pi-foo-dhcp | [lesson-02-dry-run_e2e_pi-foo-dhcp.pcapng](pi-foo-dhcp/lesson-02-dry-run_e2e_pi-foo-dhcp.pcapng) | 119 | [TSV](pi-foo-dhcp/lesson-02-dry-run_e2e_pi-foo-dhcp.tsv) |
| pi-foo-dhcp | [lesson-02-dry-run_nm-request_pi-foo-dhcp.pcapng](pi-foo-dhcp/lesson-02-dry-run_nm-request_pi-foo-dhcp.pcapng) | 27 | [TSV](pi-foo-dhcp/lesson-02-dry-run_nm-request_pi-foo-dhcp.tsv) |

## Controlled preference transition

Joel ran this follow-up on Pi 02 without reflashing, restarting dnsmasq, or
manually clearing its lease file. Starting from a confirmed .2 lease, he set
an explicit .8 preference, restarted the NetworkManager-managed client after
removing its local lease file, and confirmed .8 alone on the interface and in
the server's lease record. He then repeated with the preference set to .2.
The final interface, OLED, and server lease record all agreed on .2.
These state checks are Joel's reports; the packet fields below were independently
decoded from the archived files. Preserving the server file does not mean its
contents stayed unchanged: dnsmasq updated its lease records during the test.

| Capture | Frames | Decoded fields |
| --- | ---: | --- |
| [Move to .8](pi-foo-02/lesson-02-dry-run_lease-change_pi-foo-02.pcapng) | 13 | [TSV](pi-foo-02/lesson-02-dry-run_lease-change_pi-foo-02.tsv) |
| [Return to .2](pi-foo-02/lesson-02-dry-run_lease-change-again_pi-foo-02.pcapng) | 8 | [TSV](pi-foo-02/lesson-02-dry-run_lease-change-again_pi-foo-02.tsv) |

- Move to .8: transaction `0x65ab3865`, DORA frames 2–5. Discover and Request
  option 50 contain .8; Offer `yiaddr` is .2; ACK `yiaddr` is .8. First address
  announcement is frame 6.
- Return to .2: transaction `0x45862853`, DORA frames 1–4. Discover and Request
  option 50 contain .2; Offer `yiaddr` is .8; ACK `yiaddr` is .2. First address
  announcement is frame 5. The archive also retains frame 8, a third announcement
  not included in the seven-frame terminal excerpt Joel initially pasted.

This demonstrates the behavior of this configured client/server combination;
it is not a general claim that clients always request a different address from
the Offer or that a server must honor a preference.
