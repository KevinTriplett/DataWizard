---
name: meta-learning-review
description: >-
  Use to review accumulated session learnings and plant them into skills, design
  docs, and protocol. Triggers on: 'review learnings', 'meta-learning review',
  'what have we learned recently', 'plant learnings', or when a meta-learning
  report is ready for review. Also triggered by the session-closer's periodic
  threshold nudge when a review is due.
type: skill
updated: '2026-08-24'
version: '1.5.2'
edit_log:
  - DW-S159 2026-06-08 RP-8 effort note in Step 4.5
  - DW-S185 2026-06-15 - platform/environment learnings homing note (Step 3
    Deferred)
  - DW-S195 2026-06-22 - rewired Step 3 to point at the named Platform and
    Environment Behaviors cluster (GUIDES.md)
  - DW-S196 2026-06-22 - repointed step refs to the renamed periodic threshold
    checks step (session-closer v4.0 renumber)
  - "DW-S198 2026-06-23 - D88 sweep: dropped 5-10 session cadence quotes, defer
    to session-closer threshold step"
  - "DW-S273 2026-08-18 - v1.4.0: Step 5 stamps reviewed-through session not
    current; Step 2 superseded-claim vault sweep; Cadence + Wiring realigned to
    D114 (Review Automation guide)"
  - "DW-S284 2026-08-24 - v1.5.0: review order + holes + several-per-session
    (Backlog Mode); stack detection from frontmatter (Step 1); reverse
    supersession check + aged-report mode (Step 2); Superseded and Not-planted
    dispositions + cross-cutting observations (Step 3); target-dependent
    provenance style incl. Seed depersonalization (Step 4); Review Outcome
    format + out-of-order stamp rule (Step 5). From a four-report review
    session."
  - "DW-S285 2026-08-24 - v1.5.1: Step 4 items 5-6 - link bidirectionally at
    plant time (S245), merge on landing against open intake items (S243)
    (meta-learning review S231-S246)"
  - "DW-S285 2026-08-24 - v1.5.2: Step 3 pattern-families name-it disposition
    (3+ instances -> one standing statement; pairs with meta-learning-scan
    v1.4.0)"
---

# Meta-Learning Review Skill

## Overview

Session log Learnings sections accumulate valuable patterns, tool behaviors, and design insights across sessions. Without a systematic mechanism to harvest them back, learnings decay into archaeological artifacts that only surface if someone happens to read old session logs.

This skill governs the review-and-plant workflow: given a set of learnings (from a pre-generated report or extracted on demand), verify each against current vault state, decide where it belongs, and write it into the place where a future instance will encounter it during task-specific work.

This is the interpretive complement to design-harvest. Design-harvest plants research findings from external sources into design docs. Meta-learning-review plants operational learnings from your own session history into skills, protocol, and infrastructure docs.

## When to Use

- When a meta-learning report has been generated (by scheduled task or manually) and is ready for review
- When the session-closer's periodic threshold nudge fires (a review is due)
- When the user says "review learnings," "what have we learned recently," or "plant learnings"
- On demand, when the user wants to review recent session learnings without a pre-generated report

### When NOT to Use

