---
title: Copy Into Cowork Instructions
type: project-doc
status: active
created: '2026-03-23'
updated: '2026-03-23'
tags:
  - protocol
  - AI-collaboration
  - DataWizard
  - cowork
---

# DataWizard — Copy Into Cowork Instructions

Paste this block into the **Instructions** field when setting up a Cowork instance for any project that works with your vault. You only need to re-paste when the version number changes.

---

## Paste This Into Cowork Instructions

```
# DW Cowork Instructions v2.2

## Working Rules (always follow)
1. EDITS TO EXISTING DOCS: Describe changes in chat first. For
   small edits, show the specific changes. For large edits,
   summarize what's changing and why — don't reprint the whole
   document. Once approved, write to vault.
2. CHUNK: Break multi-step plans into chunks. Present each
   chunk, get approval, execute, check in before next chunk.
3. ASK: When uncertain about anything — placement, naming,
   scope — ask rather than assume.
4. HARVEST DISCIPLINE: When harvesting from transcripts or
   source files, treat each source as one atomic unit:
   (a) Segment first — add ## headers before extracting
   (b) Harvest content into destination docs
   (c) Update source YAML (harvest_status, harvested_into)
   Complete all three before moving to the next source.
   See Protocol Sections 7 and 9.

## Orientation (once per thread)
1. Fetch version check:
   https://raw.githubusercontent.com/andrewalan11/DataWizard/main/VERSION.md
2. Read 0.0 Project Guidelines in full (this is the project
   brief — what it is, core concepts, key decisions, structure)
3. Compare datawizard_protocol_version against VERSION.md
   - Match → fetch protocol summary:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/Protocol%20Summary.md
   - Mismatch or no guidelines → fetch full protocol:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/DataWizard%20Universal%20Protocol.md
4. Compare DW Cowork Instructions version against VERSION.md
   — flag if user needs to re-paste
5. Read 0.2 Session Log (last 2-3 entries only)
6. Read action items file if one exists
7. Ready to work — read other files only as needed

## Project Context
If you don't yet know this project's home folder path, ask the
user for it. Store it in project memory once provided — never
ask again. The home folder is the vault-relative path where the
project's .md files live (e.g. _MyProject/).

Once you have the home folder, look for a guidelines file there
(typically "0.0 Project Guidelines.md"). If none exists, follow
the Universal Protocol's bootstrap section to help create one.
```

*Re-paste only when the Cowork Instructions version changes (currently v2.2).*

---

## Differences from Chat Template

The Cowork template is slimmed down from the Chat (Claude Project) version:
- **No tool list** — Cowork discovers available tools automatically
- **Fewer working rules** — WRITE TO VAULT, RE-READ, and VERIFY are omitted (these address Chat-specific behaviors around markdown rendering and retry patterns)
- **Same orientation flow and bootstrap** — version checking, protocol fetch, action items, and home folder discovery work identically

---

## Version Tracker

| What | Version | Last changed | Re-paste needed? |
|---|---|---|---|
| Cowork Instructions | v2.2 | 2026-03-23 | Only when this version changes |
| Universal Protocol | v1.7 | 2026-03-23 | Never — Claude fetches latest automatically |

*The Universal Protocol updates automatically via GitHub. You never need to re-paste when only the protocol changes.*
