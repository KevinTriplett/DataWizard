---
title: DataWizard Seed Git Setup
type: guide
created: '2026-04-24'
updated: '2026-04-24'
---

# DataWizard Seed Git Setup

Connect your DataWizard Seed to the GitHub repo so you can pull updates with a single command. This guide covers both fresh installs and existing Seed folders.

## Prerequisites

- Git installed (run `xcode-select --install` in Terminal if you haven't already)
- GitHub CLI installed: `brew install gh` (install Homebrew first if needed: https://brew.sh)
- A GitHub account -- sign up at https://github.com if you don't have one
- Authenticate GitHub CLI: `gh auth login` (follow the prompts)

## Path A: Fresh Install (No Seed Yet)

If you don't have a Seed folder yet, clone the repo directly. This gives you the Seed and git connectivity in one step.

```bash
cd "/path/to/your/vault"
git clone https://github.com/andrewalan11/DataWizard.git "_DataWizard/Seed"
```

Replace `/path/to/your/vault` with your actual vault path. To find it: open Finder, navigate to your vault folder, press Cmd+Option+C to copy the full path.

You should see a new `_DataWizard/Seed/` folder in your vault with all the Seed files.

Skip to "Exclude from Parent Vault Git" below.

## Path B: Existing Seed (Already Installed)

If you already have a `_DataWizard/Seed/` folder from the zip install or a previous setup, you can connect it to git in place. This preserves any local changes while linking to the remote.

```bash
cd "/path/to/your/vault/_DataWizard/Seed"
git init
git branch -m master main
git remote add origin https://github.com/andrewalan11/DataWizard.git
git fetch origin main
git reset --hard origin/main
```

What this does:
- `git init` -- creates a git repo inside your existing Seed folder
- `git branch -m master main` -- renames the default branch to match GitHub's convention
- `git remote add origin` -- points to the DataWizard repo on GitHub
- `git fetch origin main` -- downloads the latest version
- `git reset --hard origin/main` -- syncs your local files to match the latest remote version

**Note:** `git reset --hard` will overwrite any local changes to Seed files. If you've customized any Seed files (which you normally shouldn't -- user-specific settings go in `Vault Config.md` which is excluded from git), back them up first.

## Exclude from Parent Vault Git

If your vault has its own git repo (for backups or other purposes), you need to tell it to ignore the Seed's nested repo. Otherwise git gets confused by a repo inside a repo.

```bash
echo "_DataWizard/Seed/" >> "/path/to/your/vault/.gitignore"
```

If the parent vault was already tracking the Seed folder, also run:

```bash
cd "/path/to/your/vault"
git rm -r --cached "_DataWizard/Seed/"
git commit -m "Stop tracking DataWizard Seed (now a nested repo)"
```

If your vault doesn't use git at all, skip this step.

## Pulling Updates

To get the latest Seed version at any time:

```bash
cd "/path/to/your/vault/_DataWizard/Seed"
git pull origin main
```

That's it. Your Seed files update to the latest version.

DataWizard also checks for updates automatically -- when you start a new conversation, Claude compares your local Seed version against GitHub and tells you if there's an update available.

## Optional: DW Save Integration

If you use DW Save (the Cmd+Shift+S sync shortcut), it can handle Seed updates as part of its sync cycle. See `_DataWizard/Seed/Scripts/datawizard-sync-setup.md` for setup details.

## Troubleshooting

**"fatal: not a git repository"** -- You're not in the right directory. Make sure you `cd` into the Seed folder, not the vault root or the `_DataWizard/` parent.

**"Permission denied"** -- Run `gh auth status` to check your GitHub authentication, then `gh auth login` to refresh if needed.

**"already exists and is not an empty directory"** (Path A only) -- You already have a Seed folder. Use Path B instead.

**Merge conflicts after pull** -- This shouldn't normally happen since you pull updates but don't push changes to the Seed repo. If it does, the safest fix is `git reset --hard origin/main` to sync back to the remote version.
