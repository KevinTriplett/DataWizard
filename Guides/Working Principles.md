---
title: Working Principles
type: guide
status: active
maturity: working
created: '2026-06-18'
updated: '2026-08-26'
operator: Andrew
tags:
  - protocol
  - DataWizard
edit_log:
  - DW-S189 2026-06-18
  - "DW-S284 2026-08-24 - Additional principles: design for the next phase at
    build time (S135; kin D112, S282)"
  - "DW-S284 2026-08-24 - Additional principles: a pointer must survive the
    condition its rule fires under (S189)"
  - "DW-S284 2026-08-24 - Additional principles: build discipline for
    native-surface tools (S199/S202/S203/S204/S207), re-check tool landscape at
    build time (S209), see it in context (S201), capture leg first (S209 +
    S257/S261) (meta-learning review S198-S209)"
  - "DW-S284 2026-08-24 - Additional principles: design and spec review
    heuristics - uniform principle, invariants x write surfaces, review pass
    between design and build (S218, S220; meta-learning review S210-S220)"
  - "DW-S285 2026-08-24 - Additional principles: second-model plan review
    evidence added to the review-pass bullet (S239/S241/S244); validation gate
    (S231); verify the drift before scheduling its fix (S233); ship the read
    affordance with the write (S241); reference implementations beat specs
    (S235) (meta-learning review S231-S246)"
  - "DW-S285 2026-08-24 - Build discipline: run it once before activating
    (S256); Additional principles: fresh-context review + read the field's other
    writers for shared-field redefinitions, with close-time insight routing
    (S257/S265/S266); bind a provisional default's validation to a must-run step
    (S264) (meta-learning review S256-S266)"
  - "DW-S285 2026-08-24 - Additional principles: optimize for the operator's
    review budget, design for bursts, coverage guardrail (D120; S264 + design
    discussion)"
  - "DW-S289 2026-08-26 - Additional principles: check the tool inventory before designing a tool (Flag Workbench / Quest GUI blind spot; inventory + pointer + tooling-review routing)"
  - "DW-S286 2026-08-26 - Build discipline: make the invariant the write gate, not the post-check (bulk backfill)"
---
# Working Principles

The long-form rationale behind the DataWizard Project Instructions. The PI states each working rule in one or two terse lines; this guide explains the *why* - the failure mode each rule prevents and the judgment behind it.

This is DW's three-layer pattern applied to its own protocol: the PI ([[DataWizard Project Instructions]]) is the compiled rule (what to do), this guide is the rationale (why), and the [[Conventions Registry]] plus dw_lint are the schema and enforcement (the exact form, checked automatically). Read the PI for the contract; read this when a rule seems arbitrary, when you want the reasoning, or when onboarding to how DW thinks. When a rule and this rationale ever disagree, the PI wins - and tell a human about the drift.

## Per-rule rationale

**1. Write to vault.** New content goes directly into the vault as `.md`, not drafted in chat. Markdown is painful to read in a chat window but renders cleanly in Obsidian, and a file in the vault is reviewable, linkable, and persistent in a way a chat message is not. Share the plan first, get approval, then write - the human reviews in Obsidian, not in the transcript.

**2. Edits - show changes at the right level of detail.** Before editing an existing document, describe the change in chat so the human can approve it. For small or surgical edits, show the specific before/after. For large ones, summarize what is being added, removed, or moved and why - never reprint the whole document. The goal is understanding and approval, not a wall of text.

**3. Re-read before writing.** Always re-read a file immediately before writing to it. Another operator or a concurrent agent may have changed it since you last looked, which means a `write_note` overwrite would clobber their work and a `patch_note` `oldString` may no longer match. Cheap insurance against silent lost-work bugs.

**4. Chunk.** Break multi-step work into chunks, present each, and check in at the boundary instead of executing everything in one pass. Chunking keeps the human in the loop where it matters, surfaces wrong turns early, and protects against context exhaustion mid-task. The user can waive this and ask for a full run.

**5. Verify.** After any write, patch, or move, confirm it landed before doing anything else. A silent success followed by a retry is how duplicate content gets created. Verify with filesystem tools where possible rather than trusting a cached read.

