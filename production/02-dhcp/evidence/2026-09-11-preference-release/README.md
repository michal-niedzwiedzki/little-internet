# Verified preference transition and renewal — 2026-09-11

Joel authorized the agent to verify the complete transition. The conditional
Discover-only preference works with a targeted server-side release: Pi 02 moved
from a real .8 lease to .2, with full DORA and a 12-hour lease. An independent
short-lease test then demonstrated ordinary timed renewal without option 50.
The final state is Pi 02 at .2 with a 12-hour lease and the conditional .2 hint.

## What was changed

Installed `dnsmasq-utils` 2.90-4~deb12u2 on pi-foo-dhcp. An apt simulation showed
one new package, no upgrades or removals; the actual install succeeded. Used its
`dhcp_release` utility only after Pi 02's Ethernet connection was deactivated.
No entire lease file was cleared and dnsmasq was not restarted. Its MainPID was
4532 before and after the test. Pi 01's .1 lease record remained byte-for-byte
unchanged throughout; its Ethernet address was checked again at the end.

Pi 02's conditional hint temporarily changed .2 → .8 → .2. Its local Ethernet
lease file was deleted between deliberately fresh exchanges. For the separate
renewal test, `send dhcp-lease-time 120;` temporarily requested a two-minute
lease. That test-only line was removed, and another DORA restored the normal
43200-second lease. The generated NetworkManager configuration was inspected.
Wi-Fi, Pi 01's preference configuration, and switch management were not changed.
The agent did not visually inspect the OLED.

## 1. Establish a real .8 binding

[Setup transcript](setup-runtime.txt). Pi 02 initially held .2 and Pi 01 held
.1. Three broadcast ARP probes for .8 returned no replies. After deactivating
Pi 02, the server utility released its .2 binding; the server then listed only
Pi 01. Configured a conditional .8 hint, cleared Pi 02's local lease, and
reactivated it. DORA transaction `0x62f4cc3c` granted .8 for 43200 seconds.
The interface and server record both confirmed .8.

The server's setup capture used `any` so that it also recorded the locally
injected DHCPRELEASE (message type 7, frame 1, ciaddr .2). All other captures
in this archive used eth0. Do not describe this release as emitted by Pi 02:
`dhcp_release` generated it locally on the server on the client's behalf.

## 2. Confirm why the old reset was insufficient

[Retained-binding transcript](retained-runtime.txt). Set the conditional hint
to .2, then ran only down/delete-client-lease/up. The server kept its .8 binding.
Transaction `0x72ff5326` shows Discover option 50 = .2, Offer yiaddr = .8,
Request option 50 = .8, ACK yiaddr = .8. The interface and server still agreed
on .8. This directly verifies the diary mismatch; it is no longer only a source
prediction. The conditional correctly accepted the server's alternative.

## 3. Verify the corrected .8-to-.2 sequence

[Release/transition transcript](release-runtime.txt). The final preference
configuration was:

```conf
# /etc/NetworkManager/dhclient-eth0.conf, on Pi 02
on transmission {
    if config-option dhcp-message-type = 01 {
        send dhcp-requested-address 10.10.0.2;
    }
}
```

After starting captures on both client and server eth0, ran these operations:

```bash
# Pi 02: stop using the old address first.
sudo nmcli -w 15 connection down eth-dhcp

# DHCP server: inspect the binding, then release only this client's old lease.
sudo cat /var/lib/misc/dnsmasq.leases
sudo dhcp_release eth0 10.10.0.8 b8:27:eb:7d:e8:ee
sudo cat /var/lib/misc/dnsmasq.leases

# Pi 02: forget the local lease and start a full new exchange.
sudo rm -f /var/lib/NetworkManager/dhclient-ea4302a7-a8e0-43f3-8aae-d9bb45eed4db-eth0.lease
sudo nmcli -w 20 connection up eth-dhcp
```