- For planting research findings from external sources (use design-harvest)
- For writing the session log entry itself (use session-closer)
- For the automated report generation step (that's a scheduled task, not this skill)

## Cadence

The review-and-plant cycle runs on a periodic per-project cadence -- long enough for meaningful patterns to accumulate while keeping each review batch manageable. The cadence number lives in one place, the **Review Automation** guide's cadence table (D114), so this skill does not restate it.

The scheduled review-status check provides the trigger: it reads `last_meta_learning_review:` in 0.0 frontmatter, computes staleness against that table, and when a review is due produces a `pending-review` report that the session-closer surfaces at close.

### Backlog Mode

When first adopting this skill on a project with many unreviewed sessions, expect the initial reviews to cover larger batches. Work through the backlog in manageable chunks (10-15 sessions per review pass) rather than attempting the full history at once. Steady-state reviews of 5-10 sessions are faster and produce cleaner results.

**Order and the stamp.** With several pending reports, review **oldest-first by default** - that is the only order in which the reviewed-through stamp (Step 5) can advance one report at a time. Newest-first is a legitimate choice when freshness matters more (the newest report plants the current version of recurring environment facts), but the stamp then holds at the last contiguous reviewed-through point until the older reports clear. A report whose range sits *behind* the stamp (a gap that was skipped earlier) is reviewed like any other but does not move the stamp.

**Several reports per session** is fine when the residue per report is small and the approval gates stay lean - "one report per session" means one report per approval cycle, not a hard ceiling. Check context headroom before starting each additional report; an aged report's review is mostly verification and is cheap, a fresh 70-learning report is not. (Four reports in one session worked; DataWizard, 2026-08.)

## How to Review

### Step 1: Gather the learnings

**Detect the stack from frontmatter, not narrative.** List the project's learning reports folder and read each report's `status:`; the pending stack is exactly the reports marked `pending-review`. Session-log "N reports pending" counts drift within a few sessions (two consecutive entries said six while one report was already `reviewed`; a later entry said eight when the true count was seven). Also read the report's own header notes: a report generated as a skill test with a forced scan range is still a real report, but its already-planted rate will be unusually high.

**Primary path (report exists):** Read the meta-learning report from the project's learning reports folder (e.g., `Workshop/Learning Reports/`). The report should contain extracted learnings organized by theme, with suggested updates.

**On-demand path (no report):** Read the Learnings sections from the last N session logs (where N is the number of sessions since the last review). Extract each discrete learning into a working list. Group by natural theme -- don't force a taxonomy. Common categories that emerge across projects include tool behavior, workflow patterns, architecture signals, and process observations, but use whatever categories fit the actual content.

### Step 2: Verify each finding against current vault state

This is the critical step that separates useful planting from noise. For each suggested update or extracted learning:

1. **Read the target document** (skill, design doc, protocol section) that the learning would be planted into
2. **Check whether it's already there.** S97 found 2 of 10 suggestions were already implemented and 4 of 6 external validations already planted. Expect a significant already-done rate, especially in active projects.
3. **Check whether the learning is still accurate.** A learning from 8 sessions ago about tool behavior may have been superseded by a tool update or a subsequent session's finding.

4. **When a learning supersedes a prior claim, check the rest of the vault.** For any learning with a "use X over Y", "Y was wrong", or "Y is deprecated" shape, verifying that the plant landed in its target doc is not enough -- search the vault for other docs still asserting the old claim, and either fix them in the same pass or file an action item per doc. A plant can succeed while other docs keep teaching the superseded thing for many sessions afterward.

5. **Check the reverse direction too: is the learning itself stale?** Tool and platform learnings age fastest. A learning that was true when logged may have been overtaken by a tool update - and a Seed skill or guide may still be teaching the stale version because it was planted promptly. When a learning turns out to be superseded, search for docs that assert it and fix them in the same pass (a skill was still stating "this tool has no partial read" two months after the server shipped one).

**Aged-report mode.** For a report older than roughly 30 sessions, the residue (ready / discuss / deferred) still gets full verification, but the items the scan already marked "already planted" only need a spot check - they cite specific docs and dates, and re-verifying every one is archaeology. The already-done rate on the residue climbs steeply with age (observed 40-75% across four aged reports), so budget the review as verification, not planting.

Do not skip verification. The meta-learning report (or on-demand extraction) works from session logs, which are snapshots of understanding at the time. The vault may have evolved since.

### Step 3: Classify each learning

For each verified learning, assign a disposition:

- **Already done.** The learning is already reflected in the target doc. Mark it in the report and move on. No write needed.
- **Ready to plant.** The learning is verified, the target doc exists, and the change is straightforward. Proceed to Step 4.
- **Needs discussion.** The learning implies a design decision or convention change that shouldn't be made unilaterally. Surface it to the user. If resolved, plant it. If not, create an action item.
- **Cross-project (DW Workshop).** The learning targets DW Seed infrastructure -- a Seed skill, protocol doc, PI working rule, or Seed guide -- but the current project is not DW itself. These items belong as feature requests or skill requests in the DW Workshop, not planted directly into the current project's docs. Proceed to Step 4.5.
- **Deferred.** The learning is valid but the target doc doesn't exist yet, or the change is complex enough to warrant its own session. Create an action item with enough context that a future instance can act on it. For complex items, write an accompanying note with the full analysis.
- **Superseded.** Distinct from already-done: the learning was never planted, but the need behind it evaporated or a later decision replaced it (a platform workaround made moot by an official-API route; a connector gap closed by an in-script adapter; a tool limitation removed by a tool update). Record what superseded it so the trail is traceable. Expect this class to grow with report age.
- **Not planted (declined).** The learning is accurate but should not be planted as phrased - too minor for a guide, a one-off, or guidance that would route around a platform restriction. Record the reason in the review outcome; a silent drop looks like an oversight to the next reviewer.

**Pattern families get a name-it disposition.** A report's Pattern Families section (meta-learning-scan v1.4.0+; for older reports, look for the same shape inside the cross-cutting observations) lists practices the project keeps rediscovering under different themes. A family with **three or more instances** is a **name-it** candidate: the plant is one standing statement of the practice - a Working Principles block, a Conventions Registry entry, a new guide, or a skill step - with the instances as its evidence, not N separate one-liners. Fewer than three: leave the family named in the Review Outcome so the next report can count against it. Naming is a design call (it usually implies a decision-log entry), so a name-it candidate is presented in Step 3.5 as its own item, and a family too large for a block (several sources, an open FR) goes to a dedicated session via an action item rather than being squeezed into the review. (Two families - multi-instance coordination, six instances; review-budget economy, four - surfaced this way; DataWizard, 2026-08.)

**Cross-cutting observations get dispositions too.** The report's closing observations are not decoration - they are often the highest-value items in the batch (a "learnings of this class have no home" observation is what produces a new guide or a new triage bucket). Walk each one and assign it a disposition exactly like a learning.

Platform and environment behaviors are the most common members of the deferred class -- and the most likely to rot. Content learnings self-plant in-session because they have an obvious home (the relevant design doc); platform gotchas (scheduled-task behavior, MCP quirks, sandbox limits) have no design doc, so they accumulate here review after review. Before deferring a platform or environment learning, give it a home in the **Platform and Environment Behaviors** guide cluster -- the standing home for these gotchas; see `Seed/GUIDES.md` for the current members -- by extending a cluster guide, or adding a new guide to the cluster if none fits, rather than leaving it homeless. (S185, named S195)

### Step 3.5: Present planting plan for approval

After classification, present the full planting plan to the user before writing anything. Group by target doc so the user can approve, adjust, or defer per-item. For each ready-to-plant item, show: the learning, the target doc, and a brief description of what the change would be. For deferred/discussion items, show the proposed action item text.

The user may reclassify items (e.g., move something from "ready to plant" to "needs discussion"), adjust target docs, or add context that changes how a learning should be framed. Only proceed to Step 4 after approval.

### Step 4: Plant the approved items

For each approved learning:

1. **Re-read the target doc** immediately before writing (Working Rule 3)
2. **Write the learning where future instances will find it during task-specific work.** This is the core principle: plant in the document that gets read when the relevant task is being done, not in a general reference doc.

Common destination types:
- **Skill step:** Add operational guidance to an existing skill's workflow (e.g., "Step 3.11: file size check" added to session-closer)
- **Design doc section:** Add validated pattern, gap, or refinement to an architecture or design document (same mechanics as design-harvest Step 3)
- **PI working rule:** Add a new rule or refine an existing one when the learning affects every session (high bar -- same as design-harvest's guidance on 0.0 updates)
- **Protocol section:** Update protocol docs when conventions or procedures have evolved
- **Action item:** For learnings that require future work rather than a doc update. Include enough context that the item is self-explanatory.

3. **Frame for the reader.** A skill reader wants "what do I do differently." A design doc reader wants "what does this mean for the architecture." Same learning, different framing. Match the target doc's voice and density.
4. **Include provenance, in the style the target requires.** The trail must be traceable, but the format depends on where the plant lands. **Project docs** (design docs, 0.x files, project skills) take session identifiers - a lightweight inline reference like "(S85, S86)". **Seed-bound content** (Seed skills, guides, protocols, templates) ships to other users, so it takes the Conventions Registry's depersonalized form - `(project, YYYY-MM)`, e.g. `(DataWizard, 2026-06)` - and never a vault name, collaborator name, operator initials, or a bare session number. Decision-log numbers (`D103`) are acceptable only where the target already cites them as its house style (the Conventions Registry does). Check this before writing, not after: a Seed plant with session numbers in it is a depersonalization defect that a later sweep has to find.
5. **Link bidirectionally at plant time.** When the plant lands in one doc but the reader who will trip on the fact arrives through another (a guide entry whose failure shows up while following a skill step; a platform fact whose symptom appears in a git workflow), add a one-line pointer from that other doc back to the plant. It is cheap while the context is warm and expensive to retrofit; a plant with no inbound path from where the problem surfaces is only half planted. (DataWizard, 2026-08)
6. **Merge on landing.** Before writing, check the project's intake folders (feature requests, skill requests) for open items the plant would satisfy - a grouped "ready to plant" list often overlaps several filed requests, and one plant can close more than one. Each candidate still gets its own classification against the live target doc (a grouped list is not pre-verified); close the ones the plant covers in the same pass, with a pointer to where the content landed. (DataWizard, 2026-08)

### Step 4.5: File cross-project items in DW Workshop

For each learning classified as **Cross-project (DW Workshop)** in Step 3:

1. **Determine the filing type.** If the learning targets a specific skill's behavior or workflow, file it as a Skill Request. If it targets protocol, PI, working rules, or general infrastructure, file it as a Feature Request.

2. **Check for duplicates.** List `_DataWizard/Workshop - DataWizard/Feature Requests/` (and `Skill Requests/` if it exists). Scan filenames for obvious overlap. If an existing FR/SR covers the same topic, append the new finding to that file rather than creating a duplicate.

3. **Create the FR/SR note** in `_DataWizard/Workshop - DataWizard/Feature Requests/` using this format:

```yaml
---
title: "[Brief descriptive title]"
type: feature-request
status: open
created: YYYY-MM-DD
updated: YYYY-MM-DD
requested_by: "[Operator] / Claude ([Project] meta-learning review)"
target_skill: "[skill name, if applicable]"
tags: [feature-request, relevant-tags]
source_session: "[ProjectAbbrev SNN]"
priority: medium
---
```

Body sections: `## Problem` (what the learning revealed), `## Proposed Changes` (specific changes to the target), `## Target` (exact file path of the Seed skill or doc), `## Source` (session and context where the learning originated).

4. **Mark the item in the report** (or working list) as "filed to DW Workshop" with the filename of the new FR/SR.

**Expected effort.** Cross-project items tend to be small, concrete skill patches rather than large design efforts -- good candidates for opportunistic resolution in light sessions. (S143)

**When running inside DW itself:** Skip this step. Learnings targeting DW infrastructure can be planted directly via Step 4 since you're already in the right project.

**Batch filing.** If multiple learnings target the same skill or doc, consolidate them into a single FR/SR with multiple proposed changes rather than filing one per learning. This matches the pattern discovered in RW S9 where 8 of 23 learnings all targeted DW Seed skills. (S142)

### Step 5: Update the review trail

After planting is complete:

1. **Append a Review Outcome section** to the report (if one exists), in this shape: a `## Review Outcome (SESSION, YYYY-MM-DD)` heading; one line of counts (how many non-already-planted items, how many planted / already done / superseded / not planted); then a **Planted** list (learning -> target doc and section), **Already done** (with where it already lives), **Superseded** (with what superseded it), **Not planted** (with the reason), **Deferred** (with the action item or home), and a closing **Stamp** line stating what the reviewed-through field moved from and to - or that it did not move, and why. This is the disposition record the next reviewer reads first.
2. **Update the report's frontmatter**: `status: reviewed`, `last_review_session:` set to the current session identifier, `updated:` and an `edit_log` entry.
3. **Update the reviewed-through stamp.** The scheduled review-status check reads `last_meta_learning_review:` in the project's 0.0 frontmatter to determine when the next review is due. Set it to the reviewed report's **end-of-scan-range session** (the reviewed-through point), not the current session -- the next scan picks up immediately after the reviewed range, so stamping the current session silently skips everything between the range end and the review session. The pending-report trigger is what nudges the next review, so the accurate stamp does not silence it. With a backlog reviewed oldest-first, each review advances the stamp one report at a time. A report reviewed out of order - newest-first, or a gap behind the current stamp - does **not** move the stamp; note that in the Review Outcome's Stamp line so the next reviewer does not "correct" it. (Order guidance: Cadence > Backlog Mode.)

### Step 6: Summarize

Present the review results to the user:
- How many learnings reviewed
- How many already done / planted / deferred / discussed
- Which files were updated
- Any items that need user input

## Wiring

### Session-closer integration

Detecting that a review is due is the job of scheduled automation, not the session-closer: the scheduled review-status check reads `last_meta_learning_review:` from the project's 0.0 frontmatter, computes staleness against the cadence table in the **Review Automation** guide (the single home for cadence numbers), and when a review is due runs the scan, leaving a `status: pending-review` report in the Learning Reports folder.

The session-closer's only related job is surfacing: at a full close it lists the Learning Reports folder for any `status: pending-review` report and, if found, adds one line to "What's next" naming the file. It holds no cadence numbers and does no gap arithmetic.

### Scheduled report generation

The report generation step is a separate automated task (not this skill). It runs on a schedule (e.g., nightly), checks the session count since the last report, and generates a new report if the threshold is met. The report extracts learnings from session logs, groups them thematically, and suggests target docs for planting.

The skill consumes whatever the scheduled task produces. If no scheduled task exists for a project, the on-demand path (Step 1) works as a fallback.

## Principles

- **Learnings live where the future work happens.** A learning noted in a session log is a historical record. The same learning planted in a skill or design doc is operational guidance. This skill bridges the gap.
- **Verify before planting.** The meta-learning report is a best guess based on session log snapshots. The vault is the source of truth. Always check current state before writing.
- **Small batches, steady cadence.** 5-10 sessions per review keeps the work manageable and learnings fresh. Larger backlogs should be chunked, not attempted in one pass.
- **Fallback to action items.** Not everything can be planted immediately. An action item with context is better than a forced plant into the wrong location or a learning that falls through the cracks.
- **Don't duplicate the session log.** The target doc should reflect the learning's implication for future work, not reproduce the session narrative. Link back to the session log for evidence.

## Common Mistakes

- **Planting without verifying.** The most common error. Reports overcount outstanding work because they don't check current file state. S97 found this on the first run: 2 of 10 items already done.
- **Force-fitting a taxonomy.** Different projects generate different kinds of learnings. Use the categories that naturally emerge rather than imposing a fixed schema.
- **Planting in 0.0 or PI when a skill or design doc is the right target.** Most learnings belong in task-specific docs, not in files every instance reads during orientation. High bar for 0.0/PI additions.
- **Skipping the provenance trail.** Every planted learning should reference where it came from. Without this, future instances can't evaluate whether the learning is still current.
- **Trying to review too many sessions at once.** Context quality degrades. Chunk backlog reviews into 10-15 session batches. Steady-state reviews of 5-10 sessions are the target.

## See Also

- design-harvest skill (plants external research findings -- complementary workflow)
- session-closer skill (produces the Learnings entries this skill consumes; contains the nudge trigger)
- research-tracking skill (tracks what's been evaluated from external sources)
