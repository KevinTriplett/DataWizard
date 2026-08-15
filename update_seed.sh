#!/bin/bash
# update_seed.sh — Download or update the DataWizard Seed from GitHub
# Lives in _DataWizard/Seed/ (project root) and works from anywhere.
#
# Usage:
#   bash update_seed.sh [--vault /path/to/vault]
#   bash update_seed.sh --install-autosync [--hour N] [--vault /path]
#   bash update_seed.sh --uninstall-autosync
#
# If run from within the Seed, auto-detects vault root.
# If run standalone (e.g. first install), pass --vault explicitly.
#
# --install-autosync (macOS only) installs a launchd agent that runs this
# script daily at --hour (default 6:00) AND at every login. launchd runs a
# missed calendar job once on wake from sleep; the login trigger covers a
# machine that was powered off at the scheduled hour. The machine does NOT
# need to be awake at the scheduled time to stay in sync.
#
# If the Seed is a git clone (Seed/.git exists), sync uses git fetch +
# fast-forward merge instead of the zip download, and refuses to touch a
# working tree with local changes or local commits.
#
# The Seed maintainer's machine must never auto-sync (upstream pushes,
# everyone else pulls). Guard: a `seed_role` row containing `upstream` in
# the vault's Vault Config.md blocks --install-autosync and sync runs.
#
# Exit codes: 0 = updated/ok, 1 = error, 2 = already current,
#             3 = skipped (local git changes or upstream guard)

set -euo pipefail

REPO_URL="https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip"
TMP_DIR="/tmp/dw-seed-update"
TMP_ZIP="/tmp/dw-seed.zip"
AGENT_LABEL="com.datawizard.seed-update"
PLIST_PATH="$HOME/Library/LaunchAgents/$AGENT_LABEL.plist"

# --- Parse arguments ---
VAULT_ROOT=""
INSTALL_AUTOSYNC=false
UNINSTALL_AUTOSYNC=false
SYNC_HOUR=6

while [ $# -gt 0 ]; do
  case "$1" in
    --vault)
      VAULT_ROOT="$2"
      shift 2
      ;;
    --install-autosync)
      INSTALL_AUTOSYNC=true
      shift
      ;;
    --uninstall-autosync)
      UNINSTALL_AUTOSYNC=true
      shift
      ;;
    --hour)
      SYNC_HOUR="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# --- Determine vault root ---
if [ -z "$VAULT_ROOT" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # Script lives at _DataWizard/Seed/update_seed.sh
  # Vault root is 2 levels up
  VAULT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

SEED_DIR="$VAULT_ROOT/_DataWizard/Seed"
SYNC_LOG="$VAULT_ROOT/_DataWizard/Seed Sync Log.md"
VAULT_CONFIG="$SEED_DIR/Vault Config.md"

log_entry() {
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local message="$1"

  # Create sync log if it doesn't exist
  if [ ! -f "$SYNC_LOG" ]; then
    local today
    today=$(date '+%Y-%m-%d')
    printf '%s\n' \
      "---" \
      "title: Seed Sync Log" \
      "type: project-doc" \
      "created: $today" \
      "updated: $today" \
      "---" \
      "" \
      "# Seed Sync Log" \
      "" \
      "Reverse-chronological log of Seed sync events. Written automatically by update_seed.sh / update_seed.ps1 and visible in Obsidian." \
      "" \
      "---" \
      "" > "$SYNC_LOG"
  fi

  echo "**$timestamp** — $message" >> "$SYNC_LOG"
  echo "$message"
}

# --- Upstream guard ---
# The maintainer's Seed is the upstream source; auto-syncing it would
# overwrite local edits with the last push. Detect via Vault Config.md.
is_upstream() {
  [ -f "$VAULT_CONFIG" ] && grep -qi 'seed_role.*upstream' "$VAULT_CONFIG"
}

# --- Uninstall autosync ---
if [ "$UNINSTALL_AUTOSYNC" = true ]; then
  if [ "$(uname)" != "Darwin" ]; then
    echo "--uninstall-autosync is macOS-only. On Windows use: update_seed.ps1 -UninstallAutosync"
    exit 1
  fi
  launchctl bootout "gui/$(id -u)/$AGENT_LABEL" 2>/dev/null || \
    launchctl remove "$AGENT_LABEL" 2>/dev/null || true
  rm -f "$PLIST_PATH"
  log_entry "Auto-sync uninstalled (launchd agent $AGENT_LABEL removed)."
  exit 0
fi

# --- Install autosync ---
if [ "$INSTALL_AUTOSYNC" = true ]; then
  if [ "$(uname)" != "Darwin" ]; then
    echo "--install-autosync is macOS-only (launchd)."
    echo "  Windows: powershell -ExecutionPolicy Bypass -File update_seed.ps1 -InstallAutosync"
    echo "  Linux:   add a cron entry, e.g.:"
    echo "           0 6 * * * /bin/bash \"$SEED_DIR/update_seed.sh\" --vault \"$VAULT_ROOT\""
    exit 1
  fi

  if is_upstream; then
    log_entry "REFUSED: --install-autosync blocked. Vault Config marks this machine as the Seed upstream (seed_role: upstream). The maintainer pushes; auto-sync would overwrite local edits."
    exit 3
  fi

  case "$SYNC_HOUR" in
    ''|*[!0-9]*)
      echo "ERROR: --hour must be a number 0-23 (got: $SYNC_HOUR)"
      exit 1
      ;;
  esac
  if [ "$SYNC_HOUR" -gt 23 ]; then
    echo "ERROR: --hour must be 0-23 (got: $SYNC_HOUR)"
    exit 1
  fi

  mkdir -p "$HOME/Library/LaunchAgents"
  cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$AGENT_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SEED_DIR/update_seed.sh</string>
        <string>--vault</string>
        <string>$VAULT_ROOT</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>$SYNC_HOUR</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/datawizard-seed-update.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/datawizard-seed-update.err</string>
