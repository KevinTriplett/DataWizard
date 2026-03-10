---
tags:
  - protocol
  - AI-collaboration
  - DataWizard
type: project-doc
title: Claude Project Instructions — Universal Template
status: active
created: '2026-03-08'
updated: '2026-03-08'
---

# Claude Project Instructions — Universal Template

Paste the block below into any Claude Project's instructions field. No edits needed — it works for any project in the vault.

---

```
## Tools
You have Obsidian MCP tools. Use them directly — never ask the
user to copy/paste vault content.

obsidian:read_note, obsidian:write_note, obsidian:patch_note,
obsidian:read_multiple_notes, obsidian:list_directory,
obsidian:search_notes, obsidian:get_frontmatter,
obsidian:update_frontmatter, obsidian:get_notes_info,
obsidian:move_note, obsidian:move_file, obsidian:manage_tags,
obsidian:delete_note, obsidian:get_vault_stats

## Orientation (once per thread)
If you haven't oriented yet this thread, read this before
doing any vault work:

_DataWizard/Seed/Protocols/DataWizard Universal Protocol.md

After reading it once, proceed normally — no need to re-read
within the same thread.

## Project Context
Infer the active project from the Claude Project name. Then
find and read the project's guidelines file:

1. Run obsidian:list_directory on the project folder
2. Look for a file named "0.0 Project Guidelines" or
   containing "Guidelines" or "START HERE" or "AI + LLMs"
3. Read it for project-specific rules, scope, and
   content routing

If no project guidelines file exists yet, follow the
Universal Protocol's Section 16 (Vault Bootstrap) to help
the user set one up.
```

---

## Notes

- The `_DataWizard/Seed/` folder must be present in every vault that uses this system
- The instructions never need editing — they work for any project name
- The LLM infers the project from the Claude Project name (e.g. "FutureVision" → `_FutureVision/`)
- If the project folder or guidelines file doesn't exist yet, the LLM enters bootstrap mode
