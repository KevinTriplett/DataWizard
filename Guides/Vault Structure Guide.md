---
title: Vault Structure Guide
type: document
created: '2026-03-07'
updated: '2026-03-07'
status: active
tags:
  - DataWizard
  - setup
  - guide
  - vault-structure
---

# Vault Structure Guide

*How to organize your Obsidian vault for DataWizard. This guide covers folder conventions, naming standards, and the YAML frontmatter schema.*

---

## Recommended Folder Structure

DataWizard doesn't require a specific folder layout, but it works best when your vault has a clear inbox, a place for processed content, and a place for the DataWizard system files themselves.

```
Your Vault/
  _!nbox/              ← new captures land here (DataWizard processes this first)
  _Clippings/          ← web clips (Obsidian Web Clipper)
  _Companions/         ← AI-generated companion notes (mirrored subfolders)
  _Transcripts/        ← raw meeting/call transcripts
  _Voice Memos/        ← voice memo transcripts
  _People/             ← people notes
  _DataWizard/         ← system folder (see below)
  [project folders]    ← your actual knowledge work
```

The `_` prefix on system folders keeps them sorted to the top in Obsidian's file explorer and signals "infrastructure, not content."

---

## The `_Companions/` Folder

Companion notes are AI-generated summaries, section maps, and key concept extractions for source notes (transcripts, clippings, etc.). They live in `_Companions/` with a subfolder structure that mirrors the source folder:

```
_Companions/
  _Transcripts/        ← companions for notes in _Transcripts/
  _Clippings/          ← companions for notes in _Clippings/
  _Meetings/           ← companions for notes in _Meetings/
```

**Why mirrored subfolders?** It keeps companions discoverable — you always know where to find a companion note based on where its source lives. It also keeps the source folders clean (transcripts with transcripts, companions with companions).

**Naming convention:** `Source Note Title — Companion.md`. Example: `2025-10-22 Michael Garfield — Companion.md`

**What companions contain:**
- Section map with timestamps (for transcripts)
- Key people, projects, and entities mentioned
- Per-section summaries optimized for LLM navigation
- Key concepts and themes extracted

**What companions do NOT contain:**
- Cross-conversation analysis (that belongs in higher-level design docs)
- The source content itself (the companion points back to the source via `source_transcript` or `source_note` in YAML)

**YAML for companions:**
```yaml
type: companion
source_transcript: "[[Source Note Name]]"
participants: ["[[Person 1]]", "[[Person 2]]"]
tags:
  - companion
  - ai-generated
generating_agent: Andrew / Claude
```

Wikilinks in `source_transcript` (or `source_note` for non-transcripts) make the relationship clickable in Obsidian's properties panel.

---

## The `_DataWizard/` Folder

This is the brain of the system. It contains all documentation, guides, taxonomy, and logs. Its structure:

```
_DataWizard/
  00 - Guides for Humans/    ← setup guides (you are here)
  01 - Project/              ← architecture docs, decision log, session log
  02 - Research/             ← pipeline specs, model research, tool comparisons
  03 - Andrew's Vault/       ← vault-owner's personal working layer (not shared)
  04 - For LLMs/             ← reference docs for AI agents
  AI + LLMs - START HERE - DataWizard - Universal Protocol.md  ← AI instructions
  Content Type Taxonomy.md   ← the 21 content types
  START HERE — For Humans.md ← human overview
```

When sharing DataWizard with others, share everything except the `03 -` folder — that contains vault-owner-specific logs, queues, and personal examples.

---

## YAML Frontmatter Schema

Every note processed by DataWizard gets a `type:` field. Optionally it also gets tags, themes, and harvest tracking fields.

### Required Field

```yaml
type: article
```

Must be one of the 21 active content types. See `Content Type Taxonomy.md` for the full list and decision tree.

### Common Optional Fields

```yaml
tags:
  - regenerative-economics
  - community
themes:
  - commons
  - decentralization
source_url: https://example.com/article
created: 2026-03-07
```

### Harvest Tracking (for source files)

Used when content has been extracted into a project document:

```yaml
harvest_status: harvested
harvested_into:
  - "[[Project Document Name]]"
harvested_date: 2026-03-07
last_agent: Claude
```

Three valid states:
- No `harvest_status` field = untouched (do not add a blank field)
- `harvest_status: reviewed` = reviewed, nothing to extract
- `harvest_status: harvested` = content extracted, `harvested_into` required

### Federation Fields

Used when a file is copied from a private folder into a shared project folder:

```yaml
# On the original:
federated_to:
  - "[[Filename]]"
federated_date: 2026-03-07

# On the copy:
federated_from: "[[OriginalFilename]]"
federated_date: 2026-03-07
```

---

## Naming Conventions

**Notes:** Use natural language titles. No date prefixes needed for content notes — DataWizard uses frontmatter `created:` for dates. **Do not use em-dashes (—), curly quotes, or other special characters in note titles** — use plain hyphens (-) and straight quotes instead. Special characters cause patch and path-matching failures for AI agents.

**Transcripts:** `YYYY-MM-DD [Participant Names] — [Topic].md`
Example: `2026-02-14 Andrew and Jay — Flow Funding Pilot.md`

**Voice memos:** Keep whatever your recorder generates — DataWizard classifies them by content, not filename.

**Log files:** Generated automatically by `classify.py` with timestamp in filename.

---

## Inbox Convention

The `_!nbox/` folder is where unprocessed captures land. The `!` prefix sorts it to the very top above other `_` folders. DataWizard runs classification on this folder first.

Keep captures raw — don't manually add frontmatter before running the classifier. Let the pipeline do that work.

---

## Private vs. Shared Folders

Some folders should never be federated into shared project spaces:

| Folder | Privacy level |
|---|---|
| `_Clippings/` | Private — personal web clips |
| `_Transcripts/` | Private — raw meeting notes |
| `_Meetings/` | Private — personal meeting notes |
| `_X Project Local/` | Private — confidential project materials |
| `_X Project Shared/` | Shared — visible to collaborators |

The naming convention `_X Project Local/` vs `_X Project Shared/` makes privacy immediately visible in the file explorer.
