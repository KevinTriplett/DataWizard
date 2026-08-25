---
name: project-reconsolidation
description: "Use when reconciling a project's tracking surfaces against reality
  - run a reconsolidation pass, reconcile open work, audit the trackers, check
  whether the action items / quests / thread roster / dashboard still agree with
  what the session logs actually show. A periodic four-source reconciliation
  audit that diffs every record of open work against recent session-log ground
  truth, classifies divergences (slipped / stalled / orphaned / done-but-open /
  contradiction / duplication / model-gap / partitioned), and writes a
  reconsolidation report. Trigger on: 'run a reconsolidation pass',
  'reconsolidation audit', 'reconcile the open work', 'the trackers have
  drifted', or when a periodic tracking-health review is due. Distinct from
  semantic divergence/framing-drift reconciliation during harvest."
type: skill
version: "1.4"
updated: 2026-08-24
created: 2026-06-29
edit_log:
  - "DW-S246 2026-08-05 - v1.2: 'wired but never exercised' lens added to Before
    You Start (S225 Backlog item; meta-learning review S221-S230)"
  - "DW-S284 2026-08-24 - v1.3: Method step 3
    verify-cross-project-state-before-flagging note (S213); step 1 partial-read
    claim superseded (get_note_outline + read_note_lines) (meta-learning review
    S210-S220)"
  - "DW-S285 2026-08-24 - v1.4: Divergence Taxonomy gains 'partitioned'
    (operator-private views, no shared surface; S235) + description list updated
    (meta-learning review S231-S246)"
---

# Project Reconsolidation Skill

## Overview

A reconsolidation pass is a periodic audit that reconciles every record of "what work is open" against the ground truth of recent session logs, flags where they disagree, and writes a reconsolidation report. It is the detection-and-repair half of work tracking. The structural half (a maintained ledger read at orientation, the fuller quest-system reactivation behind it) prevents drift; this skill catches the drift that happens anyway and verifies the prevention is holding. Both are needed: even a loop-wired system drifts, and the only way to know it has not is to look.

The name is borrowed from memory reconsolidation: a record is most editable right after it is recalled. A reconsolidation pass recalls a window of recent work, holds the several tracking surfaces next to the session-log ground truth, and repairs them while they are all loaded at once.

## When to Use

- The user says "run a reconsolidation pass," "reconcile the open work," "do a reconsolidation audit," or "check the trackers against reality."
- A periodic review of tracking health is due (pairs with the health-audit cadence, roughly every 30 sessions; see the cadence section).
- Several tracking surfaces exist (action items, a thread roster, a quest log, a dashboard) and you suspect they have diverged.
- Right after building or changing a tracking surface, to confirm the convergence is real and not just asserted.

### When NOT to Use

- For a single tracking surface with no second record to diff against. Reconsolidation is about reconciliation across surfaces; with one surface there is nothing to reconcile.
- For semantic framing drift, where collaborators mean different things by the same word during harvest. That is the separate "Divergence-Convergence Tracking" concern. This skill reconciles structural state (what is open, what is done), not meaning. Keep the two distinct to avoid a naming collision.
- As a substitute for the structural fix. If a surface is stale because nothing reads it at orientation, the repair is to wire it into the loop, not to re-run the audit forever. The audit reports that finding; it does not resolve it.

## Before You Start

1. Read this skill fully.
2. Enumerate the project's tracking surfaces: every place that claims to record open or parallel work. In a DataWizard project these are typically the session-log thread roster (or the Active Threads ledger, once it exists), 0.5 Action Items, 0.7 Quest Log, and 0.9 Dashboard plus quest frontmatter. **Also include any multi-phase driver/plan document acting as a de-facto arc** - a finite plan doc (an action plan, a build-plan roadmap) that is the main arc for a stretch of sessions is easy to miss because no orientation ever re-reads it, yet its checkboxes rot and its residuals orphan when it winds down (the S180-S189 pass found exactly this). Other systems will have their own set. The point is to list all of them, because the audit is the diff between them.
3. Pick the window. Reconsolidation works one bounded slice of session history at a time, most recent first. A week (~15-20 entries) is a good unit. Trying to reconcile the whole project at once exhausts context before the synthesis lands.
4. Confirm where the report goes (in DW: `Workshop - [Project]/Reconsolidation Reports/`).
5. **Carry the "wired but never exercised" lens.** When the window contains a canon promotion, a newly wired skill, or a capability flipped to "standard," check whether a first production exercise was scheduled and has actually run. Fully wired + zero production reps is a finding in its own right: the S225 citation-arc review found a canon promoted at S201 with no reps five weeks later, alongside two more capabilities in the same state. Canon promotions should name their first production exercise and when it runs -- flag any that don't. (S225, S232)

