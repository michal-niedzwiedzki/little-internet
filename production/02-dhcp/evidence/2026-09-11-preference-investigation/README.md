# Why the Offer and Request differ

Investigated 2026-09-11. No interface, service, configuration, lease, or capture
process was changed on the Pis. Runtime inspection was read-only; analysis used
archived captures and downloaded source matching the installed release versions.

## Finding

The unconditional configuration recommended earlier,
`send dhcp-requested-address 10.10.0.2;`, overrides the address dhclient would
normally put in its DHCPREQUEST after selecting an Offer. It is not merely a
Discover preference. In our capture, dnsmasq offers the client's existing .8
lease, dhclient sends .2 anyway, and dnsmasq grants .2 after checking its lease
and address-allocation rules.

This explains a real, successfully completed assignment, but it does not make
that Request conform to the normal SELECTING exchange. The earlier suggestion
to present it as an ordinary variation in DHCP negotiation should not be used.
The agent recommended this configuration and missed its effect on Request.

## Packet evidence

The comparison decodes preserve frame numbers and include option 54 (server
identifier) and `ciaddr`, which distinguish this Request from a renewal or an
INIT-REBOOT attempt. Message types: 1 Discover, 2 Offer, 3 Request, 5 ACK.

From [return-to-2-dhcp.tsv](return-to-2-dhcp.tsv), all rows, verbatim:

```text
frame.number	dhcp.option.dhcp	dhcp.id	dhcp.ip.client	dhcp.ip.your	dhcp.option.requested_ip_address	dhcp.option.dhcp_server_id
1	1	0x45862853	0.0.0.0	0.0.0.0	10.10.0.2	
2	2	0x45862853	0.0.0.0	10.10.0.8		10.10.0.254
3	3	0x45862853	0.0.0.0	0.0.0.0	10.10.0.2	10.10.0.254
4	5	0x45862853	0.0.0.0	10.10.0.2		10.10.0.254
```

