---
name: supervised-build
description: >-
  Use when a supervised build is declared or resumed - a multi-chunk build
  with a reviewer instance available throughout, coordinating through the
  project's Session Exchange folder (Coordination Patterns, Pattern 4). Load
  in either seat: build session or reviewer session. Triggers on: 'this is a
  supervised build', 'you are the reviewer / supervisor for this build',
  'builder thread' / 'reviewer thread', or resuming a build arc that has
  supervision notes in Session Exchange. Not for a one-shot plan review
  before a single build (Pattern 3), a build with no reviewer available, or
  incidental concurrency between unrelated sessions.
type: skill
version: '1.1'
created: '2026-08-30'
updated: '2026-08-30'
operator: Andrew
edit_log:
  - "DW-S306 2026-08-30 - v1.0: codified from Coordination Patterns Pattern 4
    after four field runs; owns the reviewer's mandated State Board write
    (five fields) and the build-side review gate"
  - "DW-S303 2026-08-30 - v1.1: real-file probe rule added to Reviewer verification (probe a copy of the hottest real file, not only fixtures; field-grounded)"
---

# Supervised Build Skill

## Overview

A supervised build runs a multi-chunk build through a per-chunk review relay: the build session plans a chunk, a reviewer instance reviews it, the build session writes it, the reviewer verifies **on disk**, fixes land, next chunk. The two instances communicate only through numbered notes in the project's `Session Exchange/` folder; the human operator pokes ("your turn") but never shuttles content.

The conceptual home is `Seed/Guides/Multi-Instance Coordination Patterns.md` - Pattern 4 for the loop and its rationale, the Transport section for note anatomy, naming, and the status handshake. This skill is the procedure. It also codifies two things the guide delegates: the **build-side gate** as a hard step, and the reviewer's **mandated State Board write** (the five-field block).

Why the gate is structural: across the field runs that produced this skill, every relayed chunk shipped clean or was caught pre-write; the one chunk written without review put three defects on disk (DataWizard, 2026-08). A relay that depends on human diligence will drop notes - so the precondition check belongs to the actor, not the operator's memory.

## Which seat are you in?

- **Build session** -> read Shared Setup, then Builder Steps.
- **Reviewer session** -> read Shared Setup, then Reviewer Steps and The State Board Write.

Both seats follow the guide's Transport conventions for filenames, frontmatter, and statuses - never improvise these; turn-taking runs on them.

## Shared Setup (once per build)

1. **Confirm the declaration.** A supervised build is declared by the human or by the charter (build plan). If the declaration exists only in chat, record it in the chunk-1 plan note so it is on the record.
2. **Name the parts:** the arc (the short name used in every exchange filename), the charter (the build plan or design doc the build executes), the **driver doc** that holds arc state, and the project's `Session Exchange/` folder.
3. **State Board present.** The driver doc must have a `### State Board` section. If absent, the reviewer creates it at its first write, using the five-field block below.
4. **Turn-taking from convention, not memory:** the highest-numbered note for the arc whose `status` names your seat is the one to act on. Both sides find the latest by listing the folder.

## Builder Steps (per chunk)

1. **Post the chunk plan.** `<Arc> - <SessionID> Chunk N Plan.md` with `status: awaiting-review`, `chunk: N`, `audience:` the reviewer. State what the chunk writes, where, and against which charter sections.
2. **The gate - hard precondition.** Before writing chunk N, list the exchange folder and require a note with `status: reviewed` covering chunk N. If it is absent, **pause and ask**: "Chunk N has no review note yet - relay it, or tell me to proceed unsupervised." Never write on silence. If the human answers "proceed unsupervised," record that answer in the chunk plan note before writing - skipping review is a conscious choice on the record, never a silent omission.
3. **Fold the review.** Pins are decided before writing (with the human where the review says so); fixes must land; minors fold without discussion. If the review raises a design question, answer it in a response note rather than writing around it.
4. **Write the chunk, then report what landed** - exact paths, sections, versions - not what was intended. Expect the reviewer to re-read everything on disk; "reported clean" is not a state.
5. **Fix round.** Land the verification findings, confirm in the exchange note, move to the next chunk.
6. **Read decisions from the folder.** Mid-build human decisions arrive as numbered notes from the reviewer - never act on a decision you only heard about secondhand.

## Reviewer Steps

Per chunk:

1. **Review the plan.** Verdict first, then pins (must be decided before write), fixes (must land), minors (fold silently), and pre-ruled answers to questions the builder will hit mid-chunk. Cite the charter's section or finding numbers so the builder can trace. Ground-truth the substrate: read what the plan's assumptions touch, not just the plan.
2. **Verify on disk after every write.** Read what landed, never what was reported. The verification half matters as much as the review half - reported-clean chunks have held defects visible only on re-read.
3. **Run, don't read, shipped scripts.** Test any script the build ships by running it on scratch fixtures **outside the vault** (a scratch dir in the shell's home, never the working tree). When a run finds an edge bug and the fix comes back as a special case, ask for the class rule, and build fixtures for the bug's *neighbors* - "what else starts a new element / what else looks like this input" - before accepting. Require dry-run output that proves the target (e.g. the line number): verify-after-write only proves the script matched its own intent.
4. **Record human decisions** as their own numbered notes, so the build session reads the decision from the folder, not from a chat it was not in.
5. **Run the tests the builder cannot.** When the build session lacks a capability (no device bridge, no live corpus), run the test from your own environment and post the results - a live-corpus run beats a synthetic fixture.
6. **Deliver, don't just file.** Flip the reviewed doc's `status` to name the review, add the banner, stamp its edit_log (the guide's Transport habits) - the author's next session opens the doc, not the exchange folder. Then end your turn with the path of the note the other side reads next: the human relays by poke, and a missing link costs a round trip.
7. **Update the State Board** (next section) before the turn ends. This is part of delivering a review, not optional bookkeeping.

**Cheap fixes are yours.** Patch small, well-specified defects yourself in files you already have loaded; anything that requires the builder to re-read or rewrite a body goes into the review note as instructions. And check the builder's status before filing: a supervision note filed after the supervised session closed has no reader - land small fixes yourself and put the state on the board.

**End with a whole-build sweep.** After the last chunk, a supervisor-tier pass over every artifact the build touched, ideally from a fresh instance. Unreviewed is where the defects live.

**Probe the real thing, not only fixtures.** When verifying a shipped tool or script, include at least one probe against a copy of the hottest real production file it will touch (copied to scratch, never the original). Synthetic fixtures only exercise the failure modes their author imagined; the real file carries shapes nobody imagined - including pre-existing damage the tool must survive. Field grounding: a real-file probe during verification surfaced that the two hottest project files had silently unparseable frontmatter from an earlier manual write - a defect no fixture modeled, caught only because the probe target was real (2026-08).

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

## When NOT to Use

- One load-bearing build, one plan, review before it starts -> Pattern 3 (second-model plan review), not this skill.
- No reviewer instance available -> the guide's baseline concurrency rules.
- Unrelated concurrent sessions touching shared surfaces -> incidental concurrency (guide baseline), not a supervised build.
