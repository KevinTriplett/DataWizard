---
name: install-wizard
description: >-
  Use after a new user completes MCP setup from the README. Verifies the
  connection, guides Project Instructions setup, explains git sync, and offers
  git onboarding. Triggers on: 'set up DataWizard', 'finish DataWizard setup',
  'I just installed DataWizard', 'verify my MCP connection', or any context
  where a new user has just connected MCP and needs to complete setup.
type: skill
version: '1.1'
updated: '2026-06-12'
---
# Install Wizard Skill

## Overview

Interactive post-install setup for new DataWizard users. Picks up where the README left off -- the user has Obsidian running, the Seed cloned, and MCP connected. This skill verifies the connection works, walks them through Project Instructions setup, explains how DW stays up to date, and offers git onboarding for collaboration.

## When to Use

- User says "set up DataWizard" or "finish DataWizard setup"
- User says "I just installed DataWizard" or "verify my setup"
- User has just completed the README install steps and is in their first conversation
- You're in a project that has DW Project Instructions but the user appears to be new (no session log, no 0.0 file)

### When NOT to Use

- User already has a working DW setup with session history (this is for first-time setup only)
- MCP is not connected yet (direct them to the README first)
- User just needs to update their Seed (point to VERSION.md / update_seed.sh)

## Before You Start

Read this skill fully. Do not skip or reorder steps -- they build on each other and each step confirms the previous one worked.

## Step 1: What Is DataWizard

Before diving into setup, give the user a brief picture of what they're installing and how the pieces fit together:

> "Before we dive into setup, here's what we're going to install:
>
> **The Vault** -- your Obsidian vault is where everything lives. Notes, transcripts, research, project docs -- all markdown files on your computer, not in the cloud.
>
> **The DataWizard Seed** -- the folder you just installed (_DataWizard/Seed/). It contains protocols, skills, and guides that teach Claude how to operate in your vault. Think of it as the instruction manual that makes Claude a vault-aware assistant instead of a generic chatbot.
>
> **The MCP Connection** -- the bridge between Claude and your vault. It lets Claude read, write, search, and organize your notes directly from a conversation.
>
> Together: you talk to Claude, Claude reads the Seed to know what to do, and uses MCP to do it in your vault. That's the whole system."

## Step 2: Nerd Calibration

Before continuing, get a sense of where the user is starting. This doesn't change what we do -- it changes how we explain things.

Ask the user (as a poll with these four questions):

1. "How comfortable are you with Obsidian?"
   - Just installed it
   - I've been using it a while
   - Power user (plugins, templates, Dataview, etc.)

2. "Have you used Claude Projects before?"
   - No / not sure what that is
   - I've tried it
   - I use them regularly

3. "How about git?"
   - Never heard of it / never used it
   - I know the basics (clone, commit, push)
   - I use it regularly

4. "How comfortable are you with Terminal / command line?"
   - Never used it
   - I can paste commands
   - I use it regularly

Store the responses mentally and adjust language throughout:

- Obsidian "just installed it" -- don't assume they know what the sidebar is, what a vault is, or how to find settings. Explain UI elements as you reference them.
- Claude Projects "no" -- Step 5 needs extra hand-holding on navigating the Claude Desktop UI. Explain what a Project is before asking them to create one.
- Git "never heard of it" -- the Step 6 git explanation is essential, do not abbreviate. Consider offering a gentler pacing for git-onboarding if they proceed.
- Terminal "never used it" -- spell out every keystroke, explain what Terminal is, never assume they know what "paste into Terminal" means.

If the user is experienced across the board, you can pick up the pace and skip explanatory asides. But never skip steps -- even experienced users benefit from the tool verification.

## Step 3: Welcome and Roadmap

Tell the user what's about to happen. Keep it brief and friendly:

> "Great, let's get you set up. Here's what we'll do:
>
> 1. Verify your vault connection is working
> 2. Set up a Claude Project with DataWizard instructions
> 3. Talk about how to keep things in sync and collaborate
>
> Each step takes about 2 minutes. I'll check in after each one."

## Step 4: Verify MCP Connection

