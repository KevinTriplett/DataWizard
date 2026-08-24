---
title: Anti-Patterns
type: protocol
created: '2026-06-13'
updated: '2026-08-24'
operator: Andrew
priority: high
maturity: working
edit_log:
  - DW-S182 2026-06-13
  - "DW-S206 2026-06-28: codified the bang-prefix filename retirement"
  - "DW-S284 2026-08-24: added 'don't retire a convention without codifying the
    retirement' (S206 meta-lesson; meta-learning review S198-S209)"
---

Explicit anti-patterns. If you catch yourself doing any of these, stop.

**Don't put private content in shared folders.** Private meeting notes, personal reflections, and confidential materials stay in private folders. Only transcripts and documents explicitly cleared for sharing go in shared project folders.

**Don't duplicate content across documents.** Content lives in one place. If the same material is relevant to two documents, put it in the most specific home and cross-reference from the other with a wikilink.

**Don't modify archived originals.** Files marked as originals, archives, or source copies should never be edited. Work from copies or companion notes.

**Don't change filenames that other notes link to.** Obsidian resolves wikilinks by filename. Renaming a file that's linked from other notes breaks those links. If a rename is needed, use Obsidian's built-in rename (which updates links) or flag it for the human.

**Don't add empty YAML fields as placeholders.** Absence of a field is meaningful - it means "not yet processed." Adding `harvest_status:` with no value, or `type:` with no value, creates ambiguity. Either set a real value or leave the field off entirely.

**Don't process files outside your scope.** Each project has boundaries. Don't modify files in other project folders unless explicitly instructed. If you find content that belongs elsewhere, flag it - don't move it yourself.

**Don't assume your context is current.** If the session log shows recent activity by another agent, re-read affected files before editing. Stale reads lead to overwrites.

**Don't write to a shared document from two agents at once.** When multiple instances might touch the same file, coordinate through the human (or claim it via a session-log stub) rather than writing simultaneously - concurrent writes clobber each other. The S178/S179 stub collision is the cautionary case.

**Don't re-run expensive operations without checking.** Before running LLM classification or enrichment on a file, check its YAML first. If it already has a valid `type:` or `harvest_status:`, it may not need reprocessing.

**Don't rewrite massive files when you only need to edit a section.** If a file is too large for surgical edits via patch, check with the user about chunking it into shell + sections first. Full-file rewrites of large documents risk accidentally dropping content.

**Don't retire a convention in practice without codifying the retirement.** Uncodified state rots: when a convention is dropped in use but no rule records the drop, templates, skills, and other instances keep recommending the old form, and it resurfaces for months. The entry directly below is the canonical case - a filename prefix retired in practice kept reappearing until the retirement was written into its canonical home, ten weeks later. Retiring something is a convention change like any other: write the rule where the old rule lived, then sweep for the old form. (DataWizard, 2026-06)

**Don't use the retired `!` filename prefix.** Prefixing note filenames with `!` to force sort order was retired (S116 / PI v4.0). Use the `0.x` infrastructure slots or a plain descriptive title - see the [[Conventions Registry]] file-naming rule.

*Extracted from the DataWizard Universal Protocol (section 12.0) in the S182 demolition (D94). Structural conventions live in the [[Conventions Registry]].*
