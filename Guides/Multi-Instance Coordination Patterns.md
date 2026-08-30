---
created: 2026-08-26
edit_log:
  - DW-S287 2026-08-26 - created (absorbs the coordination-thread, relay-review,
    second-model plan review, supervised-build, and Session Exchange patterns
    from six uses; canonical home for the exchange-note handshake convention)
  - "DW-S289 2026-08-26 - third reviewer habit: flip the status on the doc the author will open (review delivered = reviewed doc says so; superseded_by for versions)"
  - "DW-S302 2026-08-30 - Pattern 4: the reviewer writes arc state for a cold reader (mandated State Board write - status / verified / next gate / turn / blocking)"
maturity: working
operator: Andrew
seed_version: 1.3.1
title: Multi-Instance Coordination Patterns
type: guide
updated: 2026-08-30
---
# Multi-Instance Coordination Patterns

*How several instances work on one project at the same time without clobbering each other - and how to put them to work deliberately: one reviewing another's plan, one coordinating parallel legs of an arc, one supervising a build chunk by chunk. The primitives this guide builds on live elsewhere and are pointed to, not restated: the session claim ceremony (Project Instructions, Orientation Step 3; the optimistic-claim pattern in the Conventions Registry), write verification and the shared-file concurrency practice (`MCP Reliability and Write Verification`), file placement by audience (Conventions Registry, "File placement - three classes"), and the review-pass principles in `Working Principles`. This guide owns the patterns, the roles, and the exchange-note convention.*

## Two kinds of concurrency

**Incidental concurrency** is always on. Any project with more than one open thread - two Cowork windows, a scheduled task and a live session, a collaborator's instance and yours - has instances sharing files that never agreed to coordinate. Every instance must assume siblings exist.

**Deliberate coordination** is a job designed for several instances: a plan reviewed by a second model before a load-bearing build, a coordinator arbitrating the shared surfaces of two parallel legs, a supervisor reviewing each chunk of a build before it is written. These are the patterns most of this guide describes.

One rule sits under both: **every shared surface has exactly one writer at a time, and everyone else verifies.** The patterns differ in how the writer is chosen and how the others get their verification done.

## Incidental concurrency - the baseline

The baseline is already in place if the Project Instructions and the MCP guide are followed; this section names the pieces so the deliberate patterns have something to stand on.

- **Claim, then read back.** Session identifiers are claimed by the optimistic-claim pattern (write the stub, re-read the `claim_id`, renumber on loss). No coordinator, no lock; convergence comes from each claimant renumbering only its own claim. The same pattern answers any future two-sessions-one-resource problem (Conventions Registry, "Optimistic-claim pattern").
- **Shared hotspots are patched at close, once, and verified.** The session-log shell and the Active Threads ledger are the files every instance touches. Patch them only at session close, verify on the filesystem, and on failure re-read the current content before retrying - another instance may have moved it (`MCP Reliability and Write Verification`, Concurrency Practices; Working Rule 11).
- **Array fields clobber on contended files.** `update_frontmatter` replaces array fields wholesale even with `merge: true`, so a sibling's `edit_log` entry written between your read and your write is silently lost. The MCP guide names the safe append path.
- **A stub claimed today is never stale.** The orientation sweep offers to reconcile stale stubs; it must be structurally incapable of offering a live sibling's stub. Three sessions can be live in one project on one day.
- **Same day, same block: defer.** If you know a sibling advanced a shared block today (a ledger row, a decision-log section), leave that block to its close, or to the next close, rather than patching it too. A supervising session that had every reason to update a thread's ledger row left it to the build session's close for exactly this reason (DataWizard, 2026-08). Two patches to one block on one day is the collision the concurrency rule exists to prevent; the row is not urgent, the collision is expensive.
- **Foreign writes are unverified writes.** A sibling instance - especially one running under another project's instructions - can leave a shared file in a state your own checks never saw (an unparseable frontmatter block, an unresolvable path). Treat the first read after a foreign write as a verification read, not a trusting one. Working Rule 5 has a write-side twin: what you did not write, you still verify before building on.

## Roles

