#!/bin/bash
# update_seed.sh — Download or update the DataWizard Seed from GitHub
# Lives in _DataWizard/Seed/Scripts/ but works from anywhere.
# Usage: bash update_seed.sh [--vault /path/to/vault]
#
# If run from within the Seed, auto-detects vault root.
# If run standalone (e.g. first install), pass --vault explicitly.
#
# Exit codes: 0 = updated, 1 = error, 2 = already current

set -euo pipefail

REPO_URL="https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip"
TMP_DIR="/tmp/dw-seed-update"
TMP_ZIP="/tmp/dw-seed.zip"

# --- Determine vault root ---
VAULT_ROOT=""

# Check for --vault flag
while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault)
      VAULT_ROOT="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Auto-detect from script location if not specified
if [ -z "$VAULT_ROOT" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # Script lives at _DataWizard/Seed/update_seed.sh
  # Vault root is 2 levels up
  VAULT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

SEED_DIR="$VAULT_ROOT/_DataWizard/Seed"
SYNC_LOG="$VAULT_ROOT/_DataWizard/Seed Sync Log.md"

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
      "Reverse-chronological log of Seed sync events. Written automatically by update_seed.sh and visible in Obsidian." \
      "" \
      "---" \
      "" > "$SYNC_LOG"
  fi

  # Prepend entry after the --- separator (after frontmatter/header)
  # We append to the end for simplicity (newest at bottom)
  echo "**$timestamp** — $message" >> "$SYNC_LOG"
  echo "$message"
}

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

# --- Download from GitHub ---
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
  echo "     Source: $SEED_DIR/Project Instructions - Copy-Paste into Claude.md"
  echo "  2. (Optional) Set up auto-sync — see below."
else
  log_entry "Updated: Seed $OLD_VERSION -> $NEW_VERSION, PI $OLD_PI -> $NEW_PI."

  # PI change notification
  if [ "$OLD_PI" != "$NEW_PI" ]; then
    log_entry "ACTION REQUIRED: PI version changed ($OLD_PI -> $NEW_PI). Re-paste Project Instructions into Claude project settings."
    echo ""
    echo "!!! PROJECT INSTRUCTIONS CHANGED !!!"
    echo "Re-paste from: $SEED_DIR/Project Instructions - Copy-Paste into Claude.md"
  fi
fi

echo ""
echo "Seed updated successfully at $SEED_DIR"
