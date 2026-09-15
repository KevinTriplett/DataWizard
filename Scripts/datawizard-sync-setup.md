---
created: 2026-04-24
updated: 2026-09-06
type: guide
scope: seed
edit_log:
  - "DW-S227 2026-08-01 - Jay FR batch item b: scoped Windows platform note
    (Seed updates via update_seed.ps1; full DW Save PowerShell port flagged as
    future work)"
  - "DW-S253 2026-08-07 - Chunk 5: added commit-guard install step (Step 3) +
    LLM-list item + ~/Scripts re-copy note; points at Git Guide 10.0"
  - "DW-S337 2026-09-06 - FR items 1/2/4: Step 5 output-channel step +
    relaunch/verify (notification-permission-after-relaunch) + hotkey-combo
    verify; Step 4 cross-ref; Notifications fallback note; silent-notification
    troubleshooting entry"
---

# DataWizard Sync Setup Guide

> **This is the Multi-Project setup for DW Save.** For an overview of DW Save (what it is, Single vs Multi-Project, backup scheduling guidance), see Git Guide Section 5.5. This guide covers the Multi-Project path only -- use it when your vault contains multiple separate git repos that all need to sync with one keystroke.

This guide walks you through setting up `datawizard-sync.sh` -- the script that syncs your shared git repos via git. It replaces Obsidian Relay with direct git sync through GitHub. "Shared repos" means any repo inside your vault that pushes to GitHub -- collaborative projects (for example, a shared book or a team knowledge base) and the DW Seed itself.

## Platform note: this guide is macOS

`datawizard-sync.sh` is a bash script wired to macOS-specific pieces (launchd for scheduling, `osascript` for notifications, the Obsidian Shell commands hotkey). It is the multi-repo **DW Save** git flow, and it is currently Mac-only.

**On Windows:**

- **Seed updates** have a dedicated cross-platform path -- use `update_seed.ps1` (see the `Seed Install and Update` guide, Manual Update and Task Scheduler sections). Because the **zip is the canonical Seed distribution** for every platform, keeping the Seed current on Windows needs nothing from this guide.
- **Full DW Save (multi-repo git stage/commit/pull/push)** does not yet have a Windows equivalent. A PowerShell port of `datawizard-sync.sh` (Task Scheduler in place of launchd, toast notifications in place of `osascript`) is future work. Until then, Windows operators on shared git repos can use the **Obsidian Git** community plugin for per-repo auto-sync (same plugin path described in "Non-DW Collaborators" below).

The rest of this guide assumes macOS.

## What It Does

When triggered (manually or on a schedule), the script loops through your collaborative project repos and for each one: stages any changed files, commits them with a timestamp, pulls any changes your collaborators have pushed, and pushes your new commits to GitHub. You get a macOS notification telling you the result.

## Prerequisites

- Git installed (comes with macOS Xcode Command Line Tools)
- GitHub CLI (`gh`) installed: `brew install gh`
- GitHub account authenticated: `gh auth login`
- At least one collaborative project repo already cloned or initialized

## Step 1: Create the Config File

The script reads repo paths from `~/.datawizard-sync.conf`. Create this file with one repo path per line. Lines starting with `#` are comments.

```bash
cat > ~/.datawizard-sync.conf << 'EOF'
# DataWizard shared repos -- one absolute path per line
# Include the DW Seed AND any collaborative project repos.

# The Seed (always include this):
# /Users/yourname/Vaults/YourVault/_DataWizard/Seed

# Collaborative project repos:
# /Users/yourname/Vaults/YourVault/_ProjectName/Project Shared
EOF
```

Edit the file and add your actual repo paths:

```bash
nano ~/.datawizard-sync.conf
```

## Step 2: Copy the Script to Your Scripts Folder

Copy the script from Seed to wherever you keep your scripts, and make it executable:

```bash
# Create a scripts folder if you don't have one
mkdir -p ~/Scripts

# Copy from Seed (adjust vault path to match yours)
cp "/path/to/your/vault/_DataWizard/Seed/Scripts/datawizard-sync.sh" ~/Scripts/
chmod +x ~/Scripts/datawizard-sync.sh
```

> **Keep this copy current.** `datawizard-sync.sh` gets Seed updates, but this `~/Scripts/` copy does not update itself -- after any Seed update that changes `Scripts/datawizard-sync.sh`, re-run the `cp` above. To avoid the copy drifting at all, you can instead point your hotkey and launchd plist directly at the Seed copy (`.../_DataWizard/Seed/Scripts/datawizard-sync.sh`) and skip `~/Scripts/` entirely.

