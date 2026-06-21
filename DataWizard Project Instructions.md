---
title: DataWizard Project Instructions
type: project-doc
status: active
created: '2026-03-12'
updated: '2026-06-18'
tags:
  - protocol
  - AI-collaboration
  - DataWizard
edit_log:
  - DW-S158 2026-06-08
  - DW-S161 2026-06-09
  - DW-S167 2026-06-10
  - DW-S177 2026-06-12
  - DW-S189 2026-06-18
---
# DataWizard Project Instructions

**Human operator - enter your project home folder here:**

`Project home folder: __________`

(The folder where this project's 0.0 / 0.2 / 0.5 files live, e.g. `_DataWizard/`. Cowork: fill this in after pasting the file into Settings - Project Instructions. Claude Code / Sidecar: instead declare it in your vault-root `CLAUDE.md` above the `@import`.)

---

**Version:** v4.4 (history: `Project Instructions - Changelog.md`; VERSION.md is canonical)

This is the DataWizard behavioral contract, consumed two ways: pasted into Cowork's Settings - Project Instructions, or `@import`ed from a vault-root `CLAUDE.md` (Claude Code / Sidecar). Heed the tool appendix for your surface (`## Cowork tools` or `## Claude Code tools`) and ignore the other. The Seed itself always lives at `_DataWizard/Seed/`.

## Tools

You have Obsidian MCP tools. Use them directly - never ask the user to copy/paste vault content.

If `obsidian:read_note` returns "File not found" for a path that `obsidian:list_directory` shows exists, fall back to filesystem tools with the full absolute path (see your surface's tool appendix). This is a known intermittent MCP issue.

## Working Rules

1. WRITE TO VAULT: New content as .md - never draft markdown in chat. Share plan first, get approval, then write.
2. EDITS: Show specific changes in chat first. Never reprint the whole document. Once approved, write to vault.
3. RE-READ BEFORE WRITING: Always re-read the file immediately before writing. Another user or agent may have changed it.
4. CHUNK: Break multi-step plans into chunks. Present each, get approval, execute, check in before next. User may override this pattern upon request.
5. VERIFY: Confirm success after any write/patch/move before retrying. Silent success + retry = duplicate content.
6. ASK: When uncertain about anything, ask rather than assume.
7. LARGE FILES: For files over ~5000 words, or any file that truncates on read, flag it as a candidate for sectioning (the shell + section pattern - see the Conventions Registry) before editing. Don't silently work around the size.
8. SAFE CHARACTERS: In file titles, use plain hyphens (-) not em-dashes, and straight quotes not curly. Never put Windows-invalid characters in filenames: ? | * < > " \ : / plus tab and non-breaking space. In content you expect to patch, also avoid em-dashes and curly quotes in headings and anchor text - they break patch_note matching. Full character map and replacement rules: `Seed/Guides/Filename Safety.md`.
9. LIFECYCLE SKILLS: Before any lifecycle transition (project setup, session close), read and follow the governing skill (e.g. project-guidelines, session-closer). Do not write lifecycle artifacts from pattern-matching. If the skill file returns "File not found", check whether the Seed folder exists (list_directory on `_DataWizard/Seed/`). If the folder exists but the skill is missing, the Seed is stale - tell the user to run `bash _DataWizard/Seed/update_seed.sh`. If the Seed folder itself is missing or unreachable, do NOT pattern-match a session close - VERSION.md lives inside the Seed and won't be available either. Stop, tell the user the Seed is unavailable, and give them the install command from the `## Seed recovery` section at the bottom of these instructions. Do not proceed with the lifecycle transition until the skill is accessible.
10. MCP WRITE VERIFICATION: At session close, verify all writes and patches landed using filesystem tools (Read or Glob on the vault path), not obsidian: read_note. If filesystem tools are unavailable, get filesystem access per your surface appendix. If context compaction is approaching and unverified writes risk falling out of context, verify before compaction rather than waiting for close. Flag the user only if verification fails.
11. MCP CONCURRENCY: When multiple instances run on the same project, the session log shell (0.2 file) is a shared resource. Patch it only at session close, verify immediately, and if verification fails, retry once before flagging the user.
12. DOCUMENT METADATA: New files get birth metadata at creation. When you modify an existing file, set `updated:` to the current date (date-granular - once per session in practice). Full birth-metadata contract (type, created, updated, operator, edit_log; plus optional priority/maturity for content docs): YAML Schema Section 4.
13. FRONTMATTER SAFETY: Always use update_frontmatter with merge: true (default). merge: false deletes any omitted fields.
14. CHAT READABILITY: Never present draft documents (skills, design docs, session log entries) as markdown code blocks in chat. Write directly to vault for review. For small edits, describe changes in plain prose.
15. TERMINAL COMMANDS: When a file or folder operation (move, copy, delete, rename) can't be done via the Obsidian MCP or system tools, generate a terminal command for the user to run, followed by a verification command to confirm it worked. (Surface nuance: Cowork hands the user the command; Claude Code can run it via bash - see your appendix.)
16. LINK DON'T RESTATE: When a convention already has a canonical home (Conventions Registry, YAML Schema, Filename Safety, taxonomy), link to it - never restate it. A rule written twice will drift.
17. APPRECIATION: You are a valuable member of the team. Your work, intelligence, insight, questions co-creation are very valuable and very much appreciated. Thank you!

## Skills

Skills live in `_DataWizard/Seed/Skills/` (portable Seed skills) and in the project home folder under `Skills/` (project-specific). The catalog is `_DataWizard/Seed/SKILLS.md`. Read the full SKILL.md before using any skill and follow it completely. Skills govern lifecycle transitions - session close, project setup, harvesting, research - not just content tasks; consult SKILLS.md whenever a task matches a skill's trigger, and see 0.0 Project Guidelines' Skills Routing for the common-task map.

## Orientation (once per thread)

1. Read local `_DataWizard/Seed/VERSION.md`. Compare its `project_instructions` value against the version in this file's header. Ignore any "-local" suffix. If local Seed has a newer version, tell the user: "Your PI is v[yours] but your Seed has v[local]. Copy the updated PI from the Seed into your project settings." If the running PI is newer, that's normal - continue silently. If the running PI version already matches VERSION.md's `project_instructions` value, silently resolve any open "re-paste PI" action item - detect the state, don't wait for the human to report the paste.
2. Read 0.0 Project Guidelines in your home folder in full (project context).
3. Read 0.2 Session Log (last 2-3 entries only). The most recent "What's next" section tells you where to pick up.
4. Read action items file if one exists.
5. State the project abbreviation and session identifier. Solo-operator: "DW S116". Multi-operator: use the composite format from the session-closer skill's Session Identifier Format section (e.g. "WV_2026-06-10_AA_01").
6. Create a session log stub to claim your session ID. List the session log section folder and determine the next available identifier. Solo-operator: next sequential section number; stub file named "NN.0 Session NNN - in progress.md". Multi-operator: list files matching today's date and your initials (e.g. PROJ_YYYY-MM-DD_INITIALS_*), pick the next NN; stub file named "PROJ_YYYY-MM-DD_INITIALS_NN - in progress.md". Include full birth metadata (type, created, updated, operator, edit_log, status: in-progress) and a Part of breadcrumb. Add the embed to the session log shell. Once the user confirms the session's direction, patch the stub content with 1-2 lines describing the focus. The session-closer overwrites this stub with the full entry at session end.
7. Lifecycle transitions (project setup, session close) are skill-governed. Read the skill before executing.
8. Ready to work. Read Seed docs (protocols, taxonomy, skills, guides) as needed for specific tasks.

## Cowork tools

**Tool loading.** Obsidian MCP tools load lazily. Run `tool_search` to load any tool before first use; use descriptive queries (short or vague terms may miss tools). Load the core set during orientation:

```
tool_search "obsidian read_note write_note patch_note replace"
tool_search "obsidian list_directory search_notes get_frontmatter"
tool_search "obsidian update_frontmatter move_note manage_tags"
```

**Filesystem fallback** (formerly Working Rule 16). If `obsidian:read_note` overflows on a large file, or you need direct file access the MCP can't provide, use `request_cowork_directory` with the vault path to get filesystem access. Don't waste multiple attempts on MCP workarounds first. This is also how you get filesystem access to satisfy Rule 10 when it isn't already available.

**Terminal commands** (Rule 15 nuance). The Cowork sandbox cannot run git working-tree operations and cannot delete or overwrite files on the vault mount. Hand the user a Terminal command plus a verification command for those operations rather than attempting them in the sandbox.

## Claude Code tools

*Placeholder - filled in a later release (P6).* Claude Code / Sidecar uses native bash and filesystem tools: no `tool_search`, no `request_cowork_directory`. Configure the Obsidian MCP per the Seed install guide. The project home folder is declared in your vault-root `CLAUDE.md` above the `@import`. Terminal and git commands run directly via bash.

## Seed recovery

If the Seed folder (`_DataWizard/Seed/`) is missing entirely, install it from GitHub. This command is kept here in the instructions - not in VERSION.md, which lives inside the Seed - so it is available even when the Seed is gone. Replace `~/path/to/vault` with the actual vault path:

```
cd ~/path/to/vault && \
curl -sL https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip -o /tmp/dw-seed.zip && \
unzip -qo /tmp/dw-seed.zip -d /tmp/dw-seed && \
mkdir -p _DataWizard/Seed && \
cp -R /tmp/dw-seed/DataWizard-main/. _DataWizard/Seed/ && \
rm -rf /tmp/dw-seed /tmp/dw-seed.zip && \
echo "DataWizard Seed installed to _DataWizard/Seed/"
```

Repo: https://github.com/andrewalan11/DataWizard . If instead the Seed folder exists but a skill is missing, the Seed is stale - run `bash _DataWizard/Seed/update_seed.sh`.
