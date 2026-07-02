# datawizard-aliases.sh — DataWizard shell aliases
# Source this from ~/.zshrc:  source "/Users/kevintriplett/ObsidianNoSync/_DataWizard/Scripts/datawizard-aliases.sh"
# Edit this file (not ~/.zshrc) to change aliases; reload with `source ~/.zshrc` or open a new shell.

DW_PLIST="$HOME/Library/LaunchAgents/com.datawizard.sync.plist"

# Manual sync (commit + pull + push all configured repos)
alias dwsync="bash ~/Scripts/datawizard-sync.sh"

# Background auto-sync (launchd) control
alias dwstop='launchctl unload "$DW_PLIST" && echo "DW auto-sync stopped"'
alias dwstart='launchctl load "$DW_PLIST" && echo "DW auto-sync started"'
alias dwstatus='launchctl list | grep datawizard || echo "DW auto-sync not loaded"'
alias dwlog='tail -20 ~/.datawizard-sync.log'

# optional: If you have a fork of the DataWizard repo, this alias will: 
#   1. pull the upstream repo into your fork 
#   2. merge into local, preserving local edits
#   3. push back into your fork
# It requires adding a [remote "upstream"] section in .git/config
# Example:
# [remote "upstream"]
#     url = https://github.com/andrewalan11/DataWizard.git
#     fetch = +refs/heads/*:refs/remotes/upstream/*
DW_REPO="$HOME/ObsidianNoSync/_DataWizard"
alias dwpull='git -C "$DW_REPO" fetch upstream && git -C "$DW_REPO" merge upstream/main'