## Step 3: Install the Commit Guard (Per Repo)

The commit guard is a pre-commit hook that blocks a commit containing unresolved conflict markers or Windows-unsafe filenames, so corrupt content never syncs silently. Git hooks are not synced, so install it once **per repo** -- including the Seed itself -- and **re-run it after any Seed update that touches `Scripts/hooks/`** (the installer is idempotent):

```bash
bash "/path/to/your/vault/_DataWizard/Seed/Scripts/install-git-hooks.sh" "/path/to/your/repo"
```

Full behavior, the shared-team `core.hooksPath` alternative, and what a block looks like: see Git Guide Section 10.0 Commit Guards.

## Step 4: Test It

```bash
bash ~/Scripts/datawizard-sync.sh
```

You should see a macOS notification: either "DW Saved" with project names, "Everything up to date," or an error message.

If no banner appears here, don't treat it as broken yet -- macOS may not surface the notification until Obsidian has been relaunched once (see Step 5, step 12). Confirm the run's result in `~/.datawizard-sync.log`.

## Step 5: Set Up the Hotkey (Cmd+Shift+S)

This lets you "save" your work to git from inside Obsidian.

***Tip:** copy-paste these steps somewhere you can read them if opening the Settings panel hides them.*

1. In Obsidian, go to Settings > Community Plugins > Browse
2. Search for **Shell commands** > Install > Enable
3. Go to plugin Settings > Shell commands > New command
4. Paste: `bash ~/Scripts/datawizard-sync.sh`
5. Click the gear button
6. Set the alias to: `DW Save`
7. In the same gear settings modal, open the **Output** tab and set the **stdout** output channel to **Notification balloon**. It defaults to *Ignore*, so a fully successful save otherwise shows nothing in-app.
8. Close that panel, go to Settings > Hotkeys
9. Search for `DW Save`
10. Click the plus button and set the hotkey to **Cmd+Shift+S**. After capturing, double-check the combo reads exactly **Cmd+Shift+S**.
11. Close the Settings panel
12. **Relaunch Obsidian, then verify.** Fully quit and reopen Obsidian, then press your DW Save hotkey once. On macOS the notification permission registers only after a fresh Obsidian launch -- before the relaunch the "DW Saved" banner may not appear even though the save succeeded. After relaunching you should see a "DW Saved" or "Everything up to date" notice.

If you still see no notice, confirm the save landed before assuming failure: check `git log` in the repo or the repo page on GitHub. A silent notification path is not a failed save.

Now Cmd+Shift+S in Obsidian will: save + push + notification.

