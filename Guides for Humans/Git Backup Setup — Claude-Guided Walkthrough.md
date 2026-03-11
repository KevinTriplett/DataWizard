---
title: Git Backup Setup — Claude-Guided Walkthrough
type: document
created: '2026-03-11'
updated: '2026-03-11'
status: active
tags:
  - infrastructure
  - backup
  - git
  - DataWizard
  - setup-guide
---

# Git Backup Setup — Claude-Guided Walkthrough

*This guide is written for a Claude instance to follow while walking a human through git backup setup for their Obsidian vault. Each section includes instructions for Claude and commands for the human. Claude should work through this sequentially, checking in after each step before proceeding.*

---

## What We're Setting Up

A two-layer backup system:

1. **Git + GitHub** — full version history, offsite backup, rollback for bulk operations. This is the primary system.
2. **Obsidian File Recovery plugin** — quick in-app snapshots for individual file recovery. Secondary safety net.

The Obsidian Git plugin automates git so the human never needs to touch the terminal after setup.

**Why this matters for DataWizard:** Before running any pipeline operation that touches many files, the human should have a clean git snapshot to roll back to if something goes wrong.

---

## For Claude: How to Use This Guide

Work through each section in order. At each **▶ Check in** marker, pause and confirm with the human before continuing. If something fails, the **⚠️ Gotcha** notes document known issues and fixes.

Gather the following variables at the start — you'll need them throughout:

- `[VAULT_PATH]` — full path to the vault (e.g. `~/Vaults/My Vault`)
- `[YOUR_NAME]` — git author name (e.g. `Jane Smith`)
- `[YOUR_EMAIL]` — git author email
- `[GITHUB_USERNAME]` — their GitHub username
- `[REPO_NAME]` — what to name the GitHub repo (usually a version of the vault name, no spaces)

Ask the human for these before starting.

---

## Prerequisites

Before touching git, confirm these are in place:

**Homebrew** — the Mac package manager. Check with:
```bash
brew --version
```
If not installed: https://brew.sh

**A GitHub account** — https://github.com. Must be logged in.

**Obsidian** with the vault already set up and working.

▶ **Check in:** Confirm all three prerequisites are met before continuing.

---

## Section 1 — Install and Configure Git

### 1.1 Install git

```bash
brew install git
```

Verify:
```bash
git --version
```

Should return something like `git version 2.x.x`.

### 1.2 Set git identity

```bash
git config --global user.name "[YOUR_NAME]"
git config --global user.email "[YOUR_EMAIL]"
```

Verify:
```bash
git config --global user.name
git config --global user.email
```

▶ **Check in:** Confirm git is installed and identity is set correctly.

---

## Section 2 — Create the GitHub Repository

1. Go to https://github.com/new
2. Repository name: `[REPO_NAME]`
3. Set visibility to **Private**
4. **Do NOT** check "Add a README", "Add .gitignore", or "Choose a license" — the repo must be empty
5. Click **Create repository**
6. Copy the repo URL — it will look like: `https://github.com/[GITHUB_USERNAME]/[REPO_NAME].git`

▶ **Check in:** Confirm the empty private repo has been created and the URL is copied.

---

## Section 3 — Create the .gitignore

Before initializing git, create a `.gitignore` file in the vault root to exclude files that should not be tracked.

**Ask the human:** Do they use any AI plugins in Obsidian (Copilot, Smart Connections, etc.)? These often create large index files that will cause problems with GitHub's 100MB file size limit. We'll exclude them proactively.

Create the file at `[VAULT_PATH]/.gitignore` with this content:

```
# Obsidian ephemeral state — changes constantly, not meaningful to version
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/app.json

# AI plugin index files — these can be very large (100MB+) and will fail GitHub's size limit
.obsidian/copilot-index-*.json
.obsidian/smart-connections/
.smart-env/
.copilot/

# System files
.DS_Store
.trash/

# Lock files
.~lock.*
```

**Note on what IS tracked:** Everything else is tracked by default — all your notes, images, PDFs, and `.obsidian/` settings (plugins, themes, hotkeys). This is intentional: you want your settings backed up too.

