#!/bin/bash
# datawizard-sync.sh — syncs all collaborative project repos via git
# Reads repo paths from ~/.datawizard-sync.conf (one path per line)
# Manual use: bind to hotkey via Obsidian Shell Commands plugin
# Safety net: schedule via launchd every 4 hours
# See datawizard-sync-setup.md for installation instructions.

LOGFILE="$HOME/.datawizard-sync.log"
CONF="$HOME/.datawizard-sync.conf"

# Check for config
if [ ! -f "$CONF" ]; then
  osascript -e "display notification \"No config found. Create ~/.datawizard-sync.conf\" with title \"DW Sync Error\" sound name \"Basso\"" 2>/dev/null
  echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: No config file at $CONF" >> "$LOGFILE"
  exit 1
fi

# Read project paths from config
PROJECTS=()
while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  PROJECTS+=("$line")
done < "$CONF"

if [ ${#PROJECTS[@]} -eq 0 ]; then
  osascript -e "display notification \"Config file is empty. Add repo paths to ~/.datawizard-sync.conf\" with title \"DW Sync Error\" sound name \"Basso\"" 2>/dev/null
  exit 1
fi

CHANGES=0
ERRORS=0
SYNCED_NAMES=""

for DIR in "${PROJECTS[@]}"; do
  NAME=$(basename "$DIR")
  cd "$DIR" || { echo "$(date '+%Y-%m-%d %H:%M:%S') SKIP $DIR (not found)" >> "$LOGFILE"; ERRORS=$((ERRORS+1)); continue; }

  git add .
  if ! git diff --cached --quiet; then
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    git commit -m "auto-sync $TIMESTAMP on $(hostname -s)" >> "$LOGFILE" 2>&1
    CHANGES=$((CHANGES+1))
    SYNCED_NAMES="$SYNCED_NAMES $NAME,"
  fi

  git pull --rebase >> "$LOGFILE" 2>&1
  if [ $? -ne 0 ]; then
    ERRORS=$((ERRORS+1))
    osascript -e "display notification \"Sync conflict in $NAME. Open terminal to resolve.\" with title \"DW Sync Error\" sound name \"Basso\"" 2>/dev/null
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR pull failed in $DIR" >> "$LOGFILE"
    continue
  fi

  git push >> "$LOGFILE" 2>&1
  if [ $? -ne 0 ]; then
    ERRORS=$((ERRORS+1))
    osascript -e "display notification \"Push failed in $NAME. Check your connection.\" with title \"DW Sync Error\" sound name \"Basso\"" 2>/dev/null
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR push failed in $DIR" >> "$LOGFILE"
  fi
done

# Notifications
if [ $ERRORS -gt 0 ] && [ $CHANGES -eq 0 ]; then
  : # error notifications already sent above
elif [ $CHANGES -gt 0 ] && [ $ERRORS -eq 0 ]; then
  SYNCED_NAMES=$(echo "$SYNCED_NAMES" | sed 's/,$//' | sed 's/^ //')
  osascript -e "display notification \"$SYNCED_NAMES\" with title \"DW Saved\" sound name \"Pop\"" 2>/dev/null
elif [ $CHANGES -eq 0 ] && [ $ERRORS -eq 0 ]; then
  osascript -e "display notification \"Everything up to date\" with title \"DW Sync\"" 2>/dev/null
fi
