---
title: Protocol Summary
type: project-doc
version: '2.3'
status: active
created: '2026-03-12'
updated: '2026-03-23'
---

# DataWizard Protocol Summary (v2.3)

*Quick reference for oriented agents. Read the full protocol for details, edge cases, and examples.*

---

## Key Rules (Project Instructions v2.2)
- **Write to vault** — new content as .md, never draft markdown in chat
- **Edits in chat first** — show proposed changes as plain text, then write
- **Re-read before writing** — in shared projects using Relay Obsidian plugin or similar, always re-read the file immediately before writing (another user may have changed it). In solo work, re-read only if the file was last read many messages ago. YAML-only updates via `update_frontmatter` are safe without re-reading (it merges, not overwrites).
- **Chunk large tasks.** Present each chunk, get approval, execute, check in before next chunk.
- **Verify before retry.** Confirm success after any write/patch/move before attempting again.
- **Ask when uncertain.** Wrong edits are harder to undo than clarifying questions.
- **Load tools before using them.** MCP tools load lazily — if `patch_note` or another tool isn't in your tool list, run `tool_search` with a specific query (e.g., "obsidian patch note") to load it. Don't assume a tool is unavailable just because it didn't appear in the first batch.
- **Harvest discipline.** Per source: segment with `##` headers → harvest → update source YAML. Complete all three before next source. Before harvesting from any transcript, check YAML for `segmented: true` — if missing or false, prompt the user to run segmentation first.
- **Git push before batch ops.** Before any script that moves or modifies files in bulk, commit and push. `git checkout .` is your undo.

## Orientation (once per thread)

1. **Version check**: Fetch `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/VERSION.md`
2. **Read 0.0 Project Guidelines** in full — this is the project brief (what it is, core concepts, key decisions, folder structure, pointers). Compare `datawizard_protocol_version` against VERSION.md. Match → fetch Protocol Summary. Mismatch → fetch full Universal Protocol.
3. **Compare instructions version** — flag if user needs to re-paste.
4. **Read session log** (0.2) — last 2-3 entries only.
5. **Read action items** if the file exists (typically `! Action Items - [Project Name].md`).
6. **Ready to work** — read other files only as needed.

## Infrastructure Files
| Prefix | File | Required |
|---|---|---|
| `!` | Action Items - Project Name | When needed (sorts to top of folder) |
| 0.0 | Project Guidelines - Project Name | Always |
| 0.1 | MOC - Project Name | Always |
| 0.2 | Session Log - Project Name | Always |
| 0.3 | Decision Log - Project Name | Usually |
| 0.4 | Harvest Log - Project Name | When harvesting |
| 0.6 | Related Notes - Project Name | Recommended |

All infrastructure files MUST include the project name after a hyphen to be uniquely identifiable across the vault. Use plain hyphens (`-`), never em-dashes (`—`).

All 0.x infrastructure files MUST include in frontmatter:
- `updated:` — date of last modification (YYYY-MM-DD)
- `datawizard_protocol_version:` — the protocol version the file was last written or reviewed against (currently 1.7)

For shared/collaborative projects (using Relay or shared folders), infrastructure files may live inside the shared workspace (e.g., `_Project/Project Shared/0.0 Project Guidelines - Project.md`) rather than at the project root, so collaborators can see them.

The `!` prefix sorts files and folders to the top of any directory listing. Use it for action items (`! Action Items - Project Name.md`) and for master document folders (`! Master Documents/`).

Content sections start at 1.0+. Never renumber existing sections.

### 0.6 Related Notes (Dataview)

A Dataview query that surfaces vault notes tagged with or relevant to this project but living outside the project folder (e.g., clippings, seeds, transcripts, Reddit saves routed to content-type folders). Helps harvest agents and project instances discover material they might otherwise miss. Example query:

```dataview
TABLE type, harvest_status, updated
FROM #project-tag
WHERE !contains(file.path, "ProjectFolder/")
SORT updated DESC
```

Replace `#project-tag` and `"ProjectFolder/"` with the project's actual tag and home folder path.

### What goes in a 0.0 Project Guidelines file

Adapt depth to project complexity. A lightweight project might only need sections 1, 2, 6, 7, 8.

