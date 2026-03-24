---
title: Research Skill
type: project-doc
status: active
created: '2026-03-24'
updated: '2026-03-24'
datawizard_protocol_version: '1.7'
---

# Research Skill

*Skill file for DW agents conducting research passes over triaged content.*

## Purpose

Systematically research flagged content (Reddit posts, articles, links), extract useful information into companion notes, and maintain a link log to prevent duplicate work across agents and projects.

## Inputs

- **Triage review docs** — files like `Chunk N Triage Review - YYYY-MM-DD.md` that list flagged posts with brief triage notes and project relevance tags
- **Source files** — the actual Reddit saves or clippings being researched (in `_Reddit Saves/` or `_Clippings/`)
- **Link log** — `_Companions/! Research Link Log.md` — check this before researching any URL

## Outputs

- **Companion notes** — one per researched source, in `_Companions/` with extracted data
- **Link log entries** — every URL researched gets logged
- **Human review flags** — strong leads and unreadable pages flagged for user attention

---

## Workflow

### 1. Load the triage review doc

Read the triage review for the chunk you're working on. It lists flagged posts organized by subreddit and topic, with triage notes explaining why each was flagged and which projects it's relevant to.

### 2. Check the link log before researching

Before researching any post or following any link, check `_Companions/! Research Link Log.md`. If the URL is already logged:
- **Don't skip it** — a repeat appearance is a signal. Increment the `times_seen` count and append the new source to `also_seen_in`.
- Read the existing companion note to avoid duplicate research, but note the new context where it appeared.
- A link appearing 3+ times across different threads is a strong recommendation signal worth flagging.

If the URL is new, proceed with research as normal.

### 3. Read the source file

Read the Reddit save. It contains the post title, author, score, comments, and often the full text. Note:
- The `triage_relevant_to` YAML field tells you which projects care about this content
- The `triage_notes` field gives you the triager's assessment of why it matters

### 4. Assess depth tier

Based on what you find, assign one of three research depths:

**Skim** — Low relevance or thin content. Extract 1-2 key points into the companion note. Don't follow links.
- Post is tangential, low score, or mostly opinion without substance
- Content is already well-covered by something else in the link log

**Extract** — Medium relevance. Read the full post and comments, extract interesting tidbits into a structured companion note. Follow 1-2 promising links if they look substantive.
- Post describes a tool, technique, or pattern that's useful but not critical
- Comments add useful context or alternative approaches

**Deep dive** — High relevance. Read everything. Follow all promising links. For linked projects/tools: visit the main page, about page, documentation, GitHub repo. Gather as much detail as possible. Flag for human review.
- Post describes something directly applicable to DW architecture or one of the user's projects
- Post is a substantial tutorial, framework, or research doc
- Multiple comments confirm value or add significant detail
- If the discovery is a goldmine (large repo, rich ecosystem, dense docs), go deep enough to map what's there but don't try to exhaust it. Flag with `return_to: true` so a second research pass can go deeper.

### 5. Follow links

When following links from posts or comments:

a. **Check the link log first** — skip if already researched
b. **Try to read the page** — use web_fetch to get the content
c. **If the page is readable**: extract key information. For tools and projects, look for: what it does, how it works, tech stack, whether it's open source, how it compares to what we're building
d. **If the page is thin or unreadable**: try clicking through to About, Documentation, GitHub, or other second-level pages. If still no useful info after 2-3 attempts, log it in the link log as `status: unreadable` and flag for human review
e. **If it's a strong lead**: go deeper — read docs, check the GitHub repo, look at issues and README. Flag for human review with a note explaining why it's important

### 6. Create the companion note

For each researched source file, create a companion note in `_Companions/`. 

**Filename:** `c_[Topic].md` in `_Companions/c_Research/`

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
[1-3 sentence summary of what this post/thread is about]

## Key Findings
[Extracted data points, organized by topic. Be specific — names, URLs, technical details, comparisons]

## Links Explored
- [URL 1] — [what was found, 1-2 sentences]
- [URL 2] — [what was found]

## Relevance Notes
[Why this matters for the flagged projects. What patterns or tools could be applied]

## Flags
[If human_review: true, explain why — strong lead, needs decision, unreadable source, etc.]
```

The companion note is the primary output. A synthesis agent will later read ONLY these companions — so everything useful must be captured here. Don't assume the synthesizer will go back to the source.

### 7. Update the link log

After researching, add entries to `_Companions/! Research Link Log.md`:

```markdown
| URL | Source | Status | Companion | Date | Return To | Times Seen | Also Seen In |
|---|---|---|---|---|---|---|---|
| https://example.com/tool | [[Reddit Post Title]] | researched | [[Post Title — Research Companion]] | 2026-03-24 |
| https://example.com/unreadable | [[Reddit Post Title]] | unreadable | — | 2026-03-24 |
```

Status values: `researched`, `unreadable`, `human_review`, `skipped`

### 8. Update source YAML

After creating the companion, update the source file's YAML:

```yaml
research_status: researched
research_date: 2026-03-24
research_companion: "[[Source Title — Research Companion]]"
```

---

## Principles

- **Be curious, cast a wide net.** The goal is data collection, not synthesis. Capture anything that might be useful — the synthesis pass will filter later.
- **Dig into details.** Don't just note that a tool exists — find out how it works, what stack it uses, whether it's maintained, how it compares to what we're building.
- **Turn over most stones.** Follow interesting links in posts AND comments. Check GitHub repos, documentation pages, about pages. The best discoveries are often two clicks deep.
- **Log everything.** The link log prevents duplicate work. Every URL researched — whether useful or not — gets logged so the next agent doesn't waste time on it.
- **Flag generously.** When in doubt about whether something deserves human attention, flag it. Better to over-flag than to let a strong lead disappear into a companion note nobody reads.
- **Don't synthesize yet.** Resist the urge to draw conclusions or make recommendations. Extract, organize, and flag — the synthesis skill handles the rest.

---

## Chunking Strategy

Reddit triage docs are already chunked by subreddit groups (Chunk 1, 2, 3, 4). Process one chunk at a time. Within each chunk, work through subreddits in order. Within each subreddit, process flagged posts in the order listed.

At the end of each chunk, write a brief progress note:
```markdown
## Chunk N Complete — YYYY-MM-DD
Posts researched: X
Companions created: X
Links explored: X
Flagged for human review: X
```

---

## See Also

- `DW_synthesis_skill.md` — the next pass after research
- Triage review docs in `_Claude Recall/`
- Link log at `_Companions/! Research Link Log.md`
