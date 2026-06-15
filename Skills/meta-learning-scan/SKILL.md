---
name: meta-learning-scan
description: >-
  Automated scan of session log Learnings sections that produces a structured
  report for human review. Use when setting up a scheduled meta-learning task,
  when the user says 'scan learnings' or 'generate a learning report', when the
  session-closer nudge fires for meta-learning review, or any time accumulated
  session learnings need to be extracted and organized before planting. This
  skill generates the report; the meta-learning-review skill handles the actual
  planting. Also use when the user wants to set up automated learning extraction
  for any DW project.
type: skill
version: '1.2'
created: '2026-06-01'
updated: '2026-06-15'
edit_log:
  - DW-S185 2026-06-15 - platform/environment routing hint (Step 4 Deferred)
---

# Meta-Learning Scan

## Overview

Automated scan of session log Learnings sections that produces a structured report for human review. This is the report-generation half of the meta-learning workflow. The companion skill, meta-learning-review, handles the human-in-the-loop review-and-plant step that consumes this report.

The scan is designed to run as a Cowork scheduled task without user interaction, but can also be triggered manually. It never modifies vault files other than writing its report -- all planting decisions require human review.

## When to Use

- As a scheduled task running on a weekly or biweekly cadence
- Manually, when the session-closer nudge fires (30+ sessions since last review)
- When the user says "scan learnings," "generate a meta-learning report," or "what have we learned recently"

### When NOT to Use

- For the review-and-plant step (use meta-learning-review)
- For planting research findings from external sources (use design-harvest)
- When fewer than 10 sessions have elapsed since the last review (not enough signal)

## Inputs

The scan needs one input: the **project home folder** path relative to vault root (e.g., `_DataWizard`). Everything else is discovered from project conventions.

## Process

### Step 1: Discover project infrastructure

DW projects use two structural patterns. Try the full convention first; fall back to flat structure if it's not found.

**Full convention** (larger projects like DataWizard):
1. **Infrastructure folder**: `{home}/_Infrastructure - {ProjectName}/`
2. **Project Guidelines**: `0.0 Project Guidelines - {ProjectName}.md` in the infrastructure folder
3. **Session Log shell**: `0.2 Session Log - {ProjectName}.md` in the infrastructure folder
4. **Session Log sections**: `{home}/_Sections - {ProjectName}/Session Log/`
5. **Session log type**: sectioned (shell with section file embeds)

**Flat structure** (smaller projects like LocationScout):
1. **Project Guidelines**: `0.0 Project Guidelines - {ProjectName}.md` directly in `{home}/`
2. **Session Log**: `0.2 Session Log - {ProjectName}.md` directly in `{home}/`
3. **No section folder** -- session entries are inline in the single session log file
4. **Session log type**: inline

To discover which pattern applies: list `{home}/` and check for `_Infrastructure - ` subdirectory. If it exists, use full convention. If not, look for 0.0 and 0.2 directly in `{home}/`.

Read the 0.0 frontmatter to get:
- `last_meta_learning_review` -- the session identifier of the last completed review (e.g., "DW-S117")

If neither 0.0 nor 0.2 can be found in either location, abort with a clear error message naming what's missing. The project may not follow DW conventions or may not have a session log yet.

### Step 2: Determine scan range

Parse the session number from `last_meta_learning_review`. If the field is missing, treat the entire session log as unscanned (use session 0 as the start).

**Sectioned session logs:** List all files in the Session Log sections folder. Extract session numbers from filenames (pattern: `N.0 Session NNN - ...`). Identify all sessions with numbers greater than the last-reviewed session.

**Inline session logs:** Read the session log file and identify session entries by their headers. Session headers vary across projects -- look for patterns like `## LS S01:`, `## Session 5:`, `## 2026-03-22 --`, or `## {Abbrev} S{NN}:`. Extract session identifiers and map them to a comparable sequence. For projects with unnumbered early entries (common in bootstrapping), assign sequence positions by document order and only scan entries that have explicit session numbers or `### Learnings` sections.

**Minimum threshold check:** If fewer than 10 sessions are in the scan range, write a brief status note to the report location ("Scan skipped -- only N sessions since last review at S{last}. Threshold is 10.") and stop. This prevents noisy reports from thin data. For young projects with fewer than 10 total sessions, this is expected -- the scan will fire once the project matures.

### Step 3: Read learnings

**Sectioned session logs:** For each session file in the scan range (chronological order):

1. Read the file
2. Locate the `### Learnings` section (or `### Learnings\n` followed by content until the next `###` header or end of file)
3. If the section contains "No new learnings" or is empty, skip it
4. Extract each discrete learning as a separate item, preserving:
   - The category tag (e.g., `tool-behavior`, `pattern-discovered`, `decision-validated`)
   - The learning text
   - The session number for provenance

**Inline session logs:** Read the full session log file once. For each session entry in the scan range, locate its `**Learnings:**` or `### Learnings` block (formatting varies across projects -- some use bold headers, some use `###`). Learnings in inline logs are often formatted as bullet lists with bold category tags rather than the `- **tag**: text` pattern used in section files. Handle both formats.

**Context efficiency:** Read only what's needed. For sectioned logs, read just the Learnings section rather than the full entry. For inline logs, you'll read the whole file once, which is fine -- inline logs are typically under 5,000 words. If the file is too large for MCP, fall back to filesystem tools with the absolute vault path.

### Step 4: Group and analyze

Group extracted learnings by natural theme. Don't force a fixed taxonomy -- let the categories emerge from the content. Common groupings that tend to appear across projects include tool behavior, workflow patterns, architecture signals, and process observations, but use whatever fits.

For each learning, provide a **suggested disposition**:

