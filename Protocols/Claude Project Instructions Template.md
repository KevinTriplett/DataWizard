---
tags:
  - protocol
  - AI-collaboration
  - DataWizard
type: project-doc
title: Claude Project Instructions — Universal Template
status: active
created: '2026-03-08'
updated: '2026-03-10'
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
If you haven't oriented yet this thread, find and read the
Universal Protocol before doing any vault work:

1. Look for a START HERE file in the _DataWizard/Seed/ folder
2. Follow its instructions to read the Universal Protocol
3. After reading it once, proceed normally

## Project Context
At the start of the first conversation, ask the user:
"What project are we working on?"

Then find the project folder in the vault and look for a
guidelines file (typically named "0.0 Project Guidelines.md").
If none exists, follow the Universal Protocol's bootstrap
section to help the user create one.
```

---

## Notes

- The `_DataWizard/Seed/` folder must be present in every vault that uses this system
- The instructions never need editing — they work for any project
- The LLM asks the user which project, then finds the folder and guidelines
- If the project folder or guidelines file doesn't exist yet, the LLM enters bootstrap mode