## The Method

Reconciliation diffs every record of "what is open" against the ground truth of recent session logs, then flags where they disagree. The session logs are the ground truth because they are written at the moment work happened; the tracking surfaces are summaries that can rot. When a surface and the logs disagree, trust the logs and repair the surface.

1. **Extract per-session signals by grep, not full reads.** For each session in the window, pull the thread roster, the "What's next" section, the status, and the files touched. Use search over the shell and section files rather than reading each entry whole - full reads of twenty entries will blow the context budget before analysis begins. Grep the fields you need; where the MCP server offers partial reads (`get_note_outline` + `read_note_lines` on current mcpvault), read just the roster and "What's next" sections. Older servers return the whole file on every `read_note`, which is why the grep-first rule exists.

2. **Diff the carry-forward chain.** Walk the thread roster session by session and track membership in and out. A roster that is regenerated by hand each session flickers: arcs drop out and reappear, the main arc vanishes during sessions that are actively working it. The flicker is the symptom you are looking for; record exactly which arcs dropped in which sessions, because that is the evidence the roster cannot be trusted as a ledger.

3. **Cross-check every live arc against every surface.** Build the ground-truth inventory of genuinely active arcs from the logs, then look up each arc in each tracking surface. The gaps are the findings: an arc with no durable home anywhere, a quest marked active that no session has touched in months, a surface that lists work nobody is doing. **Before flagging a cross-project item as a crack, verify the other project's state directly** when it is reachable - one directory listing or frontmatter read is cheaper than a chase. A handoff that looked open for weeks turned out to have been executed on the other side within days and simply never reported back; the "done-but-open" collapsed the moment someone looked. (DataWizard, 2026-06)

4. **Classify each divergence** using the taxonomy below.

5. **Audit the model, not only the data.** This is the subtle, high-value move. When you find records that will not fit the schema cleanly, the schema may be what is wrong, not the records. If two quests both want a status the lifecycle does not offer ("worked hard but completion unverified," "overtaken by other work"), that is a vocabulary gap, not two mislabeled items. A pass that only corrects values leaves the gap to reopen next time. Flag schema and vocabulary gaps as their own findings and route them to a design decision. The first DW pass missed this until the repair session surfaced it; check the model from the start.

## Divergence Taxonomy

Classify each disagreement so the report is scannable and the fixes sort themselves into safe versus systemic:

- **slipped** - carried forward inconsistently; membership flickers across sessions.
- **stalled** - real arc, no recent progress, no explicit pause.
- **orphaned** - active work with no durable home in any tracking surface (the dangerous one; nothing will resurface it).
- **done-but-open** - completed work still marked open.
- **contradiction** - two surfaces assert incompatible states for the same item.
- **duplication / divergence** - the same arc tracked twice, or one surface tracking a different set than another.
- **model-gap** - records that do not fit the schema or vocabulary at all (from method step 5). Distinct from the others: the fix is to the schema, not the record.
- **partitioned** - on a multi-operator project, each operator maintains a private view of open work (their own roster, quest list, or "next" note) and no shared surface reconciles them; every view is internally consistent and the project-level picture does not exist. Distinct from *slipped*, which is time-based flicker within one surface: here the flicker is across operators, and repairing any one view does nothing. The fix is a shared ledger that every operator's close writes to (the Active Threads pattern), not a merge of the private views. First seen on a four-operator project's first reconciliation (Weave, 2026-08).

## Detect Now, Repair Later

Separate detection from repair across two sessions. The audit session produces the report and the inventory; a later session executes the fixes. This is deliberate, not just context budgeting. Detection wants the whole window held at once for cross-cutting pattern-spotting; repair wants a clean head and one fix at a time. Folding them together tends to produce rushed fixes made while still mid-analysis.

When you do repair, split the fixes:

- **Safe and unambiguous** (close a done-but-open item, re-status a mislabeled one, register a missing item): execute directly.
- **Systemic** (the tracking model itself is wrong, a surface should be retired or rebuilt, a vocabulary gap needs new statuses): do not patch in passing. Route to a design decision, because these ripple across dashboards and other projects.