</dict>
</plist>
PLIST

  # (Re)load the agent: bootout any old copy, then bootstrap (modern) with
  # legacy load as fallback for older macOS.
  launchctl bootout "gui/$(id -u)/$AGENT_LABEL" 2>/dev/null || true
  if ! launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH" 2>/dev/null; then
    launchctl load "$PLIST_PATH" 2>/dev/null || true
  fi

  # Verify it registered
  if launchctl print "gui/$(id -u)/$AGENT_LABEL" >/dev/null 2>&1 || \
     launchctl list 2>/dev/null | grep -q "$AGENT_LABEL"; then
    log_entry "Auto-sync installed: daily at $(printf '%02d' "$SYNC_HOUR"):00 + at login, with catch-up on wake ($AGENT_LABEL)."
    echo ""
    echo "Note: RunAtLoad means the first sync runs right now (that's expected)."
    echo "To remove later: bash update_seed.sh --uninstall-autosync"
    exit 0
  else
    log_entry "ERROR: Auto-sync plist written to $PLIST_PATH but the launchd agent did not register. Try logging out and back in, then run: launchctl list | grep datawizard"
    exit 1
  fi
fi

# --- Sync run below this point ---

if is_upstream; then
  log_entry "SKIPPED: sync refused on the upstream (maintainer) machine per Vault Config seed_role."
  exit 3
fi

# --- Capture current version (if Seed exists) ---
OLD_VERSION=""
OLD_PI=""
FRESH_INSTALL=false

if [ -f "$SEED_DIR/VERSION.md" ]; then
  OLD_VERSION=$(grep '^seed:' "$SEED_DIR/VERSION.md" | awk '{print $2}' || echo "unknown")
  OLD_PI=$(grep '^project_instructions:' "$SEED_DIR/VERSION.md" | awk '{print $2}' || echo "unknown")
else
  FRESH_INSTALL=true
fi

