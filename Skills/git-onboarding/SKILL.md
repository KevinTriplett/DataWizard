---
name: git-onboarding
description: >-
  Use when onboarding a new collaborator to a git-synced vault or DW project.
  Triggers on: 'set up git for [person]', 'onboard [person] to the repo', 'write
  a git onboarding guide', 'new team member needs git access', or any context
  where a collaborator needs git setup and project orientation.
type: skill
version: '1.1'
updated: '2026-06-14'
edit_log:
  - DW-S184 2026-06-14 - repointed Git Registry ref to 0.6 Registry
---

# Git Onboarding Skill

## Overview

Walks a new collaborator through git setup for an Obsidian vault or DW project. Generates a project-specific onboarding guide and interactively guides the human through each step with check-ins.

Uses the consolidated Git Guide (`Seed/Guides/Git Guide.md` and its sections in `Seed/Guides/Git Guide/`) as the reference. This skill adds the interactive layer: gathering user-specific variables, checking in after each step, handling errors, and customizing for the specific project.

## When to Use

- A new team member needs git access to a shared project
- Someone is setting up vault backup for the first time
- User says "set up git for [person]," "onboard [person] to the repo," "write a git onboarding guide for [person]"
- A new project needs git and the collaborators need setup instructions
- User asks to connect their vault to GitHub

### When NOT to Use

- The collaborator is already set up and just needs a workflow reminder (point them to the Git Guide directly)
- Setting up the DW Seed repo only (point to Git Guide Section 4)
- Debugging a git issue on an already-configured setup (point to Git Guide Section 9)

## Before You Start

1. Read this skill fully
2. Read the Git Guide shell (`Seed/Guides/Git Guide.md`) for the section overview
3. Read the project's 0.0 Project Guidelines (for folder structure, working conventions, repo info)
4. Check the 0.6 Registry (Git Repositories section) for existing repo details
5. If an onboarding guide already exists for this project, read it to understand what's been done

## Gather Variables

Before starting the walkthrough, collect these from the user:

| Variable | Example | Notes |
|---|---|---|
| Collaborator name | Jay Cousins | For the guide title and git author config |
| Collaborator's GitHub username | jaycousins | Needed for repo access |
| Collaborator's email | jay@example.com | For git identity config |
| Collaborator's OS | macOS / Windows | Determines platform-specific instructions |
| Project name | Weave | For the guide title and folder references |
| Repo URL | github.com/KevinTriplett/project_weave | From Git Registry or user |
| Repo owner | Kevin | Who grants collaborator access |
| Access method | SSH / HTTPS | SSH recommended; ask if they have a preference |
| Clone location | ~/Documents/Weave | Where on their machine the repo will live |

If the user doesn't know some of these, help them figure it out. The repo URL and owner are usually in the Git Registry.

## Walkthrough Flow