1. **What this project is** — one paragraph (name, purpose, scope)
2. **Current state** — pointer to session log and action items (don't duplicate status)
3. **Core concepts** — 3-6 key ideas/patterns that shape the project
4. **Key architecture decisions** — one-liners pointing to decision log
5. **Stack / instance config** — hardware, models, tools, paths (label as instance-specific)
6. **Folder structure** — what's where
7. **Key pointers** — canonical docs, config files, repos
8. **Working conventions** — project-specific rules beyond the universal protocol

Aim for 800-1200 tokens — dense but scannable, cheap to read every thread.

## Folder Taxonomy (type to home)

| Content Type | Folder |
|---|---|
| `seed`, `seedpod` | `_Seeds/` |
| `entity` | `_Entities/` |
| `event` | `_Events/` |
| `resource`, `resource-list` | `_Resources/` |
| `person` | `_People/` |
| `article`, `video` | `_Clippings/` |
| `video-transcript`, `podcast-transcript`, `meeting-transcript` | `_Transcripts/` |
| `voice-memo-transcript` | `_Transcripts/Voice Memos/` |
| `meeting-note`, `message` | `_Meetings/` |
| `companion` | `_Companions/` |
| `document`, `multi-part` | Project folder (human routes) |

## YAML Essentials
- `type:` — lowercase, single value, from Content Type Taxonomy
- Harvest tracking: absent = untouched, `pending` = triaged and routed, `reviewed` = nothing to harvest, `harvested` = content extracted
- `harvest_for:` — list of project wikilinks indicating which projects should harvest this note. A single note can be relevant to multiple projects. Set by the Harvest Agent or by hand. Example:
  ```yaml
  harvest_for:
    - "[[_MetaMyth]]"
    - "[[_Weave Project Shared]]"
  ```
- `harvested_into:` uses `[[wikilinks]]` — never full paths. Set by the project-specific agent after harvesting.
- `highlighted_by_hand: true` — flag for notes where a human has manually highlighted key passages
- `ai-generated` is a tag, not a content type. `generating_agent` is optional.

## Session Log Format
```
## YYYY-MM-DD — [Brief title]
[1-3 sentences. Max 5 lines.]
**Files:** `file1.md`, `file2.md`
**Status:** complete | in progress — [what's pending]
```
Most recent first. LLMs: read last 2-3 entries only. **Update once per session** — at the end or at a natural break point. Don't log after every step.

**Chunk long session logs.** When a session log exceeds ~10 entries or ~5000 words, convert to shell + section folder pattern. Shell contains embeds; individual sessions become section files in `0.2 Session Log - Project/`. Instances read only the last 2-3 section files for orientation.

## Citation Format
```
([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]])
```

## Archiving
- Move to `xArchive/` folder — don't leave in place
- Don't rename — keep original filename for wikilinks
- Add `> ⚠️ Archived (YYYY-MM-DD). Superseded by [[New File]].` at top

## Shell + Section Architecture
- Shell contains only `![[embed]]` references — never edit directly
- Section files hold content — always edit these
- Shell file and section subfolder share the same name (e.g., `My Document.md` + `My Document/`)
- Section numbering starts at 1.0 (not 0.0)
- Section YAML: `parent: "[[Shell Name]]"` and `section: N` (matching the filename prefix)
- 5+ sections → create a section subfolder
- For projects with multiple shell documents, use a `! Master Documents/` folder for shells and action items, keeping them separate from section subfolders
- Empty folders cannot be deleted via MCP — when files are moved out, the human deletes the empty folder manually in Obsidian

## Companion Notes
- AI-generated summaries/section maps for source notes
- Live in `_Companions/` with mirrored subfolders (`_Companions/_Transcripts/`, `_Companions/_Clippings/`, etc.)
- Named: `Source Title — Companion.md`
- YAML: `type: companion`, `source_transcript:` or `source_note:` as wikilink
- Contain section maps, key people/projects, per-section summaries
- Do NOT contain cross-conversation analysis (that belongs in design docs)

## Scripts and Guides

User-specific paths (scripts location, vault root) are in `_DataWizard/Seed/Vault Config.md`. Read this file to find the scripts directory before generating terminal commands.

**Available scripts** (in the `scripts_dir` from Vault Config):

| Script | Purpose |
|---|---|
| `classify.py` | Classify vault notes by content type |
| `route_notes.py` | Move classified notes to proper folders by type |
| `segment_transcript.py` | Add `##` topic headers to transcripts via Qwen/Ollama |
| `process_dewey_reddit.py` | Import Reddit saves from Dewey CSV exports |
| `dedup_reddit_saves.py` | Deduplicate Reddit saves by source URL |
| `organize_reddit_saves.py` | Sort Reddit saves into subreddit folders |
| `process_fathom.py` | Post-process Fathom transcript exports |

**Vault guides (read via MCP):**

| Guide | Path |
|---|---|
| Federation Guide | `_DataWizard/Seed/Guides/Federation Guide.md` |
| Vault Structure Guide | `_DataWizard/Seed/Guides/Vault Structure Guide.md` |
| Editing Claude Desktop Config | `_DataWizard/Seed/Guides/Editing the Claude Desktop Config.md` |
| Harvest Agent instructions | `_DataWizard/Seed/Agents/Harvest Agent.md` |
| Vault Config (user-specific) | `_DataWizard/Seed/Vault Config.md` |
| Vault Cleanup Architecture | `_DataWizard/Workshop/Vault Cleanup Architecture.md` |

## In-Thread Commands

These commands can be used in any thread at any time:

| Command | What it does |
|---|---|
| `DW review` | Audit the project against protocol. Offers scope options before starting. |
| `DW status` | Check the Transcript Status Dashboard and report pending items |

### DW Review — Tiered Audit

When a user types `DW review`, first re-read:
1. `_DataWizard/Seed/Protocols/Protocol Summary.md`
2. `_DataWizard/Seed/Vault Config.md`
3. Your agent-specific instructions file (if applicable)

Then ask the user what scope they want:

| Scope | What it checks | Token cost |
|---|---|---|
| **Quick** | Filenames, folder structure, infrastructure file presence | Low |
| **Standard** | Quick + frontmatter on all files (via `get_frontmatter`, not full reads) | Medium |
| **Full** | Standard + content spot-checks on key files (shells, guidelines, MOC) | High |
| **Incremental** | Only files modified since the last DW review date | Low-Medium |

For incremental reviews, check the session log for the last `DW review` entry and only audit files modified after that date.

After completing a review, log it in the session log:
```
## YYYY-MM-DD — DW Review (scope)
[Summary of findings]
**Status:** complete — [N] issues found, [M] fixed
```

Confirm to the user: "Updated — now running Protocol Summary v[X.X]. Review complete."

## What NOT to Do
- Don't put private content in shared folders
- Don't duplicate content — cross-reference instead
- Don't modify archived originals
- Don't add empty YAML fields as placeholders
- Don't process files outside your project scope
- Don't re-run expensive operations without checking YAML first
- Don't use em-dashes (—), curly quotes, or other special characters in note titles — use plain hyphens (-) and straight quotes. Special characters cause patch and path-matching failures.

---

*Full protocol: DataWizard Universal Protocol v1.7*
