---
title: 'No-Ledger Roster'
type: skill-reference
parent: "[[_DataWizard/Seed/Skills/session-closer/SKILL|session-closer]]"
created: '2026-10-18'
updated: '2026-10-18'
operator: Andrew
origin: 'DW-S422 2026-10-18 - moved verbatim from session-closer SKILL.md v4.10.3'
edit_log:
  - 'DW-S422 2026-10-18 - created: moved verbatim from session-closer SKILL.md v4.10.3'
---

*Part of the [[_DataWizard/Seed/Skills/session-closer/SKILL|session-closer]] skill*

# No-Ledger Roster

Read the previous session's "Active quest threads" section (if it exists). For each thread:
- If work was done on it this session, update its status and remaining work
- If no work was done, carry it forward unchanged
- If it was completed this session, remove it
- If a new multi-session workstream emerged this session, add it

Each thread entry includes: a bold numbered name, session history in parentheses (which sessions touched it), 2-3 sentences on remaining work, and key doc paths. This section lives after "What's next" in the output format.

If the previous session has no quest threads section (pre-S158 entries), scan the last 5-7 session logs to identify active threads and bootstrap the section. This is a one-time cost -- subsequent sessions just carry forward and update.

**Deduplication rule.** Do not include a thread that is already a Priority item or side task in "What's next." Quest threads exist for workstreams that are NOT the immediate focus -- things the next instance might forget about because they're not on the priority list. If every active thread is already covered in "What's next," omit the quest threads section entirely.

The quest threads section prevents long-running workstreams from falling off the radar when they aren't the active focus. "What's next" is the immediate handoff; quest threads are the background map of parallel work that isn't currently prioritized.