Claude can create this file directly using the filesystem tools if available. Otherwise, ask the human to create it manually in a text editor.

⚠️ **Gotcha — large AI index files:** If git push fails with "file exceeds GitHub's 100MB limit," a large AI plugin file got into the commit history. The fix requires rewriting history with `git filter-branch`. See the Troubleshooting section at the end of this guide.

▶ **Check in:** Confirm the `.gitignore` file is in place at the vault root.

---

## Section 4 — Initialize the Local Repository

```bash
cd [VAULT_PATH]
git init
git add .
git commit -m "initial vault backup"
```

The `git add .` step may take a moment if the vault is large. The commit message can be anything.

⚠️ **Gotcha — zsh history expansion:** If the vault path contains `!` (e.g. `_!nbox/`), wrap paths in single quotes in terminal commands: `'_!nbox/'`. The `!` character triggers zsh history expansion.

▶ **Check in:** Confirm the initial commit completed without errors. The output should end with something like `[main (root-commit) abc1234] initial vault backup`.

---

## Section 5 — Connect to GitHub and Push

```bash
git remote add origin https://github.com/[GITHUB_USERNAME]/[REPO_NAME].git
git branch -M main
git push -u origin main
```

The initial push will take a few minutes depending on vault size — a typical vault with images can be 200–500MB.

**Expected success output:**
```
Writing objects: 100% (XXXX/XXXX), XXX MiB | XXX KiB/s, done.
branch 'main' set up to track 'origin/main'.
```

⚠️ **Gotcha — push rejected due to large file:** If the push fails with `GH001: Large files detected`, a file exceeding 100MB got into the commit. See Troubleshooting at the end of this guide.

▶ **Check in:** Confirm the push succeeded. Ask the human to visit `https://github.com/[GITHUB_USERNAME]/[REPO_NAME]` in their browser — they should see their vault files.

---

## Section 6 — Install the Obsidian Git Plugin

This plugin automates commits and pushes from within Obsidian so the human never needs to use the terminal again.

1. In Obsidian: **Settings → Community Plugins**
2. If community plugins are disabled, click **Turn on community plugins**
3. Click **Browse**, search for **Obsidian Git**
4. Click **Install**, then **Enable**

▶ **Check in:** Confirm the plugin is installed and enabled. The settings panel should open automatically, or can be accessed via Settings → Obsidian Git.

---

## Section 7 — Configure the Obsidian Git Plugin

Work through these settings. Most are in the main settings panel; the git binary path is under **Advanced** at the bottom.

### 7.1 Fix the git binary path (critical on Mac)

Obsidian may not find the Homebrew git installation. First, get the path:

```bash
which git
```

This will return something like `/opt/homebrew/bin/git`.

In Obsidian Git settings → scroll to **Advanced** → **Custom Git binary path** → enter the full path from above (e.g. `/opt/homebrew/bin/git`).

Click **Reload** (the button nearby). If the settings panel previously showed "Git is not ready," it should now resolve. If it doesn't, **restart Obsidian completely** and reopen settings.

⚠️ **Gotcha — "Git is not ready" persists after setting binary path:** Try a full Obsidian quit and relaunch. The binary path change sometimes requires a restart to take effect.

### 7.2 Configure auto-sync settings

| Setting | Value | Notes |
|---|---|---|
| Auto commit-and-sync interval (minutes) | `5` | Core setting — commits every 5 minutes |
| Auto commit-and-sync after stopping file edits | **On** | Commits when you stop typing |
| Auto commit-and-sync only staged files | **Off** | Commit all changes, not just staged |
| Push on commit-and-sync | **On** | Push to GitHub on every commit |
| Pull on commit-and-sync | **On** | Pull before pushing |
| Pull on startup | **On** | Sync when Obsidian opens |
| Hide notifications for no changes | **On** | Suppresses noisy "nothing to commit" popups |

### 7.3 Configure commit messages

| Setting | Value |
|---|---|
| Commit message on auto commit-and-sync | `vault backup: {{date}} ({{numFiles}} files)` |
| List filenames affected in commit body | **On** |

### 7.4 Set commit author

