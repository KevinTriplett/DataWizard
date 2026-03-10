---
type: project-doc
title: START HERE For Humans — Template
status: active
created: '2026-03-10'
updated: '2026-03-10'
tags:
  - protocol
  - AI-collaboration
  - DataWizard
---

# START HERE - For Humans — Template

Use this template when creating a `START HERE - For Humans.md` for a new project. Replace everything in `[brackets]` with project-specific content.

---

```markdown
# Welcome to [Project Name]

*A quick orientation for collaborators — human and AI alike.*

---

## What Is This?

[2-3 sentences describing the project: what it is, what it does, who it's for.]

---

## What's In This Folder?

| Document | What's In It |
|---|---|
| **[Main Document]** | [Description] |
| **Action Items** | Running list of action items |
| **Open Questions** | Open questions and pending decisions |
| **MOC** | Master index — start here to find any file |
| **Session Log** | Recent changes — read this to catch up quickly |

---

## How to Navigate

- **Start with the MOC** (`0.1 MOC.md`) — it's the master index for the whole project.
- **Catching up after a gap?** Read the Session Log (`0.2 Session Log.md`) — it shows what changed and when.
- **Looking for a specific topic?** The section files are numbered and titled descriptively.

---

## For Your AI — Copy Into Project Instructions

Paste this block into your LLM's project settings (Claude Project Instructions, or equivalent). This is the only setup your AI needs.

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
