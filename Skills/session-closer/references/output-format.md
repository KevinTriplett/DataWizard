---
title: 'Output Format and Templates'
type: skill-reference
parent: "[[_DataWizard/Seed/Skills/session-closer/SKILL|session-closer]]"
created: '2026-10-18'
updated: '2026-10-18'
operator: Andrew
origin: 'DW-S422 2026-10-18 - moved verbatim from session-closer SKILL.md v4.10.3'
edit_log:
  - 'DW-S422 2026-10-18 - created: moved verbatim from session-closer SKILL.md v4.10.3'
  - 'DW-S422 2026-10-18 - v4.11.0: What-next template gains the landing check line and the Waiting-on pointer line'
---

*Part of the [[_DataWizard/Seed/Skills/session-closer/SKILL|session-closer]] skill*

# Output Format and Templates

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
seed_version: "[seed: from VERSION.md]"
```

**Content structure:**

```markdown
*Part of the [[0.2 Session Log - Project]]*

## Session N: YYYY-MM-DD (Brief Title)          ← solo-operator
## WV_2026-06-10_AA_01: Brief Title              ← multi-operator

*Orientation sweep trace (carried verbatim from the claim stub, PI Orientation Step 6): `flag sweep [PI v4.6]: N surfaced, M handled, K deferred | stubs: P stale, Q reconciled | intake: R new`. Solo projects carry the `n/a (solo)` form; a missing line means the sweep did not run -- do not omit it.*

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

**Landing check** against <previous session>'s What's next: <item> - done (<where>) / carried / <list file> "<line's title or first words>"; <item> - ...
[One clause per previous item. Required at every close tier -- Step 4, landing rule.]

**Waiting on <operator>:** <checklist location> - N open, oldest <date>
[Pointer only. Rulings and small tasks for the operator live on the checklist,
never as a paragraph here.]

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

### Active threads

Open parallel arcs live in the Active Threads ledger: [[Active Threads - {Project}]]
(maintained in place at close -- not duplicated in the entry). For projects without
a ledger, keep the roster inline here instead -- see Step 2.6 for the legacy format
(bold numbered name, session range, 2-3 sentences of remaining work, key doc paths).
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
