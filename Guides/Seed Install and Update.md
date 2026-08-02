---
title: Seed Install and Update
type: guide
created: '2026-06-11'
updated: '2026-08-01'
operator: Andrew
audience: Claude instances helping DataWizard users
purpose: >-
  Canonical guide for installing, manually updating, and auto-syncing the
  DataWizard Seed
edit_log:
  - DW-S168 2026-06-11
  - DW-S189 2026-06-18
  - "DW-S227 2026-08-01 - Jay FR batch item b: zip-as-canon distribution note;
    Windows update_seed.ps1 manual-update instructions + Task Scheduler
    auto-sync section"
  - "DW-S227 2026-08-01 - Jay FR batch item d: announcement norm added to
    Upstream Operator Note; note de-personalized (maintainer name removed)"
---
# Seed Install and Update

*For Claude instances helping DataWizard users install or update their Seed. Covers fresh install, manual updates, and automated sync setup.*

## Distribution model: zip is canonical

The **zip download is the canonical install and update path for every operator, on every platform.** All install/update commands and both update scripts (`update_seed.sh`, `update_seed.ps1`) pull the GitHub zip, not a git clone.

Git clones of the Seed are for **contributors only**. The Seed's history can be rewritten (for example, to purge an accidentally committed secret), which breaks a downstream clone's next `git pull` with an unrelated-histories error -- while the zip is unaffected. So: **operator path = zip** (the scripts below), **contributor path = git clone** (only if you intend to push changes back upstream).

---

## Step 1: Find the vault path

Run `obsidian:get_vault_stats` to confirm MCP is connected. Then run `obsidian:list_directory` with path `_DataWizard/Seed` to confirm the Seed exists.

If the Seed folder doesn't exist at all, skip to the Fresh Install section below.

## Step 2: Determine the platform

Ask your human: "Are you on Mac or Windows?" (Or check if you already know from context.)

---

## Fresh Install

If `_DataWizard/Seed` doesn't exist, the Seed was never installed.

### Mac

```bash
cd "/path/to/vault" && \
curl -sL https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip -o /tmp/dw-seed.zip && \
unzip -qo /tmp/dw-seed.zip -d /tmp/dw-seed && \
mkdir -p _DataWizard/Seed && \
cp -R /tmp/dw-seed/DataWizard-main/* _DataWizard/Seed/ && \
rm -rf /tmp/dw-seed /tmp/dw-seed.zip && \
echo "DataWizard Seed installed."
```

Replace `/path/to/vault/` with the actual vault path. If you have filesystem access, you can find it by checking where Obsidian MCP points.

### Windows (PowerShell)

```powershell
cd "C:\path\to\vault"
Invoke-WebRequest -Uri "https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip" -OutFile "$env:TEMP\dw-seed.zip"
Expand-Archive -Path "$env:TEMP\dw-seed.zip" -DestinationPath "$env:TEMP\dw-seed" -Force
if (!(Test-Path "_DataWizard\Seed")) { New-Item -ItemType Directory -Path "_DataWizard\Seed" -Force }
Copy-Item -Path "$env:TEMP\dw-seed\DataWizard-main\*" -Destination "_DataWizard\Seed\" -Recurse -Force
Remove-Item -Path "$env:TEMP\dw-seed.zip", "$env:TEMP\dw-seed" -Recurse -Force
Write-Host "DataWizard Seed installed."
```

After installing, the human also needs to paste Project Instructions into a Claude Project. Read `_DataWizard/Seed/DataWizard Project Instructions.md` and help them set it up. Without this step, the Seed files exist but Claude won't know the protocol.

For full setup (MCP connection, Weave repo access, etc.), see the `DataWizard Setup and Sync Checklist` in the Weave Workflows folder.

---

## Manual Update

If the Seed already exists, use `update_seed.sh`:

```bash
bash "/path/to/vault/_DataWizard/Seed/update_seed.sh"
```

The script auto-detects the vault path if run from within the Seed folder. It compares versions and only downloads if there's a newer version available.

If `update_seed.sh` doesn't exist (older install), use the curl command from the Fresh Install section above -- it handles both fresh installs and updates.

On Windows, use the PowerShell twin `update_seed.ps1` (same version-compare, sync-log, and PI-change behavior, same exit codes):

```powershell
powershell -ExecutionPolicy Bypass -File "C:\path\to\vault\_DataWizard\Seed\update_seed.ps1"
```

Like the bash script, it auto-detects the vault root when run from inside the Seed folder, and only downloads when a newer version is available. If `update_seed.ps1` doesn't exist (older install), use the PowerShell command from the Fresh Install section -- it handles both fresh installs and updates.

---

## Automated Sync (Mac only)

Once manual updates work, you can set up daily automatic syncing so the Seed stays current without human intervention.

### Path A: Already running datawizard-sync.sh

If the user already has a launchd agent running `datawizard-sync.sh` for git repo syncing, the Seed just needs to be included in their sync config.

1. Check if `~/.datawizard-sync.conf` exists. Ask the user to run:
   ```bash
   cat ~/.datawizard-sync.conf
   ```
