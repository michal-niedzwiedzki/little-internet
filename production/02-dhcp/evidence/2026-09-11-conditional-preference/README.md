# Conditional DHCP preference test — 2026-09-11

Joel explicitly authorized the agent to run this test and report back. Only
Pi 02's eth0 preference and connection lifecycle were changed. Wi-Fi management,
Pi 01's configuration, and dnsmasq's configuration/service were left alone.
Server lease files were read, not manually cleared. These follow the
[source investigation](../2026-09-11-preference-investigation/README.md).

## Starting state and test

Read-only checks confirmed Pi 02 had only 10.10.0.2/24, Pi 01 had only
10.10.0.1/24, and the server recorded those bindings. Pi 02 still had the original
unconditional `send dhcp-requested-address 10.10.0.2;` line. It was backed up on
Pi 02 as `/home/pi/cap/lesson-02-conditional-preference-original.conf` before
replacement. That backup is historical, not the final configuration.

For the conflict test, Pi 02 was configured to suggest the occupied .1:

```conf
on transmission {
    if config-option dhcp-message-type = 01 {
        send dhcp-requested-address 10.10.0.1;
    }
}
```

A time-limited tshark capture was started on eth0 with capture filter
`arp or icmp or (udp port 67 or udp port 68)`. Its startup was confirmed before
running:

```bash
sudo nmcli -w 15 connection down eth-dhcp
sudo rm -f /var/lib/NetworkManager/dhclient-ea4302a7-a8e0-43f3-8aae-d9bb45eed4db-eth0.lease
sudo nmcli -w 20 connection up eth-dhcp
```

The UUID was checked against the active lab profile before the first reset.
NetworkManager's generated config preserved the conditional block. Activation
succeeded, and `ip -4 addr show dev eth0` showed only .2. The
[complete command transcript](conflict-runtime.txt) records generated config,
address state, and this actual DHCP decode (all four rows):

```text
frame.number	dhcp.option.dhcp	dhcp.ip.your	dhcp.option.requested_ip_address	dhcp.option.dhcp_server_id
1	1	0.0.0.0	10.10.0.1	
2	2	10.10.0.2		10.10.0.254
3	3	0.0.0.0	10.10.0.2	10.10.0.254
4	5	10.10.0.2		10.10.0.254
```

Message types are 1 Discover, 2 Offer, 3 Request, 5 ACK. The Discover suggested
.1, the Offer contained .2, and Request selected .2. The ACK granted .2.
Unlike the previous unconditional setting, the configured hint did not replace
the address selected from the Offer. No NAK appears in this capture.

## Final setting and second exchange

Pi 02's `/etc/NetworkManager/dhclient-eth0.conf` was then changed to:

```conf
on transmission {
    if config-option dhcp-message-type = 01 {
        send dhcp-requested-address 10.10.0.2;
    }
}
```

A second capture and the same down/delete-client-lease/up sequence confirmed
that NetworkManager generated and used the final conditional .2 setting.
[Complete command transcript](restored-runtime.txt), with all DHCP rows below:

```text
frame.number	dhcp.option.dhcp	dhcp.ip.your	dhcp.option.requested_ip_address	dhcp.option.dhcp_server_id
1	1	0.0.0.0	10.10.0.2	
2	2	10.10.0.2		10.10.0.254
3	3	0.0.0.0	10.10.0.2	10.10.0.254
4	5	10.10.0.2		10.10.0.254
```

Pi 02 finished with only 10.10.0.2/24. The
[final server lease file](final-server-leases.txt) records Pi 02 at .2 and Pi 01
at .1. [Pi 01's address check](final-pi01-address.txt) confirms it retained .1.
Pi 01's preference configuration was not edited; it still needs a corresponding
conditional update before claiming both clients use this recipe. The physical
OLED was not visually checked by the agent.

## Archived evidence and limits

| Capture | Frames | Complete decode |
| --- | ---: | --- |
| [Conflict: suggest .1, accept .2](lesson-02-conditional-preference-conflict_pi-foo-02.pcapng) | 9 | [TSV](lesson-02-conditional-preference-conflict_pi-foo-02.tsv) |
| [Restored .2 preference](lesson-02-conditional-preference-restored_pi-foo-02.pcapng) | 9 | [TSV](lesson-02-conditional-preference-restored_pi-foo-02.tsv) |

Both capture processes exited successfully. Remote-before/local/remote-after
SHA-256 hashes match; [manifest.json](manifest.json) and
[SHA256SUMS](SHA256SUMS) record provenance and integrity. Every captured frame
was decoded successfully. The excerpts above omit non-DHCP frames 5–9, which
are preserved in the captures and TSVs.

Verified: the conditional is accepted by the installed client and NM merger;
Discover carries the hint; Request respects a different Offer; full DORA and
single-address installation work; restoring the .2 preference also works.

Not established: ordinary timed renewal, granting a newly preferred address
when no prior binding exists, or moving from an existing .8 binding to .2 with
the conditional configuration. The restored .2 test reacquired an existing .2
binding. It does not prove a client hint overrules an existing server binding.
No diary, image README, or PR changes were made during this test. The next
publication work is to validate the remaining behavior and update the recipe
and evidence consistently, rather than simply relabel the old override trace.