Work through these phases in order. At each **Check in** point, pause and confirm with the user (or the collaborator directly if they're present) before continuing.

### Phase 1: Repo Access

1. Confirm the repo exists and identify the owner (check Git Registry)
2. Tell the user: the repo owner needs to add the collaborator as a collaborator on GitHub (repo > Settings > Collaborators > Add people > their GitHub username)
3. The collaborator will receive an email invitation to accept

**Check in:** Confirm collaborator has been invited and has accepted.

### Phase 2: Prerequisites

Walk through Git Guide Section 1.0 (Prerequisites and Install):

1. Confirm git is installed (platform-appropriate instructions)
2. Set git identity (`git config --global user.name` / `user.email`)
3. Optionally install GitHub CLI

**Check in:** Confirm git is installed and identity is set.

### Phase 3: Clone and Open

1. Generate the clone command with the collected variables:
   - SSH: `git clone git@github.com:owner/repo.git "/clone/location"`
   - HTTPS: `git clone https://github.com/owner/repo.git "/clone/location"`
2. Instruct them to open the cloned folder as an Obsidian vault
3. If SSH: walk through key setup (Git Guide Section 2.0, SSH Keys subsection)

**Check in:** Confirm the vault is open in Obsidian and files are visible.

### Phase 4: Plugin Setup

Walk through Git Guide Section 3.0 (Obsidian Git Plugin):

1. Install the Obsidian Git community plugin
2. Configure settings (use the table from Section 3.0, customized with their author name/email)
3. Fix git binary path if needed (common on Mac)
4. Enable File Recovery core plugin

**Check in:** Open the Command Palette (`Cmd+P`) and run `Git: Commit-and-sync`. Confirm it succeeds (you should see a notification). Don't set up the hotkey yet -- that's the next phase.

### Phase 5: DW Save Setup

DW Save is how you save your work in DataWizard -- one keystroke (Cmd+Shift+S on Mac, Ctrl+Shift+S on Windows) to commit and push everything to GitHub. This is the most important habit to build: hit DW Save when you finish a session, before a call, or anytime you want your work backed up and visible to collaborators.

Reference: Git Guide Section 5.5 (DW Save).

**Step 1: Choose your setup tier.**

Ask the collaborator:

> "Will you be working in just one project repo, or does your vault have multiple shared project folders that each sync to their own GitHub repo?"

- **Single Project** (most common): Uses the Obsidian Git plugin they just installed. No extra setup needed beyond the hotkey.
- **Multi-Project**: Uses an additional plugin (Shell Commands) and a sync script to push all repos at once. Follow the walkthrough in `Seed/Scripts/datawizard-sync-setup.md`.

For most new collaborators, Single Project is the right answer.

**Step 2: Set up the hotkey.**

For Single Project:
1. Settings > Hotkeys
2. Search for **Obsidian Git: Commit-and-sync**
3. Click the **+** icon, press **Cmd+Shift+S** (Mac) or **Ctrl+Shift+S** (Windows)

For Multi-Project: follow Steps 2-4 in `datawizard-sync-setup.md` (install Shell Commands plugin, copy script, configure hotkey).

**Step 3: Choose your backup schedule.**

Ask the collaborator:

> "DW Save is your main way of saving -- you press it when you're done with a session or at a natural stopping point. There's also an auto-backup that runs in the background as a safety net, in case you forget. It runs on a longer cycle so it's not pushing half-finished work every few minutes. How often do you want the safety net to run? Common choices are every 15 minutes for active collaboration, or every 30-60 minutes if you're mostly working solo."

For Single Project: Set the **Auto commit-and-sync interval** in Settings > Community Plugins > Git (gear icon) to their chosen interval.

For Multi-Project: Adjust the `StartInterval` value in the launchd plist (see `datawizard-sync-setup.md` Step 5).

**Step 4: Test DW Save end-to-end.**

This is not optional -- always test before moving on.

1. Have the collaborator create a test note called `_test-dw-save.md` with any content
2. Tell them: "Hit Cmd+Shift+S now"
3. Confirm they see a success notification
4. Verify the file appears on GitHub (or that another team member can see it)
5. Delete the test note
6. Hit Cmd+Shift+S again to push the deletion
7. Confirm the test note is gone from GitHub

**Check in:** Confirm DW Save works and the collaborator understands the workflow: "DW Save at breakpoints, auto-backup catches the rest."

If DW Save does nothing when they press the hotkey, check that the relevant plugin (Obsidian Git or Shell Commands) is enabled under Settings > Community Plugins. Hard restarts can toggle plugins off.

### Phase 6: Generate the Onboarding Guide

Write a project-specific onboarding guide to the project's workflows folder. The guide should include:

1. **Why git** -- brief context (if replacing Relay or another sync method, explain why)
2. **What's in the vault** -- folder structure and key locations from the project's 0.0
3. **Setup summary** -- condensed version of what they just did (for reference if they need to set up on another machine)
4. **DW Save** -- how to save (Cmd+Shift+S), what it does, their chosen backup schedule, and what to do if it stops working (check plugin is enabled). Reference Git Guide Section 5.5
5. **Daily workflow** -- from Git Guide Section 5.0, customized with project-specific examples
6. **Merge conflicts** -- from Git Guide Section 5.0
7. **Quick reference** -- key commands table
8. **Working conventions** -- project-specific rules from the 0.0
9. **Safety and recovery** -- pointer to Git Guide Sections 7-8 for full reference, plus the most critical commands inline

**Guide location:** `[Project Workflows Folder]/Git Onboarding Guide - [Name].md`

**Guide frontmatter:**

```yaml
title: "Git Onboarding Guide - [Name]"
type: workflow
for: "[Collaborator Name]"
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: active
```

### Phase 7: Orientation

Brief the collaborator on project-specific context:

- Where to find the session log and action items
- Which files/folders are most relevant to their role
- Any OPSEC or sensitivity rules from the 0.0
- Who to ask if they have questions

## Output

Two deliverables:

1. **A configured collaborator** -- git installed, repo cloned, plugin running, test sync confirmed
2. **A project-specific onboarding guide** -- written to the project's workflows folder, serves as their ongoing reference

## Common Mistakes

- **Skipping the test sync.** Always verify the round-trip before declaring setup complete.
- **Forgetting the git binary path on Mac.** This is the most common cause of "Git is not ready" in the plugin. Always check it.
- **Writing a generic guide.** The onboarding guide should reference specific folders, documents, and conventions from the project's 0.0. A generic guide is what the Git Guide itself is for.
- **Not checking the Git Registry.** The registry has the repo URL, owner, branch, and setup pattern. Don't make the user look it up.
- **Assuming SSH is set up.** Many non-technical collaborators won't have SSH keys. HTTPS with a personal access token is a valid alternative -- don't force SSH if it's causing friction.
- **Skipping the DW Save test.** The hotkey is the collaborator's primary interaction with git. If it doesn't work, nothing else matters. Always test it live and make sure they see the notification before moving on.
- **Not explaining the two-layer model.** Collaborators need to understand that DW Save is their intentional save and auto-backup is the safety net. Without this context, they either never manually save (relying on auto-backup to push incomplete work) or set auto-backup too aggressively.

## Reference Implementation

See `_Weave Project Repo/Weave Workflows/Git Onboarding Guide - Jay.md` for a comprehensive project-specific example.