The server's intermediate lease listing contained only Pi 01. No client
identifier was present in Pi 02's server record (the final field was `*`), so
the utility's optional client-id argument was omitted. In a different setup,
use the address, MAC, and any actual client identifier from its lease record.
The [utility's manual](https://manpages.debian.org/bookworm/dnsmasq-utils/dhcp_release.1.en.html)
documents running it on the local dnsmasq server. Releasing the server's binding
alone does not remove an address from a still-active client, hence the ordering.

The actual client capture, filtered to transaction `0x4b71747d` and formatted
with the existing tsharkie awk formatter:

```text
 No. |  Time(s) | Source                     | Destination                | Proto    | Info
   1 |    0.000 | 0.0.0.0                    | 255.255.255.255            | DHCP     | DHCP Discover - Transaction ID 0x4b71747d
   3 |    3.005 | 10.10.0.254                | 10.10.0.2                  | DHCP     | DHCP Offer    - Transaction ID 0x4b71747d
   4 |    3.005 | 0.0.0.0                    | 255.255.255.255            | DHCP     | DHCP Request  - Transaction ID 0x4b71747d
   5 |    3.013 | 10.10.0.254                | 10.10.0.2                  | DHCP     | DHCP ACK      - Transaction ID 0x4b71747d
```

The actual server capture, with the same filter and formatter:

```text
 No. |  Time(s) | Source                     | Destination                | Proto    | Info
   1 |    0.000 | 0.0.0.0                    | 255.255.255.255            | DHCP     | DHCP Discover - Transaction ID 0x4b71747d
   3 |    3.004 | 10.10.0.254                | 10.10.0.2                  | DHCP     | DHCP Offer    - Transaction ID 0x4b71747d
   4 |    3.005 | 0.0.0.0                    | 255.255.255.255            | DHCP     | DHCP Request  - Transaction ID 0x4b71747d
   5 |    3.012 | 10.10.0.254                | 10.10.0.2                  | DHCP     | DHCP ACK      - Transaction ID 0x4b71747d
```

Only the four DHCP messages are shown in these excerpts; all other frames are
retained in the full TSVs and captures. Both Offer and ACK have yiaddr .2;
Discover and Request contain option 50 = .2. Offer/ACK lease time is 43200.
The client ended with exactly .2/24 and the server recorded .2 for Pi 02.
These are the replacement B07 captures; the September 9 originals remain in
their original archive and were not modified.

## 4. Verify timed renewal independently

[Short-lease preparation](short-runtime.txt) and [renewal transcript](renewal-runtime.txt).
Requested a 120-second lease from the same server using the additional test-only
lease-time option, reacquiring .2. The initial Offer/ACK advertise a 60-second
renewal time. The actual timed Request appears at 54.644 seconds in the client
capture, followed by ACK at 54.651 seconds. We did not force this Request with
another connection restart.

Client frames 11/12 and server frames 12/13 show the renewal. The Request has
ciaddr .2, no requested-address option 50, and no server-identifier option 54;
it is sent from .2 to .254. The ACK renews .2 for 120 seconds. This demonstrates
that the conditional hint did not leak into ordinary renewal. The test observes
one renewal with accelerated timing, not a six-hour wait under the default lease.

## 5. Restore the normal final state

[Final transcript](finalize-runtime.txt). Removed the 120-second test option,
kept the conditional .2 hint, and reacquired .2 through full DORA, transaction
`0x178a7723`. The ACK grants 43200 seconds; the client reports one .2/24 address.
The final generated config contains only the conditional hint plus NetworkManager's
ordinary added options. Pi 01 still has .1. The server retains both expected
bindings and has the same MainPID as at the start.

The remaining checks previously listed for this specific recipe are now
resolved: a different Offer is accepted; a newly preferred address is granted
after targeted release; and a timed renewal works. Broader image/release checks
are separate and are not claimed by this experiment.

## Evidence

The original files remain in `/home/pi/cap/` on their source Pis. Each copied
file was hashed remotely before and after copying and compared with the local
SHA-256. Full TSV decodes retain every packet and original frame numbers.
[manifest.json](manifest.json) records the source, interface, hashes, sizes and
frame counts; [SHA256SUMS](SHA256SUMS) verifies the pcapng files.
[verification-state.json](verification-state.json) records the phase checkpoints.

| Capture | Interface | Frames | Full decode |
| --- | --- | ---: | --- |
| [lesson-02-preference-setup-eight_pi-foo-02.pcapng](lesson-02-preference-setup-eight_pi-foo-02.pcapng) | eth0 | 11 | [TSV](lesson-02-preference-setup-eight_pi-foo-02.tsv) |
| [lesson-02-preference-setup-release_pi-foo-dhcp.pcapng](lesson-02-preference-setup-release_pi-foo-dhcp.pcapng) | any | 14 | [TSV](lesson-02-preference-setup-release_pi-foo-dhcp.tsv) |
| [lesson-02-preference-retained-eight_pi-foo-02.pcapng](lesson-02-preference-retained-eight_pi-foo-02.pcapng) | eth0 | 7 | [TSV](lesson-02-preference-retained-eight_pi-foo-02.tsv) |
| [lesson-02-preference-release-to-two_pi-foo-02.pcapng](lesson-02-preference-release-to-two_pi-foo-02.pcapng) | eth0 | 8 | [TSV](lesson-02-preference-release-to-two_pi-foo-02.tsv) |
| [lesson-02-preference-release-to-two_pi-foo-dhcp.pcapng](lesson-02-preference-release-to-two_pi-foo-dhcp.pcapng) | eth0 | 10 | [TSV](lesson-02-preference-release-to-two_pi-foo-dhcp.tsv) |
| [lesson-02-preference-timed-renewal_pi-foo-02.pcapng](lesson-02-preference-timed-renewal_pi-foo-02.pcapng) | eth0 | 12 | [TSV](lesson-02-preference-timed-renewal_pi-foo-02.tsv) |
| [lesson-02-preference-timed-renewal_pi-foo-dhcp.pcapng](lesson-02-preference-timed-renewal_pi-foo-dhcp.pcapng) | eth0 | 17 | [TSV](lesson-02-preference-timed-renewal_pi-foo-dhcp.tsv) |
| [lesson-02-preference-final-twelve-hours_pi-foo-02.pcapng](lesson-02-preference-final-twelve-hours_pi-foo-02.pcapng) | eth0 | 10 | [TSV](lesson-02-preference-final-twelve-hours_pi-foo-02.tsv) |