| Role | Does | Does not |
|---|---|---|
| **Builder / executor** | Writes the artifact; owns its surfaces; posts plans and chunk notes; re-reads after every write | Write a surface it has not been designated for; write a supervised chunk without its review |
| **Reviewer** | Reads the plan (not the code) with fresh context; ground-truths the substrate; returns flags, pins, and pre-ruled questions; verifies on disk after write | Edit the artifact under review (verify-not-edit: misstatements are flagged to the human) |
| **Coordinator** | Arbitrates shared surfaces between parallel legs; designates writers; transfers work; issues interlocked instruction notes; runs the final verification pass | Do either leg's work; own an arc of its own |
| **Mechanical executor** | Executes a judgment-stripped brief verbatim (moves, splits, renames) with parity checks | Decide anything - a brief with a decision in it is the wrong brief |
| **Human** | The sole judgment node: approves, decides, arbitrates the rare genuine conflict; pokes whichever instance's turn it is | Carry content between instances |

The human's row has a history worth knowing, because the target state is not where the pattern started. In the first orchestration the human was the **message bus and the judgment node** - every note passed through the operator's clipboard between three live threads. That round-tripped two full review cycles in a day, and it also meant every note depended on the operator remembering to shuttle it. The exchange folder (below) made the channel asynchronous: sessions write to and check the folder instead of routing through a person. The supervised-build failure then showed why the last step matters: the one chunk of six that went to disk unreviewed was the one where the relay was not made in time - operator error, not a judgment failure - and it was the one chunk with defects (DataWizard, 2026-08). A gate that depends on human diligence at the exact moment attention is lowest will drop notes. So the target: **the human pokes, never shuttles.** Content moves through the folder; the human signals "your turn" and makes the decisions only a human can make.

## Pattern 1 - The coordination thread

*For parallel legs of one arc that share files.* Two sessions are executing different legs of the same design (a forward leg instituting a convention, a backward leg certifying existing material) and both need to touch the same registry section, the same decision-log file, the same mechanism doc. Rather than sequencing one leg behind the other, a third thread coordinates.

The coordinator does not do either leg's work. It reviews both legs' plans, arbitrates their shared surfaces, and issues instructions to each. Mechanics that held three concurrent threads (plus an unrelated fourth) collision-free (DataWizard, 2026-08):

- **One designated writer per shared file.** The decision-log section gets one writer for the day; the other leg's entry for that file is drafted from its own write-up and handed to the writer to log in the same touch.
- **Transfer work, don't sequence it.** When a leg's item collides with a surface the other leg owns, move the item to the owning leg rather than making the first leg wait. The colliding item is usually one of several the leg holds; the rest are collision-free and can run in parallel. "You are less blocked than you think" is the usual finding.
- **Verify-not-edit for the non-writer.** After the writer lands the transferred item, the originating leg reads it and flags any misstatement to the human. It does not patch the file.
- **Interlocked instruction notes.** One note per leg, each answering that leg's questions about the other ("is the other thread still active?", "may I run my pre-freeze sequence?"), with an explicit do-now list, a do-NOT-do list naming what was transferred and to whom, and the one dependency that remains. Mark them complete after verification.
- **A shared-surface hold list and sweep scope-exclusions.** Name the files the other leg must not touch, and exclude the other leg's folders from any convention-flip sweep the writer runs.
- **Rename notices.** If the writer renames a shared file (a decision-log section gaining a decision number in its title), tell the other leg: a patch aimed at the old name fails with not-found, and that is the rename, not a lost file.
- **The decision record, not the plan, is the source of truth.** A plan that goes through review and rebuttal rounds accumulates supersessions; the execution-time record (decisions plus the execution plan) governs, and the plan doc carries a supersede pointer.

The coordinator ends the cluster with a **final verification pass** over every touched surface, filesystem-verified, and closes the instruction notes. One recorded deviation in that pass turned out to be already fixed - the deferral was tracking drift that no longer existed - which is why the pass reads the artifact rather than the notes about it (`Working Principles`, "Verify the drift before scheduling its fix").

## Pattern 2 - Relay review (role-matched orchestration)

*For cross-project migrations, audits, and rebuilds where the work has mechanical, judgment, and review components of different weights.* Three instances in matched roles, each on the model tier its role needs:

