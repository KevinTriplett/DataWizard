---
title: Federation Guide
type: project-doc
created: '2026-03-21'
status: active
tags:
  - datawizard
  - protocol
  - federation
---

# Federation Guide

How to copy notes between vault locations (federation) efficiently.

## Why Federate?

When a note in one location (e.g., `_Clippings/`) is relevant to a specific project (e.g., Metamorphic Media), the project needs its own copy so it can be modified independently — different YAML, different annotations, eventually different content in a shared vault context.

Wikilinks are NOT federation. A wikilink says "this exists over there." A federated copy says "this now lives here too, and we track provenance between them."

## The Pattern

Federation is a two-step operation:

### Step 1: Copy the files (zero-token)

The Claude instance generates a terminal command block. The user pastes it into Terminal.

```bash
# Example: federate 3 clippings into a project folder
cd ~/Vaults/Regen\ Vault && \
cp "_Clippings/Source Article One.md" "_Metamorphic Media/Research/Source Article One.md" && \
cp "_Clippings/Source Article Two.md" "_Metamorphic Media/Research/Source Article Two.md" && \
cp "_Clippings/Source Article Three.md" "_Metamorphic Media/Research/Source Article Three.md" && \
echo "Done — 3 files federated"
```

Rules for generating the command:
- Always `cd` to vault root first
- Use `&&` chaining so it stops on first error
- Escape spaces with backslashes in paths
- Create destination directory if needed: add `mkdir -p "dest/folder" &&` before the copies
- End with an echo confirming count
- Do NOT use `mv` — federation is always a copy

### Step 2: Update YAML on both sides (Claude does this)

After the user confirms the copy is done, the Claude instance updates frontmatter using `obsidian:update_frontmatter`:

**On the original:**
```yaml
federated_to:
  - "[[_Metamorphic Media/Research/Source Article One]]"
```

**On the copy:**
```yaml
federated_from: "[[_Clippings/Source Article One]]"
```

The instance may also update `type`, `tags`, `harvest_status`, or `harvest_for` on the copy to match the project context.

## When to Federate vs. When to Wikilink

| Situation | Use |
|---|---|
| Project needs its own YAML/annotations | Federate (copy) |
| Just referencing another note | Wikilink |
| Shared vault — each collaborator needs a copy | Federate |
| Same vault, read-only reference | Wikilink |

## For Claude Instances

When you need to federate notes:

1. Generate the full `cp` command block (see pattern above)
2. Present it to the user with a brief explanation
3. Wait for the user to confirm they've run it
4. Update YAML on all source and destination files using `obsidian:update_frontmatter`

Do NOT use `filesystem:read_text_file` + `filesystem:write_file` for federation — that reads the entire file content into your context window, wasting tokens. The terminal command is always preferred.