*Note for developers: [a fork of this plugin](https://github.com/kalliopeargentina/obsidian-shellcommands) enables keyring access for secrets like API keys and credentials.*

## Step 6: Set Up the Safety Net (Optional)

This runs the sync automatically every 2 hours as a background safety net, catching anything you forgot to manually save. Change the `<integer>7200</integer>` to change the amount of time (in seconds) between automatic syncs.

```bash
cat > ~/Library/LaunchAgents/com.datawizard.sync.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://purl.apple.com/dtds/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.datawizard.sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/YOURUSERNAME/Scripts/datawizard-sync.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>7200</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/datawizard-sync.err</string>
</dict>
</plist>
EOF
```

**Important:** Replace `YOURUSERNAME` in the plist with your actual macOS username. If copy-pasting from a chat interface, double-check the script path -- some tools convert filenames ending in `.sh` into clickable links, corrupting the path.

Load it:

```bash
launchctl load ~/Library/LaunchAgents/com.datawizard.sync.plist
```

Verify it's running:

```bash
launchctl list | grep datawizard
```

To stop it later:

```bash
launchctl unload ~/Library/LaunchAgents/com.datawizard.sync.plist
```

### Verifying the safety net is running

The safety net runs silently in the background. If the plist has a bad path or the script is missing, it fails silently -- no notification, no error visible to you. Periodically check that it's actually working:

```bash
# Is the agent loaded?
launchctl list | grep datawizard

# Any errors from the last run?
cat /tmp/datawizard-sync.err

# Recent sync activity?
tail -10 ~/.datawizard-sync.log
```

If `launchctl list` returns nothing, the agent isn't loaded. Reload it:

```bash
launchctl load ~/Library/LaunchAgents/com.datawizard.sync.plist
```

If the error log shows "not found" or "No such file," check that the script path in the plist matches the actual location of `datawizard-sync.sh`.

## Step 7: Terminal Alias (Optional)

For quick manual syncs from terminal:

```bash
echo 'alias dwsync="bash ~/Scripts/datawizard-sync.sh"' >> ~/.zshrc
source ~/.zshrc
```

Then just type `dwsync` anytime.

For more aliases, you can instead add `source "/path/to/your/vault/_DataWizard/Seed/Scripts/datawizard-aliases.sh"` inside `.zshrc` and gain the following shortcuts:
* dwsync: manual sync
* dwstop: stop auto-sync
* dwstart: start auto-sync
* dwstatus: check status of auto-sync
* dwlog: view last 20 lines of log for errors (see below)

## Notifications

- **"DW Saved"** + project names + Pop sound -- you pushed changes successfully
- **"Everything up to date"** -- nothing new to sync
- **"DW Sync Error"** + details + Basso sound -- something went wrong, check the log

If the banner still doesn't surface after an Obsidian relaunch, the in-app **Notification balloon** (Step 5) is the reliable channel since it doesn't depend on `osascript`. A system-level fallback such as `terminal-notifier` can be added but is optional.

## Troubleshooting

The log file lives at `~/.datawizard-sync.log`. Check it for details on any failures:

```bash
tail -20 ~/.datawizard-sync.log
```

Common issues:
- **"Sync conflict"**: You and a collaborator edited the same file between syncs. Open terminal, cd into the repo, and run `git status` to see what conflicted. Resolve manually (see Merge Conflicts below), then `git add .`, `git commit -m "resolve merge conflict"`, `git push`.
- **"Push failed"**: Usually a network issue or expired auth token. Try `gh auth status` to check.
- **"not found"**: A path in your config file doesn't exist. Check `~/.datawizard-sync.conf`.
- **No notification, but saves are landing**: the stdout output channel may still be set to *Ignore* (Step 5, step 7), or notifications haven't registered yet -- relaunch Obsidian (Step 5, step 12). Confirm via `git log` / GitHub; the save most likely succeeded.

## Merge Conflicts

A merge conflict happens when two people edit the same file between syncs. Git preserves both versions and marks the file:

```
<<<<<<< HEAD
Your version of the text
=======
The other person's version of the text
>>>>>>> origin/main
```

To resolve:

1. Open the conflicted file in Obsidian
2. Decide which version to keep (or combine both)
3. Delete the `<<<<<<<`, `=======`, and `>>>>>>>` markers
4. Save the file
5. In terminal, cd into the repo and run:

```bash
git add .
git commit -m "resolve merge conflict"
git push
```

In practice, conflicts should be rare. The shell + sections architecture means collaborators are usually in different files even when working on the same document. If you are on a call together, just say "I am editing X, hold off on that one."

You can also ask Claude to help you resolve the conflict, particularly if it's not obvious what needs to be revised.

## Rollback and Recovery

Git keeps full version history. You can restore any file to any previous state.

Restore a specific file:

```bash
cd "/path/to/your/repo"
git log --oneline -- "path/to/file.md"
git checkout <commit-hash> -- "path/to/file.md"
git add . && git commit -m "restored file from <commit-hash>"
git push
```

Restore the entire repo to a previous state (use with caution -- this rewrites history for all collaborators):

```bash
git log --oneline -10
git reset --hard <commit-hash>
git push --force
```

## Non-DW Collaborators

If a collaborator does not use DataWizard, they can sync using the Obsidian Git community plugin instead of this script. They clone the repo, open it as a standalone Obsidian vault, and configure the plugin for auto-sync. See the relevant project's onboarding doc for details.

## Instructions for LLM

If a user asks you to help set up sync for a new project, the steps are:
1. Initialize git in the shared project folder
2. Create the GitHub repo and push
3. Add the repo path to `~/.datawizard-sync.conf`
4. Exclude the folder from the vault-level `.gitignore`
5. Test with `dwsync` or `bash ~/Scripts/datawizard-sync.sh`
6. Install the commit guard in the new repo: `bash "<vault>/_DataWizard/Seed/Scripts/install-git-hooks.sh" "<repo>"` (re-run after any Seed `Scripts/hooks/` update). Details: Git Guide 10.0 Commit Guards.

Also verify the DW Seed path (`_DataWizard/Seed`) is in the config -- it's easy to add collaborative repos and forget the Seed itself.