- A **mechanical executor** (cheapest tier) on a **judgment-stripped brief**: verbatim moves, a fixed date cut, write-order safety (sections first, shell last), parity checks. If the brief needs a decision, the brief is wrong - take the decision out and hand it up.
- An **audit-executor** (middle tier) that does the substantive rebuild and writes **review-bait sections** - the places it knows a reviewer should look, stated as such.
- A **cross-project reviewer** (strongest tier) reading from the other project's context, surfacing what the rebuild's own audit could not see, and answering the open questions.

Coordination is through **explicit relay blocks**: each artifact says what it needs from whom next. The human is judgment node and, in the first run, message bus.

The evidence for keeping the roles adversarial: the cross-model review caught real errors in **both** directions - the reviewer's hypothesis about why a class of files was missing was refuted by the executor's date-check, and the executor's proposed field semantics were narrowed by the reviewer's application of a decision the executor did not have loaded. Neither instance would have self-caught its own (DataWizard, 2026-08). Two habits follow: model the rebuild on a **reference implementation** (a live project's files), not on the protocol docs alone - three findings from the reference transferred directly; and when the executor finds a defect in a Seed-owned asset, **fix it upstream while hot** rather than filing a feature request into the batch (Conventions Registry, "File placement - three classes", the Seed-owned-assets exception).

## Pattern 3 - Second-model plan review before a load-bearing build

*For any build whose defects would be expensive: a write engine, a concurrency guard, a shared-field redefinition.* `Working Principles` holds the principle ("put a review pass between design and build; the strongest form is a second-model review of the plan"). The mechanics:

1. **Send the plan, not the code.** The build session posts its chunk plan - approach, the invariants it relies on, and its open questions - before writing a line. The reviewer has the whole plan and no code, which is what makes the review cheap.
2. **Review from fresh context.** A different session, ideally a different model, and always one that has not been drafting the plan. The drafting instance is structurally blind to collisions outside its doc; a design that redefined what a shared stamp meant collided with a working rule and a skill step, and only a fresh reader saw it (`Working Principles`, "Redefining a shared field...").
3. **Ground-truth the substrate.** Every high-severity catch in a run of reviews came from reading what the design's assumptions touch - live field values, a sampled day of captures, the other writers of a field the design redefines - never from the doc alone (DataWizard, 2026-08).
4. **Return flags, pins, and pre-ruled questions.** Code-level flags ("the re-serializer will leak computed state into files"), design pins that must be decided consciously before write, minors to fold without discussion, and answers to the plan's open questions so the build does not stop to ask.
5. **Fold before the first line.** The build session folds the review into the plan and only then writes. Reviewer confirms the result after.

Three consecutive load-bearing builds each had real defects pre-empted this way at near-zero cost: a phantom re-serializer risk and a trimmed-line trap; fence-bounded frontmatter scanning and spacing edge cases; a case-insensitive recipient test and flag-date staleness (DataWizard, 2026-08).

**Design the chain with an author-response round.** In a plan -> review -> author response -> review round-2 chain, the sharpest insight surfaced in the author's **rebuttal**, not in either critique - the author, forced to answer the reviewer's question, unified it with a separate finding and saw the cheapest moment to adopt a pending convention (DataWizard, 2026-08). A review chain that ends at the critique leaves that round on the table. Two rounds converge; a third rarely earns its cost.

## Pattern 4 - Supervised build (per-chunk review relay)

*For a multi-chunk build with a reviewer instance available throughout.* This is Pattern 3 applied to every chunk, plus independent verification after each write. The protocol below is canonical here; the exchange-note convention it relies on is in the Transport section.

**The loop, per chunk:**

1. The build session posts a **chunk plan** note (`status: awaiting-review`, `audience:` the reviewer, `chunk: N`).
2. The reviewer answers with a **review note** (`status: reviewed`): verdict, pins, minors, pre-ruled questions.
3. The build session folds the review, then writes the chunk.
4. The reviewer **verifies on disk** - reads what landed, not what was reported - and posts findings. A chunk reported clean held two defects visible only on re-read: a paragraph contradicting a locked decision, and three handoff paths unresolvable from the reader's root (DataWizard, 2026-08). **The verification half matters as much as the review half.**
5. Fixes land; reviewer re-verifies; next chunk.

**The gate is on the build side, not in the human's memory.** In a declared supervised build, "a review note with `status: reviewed` for chunk N exists in the exchange folder" is a **hard precondition** to writing chunk N. Before writing, the build session lists the folder and looks for that note. If it is absent, it **pauses and asks**: "Chunk N has no review note yet - relay it, or tell me to proceed unsupervised." The human may always answer "proceed unsupervised on chunk N" - the point is that skipping review becomes a **conscious choice on the record**, never a silent omission. This moves the gate from a diligence-dependent relay to the actor's own precondition check, the same move as putting the flag sweep at orientation: enforce the reader's path at a guaranteed choke point (Conventions Registry, "The reader-path principle").

**The reviewer writes arc state for a cold reader.** A long-lived reviewer thread is a viewport, not a store: its context compacts or ends, and "where are we at on this arc" must not leave with it. At the end of every review it delivers, the reviewer updates the arc's State Board (the driver doc's canonical step state) with a fixed block: status, the last session it verified on disk, the next gate, whose turn it is (human / reviewer / builder / other project / named person), and the one blocking question. The test: a fresh instance can answer "where are we at" from the board alone, without the exchange folder or the reviewer's chat. The exchange note stays the message to the other instance; the board is where the state lives. The field shape is owned by the consuming project's tracking-surface design until the supervised-build skill codifies it.

