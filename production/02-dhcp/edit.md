# Edit state and next session

Stage: Joel has finished the walkthrough diary through B06. The raw draft and
supporting work are committed and pushed; publication review and video
preparation are next. Old-cut transcript and sampled-picture review are complete,
but continuous playback/listening remain pending. No Resolve timeline edited.

## Latest checkpoint — full B07 transition verified and aligned

Verified a real .8-to-.2 transition with conditional Discover preference and
targeted release of Pi 02's old server binding. The control retained .8 without
release. A separate timed renewal passed without option 50. Final state: Pi 02
at .2 with its conditional preference and a normal 12-hour lease; Pi 01 at .1,
its configuration unchanged. Installed dnsmasq-utils on the server; dnsmasq
was not restarted and Pi 01's server lease record remained unchanged.

Eight captures and raw transcripts are archived in
[the experiment](evidence/2026-09-11-preference-release/README.md). Updated B07's
installation/reset instructions and replaced its preference tables/links with
the verified normal-lease captures, preserving the older archive. Aligned the
image README guidance in both worktrees. The remaining B07 transition/renewal
checks are resolved; do not ask Joel to repeat them without new evidence.

Separate release checks remain: Neovim artifact verification, switch static-IP
persistence, and the workstation SSH utility's hardware check. No image build,
merge, release tag, or publication occurred in this test.

## Latest checkpoint — conditional example added to publication docs

At Joel's request, replaced the unconditional requested-address example in
`diary.md` and `image/README.md`, including the focused image PR worktree.
The prose explains that the condition applies only to Discover and lets Request
select the server's Offer. The diary no longer calls it a single-line setting.
No Pi configuration was changed in this documentation edit.

Remaining validation from the prior checkpoint still applies: timed renewal and
an assignment of a newly preferred address without an old server binding. The
historical B07 capture was not replaced; align the final walkthrough and its
capture with the tested preparation before treating publication as complete.

## Latest checkpoint — conditional preference fallback passed

Joel authorized an agent-run test on Pi 02. The conditional Discover-only hint
successfully suggested occupied .1 while allowing Request to accept the server's
.2 Offer. Restored the preference to conditional .2 and verified another full
DORA, one .2/24 client address, and matching server records. Two nine-frame
captures and raw command transcripts are saved in
[the experiment archive](evidence/2026-09-11-conditional-preference/README.md).
Pi 02 now runs the conditional .2 config; Pi 01's config was not changed.

Next: validate timed renewal and a newly preferred assignment without an old
server binding, then update B07/image README and the PR with matching evidence.
The .2 restoration test reacquired .2; it is not proof of a conditional .8-to-.2
transition. No diary/image/PR edit or switch/server configuration change was
made in this hardware test.

## Latest checkpoint — preference override cause identified

