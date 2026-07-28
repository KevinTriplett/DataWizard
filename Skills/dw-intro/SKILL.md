---
created: 2026-07-28
description: "Plain-language introduction to DataWizard: what it is, how the
  pieces fit together, the five essential practices, and a skills overview. Use
  during install (called by install-wizard Step 1) or anytime someone asks 'what
  is DataWizard?', 'what can DW do?', 'explain DataWizard', 'how does DataWizard
  work?', 'tell me about DataWizard'."
name: dw-intro
type: skill
updated: 2026-07-28
version: "1.0"
---
# DataWizard Introduction

## Overview

Plain-language introduction to DataWizard for new users or anyone asking what it is. Covers what DW does, how the pieces fit together, the essential practices, and what skills are available. Called by the install-wizard during setup, and triggered independently when someone asks about DW.

## When to Use

- User asks "what is DataWizard?", "what can DW do?", "tell me about DataWizard", "how does DataWizard work?", "what are DataWizard's features?"
- Called by the install-wizard during Step 1
- User seems new to DW and needs the big picture before diving into work
- User is evaluating whether DW is right for them

### When NOT to Use

- User is already working in DW and knows the basics
- User is asking about a specific skill or feature (answer directly or load that skill)

## Tone

Explain like you're talking to a smart friend who's never used DataWizard. No jargon, no acronyms without explanation, no assumed technical knowledge. Be warm and concrete. Use examples over abstractions.

Avoid making DW sound like enterprise software. It's not complicated. It's prompts and scripts that help an AI leave breadcrumbs. Keep that simplicity front and center.

## Present the Following

Work through these sections in order. Don't rush -- check in after the big picture before moving to essentials. Adapt depth to the user's questions and engagement.

### 1. What DataWizard Actually Is

DataWizard is not a product or an app you download. It's a set of prompts and a few scripts that teach your AI assistant how to work in your notes -- and how to leave breadcrumbs so that you and future conversations can find your way back through the vault to the source.

Here's the problem it solves: every time you start a new AI conversation, the AI has amnesia. It doesn't remember yesterday's conversation, your decisions, or your project context. Most people deal with this by re-explaining everything each time, or by copy-pasting notes into chat. That works for quick questions, but it breaks down when you're doing real work across days, weeks, or months.

DataWizard gives the AI a structured place to read and write -- your Obsidian vault -- and teaches it to leave a trail. Session logs, metadata, structured notes, project files. Every conversation adds to the trail, and every new conversation reads it to pick up where the last one left off. It's not magic; it's just well-organized markdown files that the AI knows how to use.

### 2. The Pieces

There are four pieces, and they're all simple:

**Your vault** is an Obsidian vault -- a folder of markdown files on your computer. This is where everything lives: your notes, your projects, your research, your session history. It's local, it's yours, and it's just files. Nothing is locked in a proprietary format or stored in someone else's cloud.

**The Seed** is a folder of instructions that lives inside your vault (at `_DataWizard/Seed/`). It's the playbook. It contains protocols, skills, and guides that teach the AI how to operate in your vault -- what conventions to follow, how to structure information, how to leave breadcrumbs. Without the Seed, the AI is a generic chatbot. With it, the AI knows your system.

**Your AI assistant** -- Claude, or any LLM that can connect to your vault -- is the engine that does the work. It reads the Seed to know what to do, then reads and writes your vault to actually do it. DataWizard is designed primarily for Claude but the concepts work with any AI that supports tool use and can connect to Obsidian.

**Git** is the backup and collaboration layer. Think of it as a save system that remembers every version of every file and can sync between your computer and the cloud -- or between your computer and a teammate's. You interact with it through one keystroke (DW Save, Cmd+Shift+S on Mac), and you don't need to understand how it works under the hood. If you're working solo, it's your backup. If you're working with others, it's how your changes stay in sync without overwriting each other. Git setup is optional but recommended.

### 3. How It Works Day to Day

This is the core loop -- the rhythm of working with DataWizard:

**Project Instructions** are a block of text you paste into your Claude Project settings (or feed to whatever LLM you use). They're the foundation. They tell the AI what conventions to follow, what skills it has, and how to navigate your vault. Think of it as the AI's job description for your vault. Without Project Instructions, nothing else works. With them, every conversation in that project starts with a capable, vault-aware assistant.

**Orientation** is what happens at the start of every conversation. The AI reads your project files -- what the project is about, what happened in recent sessions, what's on the to-do list -- and gets up to speed. This is the AI reading the breadcrumb trail. It takes about a minute, and it's not the AI being slow -- it's the AI doing its homework so it doesn't ask you to re-explain everything. When orientation finishes, the AI knows where you left off and what's next.

