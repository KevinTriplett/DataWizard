---
title: Protocol Summary
type: project-doc
version: '1.5'
status: active
created: '2026-03-12'
updated: '2026-03-12'
---

# DataWizard Protocol Summary (v1.5)

*Quick reference for oriented agents. Read the full protocol for details, edge cases, and examples.*

---

## Key Rules (Project Instructions v2.1)
- **Write to vault** — new content as .md, never draft markdown in chat
- **Edits in chat first** — show proposed changes as plain text, then write
- **Re-read before writing** — in shared/Relay projects, always re-read first
- **Chunk large tasks.** Present each chunk, get approval, execute, check in before next chunk.
- **Verify before retry.** Confirm success after any write/patch/move before attempting again.
- **Ask when uncertain.** Wrong edits are harder to undo than clarifying questions.
- **Harvest discipline.** Per source: segment with `##` headers → harvest → update source YAML. Complete all three before next source.

## Infrastructure Files
| Prefix | File | Required? |
|---|---|---|
| `!` | Action Items | When needed (sorts to top of folder) |
| 0.0 | Project Guidelines | Always |
| 0.1 | MOC | Always |
| 0.2 | Session Log | Always |
| 0.3 | Decision Log | Usually |
| 0.4 | Harvest Log - [Doc Name] | When harvesting |

The `!` prefix sorts files and folders to the top of any directory listing. Use it for action items (`! Action Items - Project Name.md`) and for master document folders (`! Master Documents/`).

Content sections start at 1.0+. Never renumber existing sections.

## YAML Essentials
- `type:` — lowercase, single value, from Content Type Taxonomy
- Harvest tracking: absent = untouched, `reviewed` = nothing to harvest, `harvested` = content extracted
- `harvested_into:` uses `[[wikilinks]]` — never full paths
- `ai-generated` is a tag, not a content type. `generating_agent` is optional.

## Session Log Format
```
## YYYY-MM-DD — [Brief title]
[1-3 sentences. Max 5 lines.]
**Files:** `file1.md`, `file2.md`
**Status:** complete | in progress — [what's pending]
```
Most recent first. LLMs: read last 2-3 entries only. **Update once per session** — at the end or at a natural break point. Don't log after every step.

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

## What NOT to Do
- Don't put private content in shared folders
- Don't duplicate content — cross-reference instead
- Don't modify archived originals
- Don't add empty YAML fields as placeholders
- Don't process files outside your project scope
- Don't re-run expensive operations without checking YAML first
- Don't use em-dashes (—), curly quotes, or other special characters in note titles — use plain hyphens (-) and straight quotes. Special characters cause patch and path-matching failures.

---

*Full protocol: DataWizard Universal Protocol v1.5*
