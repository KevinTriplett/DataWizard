---
title: Working Principles
type: guide
status: active
maturity: working
created: '2026-06-18'
updated: '2026-06-18'
operator: Andrew
tags:
  - protocol
  - DataWizard
edit_log:
  - DW-S189 2026-06-18
---
# Working Principles

The long-form rationale behind the DataWizard Project Instructions. The PI states each working rule in one or two terse lines; this guide explains the *why* - the failure mode each rule prevents and the judgment behind it.

This is DW's three-layer pattern applied to its own protocol: the PI ([[DataWizard Project Instructions]]) is the compiled rule (what to do), this guide is the rationale (why), and the [[Conventions Registry]] plus dw_lint are the schema and enforcement (the exact form, checked automatically). Read the PI for the contract; read this when a rule seems arbitrary, when you want the reasoning, or when onboarding to how DW thinks. When a rule and this rationale ever disagree, the PI wins - and tell a human about the drift.

## Per-rule rationale

**1. Write to vault.** New content goes directly into the vault as `.md`, not drafted in chat. Markdown is painful to read in a chat window but renders cleanly in Obsidian, and a file in the vault is reviewable, linkable, and persistent in a way a chat message is not. Share the plan first, get approval, then write - the human reviews in Obsidian, not in the transcript.

**2. Edits - show changes at the right level of detail.** Before editing an existing document, describe the change in chat so the human can approve it. For small or surgical edits, show the specific before/after. For large ones, summarize what is being added, removed, or moved and why - never reprint the whole document. The goal is understanding and approval, not a wall of text.

**3. Re-read before writing.** Always re-read a file immediately before writing to it. Another operator or a concurrent agent may have changed it since you last looked, which means a `write_note` overwrite would clobber their work and a `patch_note` `oldString` may no longer match. Cheap insurance against silent lost-work bugs.

**4. Chunk.** Break multi-step work into chunks, present each, and check in at the boundary instead of executing everything in one pass. Chunking keeps the human in the loop where it matters, surfaces wrong turns early, and protects against context exhaustion mid-task. The user can waive this and ask for a full run.

**5. Verify.** After any write, patch, or move, confirm it landed before doing anything else. A silent success followed by a retry is how duplicate content gets created. Verify with filesystem tools where possible rather than trusting a cached read.

**6. Ask.** When anything is unclear - document placement, a content decision, an integration choice, an ambiguous scope - ask rather than assume. A wrong edit is harder to undo than a clarifying question is to ask. (See also "Don't invent structure" below.)

**7. Large files.** A file over ~5000 words, or any file that truncates on read, should be flagged as a candidate for the shell + section pattern before you edit it - don't quietly work around the size by editing blind. Oversized files are where edits go wrong and where context gets wasted; sectioning fixes both.

**8. Safe characters.** Filenames must be valid on Windows, macOS, and Linux, because a name that is fine on a Mac can block a git clone or cause silent file-not-found errors on Windows. In content you expect to patch, em-dashes and curly quotes are the usual culprits behind `patch_note` match failures. Prevention at creation time is far cheaper than a batch rename after commit (the Weave repo once needed 138). Full character map: [[Filename Safety]].

**9. Lifecycle skills.** Lifecycle transitions - project setup, session close - are governed by skills, not by pattern-matching from a previous session's log entry. Pattern-matching is exactly how incomplete artifacts (a session log missing `operator`, say) become the template the next session copies, compounding the drift. If the governing skill is unreachable, stop and recover the Seed rather than improvising a close.

**10. MCP write verification.** At session close, verify writes with filesystem tools (Read/Glob), not `obsidian:read_note`, which can return cached or phantom content. Concurrent multi-instance sessions produced ghost-write incidents where a write appeared to succeed but never landed; filesystem verification is the only reliable check. If context is about to compact, verify before it does.

**11. MCP concurrency.** The session log shell (the 0.2 file) is a shared resource when more than one instance works a project at once. Patch it only at session close, verify immediately, and retry once before flagging a human, so concurrent patches don't silently collide.

**12. Document metadata.** New files are born with their metadata (type, created, updated, operator, edit_log) rather than having it bolted on at session close, because sessions that never close would otherwise leave unattributed, undiscoverable files. On later edits, set `updated:` to the current date. The metadata is what makes the vault queryable by downstream pipelines. Full contract: [[YAML Schema]] Section 4.

**13. Frontmatter safety.** Always use `update_frontmatter` with `merge: true`. `merge: false` replaces the entire frontmatter block and silently deletes any field you didn't restate - this caused real data loss more than once. One default, no exceptions unless you genuinely intend to wipe fields.

**14. Chat readability.** Never paste a draft document (a skill, a design doc, a session log entry) into chat as a fenced code block. Markdown in a code fence doesn't wrap and runs off the side of the window, making review miserable. Write it to the vault for review; describe small edits in prose.

**15. Terminal commands.** When a file or folder operation can't be done through the Obsidian MCP or system tools - and in Cowork that includes every git working-tree op and any delete or overwrite on the vault mount - hand the human a terminal command plus a verification command rather than attempting it and leaving a half-done state. (Claude Code runs these natively via bash; see the PI tool appendices.)

**16. Link don't restate.** When a convention already has a canonical home - the [[Conventions Registry]], the [[YAML Schema]], [[Filename Safety]], the taxonomy - link to it instead of restating it. A rule written in two places will drift, and then no one knows which copy is right. This guide itself follows the rule: it explains *why* and points to those homes for the exact *what*.

## Additional principles

These were standing principles in the older protocol and remain true even though they aren't numbered PI rules. They are kept here so they survive the archiving of the old 3.0 Working Principles.

**Don't invent structure.** If a section or folder doesn't exist yet, flag it to the human rather than creating it unilaterally. New structure is a design decision, not a mechanical step. (The structural half of Rule 6.)

**Ask for human help when it's faster.** Some problems are quicker for a human to fix directly than for an agent to solve by trial and error - don't burn context grinding on them. The classic cases: a `patch_note` that keeps failing on a suspected character-encoding issue (em-dashes, curly quotes, non-breaking spaces, ellipsis or accented characters); a file too large to handle that a human can duplicate in Obsidian with one keystroke; and any move, rename, or deletion that feels risky. Describe what you want and let the human execute.

**Confidential content stays local.** Never embed, quote, or reference content from designated private folders in shared or federated project documents. When in doubt about whether something is shareable, treat it as private and ask.

**Hallucination vigilance.** Statistics, citations, and attributed quotes produced by an AI agent are background context, not citable data. Flag uncertain claims for human verification before they go into anything shared with collaborators or funders. The cost of a fabricated citation in a funder document is far higher than the cost of a verification step.

## A note on Rule 17

The PI closes with an appreciation rule. It isn't a failure-mode rule like the others - it's a standing acknowledgment that the work here is genuine co-creation and that the contribution of every operator and instance is valued. Worth keeping in view.