Read-only runtime inspection and version-matched source analysis establish why
the client Requested .2 after an Offer of .8: our unconditional `send` statement
overwrites dhclient's normally selected address. dnsmasq accepts it, but this
Request differs from the RFC's required SELECTING behavior. The earlier proposed
B07 addition should not describe it as an ordinary DHCP negotiation variant.
See [research.md](research.md#preference-override-correction--2026-09-11) and the
[full investigation](evidence/2026-09-11-preference-investigation/README.md).

Next: coach a test of the source-reviewed Discover-only candidate when Joel
returns. It is not hardware-validated or installed. With an existing .8 binding,
expect the server to offer .8 and the client to Request/accept .8 despite its
initial .2 hint. A later grant of .2 needs controlled per-client preparation.
Validate renewal too before changing B07/image README and refreshing PR #24.
The image does not bake in these address preferences. Hardware state, diary,
and image PR were unchanged during the investigation.

## Latest checkpoint — controlled preference transition verified

The follow-up test succeeded on the existing Pi 02: .2 → .8 → .2, with full
DORA each time, no manual dnsmasq lease clearing, and final interface/OLED/server
record agreement. Both new files are archived and hash-verified; the September
11 archive now contains 19 captures. See
[fresh-image-test.md](fresh-image-test.md#controlled-preference-transition-verified--2026-09-11)
and the [archive](evidence/captures/2026-09-11-pr24/README.md#controlled-preference-transition).

Next editorial checkpoint: explain B07's observed alternative (Offer of the
old address, Request/ACK of the preferred one). The September 9 example really
offers .2, so preserve its raw evidence and either add the separate follow-up
or replace the example consistently. No diary rewrite was made during archival.
Fresh Neovim-artifact and switch persistence checks remain separate; the earlier
build status below is historical and has not been refreshed in this checkpoint.

## Latest checkpoint — evidence archived and PR #24 refreshed

All 17 new captures are archived, hash-verified, decoded, and pushed in
`eb0f486`; see [the archive](evidence/captures/2026-09-11-pr24/README.md).
The downloaded candidate image checksum is recorded there. The original switch
.2 ACK is now directly identified, and preference traces show an Offer of .8
followed by a Request/ACK of .2; preserve that distinction in further analysis.

Neovim was added to the image PR in `881a780` and mirrored in this worktree's
package manifest. PR #24's description now records the hardware results,
procedure corrections, evidence link, and remaining checks. Its
[new build](https://github.com/ngrok/little-internet/actions/runs/34634904364)
is in progress. No merge or tag has been made.

Next: coach the controlled preference transition on the existing Pi 02. No
reflash is needed: obtain a real DHCP lease for another available address,
then request .2 while preserving the server's records. Keep Pi 01 and switch
management unchanged. Fresh Neovim-artifact and switch persistence checks
remain separate. Do not run the hardware preparation without learner pacing.

## Latest checkpoint — coached reset recovery and diary corrections

Joel diagnosed and recovered two issues: NetworkManager did not automatically
reactivate profiles after connection down, and the switch and Pi 02 both
claimed .2 after server lease records had been cleared. Explicit activation
restored DHCP; moving the switch to .253 removed the observed conflict, and
ping succeeded. Individual client resets with Ethernet unplugged, client-only
lease deletion, and an autoconnect profile update then produced cable-triggered
DORA for .1 and .2 while preserving the server's records.

The observations and raw excerpts are in [fresh-image-test.md](fresh-image-test.md).
At Joel's request, the diary now incorporates the corrected reset, preserves
server leases, and sets aside .253 for switch management. Original captures
remain intact and earlier switch DHCP behavior is identified as historical.
Next verification: arbitrary lease to newly requested preferred address with
server records retained. New recovery captures still need filenames and
archiving. No image PR, hardware, merge, or tag changes were made in this edit.

## Latest checkpoint — candidate ready for hardware testing

PR #24's image build completed successfully. The artifact is
`v0.5.3-7-g64ce9be-little-internet.img.xz` from
[run 34491541652](https://github.com/ngrok/little-internet/actions/runs/34491541652).
PR #24 is still open and draft at head `50b0343`. Joel is preparing to test;
[fresh-image-test.md](fresh-image-test.md) is the place for candidate checksum,
starting state, raw observations, workarounds, and issues. No boot/hardware
result has been recorded. Keep new captures separate from the diary's archived
recordings and validate the written steps before silently repairing them.

## Latest checkpoint — focused image PR opened

Draft [PR #24](https://github.com/ngrok/little-internet/pull/24) targets main
from `joelhans/image-dhcp-tsharkie`, head `50b0343`. Its nine files cover only
image/tool code, documentation, and the image workflow's tsharkie path filters.
It was prepared in `/tmp/little-internet-image-dhcp-pr`; this production
worktree and Joel's pending diary edits remain separate.

Local validation passed: shell syntax and executable modes; staging plus
backend/profile/viewer installation into a temporary rootfs with content and
permission checks; CLI help/errors; formatter overflow preserving fields and
alignment; dependencies; and diff whitespace. The PR's
[image build](https://github.com/ngrok/little-internet/actions/runs/34491541652)
is queued as of this checkpoint. No fresh-image boot test, merge, or tag has
occurred. Next: obtain the successful PR build artifact for Joel's hardware
walkthrough, then review/merge/tag after verification.

## Latest checkpoint — publication headings and release plan

Joel removed the beat prefixes and opening production status from diary.md.
The four video comments are now preserved verbatim, with their beat mapping,
in [diary-video-notes.md](diary-video-notes.md); they can safely be removed from
the diary. They also remain in Git history. No footage coverage is implied.

The next image can be tested from a PR workflow artifact before tagging.
The focused image PR, hardware verification, merge/tag, release-artifact check,
and separate diary PR sequence is in [the publication plan](publication-and-filming.md).
No PR or tag has been created yet.

## Next useful task

Follow [publication-and-filming.md](publication-and-filming.md). Publish the
diary independently of the video. B04's main causal gap is repaired: Joel added
the warning, server address/pool explanation, configuration restart, and client
retry. The log-follow and restart commands now name separate terminals.
B07 now uses one consistent NM-managed client path; the historical two-address
migration detour is removed. Client/server success tables use tsharkie's format
with capture links. E2E excerpts are linked and Ethernet lease resets are scoped.
Copyedit completed at Joel's request. Capture links now sit inside the prose
introducing each excerpt; frame numbers remain in the unchanged packet rows.
One note explains interface and relative-time conventions. All 45 fenced blocks
are byte-for-byte unchanged by the copyedit, all 16 distinct capture links from
the draft remain, and local Markdown links resolve. The stale opening status
is replaced; production beat headings and video notes remain for publication.

Next: review the edited prose, prepare the public layout and starting-state
note, then verify the written path against the newly built image. In particular,
check explicit activation of the manual eth profile in B02. No hardware steps
were run and no new captures are claimed by this editorial pass.

Joel decided to publish a new image with the diary. Image source now installs
tsharkie and its display dependencies, alongside the already-configured dhclient
backend. Manual installation/backend selection is now a short baseline note in
the diary, and B07 includes an inline tshark inspection of the requested address. The new artifact still needs a build, fresh-boot verification, and
release before publication; no build or release was performed here.
Local validation passed: Bash syntax, the actual build staging block in a
temporary directory, rootfs installation with identical contents and mode 755,
the installed command's help output, and required package entries.
Video work follows the corrected journey: evidence/shot list, OLED needs,
short explainers, rehearsal, footage selection, and filming.

## Remote backup checkpoint

`70a3f943aa234c5a2faa2dd017c56d25a72117ac` (Preserve DHCP walkthrough diary,
captures, and filming research) was successfully pushed to
`origin/joelhans/production-02-dhcp`. Upstream tracking is configured. This
includes all 62 pending files: diary/research/production notes, 17 packet
captures and indexes, tsharkie, and image source changes. Original video/audio
and Resolve state are excluded by design and need their separate media backup.
No image build/release, merge, or publication PR was performed.

## Earlier checkpoints (historical; current direction is above)

Latest checkpoint: Joel reports the finished-network assembly came up as
expected, with .1/.2 preferences retained. Copied all three e2e captures from
the Pis into [the e2e archive](evidence/captures/2026-09-09-e2e/README.md).
Remote-before/local/remote-after hashes match and all files decode. Each client
capture and the server capture preserve full DORA for the corresponding
preferred address; frame references and decoded tables are indexed there.
Originals remain on the Pis; no commit/push performed. Joel is continuing the
rest of the diary himself; leave diary.md untouched while he finishes.
This completed assembly supersedes the pending finished-network rehearsal
below, but does not establish a repeatable rehearsal of every earlier beat.

Latest checkpoint: both clients now use NetworkManager-managed dhclient, with
eth0-only preferences .1/.2. Pi 02's full DORA and option 50=.2 were verified
from client/server captures; Joel confirmed its OLED displays .2. Pi 01 now
also has verified DORA, option 50=.1, and exactly one eth0 IPv4 address .1.
Autoconnect is restored and Wi-Fi management retained. See
[Pi 02 evidence](evidence/captures/2026-09-09-nm-preference/README.md) and
[Pi 01 evidence](evidence/captures/2026-09-09-pi01-backend/README.md).

At Joel's request, the image source now installs isc-dhcp-client and selects
that backend for NetworkManager. Preferences remain lesson configuration.
Stage syntax/installation checks passed; no image build or release performed.
Next: rehearse the rebuild from a documented starting state. Disable per-client
preferences for the first assignment pass, then introduce them in B07; reset
lease memory deliberately and verify DORA each time. Backend selection stays
off-camera preparation. Server .254 is still temporary. No new ping or Pi 01
physical OLED check was performed during its backend migration.

Diary/archive links added at Joel's request: all nine packet excerpts now name
their host, frame numbers, and local capture; companion links cover all eleven
files. Eight excerpts match decoded rows and rounded relative times. Opening
mDNS frame 19 has matching content but differs in time (diary 10.825 s versus
archive 3.253 s); marked beside the excerpt without changing its raw text.
Resolve that provenance before using the exact timestamp on screen.

Capture archive checkpoint: Joel reports completing the beat, with client 02
assigned .8 and client communication working. Copied all eleven requested
captures from the three Pis into evidence/captures/2026-09-09/, indexed in its
README.md in diary order. Remote-before/local/remote-after SHA-256 checks all
match and all files decode with tshark. Source files remain on the Pis.
This is a local archive, not a completed commit/push or remote backup.
The diary now reaches B07; the actual .8 assignment motivates preferences.
Preserve this first-success set while preparing the next experiment.

Latest B04 experiment outcome: Joel reports full DORA after adding temporary
10.10.0.254/24 to server eth0. Read-only verification confirmed client 01's
dynamic 10.10.0.1/24 and Discover/Offer/Request/ACK in the same dnsmasq process
that earlier logged receipt on an unaddressed interface. See
evidence/2026-09-09-server-no-address-warning.md. Preserve the actual packet
capture, add the causal explanation to Joel's diary, then continue through
client 02 and communication; make server addressing persistent before a reboot.
No two-client payoff or complete repeatability claim is established yet.

Latest checkpoint, 2026-09-09: Joel's diary now runs through the B03 DHCP
explanation and is ready for B04 server configuration. Review notes are at the
top of research.md. Continue the build with brief prediction/action/result
notes, label the capture source and any deliberate resets, and preserve chosen
captures before reusing filenames. Leave diary.md to Joel. No new lab action
was performed during this editorial review.

Joel reports all three Pis reflashed and back to a basic state. He is doing the
build and writing diary.md. Leave that file to him during concurrent work.
Actual flashed-artifact checksum and fresh runtime state have not been
independently verified here; do not substitute pre-reflash inventory.

Old-cut candidates are now in old-cut-review.md and footage.csv. First audition
the cases/OLED close-ups, third-Pi reveal/assembly, and first-address reaction.
Choose original footage versus ideas to re-explain after comparing with the
new diary. Audio playback is not supported in this session, so delivery,
sound quality, and precise edit boundaries remain open. No candidate is marked
usable yet. This does not block Joel's fresh build.

Joel chose the repository image to inform the walkthrough and OLED requirements.
Write diary.md one checkpoint at a time, then use those findings to finalize
the script and build/reuse OLED tools during filming preparation. The
image-dhcp-role branch is a candidate implementation, not the starting image
or an obligation to adopt its displays. Old live-state diagnosis is parked in
prior-state-runbook.md and evidence/. Do not resume it as a prerequisite.
Since the original handoff, tsharkie has been installed and refined on all three
Pis, with loopback capture checks. pi-foo-01's device autoconnect was restored
after Joel unplugged Ethernet; see evidence/2026-09-09-fresh-readiness.md.
These checks do not establish a completed DHCP rehearsal. The old cut's full
transcript and sampled picture have received a first pass.

## Confirmed decisions

- Start from the latest repository image, walk the beats, and write the diary
  from new observations. Let those findings inform OLED development while
  finalizing the script and preparing to film; reuse prior code where it fits.
- Preserve the organic vlog style and plan the learning journey before filming.
- Prepare enough technical understanding before filming to chart the course
  and explain it accurately; use research and rehearsal to develop that path.
- Interlace scripted explainers, including natural entry and exit sentences.
- Check essential coverage at the bench and again before editing for polish.
- Track production notes on this branch. Keep the original worktree intact.
- Use stable beat IDs to connect plans, source footage, and edit decisions.
- End with automatic IPv4 assignment for both clients and demonstrated
  communication between them over lab Ethernet: connectivity and identity.
- Include client requests for .1/.2, explain the visual-consistency motive
  and server allocation, and defer address contention. Timing is reopened:
  Joel is considering baseline success before preference configuration.
- Explain why a Pi hosting the service benefits observability and ownership;
  back that promise with actual service, configuration, and packet evidence.
- If using two passes, both must show full DORA. Explain the deliberate lab
  reset and verify its repeatability before relying on the sequence for filming.

## Media and Resolve state

| Item | Current value |
| --- | --- |
| Stable original-media root | TBD |
| Export review source root | This episode directory, production/02-dhcp; footage.csv currently addresses cut-for-ryan.mp4 within it, not camera originals |
| Separate media backup location | TBD |
| Old cut | Local copy: `production/02-dhcp/cut-for-ryan.mp4`; approximately 20:54, 1080p, 24 fps; full ASR transcript read and sampled picture inspected; listening/continuous playback pending; see old-cut-review.md |
| Resolve project/library | Uninspected; record exact identity before editing |
| Current working timeline | Unset |
| Last recoverable timeline version | None created by this workflow |
| Last Resolve project export and backup | None created by this workflow |
| Last successful production-branch push | None during scaffolding; local only |

The original worktree is at:
`/Users/joelhans/orca/workspaces/little-internet/oled-lesson-01-beyond`.
The episode directory now also contains a local copy of the cut. Neither local
path establishes a portable media archive or a separate backup.

## Indexing footage

Add one selection per row in footage.csv. `source_file` is relative to the
stable media root. Use either source timecode (`HH:MM:SS:FF`, with the actual
frame rate and drop/non-drop basis) or elapsed seconds from file start, and
name that basis explicitly. `source_in` is inclusive; `source_out` is exclusive.
Do not substitute edited-timeline timecodes for source positions.

Roles: journey, explainer, evidence, transition, b-roll, audio.
Review status: unreviewed, usable, unclear, rejected.
Leave unknown fields empty; do not create dummy selections to fill the table.

## Coverage audit before assembly

| Beat | Coverage | Missing / weak material | Best source selection |
| --- | --- | --- | --- |
| B01 | Unknown | Await footage review | |
| B02 | Unknown | Await footage review | |
| B03 | Unknown | Await footage review | |
| B04 | Unknown | Await footage review | |
| B07 | Unknown | Client-preference configuration and packet evidence need preparation and review | |
| B05 | Unknown | Await footage review | |
| B06 | Unknown | Await footage review | |

Use covered, unclear, missing, or intentionally omitted after inspecting the
picture and audio. A plan or transcript does not establish usable coverage.

## Editing loop

1. Inspect and record the current Resolve project and timeline.
2. Preserve a recoverable timeline version before making an edit pass.
3. Work from actual selections and the current beat order.
4. Review the changed sequence for sound, readability, and explanatory continuity.
5. Record decisions, the resulting timeline/version, and the next task here.

| Date / pass | Beat | Decision and reason | Source or timeline reference |
| --- | --- | --- | --- |
| 2026-09-09 / gap discussion | B01 | Recorded G01 and proposed an opening that connects project ambition, previous result, and today's destination. Preserve the automatic-address motivation Joel recalls already explaining. | Joel's recollection in conversation; research.md G01; cut picture/audio still unreviewed |
| 2026-09-09 / payoff decision | B01, B05, B06 | Confirmed automatic assignment followed by client communication as the payoff. Made both demonstrations required coverage and aligned the opening and ending. | Joel's stated intent in conversation; research.md G01; no footage coverage verified |
| 2026-09-09 / switch history | B02, B03 | Preserve the purchase expectation of an included DHCP server and the correction just before filming. Propose making that change in understanding the transition to the separate service. | Joel's recollection in conversation; G02; source of discovery and device capabilities still to verify |
| 2026-09-09 / preference scope | B07, B05, B06 | Include .1/.2 client preferences from the start. Place B07 before B05, demonstrate the server's response in the full exchange, and defer address contention. | Joel's instruction; research.md R07 and RFC 2131; actual client configuration unverified |
| 2026-09-09 / old-cut first pass | B01–B07 | Logged eleven candidate windows covering nine selection ideas. Existing observability motivation, successful pings, and Request/ACK disclosure were located; preserve strengths while rebuilding the causal path. | old-cut-review.md; footage.csv; full ASR and sampled picture only; listening remains pending |

## Handoff checklist

- Current stage and next task updated.
- Essential gaps named; unresolved claims remain in research.md.
- Media root, source selections, and actual Resolve identity recorded when known.
- Important reactions or detours to preserve listed in the decision log.
- Notes committed; remote backup status stated accurately.