Run through ALL Obsidian MCP tools systematically. Do not skip any -- a partial connection is worse than no connection because the user thinks it's working.

### 4a: Read tools

1. `list_directory` on `/` -- confirm it returns the vault's folder structure. If `_DataWizard/Seed/` is visible, confirm aloud.
2. `read_note` on `_DataWizard/Seed/VERSION.md` -- confirm it returns content.
3. `search_notes` for "DataWizard" -- confirm search returns results.
4. `get_vault_stats` -- report the number of notes and folders. This gives the user confidence the connection sees their whole vault.

### 4b: Write tools

1. `write_note` -- create `_DataWizard/_install-test.md` with content: "Install test -- this file was created by the DataWizard install wizard to verify MCP write access. Safe to delete."
2. `read_note` -- read it back to confirm the write worked.
3. `patch_note` -- replace "Safe to delete" with "Write verified. Safe to delete."
4. `read_note` -- read it back to confirm the patch worked.
5. `delete_note` -- delete the test file (with confirmation path).

### 4c: Frontmatter and tags

1. `write_note` -- create `_DataWizard/_install-test.md` again, this time with frontmatter: `{type: test, created: [today's date]}`
2. `get_frontmatter` -- confirm it reads the frontmatter correctly.
3. `update_frontmatter` -- add `{status: verified}` to the frontmatter.
4. `manage_tags` -- add tag `install-test`, then list tags to confirm.
5. `manage_tags` -- remove the tag.
6. `delete_note` -- clean up.

### 4d: Move tools

1. `write_note` -- create `_DataWizard/_install-test.md` one more time.
2. `move_note` -- move it to `_DataWizard/_install-test-moved.md`.
3. `read_note` -- confirm it exists at the new path.
4. `delete_note` -- clean up.

**Check in:** Tell the user the results. If everything passed:

> "Your connection is fully working -- reads, writes, search, frontmatter, tags, and file moves all verified. You're good to go."

If anything failed, troubleshoot:
- Write failures: check Obsidian is running, vault path is correct in the config
- Search failures: vault may need time to index (ask user to wait 30 seconds and retry)
- Partial failures: note exactly which tools failed and check the README troubleshooting section

Do NOT continue past this step until all tools are verified.

## Step 5: Set Up a Claude Project

This is the most important step. Project Instructions are THE mechanism that makes DataWizard work -- they tell Claude how to operate in your vault, what protocols to follow, what skills are available, and how to orient itself at the start of every conversation. Any Claude Project that has these instructions will operate with DW protocols and practices.

### 5a: Point to the Project Instructions

Read `_DataWizard/Seed/Project Instructions - Copy-Paste into Claude.md` via MCP so you know its contents, but do NOT print the instructions into chat -- they are long, unreadable in chat, and a chat copy goes stale. Direct the user to copy them from the file itself. Note: Obsidian's sidebar hides underscore-prefixed folders, so guide them to the file via Finder and a text editor. Only if the user cannot reach the file is printing the fenced block an acceptable fallback.

Tell the user:

> "Your Project Instructions live in your Seed at:
> `_DataWizard/Seed/Project Instructions - Copy-Paste into Claude.md`
>
> In a moment you'll open that file and copy the block between the ``` fences. Open it via Finder with any text editor -- Obsidian's sidebar hides the _DataWizard folder, so you won't find it there. But first, let me explain what the instructions do:
>
> They teach Claude how to work in your vault. They tell it where your files are, what conventions to follow, what skills it has, and how to pick up where the last conversation left off. Every conversation you start in a Claude Project with these instructions will have DataWizard's full capabilities.
>
> You can create multiple Claude Projects with the same instructions -- one per project in your vault, for example. Each project just needs a different 'Obsidian Vault Home folder' line pointing to that project's root folder."

### 5b: Guide the paste

Walk the user through these steps one at a time. Pause after each. Adjust detail level based on the Nerd Calibration -- if they said "no / not sure what that is" for Claude Projects, explain what a Project is first.

