---
name: block-stamper
description: >-
  Stamp sequential block IDs (^bN for articles, ^tN for transcripts) on source
  file paragraphs, making them addressable for citations, harvest provenance,
  and RAG indexing. Use before enrichment, before harvesting, or when preparing
  files for block-level citation. Triggers on: 'stamp block IDs', 'prepare for
  enrichment', 'add block references', or called as prerequisite by
  corpus-enrichment, transcript-harvest, document-harvest skills.
type: skill
version: '1.0'
created: '2026-06-11'
updated: '2026-06-11'
edit_log:
  - DW-S166 2026-06-11
---

# Block Stamper Skill

**Status:** Active (Seed)

## Overview

Stamp sequential block IDs on source file paragraphs, making every substantive paragraph addressable via Obsidian's native `^block-id` syntax. Block IDs serve as citation targets for companion notes, harvest destinations, and RAG chunk coordinates.

This is a utility skill -- it modifies source files in preparation for downstream skills (corpus-enrichment, transcript-harvest, document-harvest) that cite specific passages.

## When to Use

- Before enriching an article (corpus-enrichment skill requires block IDs for citations)
- Before harvesting a transcript or document that needs block-level provenance
- When preparing source files for RAG indexing
- User says "stamp this file", "add block IDs", "prepare for enrichment"
- Called by other skills as a prerequisite step

### When NOT to Use

- File already has block IDs (check first -- this skill is idempotent but should skip already-stamped files)
- File is a companion note, MOC, infrastructure file, or any non-source content
- File is in an archive folder

## Before You Start

1. Read this skill fully.
2. Determine the content type of the source file (article, transcript, or voice memo). This determines the block ID prefix.
3. Read the source file to check whether it already has block IDs.

## Content Type Detection

| Content Type | Block Prefix | How to Detect |
|---|---|---|
| Article / document / clipping | `^b` | Default. No speaker turns, not a transcript. |
| Transcript (meeting, interview, podcast) | `^t` | Has speaker turns (`**Name**:` pattern), or `type: transcript` / `type: meeting-transcript` in frontmatter |
| Voice memo | `^t` | `type: voice-memo` in frontmatter, or single-speaker transcript format |

When in doubt, use `^b` (article default).

## Stamping Rules

### What Gets a Block ID

- Every substantive prose paragraph (2+ sentences or one sentence making a specific claim)
- Each speaker turn in a transcript (the full turn, not each sentence within it)
- Individual list items when they contain substantive claims (not navigation lists, TOCs, or simple enumerations)
- Blockquotes that contain substantive content

### What Does NOT Get a Block ID

- Section headers (`#`, `##`, etc.) -- already addressable via `[[File#Header]]`
- YAML frontmatter
- Empty lines
- Horizontal rules (`---`)
- Image embeds (`![[image]]`, `![alt](url)`)
- Callout wrappers (`> [!note]` etc. -- stamp the content inside, not the wrapper)
- Navigation boilerplate (breadcrumbs, "Part of" lines, TOC links)
- Very short transitional lines ("See below.", "As follows:", "For example:") that carry no independent claim
- Lines that are purely formatting (bold-only section dividers like `**Section Name**` with no prose)

### Numbering

- Sequential, whole-document numbering starting at 1
- Articles: `^b1`, `^b2`, `^b3`, ...
- Transcripts: `^t1`, `^t2`, `^t3`, ...
- Block IDs are appended at the **end of the paragraph's last line**, separated by a space
- One block ID per paragraph -- never mid-paragraph

### Placement

The block ID goes at the very end of the paragraph, after all content including inline formatting, citations, and parenthetical references:

```
Reich discovered the orgasm function by studying energy pulsation
blocked in the armoured working class of post-WW1 Vienna. ^b7
```

For transcript turns:

```
**Kevin**: I had a really good call with some of the community
organizers and developers for the Holo movement. ^t1
```

For list items with substantive claims:

```
- Commons-based peer production enables collaborative work at
  planetary scale without corporate intermediaries ^b12
```

### Idempotency

