#!/bin/bash
# datawizard-sync.sh - syncs all collaborative project repos via git
# Reads repo paths from ~/.datawizard-sync.conf (one path per line)
# Manual use: bind to hotkey via Obsidian Shell Commands plugin
# Safety net: schedule via launchd every 2 hours
# See datawizard-sync-setup.md for installation instructions.
#
# Notifications go through notify() below: macOS desktop notifications via
# osascript when available, otherwise the message is written to the log so
# results are never silently lost on a non-macOS shell.

LOGFILE="$HOME/.datawizard-sync.log"
CONF="$HOME/.datawizard-sync.conf"

# notify TITLE MESSAGE [SOUND]
# macOS: desktop notification via osascript. Other platforms: log the message.
# osascript is macOS-only; without this guard the calls failed silently off-Mac.
notify() {
  local title="$1"
  local message="$2"
  local sound="${3:-}"
  if command -v osascript >/dev/null 2>&1; then
    if [ -n "$sound" ]; then
      osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null
    else
      osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null
    fi
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') NOTIFY [$title] $message" >> "$LOGFILE"
  fi
}

# --- Single-instance run guard (prevents overlapping syncs -> stale index.lock) ---
# macOS ships no flock, so use an atomic mkdir as a mutex. A PID file lets a later
# run reclaim the lock if an earlier run died without cleaning up (the EXIT trap
# does not fire on SIGKILL or power loss). RUNLOCK_MAX_AGE also reclaims if the
# recorded PID was reused by an unrelated process after a reboot. (kill -0 can
# report a PID owned by another user as "alive" via EPERM; harmless on a
# single-user Mac, and the age ceiling is the backstop regardless.)
RUNLOCK="$HOME/.datawizard-sync.lock.d"
RUNLOCK_MAX_AGE=1800   # seconds (30 min) - ~60x a normal run
if ! mkdir "$RUNLOCK" 2>/dev/null; then
  OWNER_PID=$(cat "$RUNLOCK/pid" 2>/dev/null)
  LOCK_MTIME=$(stat -c %Y "$RUNLOCK" 2>/dev/null || stat -f %m "$RUNLOCK" 2>/dev/null || echo 0)
  case "$LOCK_MTIME" in ''|*[!0-9]*) LOCK_MTIME=0 ;; esac
  LOCK_AGE=$(( $(date +%s) - LOCK_MTIME ))
  if { [ -n "$OWNER_PID" ] && ! kill -0 "$OWNER_PID" 2>/dev/null; } || [ "$LOCK_AGE" -gt "$RUNLOCK_MAX_AGE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Reclaiming stale run-lock (PID ${OWNER_PID:-none}, age ${LOCK_AGE}s)" >> "$LOGFILE"
    rm -rf "$RUNLOCK"
    mkdir "$RUNLOCK" 2>/dev/null || { echo "$(date '+%Y-%m-%d %H:%M:%S') SKIP: could not acquire run-lock" >> "$LOGFILE"; exit 0; }
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') SKIP: another sync run already in progress (PID ${OWNER_PID:-unknown})" >> "$LOGFILE"
    notify "DW Sync" "Sync already in progress - try again shortly"
    exit 0
  fi
fi
echo $$ > "$RUNLOCK/pid"
sleep 1
if [ "$(cat "$RUNLOCK/pid" 2>/dev/null)" != "$$" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') SKIP: lost run-lock claim race" >> "$LOGFILE"
  exit 0
fi
# Ownership-checked trap: only remove the lock if we still own it, so an
# age-ceiling-reclaimed predecessor cannot delete the successor's lock on exit.
trap '[ "$(cat "$RUNLOCK/pid" 2>/dev/null)" = "$$" ] && rm -rf "$RUNLOCK"' EXIT
# --------------------------------------------------------------------------------

# Check for config
if [ ! -f "$CONF" ]; then
  notify "DW Sync Error" "No config found. Create ~/.datawizard-sync.conf" "Basso"
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
  notify "DW Sync Error" "Config file is empty. Add repo paths to ~/.datawizard-sync.conf" "Basso"
  exit 1
fi

CHANGES=0
ERRORS=0
SYNCED_NAMES=""

for DIR in "${PROJECTS[@]}"; do
  NAME=$(basename "$DIR")
  cd "$DIR" || { echo "$(date '+%Y-%m-%d %H:%M:%S') SKIP $DIR (not found)" >> "$LOGFILE"; ERRORS=$((ERRORS+1)); continue; }

  # --- Self-heal: clear a stale git index.lock from an interrupted prior run ---
  # Safe because the run guard above serializes sync runs, so any lock present
  # here is from a dead run or an external git process, never a sibling sync.
  LOCKFILE="$DIR/.git/index.lock"
  if [ -e "$LOCKFILE" ]; then
    LOCK_MTIME=$(stat -c %Y "$LOCKFILE" 2>/dev/null || stat -f %m "$LOCKFILE" 2>/dev/null || echo 0)
    case "$LOCK_MTIME" in ''|*[!0-9]*) LOCK_MTIME=0 ;; esac
    LOCK_AGE=$(( $(date +%s) - LOCK_MTIME ))
    if [ "$LOCK_AGE" -gt 120 ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') Cleared stale index.lock in $NAME (age ${LOCK_AGE}s)" >> "$LOGFILE"
      rm -f "$LOCKFILE"
    else
      echo "$(date '+%Y-%m-%d %H:%M:%S') SKIP $NAME: fresh index.lock (age ${LOCK_AGE}s), git may be active" >> "$LOGFILE"
      continue
    fi
  fi
  # ----------------------------------------------------------------------------

  # Branch guard: only sync repos on main
  BRANCH=$(git branch --show-current)
  if [ "$BRANCH" != "main" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') SKIPPED $NAME -- on branch '$BRANCH', not main" >> "$LOGFILE"
    continue
  fi

  git add .
  if ! git diff --cached --quiet; then
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    if git commit -m "auto-sync $TIMESTAMP on $(hostname -s)" >> "$LOGFILE" 2>&1; then
      CHANGES=$((CHANGES+1))
      SYNCED_NAMES="$SYNCED_NAMES $NAME,"
    else
      ERRORS=$((ERRORS+1))
      notify "DW Sync Error" "Commit failed in $NAME - check log / SYNC-BLOCKED.md" "Basso"
      echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR commit failed in $DIR" >> "$LOGFILE"
      continue
    fi
  fi

  git pull --no-rebase >> "$LOGFILE" 2>&1
  if [ $? -ne 0 ]; then
    ERRORS=$((ERRORS+1))
    notify "DW Sync Error" "Sync conflict in $NAME. Open terminal to resolve." "Basso"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR pull failed in $DIR" >> "$LOGFILE"
    continue
  fi

  git push >> "$LOGFILE" 2>&1
  if [ $? -ne 0 ]; then
    ERRORS=$((ERRORS+1))
    notify "DW Sync Error" "Push failed in $NAME. Check your connection." "Basso"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR push failed in $DIR" >> "$LOGFILE"
  fi
done

# Notifications
if [ $ERRORS -gt 0 ] && [ $CHANGES -eq 0 ]; then
  : # error notifications already sent above
elif [ $CHANGES -gt 0 ] && [ $ERRORS -eq 0 ]; then
  SYNCED_NAMES=$(echo "$SYNCED_NAMES" | sed 's/,$//' | sed 's/^ //')
  notify "DW Saved" "$SYNCED_NAMES" "Pop"
elif [ $CHANGES -eq 0 ] && [ $ERRORS -eq 0 ]; then
  notify "DW Sync" "Everything up to date"
fi