1. "In Claude Desktop, click the menu icon (three lines) in the top left, then click 'Projects', then '+ Create project'."
2. "Give your project a name -- something like 'My Vault' or the name of your first project."
3. "Click the gear icon next to the project name to open settings."
4. "Find the 'Project Instructions' field."
5. "Paste the instructions block you copied from the file."
6. "Find the line that says `Obsidian Vault Home folder:` and fill in your project's home folder path. For your first project, this is probably `_DataWizard/` or whatever folder you want Claude to focus on."
7. "Click 'Save' or close the settings panel."

**Check in:** Ask the user to confirm they've pasted the instructions and set the home folder. If they're unsure about the home folder path, help them decide based on their vault structure.

## Step 6: Git -- The Sync and Collaboration Layer

This is not an optional advanced step -- it's how DataWizard stays connected. Brief psychoeducation before offering setup:

> "Let me explain how DataWizard stays up to date and how you can collaborate with others.
>
> DataWizard uses git as its sync layer. Git is a version control system -- it tracks every change you make and lets you sync those changes to a remote copy on GitHub. Think of it like a save system that remembers every version of every file, and can sync between your computer and the cloud (or between your computer and someone else's).
>
> In DataWizard, git does three things:
>
> 1. **Backup** -- your vault is saved to GitHub, so if your computer dies, nothing is lost.
> 2. **Sync** -- the DataWizard Seed (the protocols, skills, and guides you just installed) gets updates over time. Git is how those updates reach you.
> 3. **Collaboration** -- if you're working with other people in the same vault or project, git is how your changes and theirs stay in sync without overwriting each other.
>
> Even if you're working solo right now, setting up git means your work is backed up and you're ready to collaborate whenever you want to.
>
> Once git is set up, saving is one keystroke: Cmd+Shift+S (we call it 'DW Save'). That commits and pushes everything."

**Check in:** Ask the user:

> "Would you like to set up git now? It takes about 10-15 minutes and I'll walk you through every step. Or you can come back to it later -- just say 'set up git' in any future conversation."

If yes: hand off to the `git-onboarding` skill. Tell the user you're switching to the git setup flow, and load the skill.

If no: note that they can set up git anytime by saying "set up git" in a DW conversation. Move to Step 7.

## Step 7: Feedback Invitation

> "That's it -- DataWizard is set up and ready to go!
>
> One last thing: this install process is something we're actively improving. If anything was confusing, took too long, or could be better, I'd love to hear about it. Your feedback directly improves the experience for the next person.
>
> You can share feedback anytime by saying 'I have feedback about the install process' in a DW conversation, and I'll make sure it gets captured."

## Step 8: First Orientation

If the user is still in the conversation and has time, offer to run a first orientation:

> "Want me to do a quick orientation of your vault? I'll read through your project files and tell you what I see -- it's a good way to make sure everything is set up correctly and for me to learn about your vault."

If yes, proceed with the standard DW orientation sequence from the Project Instructions (read 0.0, read session log, etc.). If the project is new and has no 0.0 yet, offer to create one using the project-guidelines skill.

If no, close with:

> "You're all set. Start a new conversation in your Claude Project whenever you're ready -- I'll orient myself and we can get to work."

## Output

A fully configured DW installation:
1. MCP connection verified (all tools tested)
2. Claude Project created with Project Instructions pasted
3. User understands git's role and has either set it up or knows how to later
4. Feedback captured if offered
5. Optional: first vault orientation completed

## Common Mistakes

- **Rushing through tool verification.** Every tool must be tested. A partial connection causes mysterious failures later.
- **Not explaining what Project Instructions do.** Users who don't understand PI will delete them, edit them incorrectly, or not set the home folder. The explanation is as important as the paste.
- **Skipping the git explanation.** Users who skip git setup without understanding what they're skipping will never come back to it. The psychoeducation ensures they make an informed choice.
- **Being too technical about git.** The explanation should focus on what git does for them (backup, sync, collaboration), not how it works internally. Save the technical details for the git-onboarding skill.
- **Not offering to capture feedback.** Every install surfaces issues. If you don't ask, the user assumes the friction was their fault and doesn't report it.
- **Ignoring the Nerd Calibration.** If someone said "never used Terminal" and you tell them to "run this in your shell," you've lost them. Adjust your language to match their level throughout.
