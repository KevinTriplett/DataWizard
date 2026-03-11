---
title: Vault Backup Setup Guide
type: document
created: '2026-03-07'
updated: '2026-03-07'
status: active
tags:
  - infrastructure
  - backup
  - git
  - DataWizard
---

# Vault Backup Setup Guide — Andrew's Regen Vault

> ⚠️ **This is a vault-specific record, not the shareable guide.** It documents the actual setup performed on Andrew's Regen Vault on 2026-03-07, including real paths, usernames, and gotchas encountered.
>
> For the generic, Claude-guided setup guide suitable for sharing, see: **[[Git Backup Setup — Claude-Guided Walkthrough]]** in this same folder.

A record of how the Regen Vault git backup system was configured, and how to operate it going forward.

---

## Overview

The vault uses **git** for version control with **GitHub** as the remote, managed from within Obsidian via the **Obsidian Git** community plugin. Every 5 minutes, any changes are automatically committed and pushed to GitHub.

This gives us:
- Full version history for every file in the vault
- The ability to recover any previous version of any note
- A rollback mechanism if a pipeline run modifies files incorrectly
- A complete offsite backup

This approach follows the recommendation from [Relay.md](https://docs.relay.md/guides/backing-up-your-obsidian-vault/) — git is a passive versioning tool and does not conflict with Relay's real-time sync.

---

## Architecture

| Component | Role |
|---|---|
| **git** (via Homebrew) | Local version control |
| **GitHub** (`andrewalan11/RegenVault`) | Remote backup — private repo |
| **Obsidian Git plugin** | Auto-commit and push from within Obsidian |
| **File Recovery plugin** (core) | Short-term snapshot recovery (30-day retention, 5-min interval) |

Git is the primary recovery tool. File Recovery is a secondary safety net for quick individual-file rollbacks without needing the terminal.

---

## What's Included and Excluded

### Included (tracked in git)
Everything in the vault by default, including:
- All content folders (`_!nbox/`, `_Clippings/`, `_Transcripts/`, `_DataWizard/`, etc.)
- Relay shared folders (`_WiseCrowds Shared/`, `_MetaMyth/`)
- Images (`_Images/`)
- `.obsidian/` settings (plugins, themes, hotkeys)

### Excluded (`.gitignore`)
```
# Obsidian ephemeral state
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/app.json

# Large Copilot index files
.obsidian/copilot-index-*.json

# Tool folders
.copilot/
.smart-env/

# System files
.DS_Store
.trash/

# Lock files
.~lock.*
```

`workspace.json` and `app.json` are excluded because they change constantly and contain ephemeral UI state, not meaningful vault content. The Copilot index file was excluded because it exceeded GitHub's 100MB file size limit.

---

## Setup Steps (for reference / reproducibility)

These steps are recorded here so the setup can be reproduced on a new machine or recovered if something goes wrong.

### 1. Install git
```bash
brew install git
git config --global user.name "Andrew Hasse"
git config --global user.email "andrewhasse@gmail.com"
```

### 2. Create GitHub repo
- Create a new **private** repository at github.com — `RegenVault`
- Do not initialize with README or .gitignore

### 3. Initialize local repo
```bash
cd ~/Vaults/Regen\ Vault
git init
```

### 4. Create `.gitignore`
Create the file at `~/Vaults/Regen Vault/.gitignore` with the contents shown in the section above.

### 5. Initial commit and push
```bash
git add .
git commit -m "initial vault backup"
git remote add origin https://github.com/andrewalan11/RegenVault.git
git branch -M main
git push -u origin main
```

### 6. Install Obsidian Git plugin
- Obsidian → Settings → Community Plugins → Browse → search "Obsidian Git" → Install → Enable

### 7. Configure Obsidian Git
Key settings to configure:

| Setting | Value |
|---|---|
| Custom Git binary path | `/opt/homebrew/bin/git` |
| Auto commit-and-sync interval | `5` minutes |
| Auto commit-and-sync after stopping file edits | On |
| Auto commit-and-sync only staged files | Off |
| Push on commit-and-sync | On |
| Pull on commit-and-sync | On |
| Pull on startup | On |
| Hide notifications for no changes | On |
| Commit message (auto) | `vault backup: {{date}} ({{numFiles}} files)` |
| List filenames in commit body | On |
| Author name | `Andrew Hasse` |
| Author email | `andrewhasse@gmail.com` |

---

## Verifying It Works

Open the Obsidian Command Palette (`Cmd+P`) and run:

```
Git: Commit-and-sync
```

You should see a notification: *"Commit X files and push X files to remote"*. If it says "nothing to commit," that's also fine — it means the vault is already up to date.

To browse commit history from within Obsidian:
```
Git: Open history
```

---

## Day-to-Day Operation

No action needed — the plugin handles everything automatically. Every 5 minutes, any changes are staged, committed, and pushed to GitHub.

Manual commit-and-sync is available any time via `Cmd+P → Git: Commit-and-sync` — useful before running a DataWizard pipeline that will modify many files.

**Recommended habit:** Run a manual commit-and-sync before any bulk pipeline operation so you have a clean snapshot to roll back to if needed.

---

## Recovery

### Recover a single file (from Obsidian)
`Cmd+P → Git: View file history` — browse and restore previous versions of the current note.

### Recover a single file (from terminal)
```bash
cd ~/Vaults/Regen\ Vault

# See commit history for a specific file
git log --oneline -- "_!nbox/SomeNote.md"

# Restore a previous version (replace COMMIT_HASH)
git checkout COMMIT_HASH -- "_!nbox/SomeNote.md"
```

### Roll back the entire vault to a previous commit
```bash
cd ~/Vaults/Regen\ Vault

# See recent commits
git log --oneline -20

# Roll back (replace COMMIT_HASH)
git reset --hard COMMIT_HASH
git push --force
```

> ⚠️ `git reset --hard` is destructive — it discards all changes after the target commit. Only use this for a genuine recovery situation, not routine cleanup.

### Clone vault to a new machine
```bash
git clone https://github.com/andrewalan11/RegenVault.git ~/Vaults/Regen\ Vault
```

Then reinstall Obsidian, open the cloned folder as a vault, and reinstall plugins.

---

## GitHub Repository

**URL:** https://github.com/andrewalan11/RegenVault  
**Visibility:** Private  
**Branch:** `main`

*Setup completed: 2026-03-07*
