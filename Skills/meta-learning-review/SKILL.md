---
name: meta-learning-review
description: >-
  Use to review accumulated session learnings and plant them into skills, design
  docs, and protocol. Triggers on: 'review learnings', 'meta-learning review',
  'what have we learned recently', 'plant learnings', or when a meta-learning
  report is ready for review. Also triggered by session-closer nudge when 5-10
  sessions have elapsed since last review.
type: skill
updated: '2026-06-22'
version: '1.3.2'
edit_log:
  - DW-S159 2026-06-08 RP-8 effort note in Step 4.5
  - DW-S185 2026-06-15 - platform/environment learnings homing note (Step 3
    Deferred)
  - DW-S195 2026-06-22 - rewired Step 3 to point at the named Platform and
    Environment Behaviors cluster (GUIDES.md)
  - DW-S196 2026-06-22 - repointed step refs to the renamed periodic threshold
    checks step (session-closer v4.0 renumber)
---

# Meta-Learning Review Skill

## Overview

Session log Learnings sections accumulate valuable patterns, tool behaviors, and design insights across sessions. Without a systematic mechanism to harvest them back, learnings decay into archaeological artifacts that only surface if someone happens to read old session logs.

This skill governs the review-and-plant workflow: given a set of learnings (from a pre-generated report or extracted on demand), verify each against current vault state, decide where it belongs, and write it into the place where a future instance will encounter it during task-specific work.

This is the interpretive complement to design-harvest. Design-harvest plants research findings from external sources into design docs. Meta-learning-review plants operational learnings from your own session history into skills, protocol, and infrastructure docs.

## When to Use

- When a meta-learning report has been generated (by scheduled task or manually) and is ready for review
- When the session-closer nudge fires (5-10 sessions since last review)
- When the user says "review learnings," "what have we learned recently," or "plant learnings"
- On demand, when the user wants to review recent session learnings without a pre-generated report

### When NOT to Use

- For planting research findings from external sources (use design-harvest)
- For writing the session log entry itself (use session-closer)
- For the automated report generation step (that's a scheduled task, not this skill)

## Cadence

The review-and-plant cycle targets every **30 sessions** per project. This gives enough time for meaningful patterns to accumulate while keeping each review batch manageable.

The session-closer periodic threshold checks step (meta-learning nudge) provides the trigger: check `last_meta_learning_review:` in 0.0 frontmatter, compare against current session number, nudge if 30+ sessions have elapsed.

### Backlog Mode

When first adopting this skill on a project with many unreviewed sessions, expect the initial reviews to cover larger batches. Work through the backlog in manageable chunks (10-15 sessions per review pass) rather than attempting the full history at once. Steady-state reviews of 5-10 sessions are faster and produce cleaner results.

## How to Review

### Step 1: Gather the learnings

**Primary path (report exists):** Read the meta-learning report from the project's learning reports folder (e.g., `Workshop/Learning Reports/`). The report should contain extracted learnings organized by theme, with suggested updates.

**On-demand path (no report):** Read the Learnings sections from the last N session logs (where N is the number of sessions since the last review). Extract each discrete learning into a working list. Group by natural theme -- don't force a taxonomy. Common categories that emerge across projects include tool behavior, workflow patterns, architecture signals, and process observations, but use whatever categories fit the actual content.

### Step 2: Verify each finding against current vault state

This is the critical step that separates useful planting from noise. For each suggested update or extracted learning:

1. **Read the target document** (skill, design doc, protocol section) that the learning would be planted into
2. **Check whether it's already there.** S97 found 2 of 10 suggestions were already implemented and 4 of 6 external validations already planted. Expect a significant already-done rate, especially in active projects.
3. **Check whether the learning is still accurate.** A learning from 8 sessions ago about tool behavior may have been superseded by a tool update or a subsequent session's finding.

Do not skip verification. The meta-learning report (or on-demand extraction) works from session logs, which are snapshots of understanding at the time. The vault may have evolved since.

### Step 3: Classify each learning

For each verified learning, assign a disposition:

- **Already done.** The learning is already reflected in the target doc. Mark it in the report and move on. No write needed.
- **Ready to plant.** The learning is verified, the target doc exists, and the change is straightforward. Proceed to Step 4.
- **Needs discussion.** The learning implies a design decision or convention change that shouldn't be made unilaterally. Surface it to the user. If resolved, plant it. If not, create an action item.
- **Cross-project (DW Workshop).** The learning targets DW Seed infrastructure -- a Seed skill, protocol doc, PI working rule, or Seed guide -- but the current project is not DW itself. These items belong as feature requests or skill requests in the DW Workshop, not planted directly into the current project's docs. Proceed to Step 4.5.
- **Deferred.** The learning is valid but the target doc doesn't exist yet, or the change is complex enough to warrant its own session. Create an action item with enough context that a future instance can act on it. For complex items, write an accompanying note with the full analysis.

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
4. **Include provenance.** Reference the session(s) where the learning originated, so the trail is traceable. A lightweight inline reference (e.g., "(S85, S86)") is sufficient.

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

1. **Mark reviewed items** in the report (if one exists) with their disposition: done, planted (with target doc), deferred (with action item reference), or discussed (with outcome).
2. **Update the report's frontmatter** with `last_review_session:` set to the current session identifier.
3. **Update the session-closer tracking field.** The session-closer checks `last_meta_learning_review:` in the project's 0.0 frontmatter to determine when to nudge. Update this field to the current session identifier.

### Step 6: Summarize

Present the review results to the user:
- How many learnings reviewed
- How many already done / planted / deferred / discussed
- Which files were updated
- Any items that need user input

## Wiring

### Session-closer integration

The session-closer's periodic threshold checks step applies here. Add a check that reads `last_meta_learning_review:` from the project's 0.0 frontmatter, compares against the current session number, and adds a nudge to the "What's next" section if 5-10 sessions have elapsed.

The nudge should read: "A meta-learning review is due ([N] sessions since last review). Check for a report in [Learning Reports folder], or run on demand."

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
