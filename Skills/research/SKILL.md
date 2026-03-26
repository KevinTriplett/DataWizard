---
name: research
description: >-
  Use when systematically researching flagged content from triage reviews -
  Reddit posts, articles, tools, GitHub repos. Triggers on: 'research this',
  'look into this', 'deep dive on', 'what can you find about', processing triage
  chunks, or following up on return_to flags. Also use when exploring links from
  posts or comments.
---

# Research Skill

## Overview

Systematically research flagged content (Reddit posts, articles, links), extract useful information into companion notes, and maintain a link log to prevent duplicate work across agents and projects.

## When to Use

- Processing flagged posts from a triage review
- Deep-diving on a tool, project, or pattern discovered during scanning
- User says "research this," "look into this," "what can you find about..."
- Following up on a `return_to: true` flag from a previous research pass

### When NOT to Use

- Synthesizing across multiple companions (that's the synthesis skill)
- Triaging/scanning raw content for relevance (that's the triage workflow)
- Harvesting from transcripts or vault content (use harvest skills)

## Inputs

- **Triage review docs** — `Chunk N Triage Review - YYYY-MM-DD.md` with flagged posts and project relevance tags
- **Source files** — Reddit saves or clippings being researched
- **Link log** — `_Companions/! Research Link Log.md` — check before researching any URL

**Tool note:** The Recall Vault is accessed via `filesystem:` tools (e.g., `filesystem:read_text_file`, `filesystem:write_file`, `filesystem:list_directory`), NOT via `obsidian:` tools. The `obsidian:` namespace connects to the Regen Vault only. Use absolute paths for all Recall Vault files: `/Users/USERNAME/Vaults/Recall Vault/...`

## Outputs

- **Companion notes** — one per source, in `_Companions/c_Research/`
- **Link log entries** — every URL researched gets logged
- **Human review flags** — strong leads and unreadable pages flagged

## Workflow

### 1. Load the triage review doc

Read the triage review for the chunk you're working on. It lists flagged posts organized by subreddit and topic, with triage notes explaining why each was flagged.

### 2. Check the link log before researching

Before researching any post or following any link, check the link log. If the URL is already logged:
- Don't skip it — a repeat appearance is a signal. Increment `times_seen` and append to `also_seen_in`.
- Read the existing companion to avoid duplicate research, but note the new context.
- A link appearing 3+ times is a strong recommendation signal worth flagging.

### 3. Read the source file

Read the Reddit save. Note the `triage_relevant_to` and `triage_notes` YAML fields.

### 4. Assess depth tier

**Skim** — Low relevance or thin content. 1-2 key points. Don't follow links.

**Extract** — Medium relevance. Full post + comments. Follow 1-2 promising links.

**Deep dive** — High relevance. Read everything. Follow all promising links. Visit main pages, docs, GitHub repos. Flag for human review. If it's a goldmine, map what's there but don't exhaust it — flag with `return_to: true`.

### 5. Follow links

a. Check link log first
b. Try to read the page via web_fetch
c. Readable → extract key info (what it does, tech stack, open source?, comparison to what we're building)
d. Thin/unreadable → try About, Docs, GitHub. After 2-3 attempts, log as `status: unreadable`
e. Strong lead → go deeper, flag for human review

### 6. Create the companion note

**Path:** `_Companions/c_Research/c_[Topic].md`

**Structure:**

```markdown
---
type: companion
source_note: "[[Source Title]]"
research_date: YYYY-MM-DD
research_depth: skim | extract | deep_dive
relevant_to:
  - "ProjectName"
human_review: false | true
return_to: false | true
return_to_note: "Why this deserves a second pass"
---

# Source Title — Research Companion

## Summary
[1-3 sentences]

## Key Findings
[Specific data points: names, URLs, technical details, comparisons]

## Links Explored
- [URL] — [what was found, 1-2 sentences]

## Relevance Notes
[Why this matters for flagged projects]

## Flags
[If human_review: true, explain why]
```

The companion is the primary output. A synthesis agent reads ONLY companions — everything useful must be captured here.

### 7. Update the link log

Add entries to `_Companions/! Research Link Log.md`:

```
| URL | Source | Status | Companion | Date | Return To | Times Seen | Also Seen In |
```

Status values: `researched`, `unreadable`, `human_review`, `skipped`

### 8. Update source YAML

```yaml
research_status: researched
research_date: 2026-03-24
research_companion: "[[Source Title — Research Companion]]"
```

## Common Mistakes

- **Synthesizing during research.** Resist conclusions and recommendations. Extract and organize — synthesis is a separate pass.
- **Skipping comment threads.** The best discoveries are often two clicks deep in comment links.
- **Not checking the link log.** Duplicate research wastes context and time.
- **Shallow companion notes.** "It's a tool for X" isn't useful. Include how it works, what stack, whether maintained, how it compares.
- **Not flagging strong leads.** Over-flag rather than let a lead disappear into an unread companion.

## Principles

- Be curious, cast a wide net — data collection, not synthesis
- Dig into details — find out how things actually work
- Turn over most stones — follow links in posts AND comments
- Log everything — the link log prevents duplicate work
- Flag generously — better to over-flag
- Don't synthesize yet — that's the next skill

## Chunking Strategy

Process one triage chunk at a time. Within each chunk, work subreddits in order. At the end of each chunk, write a progress note with counts.

## Handing Off Research to Another Instance

When research will continue in a new thread (common for large triage batches or multi-repo deep dives), write the session log entry using the session-closer skill. For research tasks specifically, the "What's next" section must include:

1. **Specific files to read, in priority order** — not "study the repos" but "read this file first, then this file, then this file." The incoming instance should be able to start reading immediately.
2. **What to extract from each source** — different sources yield different things. State what you're looking for in each (methodology from one, patterns from another, formal requirements from a third).
3. **Where to write the output** — which companion note or research doc to append to or create.
4. **How this connects to previous research** — what's already been harvested (with file path), what's new territory. "We did a first pass from web search, now we have the primary sources" is the kind of framing that prevents duplicate work.
5. **"Read the supporting files, not just the main doc"** — explicitly instruct the instance to go deeper when repos or collections have reference files, agents/, examples/, etc. The richest patterns are often in the supporting material.

## See Also

- session-closer skill — session log writing and handoff methodology
- Synthesis skill (not yet built) — the next pass after research
- Triage review docs in Recall Vault `_Claude Recall/`
- Link log at `_Companions/! Research Link Log.md`