- **Never re-stamp an already-stamped paragraph.** Before stamping, check if the file contains any `^b` or `^t` patterns at end of lines.
- If the file is fully stamped (every substantive paragraph has an ID), skip it entirely and report "already stamped."
- If the file is partially stamped (some paragraphs have IDs, some don't), this is unusual -- report it to the user rather than attempting a partial stamp. Partial stamps suggest a previous interrupted run or manual editing.
- Block IDs are assigned once and never renumbered. If content is later inserted, new paragraphs get the next available number (not renumbered to fill gaps).

## The Stamping Process

### Step 1: Read the file

Read the full source file. If it's large (>10K words), use filesystem Read in multiple passes if obsidian MCP overflows.

### Step 2: Check for existing block IDs

Scan the content for patterns matching `\^[bt]\d+` at end of lines. If found:
- If every substantive paragraph already has one: report "already stamped" and skip.
- If only some do: report "partially stamped -- needs review" and skip.

### Step 3: Identify substantive paragraphs

Walk through the file line by line. Identify paragraph boundaries (blank lines separate paragraphs). For each paragraph, apply the "what gets a block ID" and "what does NOT" rules above.

For transcripts, each speaker turn (starting with `**Name**:`) is one block regardless of how many lines it spans.

### Step 4: Assign block IDs

Number substantive paragraphs sequentially. Append the block ID at the end of each paragraph's last line, separated by a space.

### Step 5: Write back

Write the stamped content back to the source file. Preserve all frontmatter exactly as-is -- only the body content changes.

**For Obsidian MCP:** Use `obsidian:write_note` with the stamped content body. Be careful to preserve existing frontmatter by including it in the write.

**For filesystem:** Use the Write tool to overwrite the file with the complete content (frontmatter + stamped body).

**Important:** If the file has special characters in the filename (curly quotes, full-width parentheses, etc.) that cause obsidian MCP tools to fail, fall back to filesystem tools using the full absolute path.

### Step 6: Verify

After writing, read the file back and confirm block IDs are present. Count the number of IDs stamped.

### Step 7: Report

Report to the calling skill or user:
- Filename
- Content type detected
- Block prefix used
- Number of blocks stamped
- Any edge cases or concerns (e.g., bold-text "headers" that aren't real markdown headers, unusually short file)

## Edge Cases

**Bold-text section dividers:** Some sources use `**Bold Text**` as section dividers instead of `## Markdown Headers`. These are NOT paragraphs and should NOT get block IDs. However, they also aren't addressable via `[[File#Header]]` (Obsidian only resolves real markdown headers). Block IDs on surrounding paragraphs become the only citation path for these sections. Note this in the report.

**Very short files (<200 words):** Still stamp them. Even 3-4 block IDs are useful for citation precision.

**Files with no substantive paragraphs:** Possible for very thin clippings (just a title and a link). Report "no substantive content to stamp" and skip.

**Mixed content:** Some files have prose paragraphs interspersed with code blocks, tables, or embedded content. Stamp the prose; skip the non-prose.

## Common Mistakes

- **Stamping headers.** Headers are already addressable. Don't add block IDs to them.
- **Stamping inside YAML.** Never touch frontmatter content.
- **Re-stamping.** Always check for existing IDs first.
- **Renumbering.** Block IDs are permanent. Never renumber to fill gaps.
- **Putting block ID on the wrong line.** It goes on the LAST line of a multi-line paragraph, not the first.
- **Forgetting the space.** `text^b1` won't resolve in Obsidian. Must be `text ^b1` with a space before the caret.
- **Stamping companion notes.** Only stamp source files, never companions or other DW infrastructure.

## Batch Processing

When stamping multiple files (e.g., as a pre-step in overnight enrichment):

1. Process files one at a time -- read, stamp, write, verify before moving to the next
2. Report a summary after the batch: files processed, total blocks stamped, any files skipped and why
3. If a file fails to stamp (write error, special character issue), log the failure and continue with the next file

## See Also

- [[Citation Mechanism - Block-Level Provenance]] -- full design doc for the citation system
- corpus-enrichment skill -- primary consumer; uses block IDs for companion citations
- transcript-harvest skill -- uses block IDs for harvest destination citations
- document-harvest skill -- uses block IDs for harvest destination citations
- [[Rabbit Whole RAG - Corpus Architecture]] -- RAG layer uses block IDs as chunk coordinates
