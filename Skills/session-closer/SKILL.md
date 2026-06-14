---
name: session-closer
description: >-
  Use at the end of every session to write the session log entry. Triggers on:
  'let's wrap up', 'close out the session', 'write the session log', 'we're done
  for today', end of any work session. Also triggers when the user says 'let's
  pick up where we left off' in a new thread and there's no log entry for the
  previous session.
type: skill
updated: '2026-06-14'
version: '3.6'
edit_log:
  - DW-S158 2026-06-08
  - DW-S159 2026-06-08
  - DW-S161 2026-06-09
  - DW-S167 2026-06-10
  - DW-S168 2026-06-11
---

# Session Closer Skill

## Overview

Writes the session log entry at the end of every work session. The session log entry is the primary handoff mechanism — the next instance reads it during orientation and picks up where this session left off. There is no separate handoff briefing. The session log IS the handoff.

## When to Use

- End of any session (user says "let's wrap up," "close out," "write the session log," "we're done")
- At a natural break point when the user wants to capture progress before continuing
- If you notice the session has done significant work and no log entry has been written yet

### When NOT to Use

- Mid-session status updates (just talk in chat)
- Updating action items only (do that as part of closing, or separately)

## Session Identifier Format

Session identifiers vary by project type. Check the project's 0.0 Project Guidelines -- if it lists multiple operators, use multi-operator format.

**Solo-operator projects:** Sequential numbering.
- Session ID: `S{N}` (e.g., `S113`)
- File name: `NN.0 Session N - Brief Title.md` (e.g., `99.0 Session 113 - Brief Title.md`)
- Heading: `## Session N: YYYY-MM-DD (Brief Title)`
- Frontmatter title: `"Session N - Brief Title"`
- Frontmatter section: `N` (integer)
- Edit log entry: `ProjectAbbrev-S{N} YYYY-MM-DD` (e.g., `DW-S113 2026-06-10`)
- Thread name: `checkmark ProjectAbbrev SNN - description`

**Multi-operator projects:** Composite ID encoding project, date, operator, and daily sequence.
- Format: `PROJ_YYYY-MM-DD_INITIALS_NN`
- `PROJ` -- project abbreviation (e.g., `WV` for Weave)
- `YYYY-MM-DD` -- session date
- `INITIALS` -- operator's initials from the operator registry in 0.0 Project Guidelines
- `NN` -- daily sequence number, always two digits, starting at `01`, present even for the first session of the day
- File name: `WV_2026-06-10_AA_01 - Brief Title.md` (session ID as prefix, no section number)
- Heading: `## WV_2026-06-10_AA_01: Brief Title`
- Frontmatter title: `"WV_2026-06-10_AA_01 - Brief Title"`
- Frontmatter section: `"WV_2026-06-10_AA_01"` (the full session ID as a string)
- Edit log entry: `WV_2026-06-10_AA_01` (date is embedded, no need to repeat)
- Thread name: `checkmark WV_2026-06-10_AA_01 - description`

To claim a session ID during orientation, list the session log folder for files matching today's date and your initials (e.g., `WV_2026-06-10_AA_*`), and pick the next NN.

Throughout this skill, examples use solo-operator format. For multi-operator projects, substitute the corresponding format from this section.

## How to Close a Session

### Step 1: Review the session

Scan the conversation for:
- What was accomplished (files created, modified, moved, decisions made)
- What was discussed but not yet acted on
- Any problems encountered and how they were resolved
- Patterns discovered, assumptions confirmed or invalidated, tool behaviors learned

### Step 2: Draft the session log entry

Follow the output format below. Write the full entry and present it in chat for user approval. **Present the "What's next" section separately in chat** so the user can review and confirm the plan for next session before it gets written to the vault.

> **Harvest sessions:** For sessions that are primarily harvest work, the session log entry may already be partially written as part of the end-of-harvest checklist (which includes a session log update). In that case, the session closer adds Learnings and What's Next to the existing entry rather than writing a full entry from scratch. Check whether a partial entry already exists before drafting.

### Step 2.5: Frontmatter validation

Before presenting the draft, verify all required frontmatter fields are present. Required fields for session log entries:

- `title` (see Session Identifier Format section for the format -- solo-operator: "Session N - Brief Title"; multi-operator: "PROJ_YYYY-MM-DD_INITIALS_NN - Brief Title")
- `type: project-doc`
- `parent` (wikilink to the session log shell)
- `section` (solo-operator: section number in the shell; multi-operator: the full session ID string)
- `created` (YYYY-MM-DD)
- `updated` (YYYY-MM-DD)
- `operator` (human operator's first name -- see Step 3.14)
- `datawizard_protocol_version` (the `protocol:` value from `_DataWizard/Seed/VERSION.md`, read during orientation)
- `seed_version` (the `seed:` value from the same VERSION.md)

Both version fields are read from VERSION.md during orientation -- never hardcode them from template examples. If any field is missing from the draft, add it before proceeding. Do not present a draft with missing required fields. This is especially important for `operator`, which powers team dashboards and authorship queries but is easy to omit when pattern-matching from older session logs that predate this requirement. `seed_version` makes team Seed currency visible -- when scanning session logs, a stale Seed version is immediately apparent.

### Step 2.6: Active quest threads

Read the previous session's "Active quest threads" section (if it exists). For each thread:
- If work was done on it this session, update its status and remaining work
- If no work was done, carry it forward unchanged
- If it was completed this session, remove it
- If a new multi-session workstream emerged this session, add it

Each thread entry includes: a bold numbered name, session history in parentheses (which sessions touched it), 2-3 sentences on remaining work, and key doc paths. This section lives after "What's next" in the output format.

If the previous session has no quest threads section (pre-S158 entries), scan the last 5-7 session logs to identify active threads and bootstrap the section. This is a one-time cost -- subsequent sessions just carry forward and update.

**Deduplication rule.** Do not include a thread that is already a Priority item or side task in "What's next." Quest threads exist for workstreams that are NOT the immediate focus -- things the next instance might forget about because they're not on the priority list. If every active thread is already covered in "What's next," omit the quest threads section entirely.

The quest threads section prevents long-running workstreams from falling off the radar when they aren't the active focus. "What's next" is the immediate handoff; quest threads are the background map of parallel work that isn't currently prioritized.

### Step 3: Get approval and write

Present the draft. The user may want to edit, add context, or adjust priorities. Once approved:
1. Re-read the session log shell to get the current section number and embed list
2. Write the new section file with the final title to the session log folder. Solo-operator: `99.0 Session 113 - Brief Title.md` (use section number as prefix). Multi-operator: `WV_2026-06-10_AA_01 - Brief Title.md` (session ID as prefix). See Session Identifier Format for full details.
3. **If a session stub exists from orientation** (a section file with `status: in-progress` and "in progress" in the filename): delete it using `delete_note`. The stub and the final entry have different filenames, so writing the final entry does NOT remove the stub -- you must explicitly delete it.
4. Patch the shell embed to reference the final filename. If the shell already embeds the stub filename, replace it with the final filename. If no stub existed, add the embed as usual.

> **Parallel instance check:** Before writing, re-list the session log
> section folder and verify the target identifier doesn't already exist
> as a file. Solo-operator: check the section number (e.g., 38.0).
> Multi-operator: check the session ID (e.g., `WV_2026-06-10_AA_01`).
> If another instance has claimed it since orientation, increment to
> the next available number. Multiple instances may work in parallel.

> **Flat-file fallback:** If the project's session log hasn't been migrated to shell + sections yet, skip the section file and embed steps. Instead, patch the entry directly into the flat session log file -- insert below the header, above existing entries.

### Step 3.5: Knowledge transfer check

**Before moving to infrastructure updates, triage each learning from this session.**

For each finding, decision, or detailed context that emerged during the session, classify it:

- **Session-log-only**: Routine or one-off (e.g., "tool X was slow today," "retried three times before patch landed"). No further planting needed.
- **Design-doc**: Technical finding that future task-specific work needs. Identify the specific target doc and plant it there. Example: an edge case discovered during a build belongs in the relevant design doc, not just the session log.
- **Skill-update**: Process improvement that should change how a skill works. Patch the skill now or add a specific action item naming the skill and what to change.
- **Protocol-update**: Convention change that affects all projects. Handled by Step 3.6 (convention-change check) -- flag it there if not already caught.

**Insight-capture awareness.** If the insight-capture skill was invoked mid-session, its report lists what was planted and where. Use that as a starting point -- verify nothing additional surfaced since the capture ran, rather than doing a full from-scratch triage. If no insight-capture was run, do the full triage as usual.

**Planting verification.** For each learning classified as design-doc or skill-update, verify the content was actually written to the target before closing. Not just "did you think about it" but "confirm the patch landed." If planting hasn't happened yet, do it now or add a specific action item with the target file path.

**Backlinks.** When a learning is planted in a design doc or skill, note where it went in the session log's Learnings section (e.g., "See Editorial Technical Notes > Frame Rate section for full detail"). This makes the session log a discovery record that points to where the substance lives.

This is not optional. Do not ask the user -- run the triage yourself. If everything has been transferred, move on silently.

> **Harvest sessions:** In a harvest session, the entire session is knowledge transfer -- every chunk writes findings into destination documents. The triage is still valuable (verify nothing remains only in chat), but recognize that harvest sessions are inherently knowledge-transfer-complete in a way that design or build sessions aren't.

### Step 3.6: Convention-change check

**Ask yourself (and surface to the user if yes):**

"Did this session establish or change any conventions, folder
patterns, naming rules, or structural practices that differ from
what the protocol docs currently say?"

If yes, do one of:
1. Update the relevant protocol docs now (the Conventions Registry,
   YAML Schema, or whichever docs describe the old convention), OR
2. Add an explicit action item naming the *specific docs* that
   need updating -- not just "update protocol" but "update the
   Conventions Registry's X entry and the YAML Schema's Y field."

If a Decision Log entry was written this session, verify its
`Protocol updated:` flag is accurate.

This step catches drift at the source. Five weeks of undocumented
convention change (the _ prefix migration, S58-S63) is the pattern
this prevents.

### Step 3.7: Residual value check (harvest sessions)

**For sessions that included harvest work**, before closing, re-scan
each harvest source for remaining extractable value. Look for:
threads you deprioritized during the main harvest pass, tangential
insights worth capturing, content relevant to a different project
than the primary harvest target, novel language or framings not yet
flagged as lexicon candidates, and any tensions or disagreements
you may have flattened. If you find more to extract, do another
harvest pass before proceeding to infrastructure updates.

This is not optional. Instances consistently underestimate residual
value on first pass. The knowledge transfer check (3.5) asks whether
findings got planted in the right docs -- this step asks whether
you got everything out of the source material in the first place.

> **Non-harvest sessions:** Skip this step entirely.

Scan your own context for:
- Findings that are only in chat, not yet in any vault file
- Patterns described in Learnings that should also live in a
  skill or design doc
- Tool evaluations discussed but not added to the tracking index
- Design implications mentioned but not planted in design docs
- Decisions made but not logged in the decision log

If everything has been planted, say so and move on. If not,
propose what still needs writing and where it goes.

### Step 3.8: Metadata verification

For each file modified this session (from the "Files updated" and "Files created" lists):

1. Verify birth metadata is present (type, created, updated, operator, edit_log). Birth metadata should already exist from creation time (Working Rule 12); if any field is missing, add it now as a fallback.
2. Verify `updated:` reflects today's date (YYYY-MM-DD)
3. Append this session's identifier to `edit_log:` (solo-operator: `"DW-S70 2026-05-23"`; multi-operator: `"WV_2026-06-10_AA_01"` -- date is embedded in the ID). Deduplicate -- if the session already appears, don't add it again.
4. For shell files whose sections were edited: bump the shell's `updated` field (but no `edit_log` on shells)

Use `update_frontmatter` for efficiency -- it merges without requiring a full re-read.

**Scope:** `edit_log` is required on section files, recommended on infrastructure files (0.x) and standalone docs. Shell files are exempt -- they are assembly surfaces whose edit history is captured by their sections' logs. See the [[YAML Schema]] edit_log section for the full convention.

This step catches metadata drift at the source rather than requiring periodic remediation passes.

### Step 3.9: Section-shell sync check

For each section file created or renamed this session, verify its parent shell contains a matching `![[filename]]` embed.

1. Identify the parent shell from the section's `parent:` frontmatter field
2. Read the shell and check that each new section filename appears in an `![[...]]` embed
3. If any are missing, flag them and offer to add the embeds to the shell in the appropriate position

This catches the most common drift pattern -- adding sections without updating the shell -- at the point of creation. Skip this step if no section files were created or renamed this session.

### Step 3.10: Periodic project health audit

Check the project's `0.0 Project Guidelines` frontmatter for `last_health_audit:` (format: `"ProjectAbbrev-SNN"` for solo-operator, or `"PROJ_YYYY-MM-DD_INITIALS_NN"` for multi-operator). To determine the gap: solo-operator projects can subtract session numbers; multi-operator projects must list the session log folder and count files dated after the reference session's date. If the current session is 30+ sessions past the last audit, or if no audit has ever been recorded, prompt the user:

"It's been [N] sessions since the last project health audit (or: no audit on record). Want me to run a DW review? It checks shell-section drift, YAML compliance, filename safety, and protocol conformance. Takes 5-10 minutes."

If the user agrees, load and follow the `project-health-audit` skill. After the audit completes, update `last_health_audit:` in the project's 0.0 frontmatter to the current session identifier.

If declined, note it and move on. The prompt will recur in another 10 sessions.

**Silence rule:** Do not mention health audits in "What's next," during orientation, or anywhere outside this step. No "approaching threshold" or "getting close" language. The nudge exists only here, only when the threshold is met. Instances that pre-announce upcoming audits create noise across every session and every project.

### Step 3.11: File size check

Scan the "Files updated" and "Files created" lists for files
that may be approaching MCP read limits. For any file you
touched this session that you noticed was large or slow to
read, check its size. Flag files approaching 50KB as
candidates for shell + sections migration.

If a file is already over 50KB and hasn't been sectioned,
add an action item: "Section [filename] -- currently [size],
exceeds MCP read limit."

This catches growth before overflow. Skip if no large files
were encountered this session.

### Step 3.12: Meta-learning review nudge

Two independent triggers -- either one fires the nudge:

**Trigger 1: Session count.** Check the project's `0.0 Project Guidelines` frontmatter for `last_meta_learning_review:` (format: `"ProjectAbbrev-SNN"` for solo-operator, or `"PROJ_YYYY-MM-DD_INITIALS_NN"` for multi-operator). To determine the gap: solo-operator projects can subtract session numbers; multi-operator projects must list the session log folder and count files dated after the reference session's date. If the current session is 30+ sessions past the last review, or if no review has ever been recorded, add a nudge to the "What's next" section:

"A meta-learning review is due ([N] sessions since last review). Check for a report in [Learning Reports folder], or run on demand by loading the meta-learning-review skill."

**Trigger 2: Pending report.** Check whether a report with `status: pending-review` exists in the project's Learning Reports folder. For full-convention projects: `{home}/Workshop - {ProjectName}/Learning Reports/`. For flat-structure projects: `{home}/Learning Reports/`. List the folder; if any file matching `Meta-Learning Report - *.md` exists, read its frontmatter and check for `status: pending-review`. If found, nudge regardless of session count:

"A meta-learning scan report is waiting for review: [filename]. Load the meta-learning-review skill to review and plant the findings."

This trigger exists because the nightly vault-wide scan (meta-learning-scan skill) may produce reports between sessions. Without this check, reports sit unnoticed until the 30-session threshold fires.

This does not block session close -- it's a passive reminder in the handoff.

### Step 3.13: Content Interests staleness check

Check the project's `0.0 Project Guidelines` frontmatter for `last_content_interests_review:` (format: `YYYY-MM-DD`). If 30+ days have passed since the last review, or if 10+ sessions have occurred since then, add a nudge to the "What's next" section:

"Content Interests may need refreshing ([N] days since last review). Load the content-interests-review skill to check whether the project's routing signals still match its current direction."

Also nudge if no `last_content_interests_review:` field exists and the project has a Content Interests section -- this means the field was never backfilled.

This is a passive reminder in the handoff, not a blocker. The project instance that picks up the next session has the context to judge whether a review is actually needed -- time alone doesn't determine drift. If the project's direction hasn't changed, the instance can skip it and note why.

### Step 3.14: Operator field and team flag prompt

**Operator field (always).** Verify `operator: FirstName` is present in the frontmatter of the following files. Birth metadata (Working Rule 12) should have set this at creation time; if missing, add it now as a fallback:
- The session log section file (always)
- Any content documents created or substantially updated this session

Use the human operator's first name (e.g. `Andrew`, `Kaliya`, `Jay`). This field powers the "Recent Team Activity" section of the team dashboard and makes authorship queryable via Bases/Dataview.

**Team flag prompt (multi-operator projects only).** If the project has more than one operator, present the user with a list of files created or substantially updated this session. Pre-select:
- Any file created this session with `priority: high`
- New synthesis documents, analyses, or research notes
- Any file that substantially updates a shared canonical doc (design docs, strategy docs, etc.)

**In Cowork (AskUserQuestion available):** Use `AskUserQuestion` with `multiSelect: true` to present candidates as selectable options. Each option's `label` is the file's display name; `description` summarizes what changed this session. Pre-selected items should appear first in the options list with "(Recommended)" appended to the label. This lets the operator click rather than type. If the operator has indicated a preference against AskUserQuestion, fall back to the text-list approach below.

**In Chat or when AskUserQuestion is unavailable:** Ask in prose: "Which of these should be flagged for team attention -- meaning other operators should read it before their next session?" List the candidates with numbered options for easy selection.

For each file the user selects:
1. Add `flag: YYYY-MM-DD` (today's date) to its frontmatter
2. Add `flag_by: FirstName` (the operator's first name)
3. Ask for a one-line `flag_note`, or suggest a default based on the file title/context
4. Add `flag_for:` as a YAML list of all other team operators (e.g. if Andrew flags it: `flag_for: [Kaliya, Jay, Kevin]`). The user can adjust the list if it's only relevant to specific people.

**On ungraceful session close** (context exhausted before the user can confirm): auto-flag any `priority: high` files created this session using `flag_by: "FirstName (auto)"` and `flag_for:` listing all other team operators. The human can review and remove auto-flags in a subsequent session.

**Team read dismiss (multi-operator projects only).** During orientation or at any point in the session when the operator reads a file that has a `flag_for` list containing their name, remove their name from the `flag_for` list using `update_frontmatter`. When the list is empty, all operators have seen the item -- anyone can then clear the `flag`, `flag_by`, `flag_note`, and `flag_for` fields to remove it from the dashboard entirely.

**Solo operators:** Apply the `operator` field as usual. Skip the team flag prompt and team read tracking -- there are no other operators to notify. The field is still useful if the project gains team members later.

### Step 4: Update related infrastructure files

Check whether the session produced work that belongs in other files:
- **Action items**: Check off completed items, add new ones. Optional but recommended. See the triage guidance below when the backlog needs cleanup.
- **Decision log**: If decisions were made during the session (agreements, vision refinements, commitments, technical choices, scope changes), they belong as separate entries in the Decision Log. Note them in "What happened" and point to the Decision Log entry.
- **Harvest ledger**: If harvesting was done during the session, verify the Harvest Ledger was updated as part of the harvest checklist. If not, update `0.4 Harvest Ledger - [Project].md` now.

Propose specific changes for each file. Get approval before writing.

#### Action items triage guidance

Session-close action item updates are incremental -- check off what's done, add what's new. But every ~30 sessions (matching the health audit cadence), the action items file benefits from a full triage pass. When doing a triage:

1. **Work in reverse-chronological order.** Start from the most recent items and work backwards. The newest items represent the current state of play, which makes it easy to spot older items that have been overtaken by events.

2. **Group by conversation partner** when the project involves recurring calls with the same people. Action items from calls with the same person overlap heavily -- grouping by partner makes duplicates immediately visible and produces a cleaner, more actionable list.

3. **Expect ~1/3 staleness.** Roughly a third of accumulated action items will be stale -- not explicitly resolved, just no longer relevant. This is normal. Flag them for removal rather than carrying them forward indefinitely.

Full triage is a periodic activity, not a session-close requirement. The session-closer's job is incremental maintenance; the triage patterns above apply when the backlog has grown unwieldy. (RW S9, S142)

### Step 5: Suggest final thread name

Suggest a final thread name for the session. Solo-operator format: `checkmark ProjectAbbrev SNN - brief description` (e.g., `√ DW S43 - Weave git migration final stage`). Multi-operator format: `checkmark PROJ_YYYY-MM-DD_INITIALS_NN - description` (e.g., `√ WV_2026-06-10_AA_01 - session ID convention update`). The checkmark prefix signals the session is complete. Base the description on what actually happened, not the provisional name from orientation.

This step is intentionally last. The thread name is the signal that all session-close work is complete -- the user copies it, and the session is done.

## Output Format

The entry is a section file in the session log folder. Solo-operator example: `0.2 Session Log - Project/13.0 Session 29 - Brief Title.md`. Multi-operator example: `Session Log - Weave Project/WV_2026-06-10_AA_01 - Brief Title.md`.

**Frontmatter (solo-operator):**
```yaml
title: "Session N - Brief Descriptive Title"
type: project-doc
parent: "[[0.2 Session Log - Project]]"
section: N
created: YYYY-MM-DD
updated: YYYY-MM-DD
operator: FirstName
datawizard_protocol_version: "[protocol: from VERSION.md]"
seed_version: "[seed: from VERSION.md]"
```

**Frontmatter (multi-operator):**
```yaml
title: "WV_2026-06-10_AA_01 - Brief Descriptive Title"
type: project-doc
parent: "[[0.2 Session Log]]"
section: "WV_2026-06-10_AA_01"
created: YYYY-MM-DD
updated: YYYY-MM-DD
operator: FirstName
datawizard_protocol_version: "[protocol: from VERSION.md]"
seed_version: "[seed: from VERSION.md]"
```

**Content structure:**

```markdown
*Part of the [[0.2 Session Log - Project]]*

## Session N: YYYY-MM-DD (Brief Title)          ← solo-operator
## WV_2026-06-10_AA_01: Brief Title              ← multi-operator

### What happened

[Narrative of what was accomplished. Dense but readable. Group related work
under bold topic headers. Include file paths for anything created or modified.]

**Files created:** [list with full paths]
**Files updated:** [list with full paths]
**Files archived/moved:** [list if applicable]
**Status:** complete | in progress — [what's pending]

### Learnings

Each learning is a discrete, standalone observation -- a fact that's useful on its
own without needing the rest of the session context. (This is the "observational
memory" pattern: discrete facts are 4-10x more token-efficient and more searchable
than conversation summaries.)

- **category**: Description of the learning with enough context that a future
  instance searching for this topic would find it useful. Reference the source
  (decision, tool, research, conversation) that produced the insight.

Categories: pattern-confirmed, pattern-discovered, tool-behavior,
decision-validated, assumption-invalidated, edge-case,
routing-heuristic, harvest-pattern

If no learnings this session, write: "No new learnings this session."

### What's next

[Write this as if briefing a new team member who has read the 0.0 but nothing
else. This section is the handoff — it must be specific enough that the next
instance can start working immediately.]

**"What's next" is a direction, not a contract.** The items listed here are the
best guess at what's most valuable to do next, based on where this session ended.
They are NOT commitments. The next session may go in a completely different
direction if the user wants to follow a thread, go deep on something unexpected,
or if the work naturally evolves. Sessions that spend their entire context on one
deep task (a handbook deep-read, a design discussion, a complex refactor) are
just as productive as sessions that tick off five items. Never rush through work
or cut corners to get through the list. There's always a next session.

Include:
- **Specific file paths** to read first (not just topic names)
- **Why this work matters** — one sentence connecting to the larger arc
- **What depends on what** — sequence and causal chain
- **Prioritization** — what's the main focus vs side tasks
- **Key documents** — list the 3-5 most important files for the next instance
  to read, with a phrase explaining what each contains

Adapt detail to the work type:
- Research/harvest: what sources, what to extract, where output goes
- Build/migration: what spec to follow, what success looks like
- Design: what prior decisions constrain the space, what the deliverable is
- Debugging: what's broken, what was tried, where the evidence is

### Active quest threads

Threads of ongoing work across recent sessions. Included so future
instances don't lose sight of parallel workstreams. See Step 2.6 for
how to maintain this section.

**1. Thread name** (session range, e.g. S152-S157 or WV_2026-06-01_AA_01 through WV_2026-06-10_JC_02)
Remaining work summary. Key doc: `path/to/spec.md`.

**2. Thread name** (session range)
Remaining work summary. Key doc: `path/to/spec.md`.

[Repeat for each active thread. Remove when completed.]
```

## Structured Format for Complex Sessions

For sessions with many moving parts (multi-file refactors, long research batches, architecture changes across several docs), the narrative "What happened" can optionally be replaced with a structured format based on the AI Agent Handbook's compaction template. This makes the session log entry function as a structured state snapshot that's easier for the next instance to parse.

Use the structured format when: the session touched 5+ files, made multiple independent decisions, or spanned multiple work phases. Use the narrative format for simpler sessions.

```markdown
### What happened (structured)

**Active goal:** [One sentence: what were we trying to achieve this session?]

**Key decisions:**
- [What was decided] -- [why / what alternatives were rejected]
- [What was decided] -- [why]

**Artifacts modified:**
- `path/to/file.md` -- [what changed and why, 1-2 sentences]
- `path/to/other.md` -- [what changed and why]

**Current state:** [What's done, what's in progress, what's blocked]

**Errors and resolutions:** [Any problems hit and how they were solved, or "None"]

**Critical context:** [Anything else a fresh instance needs to know that doesn't fit above]
```

The "Files created/updated" lists and "Status" line still apply on top of either format. The Learnings and What's Next sections are unchanged.

## Writing the Title

The session title should capture the main theme in 3-8 words. Use plain hyphens, not em-dashes. Good titles: "Session Closer Skill, Reddit Triage". Bad titles: "Various tasks and cleanup" (too vague).

## Common Mistakes

- **Treating "What's next" as a checklist.** It's a direction, not a mandate. The next instance should feel free to spend the entire session on one deep task if that's where the value is. Rushing through items to "complete the list" produces worse work than going deep on one thing. The user values depth over breadth.
- **Vague "What's next."** "Continue the skills work" is useless. "Build the session-closer skill — read Section 6 Proposal #1 and Section 7 Proposal #11 in the Agent Architecture doc for the spec" is useful.
- **Missing file paths in "What's next."** Every "What's next" should have at least 2-3 exact paths. The incoming instance shouldn't need to search for anything.
- **No prioritization.** Without it, the next instance treats everything as equal priority. Use "Priority 1 / Priority 2" or "The main focus is X. Also when you get a chance: Y."
- **Learnings too vague.** "Learned about MCP tools" isn't searchable. "tool_search needs multi-word descriptive queries including the tool name; single words return nothing" is.
- **Forgetting the "why."** A fresh instance doesn't know why a particular task matters. One sentence of framing prevents misunderstanding.
- **Over-narrating "What happened."** This isn't a diary. Dense, scannable, focused on what a future reader needs to know.
- **Duplicating "What's next" in quest threads.** If a workstream is already a Priority item in "What's next," don't repeat it in quest threads. The quest threads section exists for background work that's NOT the immediate focus -- things the next instance might forget about because they're not on the priority list. When all active threads are already priorities, omit the section entirely.
- **Following a stale "What's next" without re-evaluating.** If the previous session's "What's next" was written because that session was low on context (not because the items are the highest-value work), a fresh session should re-evaluate priorities rather than following the stale plan. The "What's next" reflects the best guess at the time -- a fresh context window with full project awareness may see a better path (S114).

## Relationship to Other Files

- **Session log shell** (`0.2 Session Log - Project.md`): Add an embed reference (`![[section filename]]`) to the shell after creating the section file.
- **Action items**: Check off completed items, add new ones. Optional but recommended.
- **Decision log**: Decisions belong as separate numbered entries. The session log references them but doesn't replace them.
- **Harvest ledger**: If harvesting was done, update `0.4 Harvest Ledger - [Project].md` with source, destinations, and agent. Source YAML should already be updated as part of the harvest checklist.

## Synthesis Check

Before closing, verify two things:

1. **Cross-cutting synthesis.** If this session involved multi-item analysis (research batches, triage passes, cross-doc comparisons), have the cross-cutting findings been captured? Synthesis degrades across context boundaries but mechanical execution doesn't. If the thinking hasn't been written down yet (as an integration memo, design doc update, or explicit "Learnings" entry), capture it now -- before the session log, not after.

2. **Knowledge transfer completeness.** The session log is a handoff document, not a knowledge store. Detailed findings, patterns, tool evaluations, and architectural implications belong in design docs, skills, and tracking files where future instances will encounter them during task-specific work. If a finding only exists in the session log, it will likely be missed -- future instances read the last 2-3 session entries for orientation, then work from design docs and skills. Always ask: "would a future instance working on [relevant topic] find this in the doc they'd naturally read?" If not, plant it there.

See [[Context and Session Management]] for the rationale.