| Setting | Value |
|---|---|
| Author name for commit | `[YOUR_NAME]` |
| Author email for commit | `[YOUR_EMAIL]` |

▶ **Check in:** Confirm all settings are configured. Now test it.

---

## Section 8 — Verify Everything Works

In Obsidian, open the Command Palette (`Cmd+P`) and run:

```
Git: Commit-and-sync
```

**Expected result:** A notification appears saying `Committed X files and pushed X files to remote` (or `Nothing to commit` if no changes since the initial push — both are fine).

If you see an error, check:
- Is "Git is not ready" showing in settings? → Recheck Section 7.1
- Authentication error? → See Troubleshooting below

▶ **Check in:** Confirm the test commit-and-sync succeeded. Setup is complete.

---

## Section 9 — Enable File Recovery (Secondary Safety Net)

This is a built-in Obsidian plugin — no installation needed.

1. Settings → Core Plugins → **File Recovery** → Enable (if not already on)
2. Click the gear icon next to File Recovery
3. Set **Snapshot interval** to `5` minutes
4. Set **History length** to `30` days (up from the 7-day default)

This gives you a quick in-app way to recover individual files without touching the terminal.

▶ **Check in:** Confirm File Recovery is enabled with updated settings.

---

## Day-to-Day Operation

No action needed — the Obsidian Git plugin handles everything automatically every 5 minutes.

**One good habit to establish:** Before running any DataWizard pipeline that will touch many files, run a manual commit-and-sync first (`Cmd+P → Git: Commit-and-sync`). This creates a clean snapshot you can roll back to if the pipeline does something unexpected.

**To browse commit history:** `Cmd+P → Git: Open history`

**To restore a previous version of a note:** Open the note, then `Cmd+P → Git: View file history`

---

## Recovery Reference

### Roll back a single file (terminal)
```bash
cd [VAULT_PATH]
git log --oneline -- "path/to/Note.md"   # find the commit hash
git checkout [COMMIT_HASH] -- "path/to/Note.md"
```

### Roll back the entire vault
```bash
cd [VAULT_PATH]
git log --oneline -20                     # find target commit
git reset --hard [COMMIT_HASH]
git push --force
```
> ⚠️ `git reset --hard` is destructive — all changes after the target commit are permanently lost. Only use for genuine recovery.

### Clone vault to a new machine
```bash
git clone https://github.com/[GITHUB_USERNAME]/[REPO_NAME].git [VAULT_PATH]
```
Then open the cloned folder as an Obsidian vault and reinstall plugins.

---

## Troubleshooting

### Push rejected: file exceeds 100MB

GitHub rejects files over 100MB. The file is already in commit history so the `.gitignore` fix alone won't help — history must be rewritten.

**Step 1:** Note the filename from the error message.

**Step 2:** Add the file pattern to `.gitignore` (Claude can do this).

**Step 3:** Stage any uncommitted changes first:
```bash
cd [VAULT_PATH]
git stash
```

**Step 4:** Rewrite history to remove the file:
```bash
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch "PATH/TO/LARGE/FILE"' \
  --prune-empty --tag-name-filter cat -- --all
```

**Step 5:** Restore stashed changes:
```bash
git stash pop
```
If stash pop fails with `fatal: 'refs/stash@{0}' is not a stash-like commit` — the stash was rewritten along with history. This is harmless; the changes it held were minor (cursor positions, etc.). Just continue.

**Step 6:** Force push:
```bash
git push -u origin main --force
```

### Authentication failure on push

GitHub no longer accepts password authentication. Use a **Personal Access Token** instead:

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with `repo` scope
3. When git prompts for password, enter the token instead

### "Git is not ready" in Obsidian Git settings

1. Run `which git` in terminal — note the full path
2. Obsidian Git settings → Advanced → Custom Git binary path → enter the full path
3. Click Reload, or restart Obsidian fully if Reload doesn't help

### Obsidian Git not auto-committing

Check that:
- Auto commit-and-sync interval is set to `5` (not `0`)
- The plugin is enabled (Settings → Community Plugins)
- "Git is not ready" is not showing in settings