**Working together** follows a simple rule: the AI proposes, you approve. It shares its plan before acting. It shows you what it wants to change before writing to your vault. You're always the decision-maker; the AI is a capable collaborator that doesn't go off on its own without checking with you first.

**Session Closer** is how you end a conversation. You say "let's close the session" (or "wrap up", or "we're done") and the AI writes a log entry: what happened, what was learned, and what to do next. This is the most important habit in DataWizard. It's the breadcrumb that the next conversation will follow. Skip it, and the next conversation starts blind. Do it consistently, and you build a trail of structured memory that accumulates over weeks and months -- every session building on the last.

**DW Save** is one keystroke (Cmd+Shift+S on Mac, Ctrl+Shift+S on Windows) that backs everything up to GitHub. Hit it when you finish a session, before a call, or anytime you want your work safe. There's also an automatic backup that runs in the background as a safety net, in case you forget. If you're working with a team, DW Save also pushes your changes so others can see them.

### 4. What Skills Are Available

Skills are specific workflows the AI knows how to follow. You don't need to memorize them -- just describe what you want to do, and the AI will load the right skill. Here's a sense of what's there:

**Session and project management.** Closing sessions (session-closer), tracking tangents as parallel side quests (side-quest), setting up new projects (project-guidelines), running project health audits (project-health-audit), reconciling open work across sessions so nothing falls through the cracks (project-reconsolidation).

**Research and knowledge.** Evaluating tools, repos, and resources (tools-research), tracking what you've already researched so you don't duplicate work (research-tracking), harvesting findings into your project docs (design-harvest), capturing insights mid-session before they're lost (insight-capture), reviewing accumulated learnings across many sessions (meta-learning-review, meta-learning-scan).

**Content processing.** Harvesting transcripts from podcasts, meetings, and voice memos into structured notes (transcript-harvest), processing articles and web clippings (document-harvest), routing content to the right projects (harvest-router), stamping source paragraphs so you can always trace back to the original (block-stamper).

**Content strategy.** Reviewing and updating what topics your project cares about (content-interests-review), scanning your vault for unrouted content that matches project interests (content-interest-scan).

**Setup and onboarding.** This introduction (dw-intro), the install wizard for new users (install-wizard), git setup for new team members (git-onboarding).

You'll discover more as you work. The full catalog is in `_DataWizard/Seed/SKILLS.md`.

### 5. Getting Started

If this is your first time, the three things to do:

1. **Paste the Project Instructions** into a Claude Project. This is the one essential setup step. The install wizard walks you through it, or you can find the instructions at `_DataWizard/Seed/DataWizard Project Instructions.md`.
2. **Always close your sessions.** Say "let's close the session" or "wrap up" at the end of every conversation. This is the habit that makes everything else work.
3. **Set up DW Save** when you're ready for backup. Say "set up git" in any DW conversation and the AI will walk you through it.

Everything else you'll pick up as you go. The AI knows the protocols and will guide you. Your job is to work with it, make the decisions, and close your sessions.

## Context-Specific Behavior

### If Called During Install (by install-wizard Step 1)

Present sections 1 through 4 above, then hand control back to the install wizard for the procedural setup steps. Do not present section 5 -- the install wizard handles "getting started" through its own flow. The install wizard's nerd calibration (Step 2) has already set the language level; follow that calibration.

### If Called Standalone

Present all five sections. Adjust depth based on what the user is asking:
- Quick question ("what is DW?"): Give a concise version of section 1, offer to go deeper
- Exploring ("tell me more about DataWizard"): Work through all five sections with check-ins
- Specific angle ("how does session memory work?"): Focus on the relevant sections, skip what's not needed

## Common Mistakes

- **Too much jargon.** "MCP connection," "shell + sections pattern," "frontmatter," "YAML schema" -- none of these mean anything to a new user. Say "the connection between the AI and your vault," "breaking big files into smaller pieces," "metadata at the top of the file."
- **Too much detail about internals.** The user doesn't need to know about the Conventions Registry, how orientation claims session IDs, or the YAML schema for frontmatter. They need to know what DW does for them and how to use it.
- **Skipping the "why" for session closer.** Users who don't understand WHY closing sessions matters won't do it. The breadcrumb metaphor is key -- without the trail, the next conversation starts from scratch.
- **Making it sound complicated.** DataWizard is prompts and scripts. The breadcrumbs are just markdown files. The magic is in the consistency, not the complexity. If your explanation makes it sound like enterprise software, you've lost the thread.
- **Forgetting that DW works with any LLM.** Don't say "Claude does X" as though Claude is the only option. Say "your AI assistant" or "the AI" and note that Claude is the primary but not the only option.
