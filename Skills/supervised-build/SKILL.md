---
name: supervised-build
description: >-
  Use when a supervised build is declared or resumed - a multi-chunk build with
  a reviewer instance available throughout, coordinating through the project's
  Session Exchange folder (Coordination Patterns, Pattern 4). Load in either
  seat: build session or reviewer session. Triggers on: 'this is a supervised
  build', 'you are the reviewer / supervisor for this build', 'builder thread' /
  'reviewer thread', or resuming a build arc that has supervision notes in
  Session Exchange. Not for a one-shot plan review before a single build
  (Pattern 3), a build with no reviewer available, or incidental concurrency
  between unrelated sessions.
type: skill
version: '1.5.2'
created: '2026-08-30'
updated: 2026-10-18
operator: Andrew
edit_log:
  - 'DW-S419 2026-10-18 - v1.5.2: Reviewer Steps - operator-run check scripts travel as vault files with sha256 checked against the rehearsal copy, never heredoc pastes; in-thread delivery bullet points to it (DW-S418 Seed history purge)'
  - 'DW-S403 2026-10-13 - v1.5.1: in-thread variant - per-builder worktree and output folder, no git stash across worktrees (board intake B-0072, Holonic Canvas)'
  - 'DW-S398 2026-10-12 - v1.5.0: Reviewer 3 fixture experiments (two runs, partial apply, re-plan); forced event ordering for a claimed flake; in-thread variant: lead re-counts from files, resume the plan reviewer for verification, cancelled launch may have run (board intake)'
  - 'DW-S397 2026-10-12 - v1.4.0: In-thread variant section (sub-agent builder; codified on second use); Builder 4 ship-the-spec-surface-early; Reviewer 3 independent classifier over rollback copies; whole-build sweep = blind hand run for skills; chunk-vs-pre-flight instruments (meta-learning review S377-S392)'
  - "DW-S306 2026-08-30 - v1.0: codified from Coordination Patterns Pattern 4
    after four field runs; owns the reviewer's mandated State Board write (five
    fields) and the build-side review gate"
  - "DW-S303 2026-08-30 - v1.1: real-file probe rule added to Reviewer
    verification (probe a copy of the hottest real file, not only fixtures;
    field-grounded)"
  - "DW-S317 2026-08-31 - v1.2: silent-drops probe added to Reviewer Steps (any
    silently discarded input gets a counter/warning; second field arc -
    stamp_blocks S294, dw_status S319 - met codify-on-second-use)"
  - "DW-S333 2026-09-05 - v1.3: harness-validation rule added to Reviewer Steps
    (validate the harness against the real tool's actual output; per-scenario
    expected-message assertions) - second field arc of the
    instrument-measures-itself class (S268 flag distribution, S333 insteadOf
    harness) met codify-on-second-use"
  - 'DW-S327 2026-09-06 - v1.3.1: Shared Setup step 0 - charter authors grep the shared canon before scoping (field-grounded)'
  - "DW-S374 2026-09-23 - v1.3.2: owning-project supervisor orientation
    (Shared Setup 2); same-session review->build sequencing note (seats
    section). Meta-learning review S301-S323."
  - "DW-S374 2026-09-23 - v1.3.3: fresh-eyes definition (Reviewer Steps;
    meta-learning review S324-S337)"
  - "DW-S374 2026-09-23 - v1.3.4: reviewer-lands-cheap-guards boundary
    (Reviewer Steps; meta-learning review S338-S362)"
---

# Supervised Build Skill

## Overview

A supervised build runs a multi-chunk build through a per-chunk review relay: the build session plans a chunk, a reviewer instance reviews it, the build session writes it, the reviewer verifies **on disk**, fixes land, next chunk. The two instances communicate only through numbered notes in the project's `Session Exchange/` folder; the human operator pokes ("your turn") but never shuttles content.

The conceptual home is `Seed/Guides/Multi-Instance Coordination Patterns.md` - Pattern 4 for the loop and its rationale, the Transport section for note anatomy, naming, and the status handshake. This skill is the procedure. It also codifies two things the guide delegates: the **build-side gate** as a hard step, and the reviewer's **mandated State Board write** (the five-field block).

Why the gate is structural: across the field runs that produced this skill, every relayed chunk shipped clean or was caught pre-write; the one chunk written without review put three defects on disk (DataWizard, 2026-08). A relay that depends on human diligence will drop notes - so the precondition check belongs to the actor, not the operator's memory.

## Which seat are you in?

- **Build session** -> read Shared Setup, then Builder Steps.
- **Reviewer session** -> read Shared Setup, then Reviewer Steps and The State Board Write.

