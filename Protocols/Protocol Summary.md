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

## Key Rules
- **Draft before writing.** Never use write_note, patch_note, or move_note without explicit human approval.
- **Chunk large tasks.** Present each chunk, get approval, execute, check in before next chunk.
- **Verify before retry.** Confirm success after any write/patch/move before attempting again.
- **Ask when uncertain.** Wrong edits are harder to undo than clarifying questions.

## Infrastructure Files (0.x series)
| Number | File | Required? |
|---|---|---|
| 0.0 | Project Guidelines | Always |
| 0.1 | MOC | Always |
| 0.2 | Session Log | Always |
| 0.3 | Decision Log | Usually |
| 0.4 | Harvest Log — [Doc Name] | When harvesting |
| 0.5 | Action Items | When needed |

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
Most recent first. LLMs: read last 2-3 entries only.

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
- Each section starts with `*Part of the [[Shell Document Name]]*`

## What NOT to Do
- Don't put private content in shared folders
- Don't duplicate content — cross-reference instead
- Don't modify archived originals
- Don't add empty YAML fields as placeholders
- Don't process files outside your project scope
- Don't re-run expensive operations without checking YAML first

---

*Full protocol: DataWizard Universal Protocol v1.5*
