---
name: session-closer
description: >-
  Use at the end of every session to write the session log entry. Triggers on:
  'let's wrap up', 'close out the session', 'write the session log', 'we're done
  for today', end of any work session. Also triggers when the user says 'let's
  pick up where we left off' in a new thread and there's no log entry for the
  previous session.
type: skill
updated: '2026-05-26'
version: '1.8'
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

### Step 3: Get approval and write

Present the draft. The user may want to edit, add context, or adjust priorities. Once approved:
1. Re-read the session log shell to get the current section number and embed list
2. Write the new section file to the session log folder. **If a session stub was written during orientation** (a section file with `status: in-progress`), overwrite that file with the full entry — same section number, same filename slot. Rename the file to replace "in progress" with the final title. Do not create a second section file.
3. Patch the shell to update the embed reference (replace the stub filename with the final filename). If no stub exists, add the embed as usual.

> **Parallel instance check:** Before writing, re-list the session log
> section folder and verify the target section number (e.g., 38.0)
> doesn't already exist as a file. If another instance has written a
> session with that number since orientation, increment to the next
> available number. Multiple instances may work in parallel.

> **Flat-file fallback:** If the project's session log hasn't been migrated to shell + sections yet, skip the section file and embed steps. Instead, patch the entry directly into the flat session log file -- insert below the header, above existing entries.

### Step 3.5: Suggest final thread name

Suggest a final thread name for the session. Format: `checkmark ProjectAbbrev SNN - brief description` (e.g., `√ DW S43 - Weave git migration final stage`). The checkmark prefix signals the session is complete. Base the description on what actually happened, not the provisional name from orientation.

### Step 3.6: Knowledge transfer check

**Before moving to infrastructure updates, ask the user:**

"Is there anything else from this session that needs to be
documented in more detail before we close? I want to make sure
we've transferred the details of what we learned into the
appropriate design docs, skills, and tracking files -- not just
the session log."

This is not optional. The session log captures WHAT happened,
but detailed findings belong in the docs where future work
happens.

> **Harvest sessions:** In a harvest session, the entire session is knowledge transfer -- every chunk writes findings into destination documents. The check is still valuable (use it to verify nothing remains only in chat), but recognize that harvest sessions are inherently knowledge-transfer-complete in a way that design or build sessions aren't.

A learning noted in the session log as "discovered X
pattern" is far less useful than that same pattern written into
the relevant skill or design doc with full context.

### Step 3.7: Convention-change check

**Ask yourself (and surface to the user if yes):**

"Did this session establish or change any conventions, folder
patterns, naming rules, or structural practices that differ from
what the protocol docs currently say?"

If yes, do one of:
1. Update the relevant protocol docs now (Protocol Summary, Naming
   Conventions, Vault Bootstrap, or whichever docs describe the
   old convention), OR
2. Add an explicit action item naming the *specific docs* that
   need updating -- not just "update protocol" but "update Protocol
   Summary Section X and Naming Conventions Section Y."

If a Decision Log entry was written this session, verify its
`Protocol updated:` flag is accurate.

This step catches drift at the source. Five weeks of undocumented
convention change (the _ prefix migration, S58-S63) is the pattern
this prevents.

### Step 3.8: Residual value check (harvest sessions)

**For sessions that included harvest work**, before closing, re-scan
each harvest source for remaining extractable value. Look for:
threads you deprioritized during the main harvest pass, tangential
insights worth capturing, content relevant to a different project
than the primary harvest target, novel language or framings not yet
flagged as lexicon candidates, and any tensions or disagreements
you may have flattened. If you find more to extract, do another
harvest pass before proceeding to infrastructure updates.

This is not optional. Instances consistently underestimate residual
value on first pass. The knowledge transfer check (3.6) asks whether
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

### Step 3.9: Metadata verification

For each file modified this session (from the "Files updated" and "Files created" lists):

1. Verify `updated:` reflects today's date (YYYY-MM-DD)
2. Append this session's identifier to `edit_log:` (e.g., `"DW-S70 2026-05-23"`). Deduplicate -- if the session already appears, don't add it again.
3. For shell files whose sections were edited: bump the shell's `updated` field (but no `edit_log` on shells)

Use `update_frontmatter` for efficiency -- it merges without requiring a full re-read.

**Scope:** `edit_log` is required on section files, recommended on infrastructure files (0.x) and standalone docs. Shell files are exempt -- they are assembly surfaces whose edit history is captured by their sections' logs. See Protocol Summary > edit_log Field for the full convention.

This step catches metadata drift at the source rather than requiring periodic remediation passes.

### Step 3.10: Section-shell sync check

For each section file created or renamed this session, verify its parent shell contains a matching `![[filename]]` embed.

1. Identify the parent shell from the section's `parent:` frontmatter field
2. Read the shell and check that each new section filename appears in an `![[...]]` embed
3. If any are missing, flag them and offer to add the embeds to the shell in the appropriate position

This catches the most common drift pattern -- adding sections without updating the shell -- at the point of creation. Skip this step if no section files were created or renamed this session.

### Step 3.11: Periodic project health audit

Check the project's `0.0 Project Guidelines` frontmatter for `last_health_audit:` (format: `"ProjectAbbrev-SNN"`). If the current session is 10+ sessions past the last audit, or if no audit has ever been recorded, prompt the user:

"It's been [N] sessions since the last project health audit (or: no audit on record). Want me to run a DW review? It checks shell-section drift, YAML compliance, filename safety, and protocol conformance. Takes 5-10 minutes."

If the user agrees, load and follow the `project-health-audit` skill. After the audit completes, update `last_health_audit:` in the project's 0.0 frontmatter to the current session identifier.

If declined, note it and move on. The prompt will recur in another 10 sessions.

### Step 3.12: File size check

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

### Step 3.13: Meta-learning review nudge

Check the project's `0.0 Project Guidelines` frontmatter for `last_meta_learning_review:` (format: `"ProjectAbbrev-SNN"`). If the current session is 5-10 sessions past the last review, or if no review has ever been recorded, add a nudge to the "What's next" section:

"A meta-learning review is due ([N] sessions since last review). Check for a report in [Learning Reports folder], or run on demand by loading the meta-learning-review skill."

This does not block session close -- it's a passive reminder in the handoff. If a meta-learning report already exists and hasn't been reviewed, mention that specifically.

### Step 4: Update related infrastructure files

Check whether the session produced work that belongs in other files:
- **Action items**: Check off completed items, add new ones. Optional but recommended.
- **Decision log**: If decisions were made during the session (agreements, vision refinements, commitments, technical choices, scope changes), they belong as separate entries in the Decision Log. Note them in "What happened" and point to the Decision Log entry.
- **Harvest ledger**: If harvesting was done during the session, verify the Harvest Ledger was updated as part of the harvest checklist. If not, update `0.4 Harvest Ledger - [Project].md` now.

Propose specific changes for each file. Get approval before writing.

## Output Format

The entry is a section file in the session log folder (e.g., `0.2 Session Log - Project/13.0 Session 29 - Brief Title.md`).

**Frontmatter:**
```yaml
title: "Session N - Brief Descriptive Title"
type: project-doc
parent: "[[0.2 Session Log - Project]]"
section: N
created: YYYY-MM-DD
updated: YYYY-MM-DD
datawizard_protocol_version: "1.7"
```

**Content structure:**

```markdown
*Part of the [[0.2 Session Log - Project]]*

## Session N: YYYY-MM-DD (Brief Title)

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

### What's next (Session N+1)

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