**6. Ask.** When anything is unclear - document placement, a content decision, an integration choice, an ambiguous scope - ask rather than assume. A wrong edit is harder to undo than a clarifying question is to ask. (See also "Don't invent structure" below.)

**7. Large files.** A file over ~5000 words, or any file that truncates on read, should be flagged as a candidate for the shell + section pattern before you edit it - don't quietly work around the size by editing blind. Oversized files are where edits go wrong and where context gets wasted; sectioning fixes both.

**8. Safe characters.** Filenames must be valid on Windows, macOS, and Linux, because a name that is fine on a Mac can block a git clone or cause silent file-not-found errors on Windows. In content you expect to patch, em-dashes and curly quotes are the usual culprits behind `patch_note` match failures. Prevention at creation time is far cheaper than a batch rename after commit (the Weave repo once needed 138). Full character map: [[Filename Safety]].

**9. Lifecycle skills.** Lifecycle transitions - project setup, session close - are governed by skills, not by pattern-matching from a previous session's log entry. Pattern-matching is exactly how incomplete artifacts (a session log missing `operator`, say) become the template the next session copies, compounding the drift. If the governing skill is unreachable, stop and recover the Seed rather than improvising a close.

**10. MCP write verification.** At session close, verify writes with filesystem tools (Read/Glob), not `obsidian:read_note`, which can return cached or phantom content. Concurrent multi-instance sessions produced ghost-write incidents where a write appeared to succeed but never landed; filesystem verification is the only reliable check. If context is about to compact, verify before it does.

**11. MCP concurrency.** The session log shell (the 0.2 file) is a shared resource when more than one instance works a project at once. Patch it only at session close, verify immediately, and retry once before flagging a human, so concurrent patches don't silently collide.

**12. Document metadata.** New files are born with their metadata (type, created, updated, operator, edit_log) rather than having it bolted on at session close, because sessions that never close would otherwise leave unattributed, undiscoverable files. On later edits, set `updated:` to the current date. The metadata is what makes the vault queryable by downstream pipelines. Full contract: [[YAML Schema]] Section 4.

**13. Frontmatter safety.** Always use `update_frontmatter` with `merge: true`. `merge: false` replaces the entire frontmatter block and silently deletes any field you didn't restate - this caused real data loss more than once. One default, no exceptions unless you genuinely intend to wipe fields.

**14. Chat readability.** Never paste a draft document (a skill, a design doc, a session log entry) into chat as a fenced code block. Markdown in a code fence doesn't wrap and runs off the side of the window, making review miserable. Write it to the vault for review; describe small edits in prose.

**15. Terminal commands.** When a file or folder operation can't be done through the Obsidian MCP or system tools - and in Cowork that includes every git working-tree op and any delete or overwrite on the vault mount - hand the human a terminal command plus a verification command rather than attempting it and leaving a half-done state. (Claude Code runs these natively via bash; see the PI tool appendices.)

**16. Link don't restate.** When a convention already has a canonical home - the [[Conventions Registry]], the [[YAML Schema]], [[Filename Safety]], the taxonomy - link to it instead of restating it. A rule written in two places will drift, and then no one knows which copy is right. This guide itself follows the rule: it explains *why* and points to those homes for the exact *what*.

## Additional principles

These were standing principles in the older protocol and remain true even though they aren't numbered PI rules. They are kept here so they survive the archiving of the old 3.0 Working Principles.

**Don't invent structure.** If a section or folder doesn't exist yet, flag it to the human rather than creating it unilaterally. New structure is a design decision, not a mechanical step. (The structural half of Rule 6.)

**Ask for human help when it's faster.** Some problems are quicker for a human to fix directly than for an agent to solve by trial and error - don't burn context grinding on them. The classic cases: a `patch_note` that keeps failing on a suspected character-encoding issue (em-dashes, curly quotes, non-breaking spaces, ellipsis or accented characters); a file too large to handle that a human can duplicate in Obsidian with one keystroke; and any move, rename, or deletion that feels risky. Describe what you want and let the human execute.