2. Look for a line pointing to their `_DataWizard/Seed` folder (e.g. `/Users/username/Vaults/Regen Vault/_DataWizard/Seed`).
3. If the Seed path is missing, add it. Ask the user to run:
   ```bash
   echo "/path/to/vault/_DataWizard/Seed" >> ~/.datawizard-sync.conf
   ```
   Replace with their actual vault path.
4. Verify the launchd agent is loaded:
   ```bash
   launchctl list | grep datawizard
   ```
   Should show `com.datawizard.sync`. If not, they need to reload it.

Done. Their existing sync schedule now covers the Seed.

### Path B: Seed-only sync

For users who don't run `datawizard-sync.sh`, set up a standalone daily sync.

1. Test the script manually first:
   ```bash
   bash "/path/to/vault/_DataWizard/Seed/update_seed.sh"
   ```
   Should print "Already current" or "Seed updated successfully." Check for errors.

2. Create the launchd plist. Ask the user to run (replacing VAULT_PATH with their actual vault path):
   ```bash
   cat > ~/Library/LaunchAgents/com.datawizard.seed-update.plist << 'EOF'
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
     "http://purl.apple.com/dtds/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.datawizard.seed-update</string>
       <key>ProgramArguments</key>
       <array>
           <string>/bin/bash</string>
           <string>VAULT_PATH/_DataWizard/Seed/update_seed.sh</string>
       </array>
       <key>StartCalendarInterval</key>
       <dict>
           <key>Hour</key>
           <integer>6</integer>
           <key>Minute</key>
           <integer>0</integer>
       </dict>
       <key>RunAtLoad</key>
       <true/>
       <key>StandardErrorPath</key>
       <string>/tmp/datawizard-seed-update.err</string>
   </dict>
   </plist>
   EOF
   ```
   **Important:** The user must manually edit the file to replace `VAULT_PATH` with their actual vault path before loading.

3. Load it:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.datawizard.seed-update.plist
   ```

4. Verify:
   ```bash
   launchctl list | grep datawizard.seed
   ```
   Should show `com.datawizard.seed-update`.

The Seed will now sync daily at 6am and on login.

### Windows (Task Scheduler)

Windows uses Task Scheduler in place of launchd. This mirrors the Mac Path B (Seed-only daily sync) using `update_seed.ps1`.

1. Test the script manually first:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\path\to\vault\_DataWizard\Seed\update_seed.ps1"
   ```
   It should print "Already current..." or "Seed updated successfully...". Check for errors.

2. Register a scheduled task that runs it daily at 6am and at logon (edit the vault path first). Ask the user to run this once in PowerShell:
   ```powershell
   $vault  = "C:\path\to\vault"
   $script = Join-Path $vault "_DataWizard\Seed\update_seed.ps1"
   $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
   $triggers = @(
       (New-ScheduledTaskTrigger -Daily -At 6am),
       (New-ScheduledTaskTrigger -AtLogOn)
   )
   Register-ScheduledTask -TaskName "DataWizard Seed Update" -Action $action -Trigger $triggers -Description "Daily DataWizard Seed sync from GitHub"
   ```

3. Verify the task is registered:
   ```powershell
   Get-ScheduledTask -TaskName "DataWizard Seed Update"
   ```

4. (Optional) Run it once on demand to confirm it works end to end:
   ```powershell
   Start-ScheduledTask -TaskName "DataWizard Seed Update"
   ```

The Seed will now sync daily and at logon. Results are logged to `_DataWizard\Seed Sync Log.md`, the same log the Mac path writes.

> Note: this Windows recipe has not yet been validated on a live Windows machine -- confirm the first run against the Seed Sync Log before relying on the schedule.

---

## Verify

After any install or update, read `_DataWizard/Seed/VERSION.md` using `obsidian:read_note`. It contains the current `seed:`, `protocol:`, and `project_instructions:` versions. Tell the human what you see.

To check if automated sync is working over time, look for `_DataWizard/Seed Sync Log.md` in Obsidian. Each sync writes a timestamped entry. If the log exists and has recent entries, sync is running.

Claude instances now report `seed_version` in session log frontmatter (protocol 1.8). When scanning session logs, a stale `seed_version` value means that operator's Seed isn't current.

## Check Project Instructions

While verifying, check whether the human's Project Instructions version matches. The PI version is in the header of whatever instructions are pasted into their Claude Project settings (e.g. "DW Project Instructions v4.3"). If their running PI is older than what VERSION.md says, tell them:

> "Your Project Instructions are out of date. Copy the updated version from `_DataWizard/Seed/DataWizard Project Instructions.md` into your Claude Project settings."

---

## Upstream Operator Note

The Seed maintainer (whoever publishes the Seed to GitHub) does NOT run auto-sync. Their local Seed is the upstream source -- running `update_seed.sh` / `update_seed.ps1` would overwrite local edits with the last push to GitHub. This guide's install/update automation is for downstream operators only.

**Announcement norm.** After each Seed push, the maintainer posts a one-line announcement to the operator/team channel: the new `seed:` / `project_instructions:` versions and whether operators must re-paste Project Instructions. This is the push-side counterpart to the local-only version check instances run at orientation -- without it, operators have no signal that a new Seed shipped (both the zip and npx caches update silently).