The [source capture](../captures/2026-09-11-pr24/pi-foo-02/lesson-02-dry-run_lease-change-again_pi-foo-02.pcapng)
has eight frames; non-DHCP frames 5–8 are omitted from this decode. There is one
Offer in this file, for .8. The Request selects server .254 but requests .2.
All four messages share the same transaction ID and client MAC. The reverse
transition has the same pattern with the addresses reversed; see the
[controlled-test archive](../captures/2026-09-11-pr24/README.md#controlled-preference-transition).

The older [diary decode](diary-dhcp.tsv), from
[`lesson-02_nm-request_pi-foo-02.pcapng`](../captures/2026-09-09-nm-preference/lesson-02_nm-request_pi-foo-02.pcapng),
shows .2 in Discover/Request option 50 and in Offer/ACK `yiaddr`. Its raw rows
remain accurate. The override is invisible when the offered and configured
addresses happen to match. The older packets alone do not establish why the
server selected .2; do not assert a particular historical lease-file state.

## Protocol expectation

[RFC 2131 §4.3.1](https://www.rfc-editor.org/rfc/rfc2131.html#section-4.3.1)
prioritizes the client's current binding, then an eligible previous binding,
before a requested address when selecting an Offer. Thus an Offer of .8 despite
a Discover preference for .2 is expected with a usable existing .8 binding.

[RFC 2131 §4.3.2](https://www.rfc-editor.org/rfc/rfc2131.html#section-4.3.2)
requires the SELECTING Request's option 50 to equal the chosen Offer's `yiaddr`.
It is a MUST, not merely a suggestion. The differing .2 Request in this capture
does not follow that requirement. This is distinct from suggesting .2 in Discover,
which the protocol permits.

## Client implementation: where the override happens

[Client runtime evidence](client-runtime.txt) establishes ISC dhclient
4.4.3-P1-2 and NetworkManager 1.42.4-1+rpt1+deb12u1. The source configuration
and NetworkManager-generated `/var/lib/NetworkManager/dhclient-eth0.conf` both
contain the same unconditional `send` line. The running eth0 client was also
observed using this generated file through `-cf`, with NetworkManager as parent.
No standalone competing client was observed in that process listing.

Inspected the exact upstream [ISC DHCP 4.4.3-P1 source archive](https://downloads.isc.org/isc/dhcp/4.4.3-P1/dhcp-4.4.3-P1.tar.gz)
and the [Debian 4.4.3-P1-2 patch archive](https://deb.debian.org/debian/pool/main/i/isc-dhcp/isc-dhcp_4.4.3-P1-2.debian.tar.xz).
The Debian patch series does not change the following option-construction path:

1. `client/dhclient.c`, `state_selecting()` around lines 1429–1440, selects the
   Offer and passes that lease to `make_request()`.
2. `make_request()`, around lines 3498–3522, supplies the offered lease's address
   and server identifier to `make_client_options()` in S_REQUESTING.
3. `make_client_options()`, around lines 3307–3324, first installs the ordinary
   requested-address option using that address. Around lines 3425–3431 it then
   executes configured transmission statements against the outgoing options.
4. `client/clparse.c`, around lines 835–854, places a top-level `send` statement
   in the transmission group.
5. `common/execute.c`, around lines 310–345, passes `send` to `set_option()`;
   `common/options.c`, around lines 2381–2385, replaces any existing value.

Consequently dhclient first prepares a Request for .8, then the configured
statement replaces option 50 with .2 before the packet is serialized. This is
source-backed causation consistent with the actual configuration and capture,
not an instruction trace collected from the running binary.

The [ISC dhclient.conf manual](https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhclientconf)
describes `send` as specifying an outgoing option value and cautions against
manually specifying options the protocol already supplies. It does not promise
that this statement is a Discover-only preference.

## Server implementation: why it still ACKs .2

[Server runtime evidence](server-runtime.txt) establishes dnsmasq 2.90-4~deb12u2,
interface eth0, and the .1–.10 pool. Inspected the upstream
[dnsmasq 2.90 source archive](https://thekelleys.org.uk/dnsmasq/dnsmasq-2.90.tar.xz)
and the [Debian patch archive](https://deb.debian.org/debian/pool/main/d/dnsmasq/dnsmasq_2.90-4~deb12u2.debian.tar.xz).
No Debian patch in that archive modifies `src/rfc2131.c`.

In that source file:

- DHCPDISCOVER, around lines 1130–1137: a usable existing lease is chosen before
  option 50's suggested address, explaining the Offer of .8.
- DHCPREQUEST, around lines 1190–1201: option 50 becomes the candidate `yiaddr`;
  option 54 identifies SELECTING and the selected server.
- Around lines 1243–1249: if this client has a lease at another address, the
  old binding is pruned. The server is allowed to update its own records;
  preserving the file did not mean keeping the contents unchanged.
- Around lines 1305–1367: it checks the network, range, reservations, and
  conflicting recorded leases, then allocates the candidate. This path does
  not enforce equality with an earlier Offer before reaching ACK.

This explains both the .2 ACK and Joel's confirmation that .8 disappeared from
the server record. Acceptance by dnsmasq does not establish that every DHCP
server will accept the same Request, or that the new address must be granted.

## Candidate correction — source-reviewed, not executed

The intended teaching behavior is: suggest an address in Discover, then let
dhclient Request the address selected from the server's Offer. A candidate
replacement for the unconditional line is:

```conf
on transmission {
    if config-option dhcp-message-type = 01 {
        send dhcp-requested-address 10.10.0.2;
    }
}
```

This is NOT a tested lab instruction yet. Replace the unconditional statement;
leaving it elsewhere would preserve the override.

The source supports this candidate: `parse_on_statement()` recognizes the
transmission event; the client parser assigns its body to the transmission
group; `make_client_options()` installs outgoing message type before evaluating
that group; `config-option` reads the outgoing options. `01` is a hexadecimal
data literal for Discover's one-byte type. A top-level `if` without `on
transmission` would enter the receipt group instead, so it is not equivalent.
See the [ISC expression manual](https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhcp-eval).
NetworkManager's [1.42.4 configuration merger](https://raw.githubusercontent.com/NetworkManager/NetworkManager/1.42.4/src/core/dhcp/nm-dhcp-dhclient-utils.c)
preserves conditional blocks; actual generated configuration still needs
checking in the lab.

Expected checkpoint with the server retaining .8: Discover suggests .2, Offer
contains .8, Request selects .8, ACK grants .8, and the interface/OLED agree.
That would correctly demonstrate that the server can decline the preference.
To subsequently demonstrate granting .2, we need a deliberate, verified
per-client release/expiry or another controlled initial state. Do not wipe all
server leases to force the desired result. A server reservation is a separate
policy mechanism, not an equivalent client-preference demonstration.

Before publishing a replacement, verify the generated config, full DORA in
both honored and unhonored preference cases, installed address/server record/
OLED agreement, and ordinary renewal (which must not acquire an unconditional
option-50 override). No behavior of the candidate has been tested on hardware.

## Publication and image implications

- Do not add the previously proposed paragraph framing the mismatched Request
  as normal DHCP negotiation. Keep this investigation in research/test notes.
- B07 and the image README need a validated replacement for their unconditional
  example before publication. The clean historical capture remains valid.
- The image packages dhclient and selects its backend; it does not bake .1/.2
  preferences into fresh nodes. This finding identifies a lesson/example
  configuration issue, not evidence that the base image cannot acquire leases.
- PR #24's successful assignment test is evidence of observed behavior, not
  sufficient approval of the existing preference recipe. Preserve that distinction
  in the next PR update. No PR, image configuration, or diary was modified in
  this investigation.

[sources.json](sources.json) records downloaded source URLs, byte sizes, and
SHA-256 hashes. Source archives remain temporary local research material;
the small runtime records and packet decodes are tracked here.
