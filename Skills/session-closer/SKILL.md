---
name: session-closer
description: >-
  Use at the end of every session to write the session log entry. Triggers on:
  'let's wrap up', 'close out the session', 'write the session log', 'we're done
  for today', end of any work session. Also triggers when the user says 'let's
  pick up where we left off' in a new thread and there's no log entry for the
  previous session.
type: skill
updated: '2026-03-28'
version: '1.1'
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

### Step 3: Get approval and write

Present the draft. The user may want to edit, add context, or adjust priorities. Once approved:
1. Re-read the session log shell to get the current section number and embed list
2. Write the new section file to the session log folder
3. Patch the shell to add the embed reference for the new section

### Step 4: Update related infrastructure files

Check whether the session produced work that belongs in other files:
- **Action items**: Check off completed items, add new ones. Optional but recommended.
- **Decision log**: If decisions were made during the session (agreements, vision refinements, commitments, technical choices, scope changes), they belong as separate entries in the Decision Log. Note them in "What happened" and point to the Decision Log entry.
- **Harvest log**: If harvesting was done during the session, update the Harvest Log with what was harvested, from which sources, and into which project notes.

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
decision-validated, assumption-invalidated, edge-case

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
- **Harvest log**: Harvesting work gets its own log entry with source, output, and status.

## Synthesis Check

Before closing, verify: if this session involved multi-item analysis (research batches, triage passes, cross-doc comparisons), have the cross-cutting findings been captured? Synthesis degrades across context boundaries but mechanical execution doesn't. If the thinking hasn't been written down yet (as an integration memo, design doc update, or explicit "Learnings" entry), capture it now — before the session log, not after. See [[Context and Session Management]] for the rationale.
