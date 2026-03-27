---
title: Research Tracking Index Template
type: skill-reference
parent: research-tracking
---

# Research Tracking Index Template

## When to Create One

Create this when you have 5+ research notes and start wondering
"did we already look at this?" That's the signal.

## Setup

Create a note in your project's research or workshop area. Name it
something like `! Research Tracking Index.md` (the `!` prefix keeps
it sorted to the top).

## Template

Use this structure:

```
---
title: "Research Tracking Index"
type: project-doc
status: active
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Research Tracking Index

Master lookup for tools, frameworks, and patterns evaluated for
this project. Check here before researching anything new.

## Evaluated

| Name | URL | Date | Depth | Relevance | Output |
|---|---|---|---|---|---|
| [Example Tool] | [link] | YYYY-MM-DD | moderate | high | [[Research Note Title]] |
| [Light Item] | [link] | YYYY-MM-DD | light | low | Inline verdict here with key details. |

## Depth Key

- **Light**: Surface scan, brief assessment. No full note -- the
  Output column captures the verdict and any standout details.
- **Moderate**: Docs + links read, structured research note written.
- **Deep**: Source code inspected, architecture analyzed, full
  research note with transferable patterns.

## Queued for Review

Items flagged for future investigation. Each has a trigger condition
describing when it becomes worth evaluating.

| Name | URL | Trigger | Flagged |
|---|---|---|---|
| [Tool Name] | [link] | [When to investigate] | YYYY-MM-DD |
```

## Column Guide

**Output column examples:**

For moderate/deep evaluations (link to research note):
> [[DUMBAI - Defensive Agent Design Patterns]]

For light evaluations (inline verdict + key details):
> Community consensus: md for context/intent, code for execution.
> Key detail: break files ~500 lines per domain, load only what's
> relevant. No new patterns beyond existing architecture.

The inline verdict should always answer three questions:
1. What was it?
2. Why didn't it warrant a full note?
3. Was there any standout detail worth preserving?

**Queued for Review -- Trigger column:**
Describes when this becomes worth investigating. Prevents premature
research on things that only matter at a future milestone. Examples:
- "When building the search layer"
- "When publishing skills externally"
- "When the enrichment pipeline reaches Step 3"

## Optional Columns

Projects with richer needs can add columns. Some useful ones:

- **Cross-Project**: Flag items relevant to other projects
- **Design Docs**: Track which design docs each evaluation fed into
- **Batch**: Tag items processed together to trace cluster patterns

Start minimal. Add columns when you feel the need, not in advance.

## Maintenance

- Add an entry after every evaluation, even light ones
- Check the Queued section when starting new work -- a queued item's
  trigger condition may now be met
- Update relevance if your understanding changes after later research
- Update the `updated` date in frontmatter after each batch
