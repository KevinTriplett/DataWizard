---
created: 2026-04-24
updated: 2026-04-24
type: guide
scope: seed
---

# DataWizard Sync Setup Guide

This guide walks you through setting up `datawizard-sync.sh` -- the script that syncs collaborative project repos (like ReWoven, Weave) via git. It replaces Obsidian Relay with direct git sync through GitHub.

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
# DataWizard collaborative project repos
# Add one absolute path per line

# Example:
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

## Step 3: Test It

```bash
bash ~/Scripts/datawizard-sync.sh
```

You should see a macOS notification: either "DW Saved" with project names, "Everything up to date," or an error message.

## Step 4: Set Up the Hotkey (Cmd+Shift+S)

This lets you "save" your work to git from inside Obsidian.

1. In Obsidian, go to Settings > Community Plugins > Browse
2. Search for **Shell commands** > Install > Enable
3. Go to Settings > Shell commands > New command
4. Paste: `bash ~/Scripts/datawizard-sync.sh`
5. Set the alias to: `DW Save`
6. Close that panel, go to Settings > Hotkeys
7. Search for `DW Save`
8. Set the hotkey to **Cmd+Shift+S**

Now Cmd+Shift+S in Obsidian = save + push + notification.

## Step 5: Set Up the Safety Net (Optional)

This runs the sync automatically every 4 hours as a background safety net, catching anything you forgot to manually save.

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
    <integer>14400</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/datawizard-sync.err</string>
</dict>
</plist>
EOF
```

**Important:** Replace `YOURUSERNAME` in the plist with your actual macOS username.

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

## Step 6: Terminal Alias (Optional)

For quick manual syncs from terminal:

```bash
echo 'alias dwsync="bash ~/Scripts/datawizard-sync.sh"' >> ~/.zshrc
source ~/.zshrc
```

Then just type `dwsync` anytime.

## Notifications

- **"DW Saved"** + project names + Pop sound -- you pushed changes successfully
- **"Everything up to date"** -- nothing new to sync
- **"DW Sync Error"** + details + Basso sound -- something went wrong, check the log

## Troubleshooting

The log file lives at `~/.datawizard-sync.log`. Check it for details on any failures:

```bash
tail -20 ~/.datawizard-sync.log
```

Common issues:
- **"Sync conflict"**: You and a collaborator edited the same file between syncs. Open terminal, cd into the repo, and run `git status` to see what conflicted. Resolve manually, then `git add .`, `git rebase --continue`, `git push`.
- **"Push failed"**: Usually a network issue or expired auth token. Try `gh auth status` to check.
- **"not found"**: A path in your config file doesn't exist. Check `~/.datawizard-sync.conf`.

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
git rebase --continue
git push
```

In practice, conflicts should be rare. The shell + sections architecture means collaborators are usually in different files even when working on the same document. If you are on a call together, just say "I am editing X, hold off on that one."

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

## For Claude Instances

If a user asks you to help set up sync for a new project, the steps are:
1. Initialize git in the shared project folder
2. Create the GitHub repo and push
3. Add the repo path to `~/.datawizard-sync.conf`
4. Exclude the folder from the vault-level `.gitignore`
5. Test with `dwsync` or `bash ~/Scripts/datawizard-sync.sh`