**Recorded human decisions get their own note.** When the human makes a design decision mid-build (an approval gate's shape, a threshold), the reviewer records it as a numbered note so the build session reads the decision from the folder, not from a chat it was not in.

**A reviewer with its own tools runs the test the builder cannot.** When the build session lacks a capability (no device bridge, no live corpus), the supervisor runs the test from its own environment and posts the results - a live-corpus run of a spec's query, corrected and uncorrected variants side by side, is worth more than a synthetic fixture (DataWizard, 2026-08).

**End with a whole-build sweep.** After the last chunk, a supervisor-tier pass over every artifact the build touched, ideally from a fresh instance. The lesson behind it: *unreviewed is where the defects live.* Three supervised chunks shipped clean or with pre-write catches; the one unsupervised chunk put three defects on disk, one of which would have mass-stamped a whole project's flags as expired on the first close after rollout (DataWizard, 2026-08).

A skill for this loop is warranted on the second supervised build that uses this guide (codify on second use); until then the guide is the protocol.

## Transport - the Session Exchange folder

**Where:** the project's `Session Exchange/` folder (under its Workshop folder when one exists). The placement rule - which notes go here, which go to another project's intake, which are fixed upstream in the Seed - is the Conventions Registry's "File placement - three classes"; this section owns what the notes look like.

| Situation | Transport |
|---|---|
| Instance-to-instance within one project (reviews, review requests, chunk plans, supervision notes, recorded decisions, briefs, integration checks) | This project's `Session Exchange/` - both sides of an exchange file here |
| Addressed to another project (a handoff, a feature request, a note for their instances) | That project's intake or `Session Exchange/`, never the origin's infrastructure folder; the origin keeps a session-log line |
| A defect in a Seed-owned skill, guide, protocol, or script, found while working anywhere | Fix upstream in the Seed while the context is hot; record it in the session log; no round-trip |

**Note anatomy** (the exchange-note handshake convention - canonical here):

- **Filename:** `<Arc> - <SessionID> <Kind> NN.md` - e.g. `<Arc> - <ReviewerID> Supervision Note 03.md`, `<Arc> - <BuildID> Chunk 2 Plan.md`, `<Arc> - <SessionID> Review Request.md`. `NN` is monotonic per arc per author; both sides find the latest by listing the folder, not by memory.
- **Frontmatter:** birth metadata per the YAML Schema, plus `audience:` (the session or role meant to act next), `source_session:`, `status:` (`awaiting-review` | `reviewed` | `awaiting-response` | `closed`; `active` for an open supervision series), `related:` (the charter, the previous note), and `chunk:` for supervised builds.
- **Body:** a one-paragraph header stating what the note reviews and against what charter; a **verdict** first; then pins (must be decided before write), fixes (must land), minors (fold without discussion), and an offer or question for the other side. Cite the charter's finding numbers so the other side can trace.
- **Turn-taking from convention, not memory:** the note with the highest `NN` whose `status` names the reader's turn is the one to act on.

**Three reviewer habits** that belong with the transport because they govern what a note may claim and whether it lands:

- **Ground-truth the substrate.** A review that reads only the design doc reviews the author's beliefs. Read what the assumptions touch - and when a design redefines a shared field's meaning, read the field's **other writers**; that is where the collision lives.
- **Check every path from the reader's root.** A handoff note whose links do not resolve from the reader's project fails the same way an undelivered flag does. Reader-path failures reproduce at every scale, including inside the coordination artifacts built to fix them.
- **Flip the status on the doc the author will open.** A review note is delivered only when the *reviewed* document says so: set its `status` to name the review (`reviewed - see <note>`), add a one-line banner under the title pointing at the review note and at any revised version, and stamp its edit_log. The author's next session opens the design doc, not the exchange folder; a review that lives only in `Session Exchange/` is addressed but not delivered. Same move for a superseding version: the old doc gets `status: superseded` and a `superseded_by:` pointer. (Adopted after a review of a collaborator design note, 2026-08.)

## Worked example - a six-note supervision run

A reviewer session supervised a build session through three chunks of a shared-infrastructure build, entirely through numbered exchange notes, in one day (DataWizard, 2026-08):

1. **Note 01 - Chunk 1 plan review.** Approved with four amendments (a depersonalization pass, a field to keep, an approval gate that must be an explicit decision rather than default-on-silence, handoff refinements).
2. **Note 02 - Chunk 1 verification.** On-disk read caught two required fixes the build had reported clean: a paragraph contradicting a locked decision, and three handoff paths unresolvable from the recipient project's root. Fixed and re-verified.
3. **Note 03 - Chunk 2 design review.** Go, with three pins to decide consciously (the sweep stays read-only; a stale-stub check offers mark-abandoned only, since a backfill-close would be a pattern-matched lifecycle transition; the trace is written unconditionally with gated checks reporting n/a) and two minors; endorsed a threshold with a live-sibling guard.
4. **Note 04 - Recorded human decision.** The approval-gate shape the human chose, written down so the build session could codify it.
5. **Note 05 - Live-corpus test.** Run from the reviewer's own device bridge because the build session had none: the spec's query verbatim over a live project, corrected and uncorrected variants side by side (identical - the corrections were additive-safe), and the delta from a baseline fully attributed to corpus drift. Also verified Chunks 1-2 on disk.
6. **Note 06 - Decision-entry review and Chunk 3 retro-verification.** Chunk 3 had gone to disk unreviewed (the relay was not made in time). Three defects found: expiry keyed on age instead of the due field; no pre-rollout guard, which would have mass-expired every pre-existing flag on the first close; deferred flags overwritable. All three fixed and verified before close.

The run produced the protocol in Pattern 4: every relayed chunk was clean or caught pre-write; the one dropped relay was the one with defects; and the fix was to make the gate a build-side precondition rather than a better-remembered relay.

## Choosing a pattern

| Situation | Pattern |
|---|---|
| A solo session discovers a live sibling (a stub claimed today, a shared block touched today) | Baseline: patch shared hotspots at close only, defer same-day blocks, verify foreign writes |
| Two legs of one arc must touch the same files | Coordination thread |
| A cross-project migration, audit, or rebuild with mechanical + judgment + review components | Relay review |
| One load-bearing build, one plan | Second-model plan review (with an author-response round if the review raises design questions) |
| A multi-chunk build with a reviewer available throughout | Supervised build, gate on the build side |
| Any of the above needs a note to reach another instance | Session Exchange, per the note anatomy |

**Codify on second use.** A coordination shape used twice gets its own section here. Each pattern above earned its place that way - the relay review was flagged for codification at its first use and written up at its sixth; the cost of the delay was five uses of a pattern that lived only in session logs.

---

*Evidence classes are cited as (project, month) per the Seed depersonalization rule; the session-level detail lives in the originating project's session log and Session Exchange folder. Related: `Working Principles` (review-pass principles), `MCP Reliability and Write Verification` (concurrency practice and write verification), `Team Attention Rollout` (the reader-path principle applied to flags), Conventions Registry (optimistic-claim pattern, file placement, reader-path principle).*