**Confidential content stays local.** Never embed, quote, or reference content from designated private folders in shared or federated project documents. When in doubt about whether something is shareable, treat it as private and ask.

**Hallucination vigilance.** Statistics, citations, and attributed quotes produced by an AI agent are background context, not citable data. Flag uncertain claims for human verification before they go into anything shared with collaborators or funders. The cost of a fabricated citation in a funder document is far higher than the cost of a verification step.

**Design for the next phase at build time.** When building a pipeline stage, a schema, or a store, spend the small extra effort to make its output usable by the phase you already know is coming - retrofitting later is expensive, doing it now is nearly free. The canonical case: designing enrichment output for graph-readiness (normalized entity slugs, typed relationships) before the pipeline ever ran, rather than re-processing every companion note once a graph was wanted (DataWizard, 2026-05). Later instances of the same move: block IDs stamped on every companion at write time so citations could be verified afterwards (2026-08), and a db-backed intake queue designed together with its vault write-back contract rather than bolting the vault on later (2026-08). The test is cheap: name the next phase, ask what it will need from this one, and add only the fields or hooks that answer it.

**A pointer must survive the condition its rule fires under.** Link-don't-restate has a safety limit: slimming a rule to a pointer is only safe if the pointer's target is still reachable in the exact situation the rule exists for. The canonical catch: the PI's Seed-absent recovery rule once pointed at VERSION.md - which lives inside the Seed and is therefore gone precisely when the rule fires (DataWizard, 2026-06). The fix keeps the recovery command in the PI body (`## Seed recovery`). Before replacing any inline instruction with a pointer, name the rule's failure case and check that the target is readable from inside it; if not, the content stays inline, however much it duplicates.

**Build discipline for tools that touch native surfaces.** A reusable validation playbook, learned across a database-substrate rebuild and two source-adapter builds (DataWizard, 2026-06):

- *Audit against live state before building.* A read-only audit of what actually exists corrected two load-bearing assumptions in a build plan that would have derailed the next two steps. Plans inherit the state of the docs they were written from, not the state of the vault.
- *Validate on a `/tmp` copy before native execution.* A full dry run against a copy caught two real data-fidelity bugs that the safety gate and count-only checks had both missed.
- *Turn a validation finding into a runtime guardrail, not a doc note.* When a run proved lossy, the script was changed to refuse that run unless `--force` is passed. Durable protection beats a comment somebody has to remember.
- *Isolate the native-only step.* Put the part that genuinely needs the user's machine (a keychain read, a live db write) behind one flag or one function, so everything else is testable from the sandbox with no install.
- *Build the enforcement check early.* The first report from a new lint check is the live cleanup worklist - no separate audit pass needed, and defects surface the day the check exists.
- *Run it once before activating.* Visual review passes what the runtime rejects: a regex capture-group index (`.group(2)` where the alternation was non-capturing and the only group was 1) read fine and threw `IndexError` on the first live fire. Trace every `.group(N)` against the pattern's numbered groups, and run the script end to end - on a fixture if not on live data - before the trigger or schedule that activates it is armed. (DataWizard, 2026-08)
- *Make the invariant the write gate, not the post-check.* For any bulk edit across many files, state the per-file invariant ("exactly one line added, nothing else changed"; "count equals N with these exclusions") and have the script compute every change in memory, test the invariant, and refuse to write the whole batch if any file fails - then verify the count from disk. A 71-file frontmatter backfill run this way needed no cleanup; the same job as a parse-and-dump would have rewritten unrelated fields in every file. Procedure: [[MCP Reliability and Write Verification]] (Bulk Frontmatter Backfills). (DataWizard, 2026-08)