Both seats follow the guide's Transport conventions for filenames, frontmatter, and statuses - never improvise these; turn-taking runs on them. Taking both seats in one session (review, then build) is fine when the review target and the build charter are *different documents* - the design-then-build separation protects design freshness, which the earlier design session already provided. (DataWizard, 2026-09)

## Shared Setup (once per build)

0. **Charters for shared-canon content: grep the canon first.** When the build's deliverable lives in a shared canon location (a guide, protocol, or template collection), the charter author greps that collection for existing homes of every scoped topic BEFORE scoping sections, and the chunk-1 plan reports the division (what points where, what this build owns). A charter that scopes a section an existing doc already owns produces a restatement the reviewer must catch late; the grep moves the catch to authoring time. (Field grounding: a guide charter scoped a section that restated an existing runtime-behaviors guide; the reviewer's ground-truthing caught it at the chunk-1 gate, 2026-09.)

1. **Confirm the declaration.** A supervised build is declared by the human or by the charter (build plan). If the declaration exists only in chat, record it in the chunk-1 plan note so it is on the record.
2. **Name the parts:** the arc (the short name used in every exchange filename), the charter (the build plan or design doc the build executes), the **driver doc** that holds arc state, and the project's `Session Exchange/` folder. When the build targets another project's repo, orient the supervisor to the *owning* project, not the target repo: the run-don't-read discipline and the tool contract live in the owning frame. (Field grounding: an owning-frame supervisor caught a key-gluing class defect before the live run, 2026-08.)
3. **State Board present.** The driver doc must have a `### State Board` section. If absent, the reviewer creates it at its first write, using the five-field block below.
4. **Turn-taking from convention, not memory:** the highest-numbered note for the arc whose `status` names your seat is the one to act on. Both sides find the latest by listing the folder.

## Builder Steps (per chunk)

1. **Post the chunk plan.** `<Arc> - <SessionID> Chunk N Plan.md` with `status: awaiting-review`, `chunk: N`, `audience:` the reviewer. State what the chunk writes, where, and against which charter sections.
2. **The gate - hard precondition.** Before writing chunk N, list the exchange folder and require a note with `status: reviewed` covering chunk N. If it is absent, **pause and ask**: "Chunk N has no review note yet - relay it, or tell me to proceed unsupervised." Never write on silence. If the human answers "proceed unsupervised," record that answer in the chunk plan note before writing - skipping review is a conscious choice on the record, never a silent omission.
3. **Fold the review.** Pins are decided before writing (with the human where the review says so); fixes must land; minors fold without discussion. If the review raises a design question, answer it in a response note rather than writing around it.
4. **Write the chunk, then report what landed** - exact paths, sections, versions - not what was intended. Expect the reviewer to re-read everything on disk; "reported clean" is not a state. Ship the user-facing spec surface early - a mirror header, a usage block, a README line - in the first chunk that makes the feature reachable, not at the declaration of done: a parallel session used the hand path before the build was declared done, because the surface it read was the only one that existed. (DataWizard, 2026-10)
5. **Fix round.** Land the verification findings, confirm in the exchange note, move to the next chunk.
6. **Read decisions from the folder.** Mid-build human decisions arrive as numbered notes from the reviewer - never act on a decision you only heard about secondhand.

## Reviewer Steps

A pre-flight fresh-eyes review earns its keep even single-session: "fresh eyes" means *did not author the artifact*, not necessarily a separate thread - a same-session reviewer who did not write the chunk still catches what the author cannot. (DataWizard, 2026-09) Chunk reviews and the whole-build pre-flight are different instruments, keep both: a chunk review sees what the chunk touches, the pre-flight sees what the whole build assumes. In two arcs a builder-written pre-flight note answered by a fresh reviewer found four defects that seven chunk reviews of the same artifacts had passed (a stale block, a filter that had never fired, a change feed with no per-run sequence, a missing release note). The standing pre-flight questions live in the consuming project's 0.0 until their Seed home lands. (DataWizard, 2026-10)

**Reviewer-lands-cheap-guards boundary.** A reviewer may land a finding directly - collapsing review -> builder -> re-review into one session - only when it is a small, class-level guard the reviewer can prove in-session with a fixture plus a live dry-run. Body rewrites and design changes always go back to the builder, who has the build context. (DataWizard, 2026-09; stated independently twice before naming.)

Per chunk:

1. **Review the plan.** Verdict first, then pins (must be decided before write), fixes (must land), minors (fold silently), and pre-ruled answers to questions the builder will hit mid-chunk. Cite the charter's section or finding numbers so the builder can trace. Ground-truth the substrate: read what the plan's assumptions touch, not just the plan.
2. **Verify on disk after every write.** Read what landed, never what was reported. The verification half matters as much as the review half - reported-clean chunks have held defects visible only on re-read.
3. **Run, don't read, shipped scripts.** Test any script the build ships by running it on scratch fixtures **outside the vault** (a scratch dir in the shell's home, never the working tree). When a run finds an edge bug and the fix comes back as a special case, ask for the class rule, and build fixtures for the bug's *neighbors* - "what else starts a new element / what else looks like this input" - before accepting. Require dry-run output that proves the target (e.g. the line number): verify-after-write only proves the script matched its own intent. When the build ships an apply step that keeps rollback copies, verify the apply with an independent classifier over those copies - a second query or script that shares nothing with the apply script's own guard - never with the guard that did the writing. (DataWizard, 2026-10) The reviewer brief asks for experiments on the fixtures, not only a read: two runs in a row (idempotency), a partial apply, a re-plan after a change. In one field run 29 tests passed while four must-fix defects surfaced only from these experiments. (Holonic Canvas, 2026-10)
4. **Record human decisions** as their own numbered notes, so the build session reads the decision from the folder, not from a chat it was not in.
5. **Run the tests the builder cannot.** When the build session lacks a capability (no device bridge, no live corpus), run the test from your own environment and post the results - a live-corpus run beats a synthetic fixture.
6. **Deliver, don't just file.** Flip the reviewed doc's `status` to name the review, add the banner, stamp its edit_log (the guide's Transport habits) - the author's next session opens the doc, not the exchange folder. Then end your turn with the path of the note the other side reads next: the human relays by poke, and a missing link costs a round trip.
7. **Update the State Board** (next section) before the turn ends. This is part of delivering a review, not optional bookkeeping.

**Cheap fixes are yours.** Patch small, well-specified defects yourself in files you already have loaded; anything that requires the builder to re-read or rewrite a body goes into the review note as instructions. And check the builder's status before filing: a supervision note filed after the supervised session closed has no reader - land small fixes yourself and put the state on the board.

**Operator-run scripts travel as vault files, not pastes.** When a check script is for the human operator to run in their own terminal, it reaches them as a vault file, and the operator compares its sha256 with the value the reviewer recorded from its rehearsal copy before running it. Never deliver such a script as a heredoc paste: a long paste can be cut off partway. This holds in the relay and in the in-thread variant alike. (DataWizard, 2026-10)

**End with a whole-build sweep.** After the last chunk, a supervisor-tier pass over every artifact the build touched, ideally from a fresh instance. Unreviewed is where the defects live. For a skill deliverable the sweep is a blind hand run: a fresh instance holding only the skill text runs it end to end, and the skill is "built" when that run passes - not when the text is written. One blind run surfaced fourteen defects the author could not see. (DataWizard, 2026-10)

**Probe the real thing, not only fixtures.** When verifying a shipped tool or script, include at least one probe against a copy of the hottest real production file it will touch (copied to scratch, never the original). Synthetic fixtures only exercise the failure modes their author imagined; the real file carries shapes nobody imagined - including pre-existing damage the tool must survive. Field grounding: a real-file probe during verification surfaced that the two hottest project files had silently unparseable frontmatter from an earlier manual write - a defect no fixture modeled, caught only because the probe target was real (2026-08).

**Validate the harness against the real tool.** A fixture that stubs, rewrites, or simulates what a tool reports must be checked against what the tool actually prints - configured intent and effective output can differ (e.g. `git remote -v` prints insteadOf-rewritten URLs, not the configured ones). And every scenario asserts its expected message, never just the exit code, so a silently degraded harness cannot pass. Field grounding: a URL-guard regression harness built on insteadOf rewrites silently exercised only the guard's no-match path; per-scenario message assertions caught it, and incidentally proved the degraded path failed closed (2026-09). Same class as the live-distribution check: the measuring instrument measuring itself.

**Probe for silent drops.** Ask of every parser or pipeline the build ships: where does this discard input without a trace? Any input the system drops silently - an unrecognized field, an annotated value, an unresolvable reference or embed, an unmappable record - gets a counter or a lint warning, never silence; the behavior (ignore, degrade, skip) is often right, the invisibility is the defect. Field grounding: two arcs, every review-found defect in this class - a stamper's silent wrong-line write (2026-08), and a status board whose annotated statuses, unknown keys, and missing embeds each vanished from counts until instrumented (2026-08).

**Force the ordering before accepting "flake".** When the lead calls a failure a flake, the reviewer forces the event ordering - what ran, in what order, with what output - before accepting the label, with a probe that drives the other order. In the field six plain re-runs passed while a forced-order probe proved a real race, which then failed deterministically before the fix and passed after - the third field instance of fresh eyes running code. (Holonic Canvas, 2026-10)

## The State Board Write (mandated, reviewer-owned)

A reviewer thread is a viewport, not a store: its context compacts or ends, and "where are we at on this arc" must not leave with it. The store is the driver doc's `### State Board`. At the end of **every** review it delivers - chunk review, verification, disposition - the reviewer updates the board with this fixed block:

```
status: <the arc's state, one line>
verified: <last session whose work was verified on disk - not last reported>
next_gate: <the next gate or unlock and its one-line condition>
turn: human | reviewer | builder | other-project:<name> | person:<name>
blocking: <the one open question, or none>
```

The test: a fresh instance can answer "where are we at" from the board alone - without the exchange folder or the reviewer's chat. The exchange note stays the message to the other instance; the board is where the state lives. A supervision note filed after the supervised session closed still lands its state on the board. The board write does not replace the builder's own close-time writes (session log, ledger); those stay with the session-closer.

## In-thread variant (sub-agent builder)

Codified on second use (two projects, 2026-10). The whole build runs inside ONE session: the lead holds the reviewer seat and dispatches sub-agent builders (and, for prose, a writer seat) from the supervisor thread; the human appears only at apply gates. What changes and what does not:

- **The relay collapses to turns.** Exchange notes between seats become sub-agent briefs and hand-backs; chunk plans live in the lead's brief, not in the Session Exchange folder. The **driver doc and its State Board stay mandatory** - the session's context is still a viewport, and a fresh instance must still answer "where are we at" from the board.
- **The gate does not weaken.** Sub-agent builders remove the human relay without weakening the gate only while the supervisor verifies from disk and runs the shipped scripts itself (Reviewer Steps 2-3). A hand-back is a report; the run is the evidence. Seven chunks across two sessions landed with zero defects on disk this way.
- **Delivery is by fresh-named artifacts with a hash on both sides.** A builder delivers each iteration under a new name (`.v2`, `.v3`) and the lead compares `sha256` container-side and device-side before running anything - same-path re-use is stale in both bridge directions (Cowork Build Environment, Device Bridge). Operator deliveries follow the same rule (Reviewer Steps, "Operator-run scripts travel as vault files").
- **Scratch, never the vault.** The reviewer still runs the server or script on a scratch copy outside the working tree; builders write to the vault only through the gate.
- **Re-count from the files.** Never carry a number from a sub-agent report into canon without re-deriving it from the files: a worker's prose misstated a count that its own export had right. (Holonic Canvas, 2026-10)
- **Resume the plan reviewer for verification.** Resume the sub-agent that reviewed the plan by message (SendMessage to the same agent) for the verification seat: it keeps fresh eyes - it did not author the code - and saves the re-orientation a second fresh instance costs. (Holonic Canvas, 2026-10)
- **One file set per builder, no sharing.** When several builder sub-agents run in parallel, give each a disjoint set of target files and have each back up its targets first; the lead merges nothing. Six parallel builders over fifteen files produced no write conflicts under this rule; the one near-miss was a shared mirror file edited by a sibling session mid-run, caught by an mtime guard. (DataWizard, 2026-10) In a git repo, give each parallel builder its own worktree (`git worktree add ../<tree> -b <branch>`) and its own output folder for patches, logs and checksums, and brief each never to enter a sibling's tree and never to use `git stash` - the stash is shared across worktrees. The lead still verifies each tree on disk and re-runs each suite itself; two builders on two folders of one repo landed clean this way in about 30 minutes of wall time. (Holonic Canvas, 2026-10)
- **A cancelled launch may have run.** A sub-agent launch rejected or cancelled at the approval prompt may still have run and left files behind; before relaunching, check disk state (`git status`, the outputs folder) and tell the next agent what is there. Three field instances; the full behavior is in the Cowork Build Environment guide. (Evolutionary Media Commons, Holonic Canvas, 2026-10)
- **Topology and casting.** The repeatable shape: a synthesis-tier reviewer in-thread, a worker-tier builder seat and (when the deliverable is prose) a worker-tier writer seat as sub-agents, and one living supervision note per session holding the chunk verdicts. Cast the seats with the model-casting skill; the reviewer writes the supervision note while the builder runs, not after.

## When NOT to Use

- One load-bearing build, one plan, review before it starts -> Pattern 3 (second-model plan review), not this skill.
- No reviewer instance available -> the guide's baseline concurrency rules.
- Unrelated concurrent sessions touching shared surfaces -> incidental concurrency (guide baseline), not a supervised build.