## Report Structure

Write the report to the reconsolidation reports folder. Use the prior report as a living template; the headings below mirror the first DW pass.

```
# Reconsolidation - [window] ([dates])

## Method
The four steps, and which window and how many entries.

## Headline
The one-paragraph verdict. What is the real state of tracking health?
Lead with whether anything fell through, and why or why not.

## Finding 1 - The divergent records
A table: each tracking surface, what it tracks, how current it is, verdict.
This is the "they disagree, and here is how" finding.

## Finding 2 - Ground-truth inventory
A table of genuinely active arcs from the logs: real status, durable home,
whether it is registered in the formal system, last touched, next step.
This table is the most reusable output - it seeds the ledger repair.

## Finding 3 - Flagged cracks
Numbered table of specific divergences, each with a recommended action and
its taxonomy class. Mark which fixes are held for a separate session.

## Finding 4 - Carry-forward integrity
The membership-flicker evidence from method step 2, with the root cause.

## Systemic root cause and the fix
Tie the findings to the structural mechanism (what rots and why), and to
the prevention design if one exists. Name whether the fix is drafted.

## Not a crack (the system working)
What looked like a problem but was the protocol doing its job. This keeps
the audit honest and prevents over-correcting.

## Meta-finding (if a repair pass has run)
Anything the repair exposed about the model itself - schema or vocabulary
gaps that value-level fixes would have missed.

## Next passes
The next window backward, and any held fixes routed to a design session.
```

## Cadence

Run reconsolidation periodically, one window at a time, working backward from the present. Pace it with the project's other periodic reviews (in DW, the ~30-session health-audit cadence is a natural pairing). The first few passes work backward through recent history to establish a clean baseline; after that, a rolling pass over each new window keeps drift from accumulating. Each pass names the next window in its "Next passes" section so the chain is self-continuing.

Window size is not fixed. Recent windows are dense with live, half-finished arcs and want the tighter unit (~a week); older windows are mostly settled history with few open divergences, so backward passes can take progressively larger strides as they recede. Let the density of open work set the stride, not the calendar.

The canonical target the audit reconciles toward is the maintained ledger (the structural-prevention surface), once it exists. Before the ledger exists, the audit reconciles toward the most-current surface (in DW that was 0.5 Action Items, the de facto backstop because orientation reads it every session).

## Relationship to Other Patterns

- **The maintained ledger / structural prevention** is the complement: it prevents drift by being read every orientation and maintained at close; reconsolidation detects and repairs the drift that slips past it. A reconsolidation pass is also what makes the structural fix safe to trust, because it verifies the convergence is holding.
- **The health audit** checks the project against protocol (filenames, YAML, links, infrastructure completeness) - data measured against fixed rules. Reconsolidation checks the tracking surfaces against each other and against reality, and (method step 5) the rules themselves against reality. Two complementary audit postures - rules-as-fixed versus rules-as-possibly-wrong - on a similar cadence; run them in the same neighborhood, and watch whether they converge into two halves of one audit.
- **Claude-first, codify-later.** This skill was written only after a manual pass demonstrated the method and set the quality bar. When extending the method, run a manual pass on a new kind of divergence before encoding it here.

## Common Mistakes

- **Reading entries whole instead of grepping.** Twenty full session reads exhaust the window before analysis. Pull fields by search.
- **Repairing while auditing.** Fixes made mid-analysis are rushed and skip the safe-versus-systemic split. Detect now, repair in a later session.
- **Fixing values when the schema is broken.** If records keep refusing to fit, audit the model (method step 5). A value-only pass leaves the gap to reopen.
- **Treating roster flicker as a data problem.** The flicker is structural: a hand-regenerated, vantage-dependent roster cannot be a reliable ledger no matter how carefully each session rebuilds it. Name the structural cause, do not just re-add the dropped arc.
- **Over-correcting.** Include the "not a crack" section. Some apparent gaps are the protocol working as designed (a session correctly skipped under concurrency, an arc deliberately paused). Repairing those undoes good behavior.
- **Confusing this with semantic divergence.** Structural state reconciliation, not meaning reconciliation. See "When NOT to Use."

## Reference Implementation

Maintainer-vault example (not shipped with the Seed -- skip if absent): `Workshop - DataWizard/Reconsolidation Reports/Reconsolidation - S190-S209.md`, the first pass that established the method and the report template. Decisions D105 (the ledger) and D106 (this pattern) record the rationale.