**Check the tool inventory before designing a tool - your own project's and the upstream project's.** A tool that exists but sits on no reader's path gets designed twice. The canonical case: a collaborator project designed a per-person flag-triage surface in a full design session without knowing the upstream project had shipped, three weeks earlier, a GUI with the same attention view, the write path, and the concurrency guard the new design was asking for - the built tool was tracked in a deployment-gate queue the collaborator's instances never read (DataWizard, 2026-08). Two fixes, both structural rather than remembered: the upstream project keeps one **inventory of every tool regardless of deployment state** (designed / built / live - the gate queue and the live registry each hold only half the answer) fed at session close, and the collaborator's 0.0 carries a pointer to it with this rule attached. Process companion: tooling design notes route to an upstream reviewer through Session Exchange before build ([[Multi-Instance Coordination Patterns]], second-model plan review), scoped to *tools* so it stays inside the review budget. Same family as "re-check the tool landscape at build time" below - that one is about the outside world's tools, this one is about your own.

**Re-check the tool landscape at build time, not just design time.** Tool drift outruns design-then-build: a transcription app assessed as "closed, no hook" during design shipped local speaker recognition three weeks later, before the build started - and the same note had already flagged a comparable flip once before. The design-session assessment sets direction; the build session re-verifies the specific tools it depends on before committing to them. (DataWizard, 2026-06)

**"See it in context" beats describing.** For a decision that is cosmetic but becomes canon once made (a display glyph, a heading style, a citation rendering), defer it until a rendered example exists and decide by looking at it. One demo resolved in minutes what a description had left open for sessions. (DataWizard, 2026-06)

**The capture leg is load-bearing - design it first.** Front-of-pipeline capture and intake are chronically under-designed relative to the sophisticated processing behind them: the back end gets lavish design while "get the file off the phone" is parked, and the parked step is exactly what breaks and blocks the operator. Seen three times in one project: an audio pipeline whose recording handoff was the missing piece, an intake importer that was built but never once production-run because nothing fed it, and a message-capture pipeline that only became real when its trigger went live. Before designing processing, design and verify the step that gets raw material into the system. (DataWizard, 2026-06 to 2026-08)

**Design and spec review heuristics.** Three cheap, high-yield moves for reviewing a design or a spec before it is built (DataWizard, 2026-07):

- *Apply the system's own principle uniformly.* Wherever a stated principle has an exemption, look there first - non-uniform application is exactly where the bugs hide. Applying a "markdown is canonical" rule to the one component that had been exempted from it surfaced both a runtime mismatch and a correctness bug (a non-idempotent append under a deferred cursor).
- *List the declared invariants, then check every write surface against each one.* A spec review that did this found three correctness bugs, all sitting in write surfaces where the spec's own idempotency invariant had simply not been applied. Invariants stated once and applied selectively are the spec-level form of the point above.
- *Put a review pass between design and build.* A spec that was buildable as written still yielded eight issues to a dedicated review at zero code cost, and the build that followed ran with no reopened design questions. The pass is cheap because the reviewer has the whole spec and no code yet; the same defects found during the build cost a re-design each. The strongest form is a *second-model* review of the *plan* (not the code) before any load-bearing build: three consecutive builds of a write engine, a concurrency guard, and an attention view each had real defects pre-empted this way at near-zero cost (DataWizard, 2026-08).

**Validation gate: the method must reproduce the hand-certified set first.** Before trusting an automated verifier, adjudicator, or extraction method on unseen items, require it to reproduce N of N verdicts on a small hand-certified gold set. A method that cannot pass the items a human has already settled has no claim on the items nobody has checked. The gold set bootstraps itself: the first hand-certified batch becomes the gate for the method that certifies the rest (a citation verifier passed 12/12 before it was let loose on the remaining 62 quotes; DataWizard, 2026-07). Kin to the pre-flight review note - both put a cheap check between "built" and "trusted".

**Verify the drift before scheduling its fix.** A claim that something is fixed and a claim that something is broken deserve the same treatment: one targeted read against the artifact itself before the claim becomes a task. Session logs and handoff notes inherit the state of the docs they were written from; a "pinned" claim was found false across three docs, and a "still broken" claim scheduled a fix for a defect that had already been repaired (DataWizard, 2026-07). The read costs a minute; a fix scheduled from a stale claim costs a session. Companion to the Conventions Registry's "copied state rots".