# --- Git mode: Seed is a git clone ---
if [ -d "$SEED_DIR/.git" ]; then
  if ! command -v git >/dev/null 2>&1; then
    log_entry "ERROR: Seed is a git clone but git is not installed."
    exit 1
  fi

  # Never clobber local work: skip if tracked files have local edits.
  # Untracked files (e.g. a user's Vault Config.md) are fine -- if one ever
  # collides with an incoming file, the ff-only merge below fails safely.
  if [ -n "$(git -C "$SEED_DIR" status --porcelain --untracked-files=no 2>/dev/null)" ]; then
    log_entry "SKIPPED: Seed git working tree has local edits to tracked files. Commit, stash, or discard them, then sync again."
    exit 3
  fi

  if ! git -C "$SEED_DIR" fetch origin main --quiet 2>/dev/null; then
    log_entry "ERROR: git fetch failed. Check network connection."
    exit 1
  fi

  # Skip if local commits are ahead of origin (likely a maintainer or a fork)
  AHEAD=$(git -C "$SEED_DIR" rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
  if [ "$AHEAD" -gt 0 ]; then
    log_entry "SKIPPED: Seed git clone has $AHEAD local commit(s) ahead of origin/main. Push or reconcile them manually."
    exit 3
  fi

  BEHIND=$(git -C "$SEED_DIR" rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
  if [ "$BEHIND" -eq 0 ]; then
    log_entry "Already current (git, Seed $OLD_VERSION, PI $OLD_PI). No update needed."
    exit 2
  fi

  if ! git -C "$SEED_DIR" merge --ff-only origin/main --quiet; then
    log_entry "ERROR: git fast-forward merge failed (divergent history?). See the Seed VERSION.md recovery notes; reset, don't merge."
    exit 1
  fi

  NEW_VERSION=$(grep '^seed:' "$SEED_DIR/VERSION.md" | awk '{print $2}' || echo "unknown")
  NEW_PI=$(grep '^project_instructions:' "$SEED_DIR/VERSION.md" | awk '{print $2}' || echo "unknown")

  log_entry "Updated via git: Seed $OLD_VERSION -> $NEW_VERSION, PI $OLD_PI -> $NEW_PI ($BEHIND commit(s))."

  if [ "$OLD_PI" != "$NEW_PI" ]; then
    log_entry "ACTION REQUIRED: PI version changed ($OLD_PI -> $NEW_PI). Re-paste Project Instructions into Claude project settings."
    echo ""
    echo "!!! PROJECT INSTRUCTIONS CHANGED !!!"
    echo "Re-paste from: $SEED_DIR/DataWizard Project Instructions.md"
  fi

  echo ""
  echo "Seed updated successfully at $SEED_DIR"
  exit 0
fi

# --- Zip mode: download from GitHub ---
echo "Downloading DataWizard Seed from GitHub..."
rm -rf "$TMP_DIR" "$TMP_ZIP"

if ! curl -sL "$REPO_URL" -o "$TMP_ZIP"; then
  log_entry "ERROR: Failed to download from GitHub. Check network connection."
  exit 1
fi

if ! unzip -qo "$TMP_ZIP" -d "$TMP_DIR"; then
  log_entry "ERROR: Failed to unzip download."
  rm -rf "$TMP_DIR" "$TMP_ZIP"
  exit 1
fi

# --- Compare versions before copying ---
NEW_VERSION=$(grep '^seed:' "$TMP_DIR/DataWizard-main/VERSION.md" | awk '{print $2}' || echo "unknown")
NEW_PI=$(grep '^project_instructions:' "$TMP_DIR/DataWizard-main/VERSION.md" | awk '{print $2}' || echo "unknown")

if [ "$FRESH_INSTALL" = false ] && [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
  log_entry "Already current (Seed $OLD_VERSION, PI $OLD_PI). No update needed."
  rm -rf "$TMP_DIR" "$TMP_ZIP"
  exit 2
fi

# --- Copy to Seed directory ---
# Trailing /. (not /*) so dotfiles like .gitignore are included
mkdir -p "$SEED_DIR"
cp -R "$TMP_DIR/DataWizard-main/." "$SEED_DIR/"

# --- Cleanup ---
rm -rf "$TMP_DIR" "$TMP_ZIP"

# --- Verify ---
if [ ! -f "$SEED_DIR/VERSION.md" ]; then
  log_entry "ERROR: Update appeared to succeed but VERSION.md not found. Check $SEED_DIR."
  exit 1
fi

# --- Log results ---
if [ "$FRESH_INSTALL" = true ]; then
  log_entry "Fresh install complete. Seed $NEW_VERSION, PI $NEW_PI."
  echo ""
  echo "Next steps:"
  echo "  1. Paste Project Instructions into your Claude project settings."
  echo "     Source: $SEED_DIR/DataWizard Project Instructions.md"
  echo "  2. (Recommended) Turn on daily auto-sync:"
  echo "     bash \"$SEED_DIR/update_seed.sh\" --install-autosync"
else
  log_entry "Updated: Seed $OLD_VERSION -> $NEW_VERSION, PI $OLD_PI -> $NEW_PI."

  # PI change notification
  if [ "$OLD_PI" != "$NEW_PI" ]; then
    log_entry "ACTION REQUIRED: PI version changed ($OLD_PI -> $NEW_PI). Re-paste Project Instructions into Claude project settings."
    echo ""
    echo "!!! PROJECT INSTRUCTIONS CHANGED !!!"
    echo "Re-paste from: $SEED_DIR/DataWizard Project Instructions.md"
  fi
fi

echo ""
echo "Seed updated successfully at $SEED_DIR"