- **Already planted** -- The learning describes work that was done in-session (e.g., "planted in D12 cross-reference," "added to Build Plan"). These are the majority in projects with active design-harvest workflows. Evidence: the learning text itself describes the planting, or the session's "Files updated" section lists the target doc.

- **Ready to plant** -- The learning contains actionable guidance not yet captured in an operational doc. Suggest a specific target doc and briefly describe what the change would be.

- **Needs discussion** -- The learning implies a design decision or convention change that shouldn't be made unilaterally. Flag it with a note about what makes it non-obvious.

- **Deferred** -- The learning is valid but the target doc doesn't exist yet, or the context for planting isn't ripe (e.g., a pattern discovered from a first experiment that should be validated by a second).

When a deferred learning is a platform or environment behavior (scheduled-task quirks, MCP reliability, sandbox limits), suggest the environment-guide cluster (`Cowork Scheduled Tasks`, `MCP Reliability and Write Verification`, `Editing the Claude Desktop Config`) as its target rather than labeling it homeless -- these are the most rot-prone learnings and benefit from a standing home. (S185)

**Lightweight verification for "ready to plant" items:** When suggesting a target doc, check whether the doc exists and (if feasible within context budget) whether the learning is already reflected there. This saves time during the review step. Don't spend more than ~20% of context on verification -- the review skill does thorough verification anyway.

**Check broadly, not just the obvious target.** A learning about "triage cadence" might suggest session-closer as the target, but it may already be planted in 0.0 Working Conventions or a protocol doc. When verifying, check both the suggested target AND the project's 0.0 (especially Session Planning and Working Conventions sections), since operational patterns often land in 0.0 during manual reviews.

**Post-review scan timing.** If the scan runs after a manual review in the same session window, items planted during that review will correctly appear as "already planted." This is expected behavior, not an error -- the scan reflects current vault state, which is exactly what the review skill needs.

### Step 5: Write report

Write the report to the project's workshop or research area:

**Full convention projects:** `{home}/Workshop - {ProjectName}/Learning Reports/Meta-Learning Report - {Abbrev} S{start}-S{end}.md`

**Flat structure projects:** `{home}/Learning Reports/Meta-Learning Report - {Abbrev} S{start}-S{end}.md`

Create the `Learning Reports/` folder if it doesn't exist.

**Report frontmatter:**
```yaml
title: "Meta-Learning Report - {Abbrev} S{start}-S{end}"
type: project-doc
created: {today}
updated: {today}
scan_range: "S{start}-S{end}"
sessions_scanned: {count}
learnings_extracted: {count}
last_review_session: "{Abbrev}-S{last_reviewed}"
status: pending-review
```

**Report structure:**

```markdown
# Meta-Learning Report: {Project} S{start}-S{end}

## Scan Summary

- Sessions scanned: N (S{start} through S{end})
- Learnings extracted: N
- Sessions with no learnings: N (list session numbers)
- Already planted: N
- Ready to plant: N
- Needs discussion: N
- Deferred: N

## Findings by Theme

### {Theme Name}

**Already planted:**
- {learning summary} (S{nnn}) -- {where it was planted}

**Ready to plant:**
- {learning summary} (S{nnn}) -- Suggested target: {doc path}. {Brief description of change.}

**Needs discussion:**
- {learning summary} (S{nnn}) -- {Why this needs discussion}

**Deferred:**
- {learning summary} (S{nnn}) -- {Why deferred, what would unblock it}

### {Next Theme}
...

## Cross-Cutting Observations

{Any patterns that span multiple themes -- e.g., "the design-harvest workflow
is self-planting most findings, leaving only process heuristics unplanted"
or "tool behavior learnings are accumulating without a clear home doc."}
```

### Step 6: Signal completion

Do NOT update `last_meta_learning_review` in 0.0 frontmatter -- that's the review skill's job after planting is complete.

If running as a scheduled task, the report's existence with `status: pending-review` signals that a review is ready. The meta-learning-review skill checks for pending reports in its Step 1 (primary path).

## Scheduled Task Setup

To wire this up as a Cowork scheduled task, use the following prompt template:

```
Read the meta-learning-scan skill at {project_home}/Seed/Skills/meta-learning-scan/SKILL.md.
Run it against the project at {project_home}.
Write the report but do not plant anything.
If the scan threshold isn't met (fewer than 10 sessions), note that and stop.
```

**Recommended cadence:** Weekly. The 10-session minimum threshold means the task is a no-op most weeks for projects with low session frequency, so there's no cost to running it often.

**Multi-project setup:** Create one scheduled task per project, each pointing to its own project home folder. Reports accumulate independently.

## Common Mistakes

- **Planting during the scan.** The scan produces a report, nothing more. Planting requires human review via meta-learning-review. This separation exists because disposition classification from session log snapshots has a significant error rate (S97 found 2/10 items already done that the report didn't catch).
- **Updating last_meta_learning_review.** Only the review skill updates this field, after planting is complete. Updating it during the scan would cause the review to think no scan is needed.
- **Reading full session files.** Most session files are 3,000-8,000 words. The Learnings section is typically 200-500 words. Reading only what's needed preserves context for the analysis step.
- **Forcing a fixed taxonomy.** Different projects generate different kinds of learnings. A pipeline-focused project produces tool-behavior and architecture-signal learnings. A team-workflow project produces process and coordination learnings. Let the themes emerge.
- **Scanning too few sessions.** Reports from 3-5 sessions are noise -- not enough signal for cross-cutting patterns. The 10-session threshold exists for a reason.

## See Also

- meta-learning-review (consumes the report this skill produces; handles review-and-plant)
- session-closer (produces the Learnings entries this skill scans; contains the 30-session nudge)
- design-harvest (complementary workflow for external research findings)