**Ship the read affordance with the write affordance.** When a build adds a way to write something - a status, a flag, a task field - the same chunk must render it somewhere a reader will see it. A correct write with no render path reads as a broken feature to the next operator and invites duplicate writes or a second "fix" of a working thing (DataWizard, 2026-08). The test at chunk boundary: for each new write, name the view that shows it; if none exists yet, the write is not done.

**Reference implementations beat specs for cross-project migrations.** When porting a convention, tracking model, or file format to another project, hand the receiving instance a working example from a project that already runs it - a real ledger, a real State Board, a real quest file - not only the spec. Specs describe the shape; the reference carries the judgment calls the spec left implicit, and the receiving instance diffs against it instead of interpreting from scratch. A four-operator project took the tracking discipline on first contact from a reference ledger where a spec-only handoff had stalled (DataWizard, 2026-08). Same family as the porting sequence: audit, fix structure, backfill, then build.

**Redefining a shared field or convention needs a fresh-context review - and a read of the field's other writers.** The instance drafting a design is structurally blind to collisions that live outside its doc: a design that redefined the meaning of `updated:` collided with a working rule and a session-closer step, and nothing inside the design doc could have shown it - a reviewer with fresh context caught it on the first read (DataWizard, 2026-08; the fifth independent-review win in ten sessions). Two habits follow. First, any design that changes what a shared field, stamp, or convention *means* gets an independent review before build, not only a self-check. Second, at design time budget one read for the field's *other writers* - every skill step, script, or rule that also sets it - because that is where the collision lives; the drafting doc only shows the new writer. Kin to "change the value, check the rationale": a value change is visible everywhere it is used, a semantics change is visible nowhere but in the writers that assumed the old meaning. The same routing instinct applies to insights captured at session close: an insight only survives if it is written to the surface that fires when it matters (a build-time check into the build plan's phase text, a codification question into the item that triggers codification), not only into the session log.

**Bind a provisional default's validation to a step that must run anyway.** A provisional default - a consent rule, a threshold, a routing choice adopted "until the data says otherwise" - silently hardens if nothing owns the check that would revise it. Give the validation to a step that runs regardless: the go-forward pilot that reads the tail anyway owns the volume check that decides whether the default stands, so the check is structurally unskippable rather than a remembered intention (DataWizard, 2026-08). The test: name the step that will run the validation and the date it next runs; if the answer is "someone should look at it", the default is already permanent.

**Optimize for the operator's review budget - and design for bursts.** Every pipeline in this system ends at a human review gate by design (dry-run-then-apply, pre-flight review, gold-set certification), so the gate is the throughput limit of the whole system: extraction gets cheaper every quarter, the operator's attention does not. Features that look like extraction-quality work - tiered gating, batch-approve defaults, trust graduation, learn-on-confirm aliases - are really bets on that one scarce resource, and the scoping test for any intake or harvest feature is *what does this do to the cost of a review verdict, or the number of verdicts needed?* (DataWizard, 2026-08.) Review budget is also not a steady trickle: it arrives in **bursts** - flow sessions where the operator clears hundreds of items in a few hours, then weeks of nothing, punctuated by single items that must be routed *now*. So a review surface must (1) be safe to ignore for weeks - no expiry pressure, no decay, no nudges that turn a queue into guilt; (2) sustain flow - keyboard-speed, batch-approve with exceptions, one decision per item, no per-item modal questions; and (3) have an **express lane** that routes one new item without touching the backlog. Trust graduation learns from flow-session verdicts, because that is where confirmed decisions concentrate. **Guardrail - reduce the cost of review, never its coverage.** Graduation reduces what needs a verdict, not what gets shown; every auto-approve path keeps a sampled audit that cannot be graduated away. A flag that fires on 100% of one class and 0% of another is measuring the pipeline, not the world (the disappearing-flag lesson), and an optimized gate that stops showing things is exactly where that goes unnoticed. Decision-log entry D120.

## A note on Rule 17

The PI closes with an appreciation rule. It isn't a failure-mode rule like the others - it's a standing acknowledgment that the work here is genuine co-creation and that the contribution of every operator and instance is valued. Worth keeping in view.
