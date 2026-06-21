---
title: YAML Schema
type: protocol
created: '2026-06-13'
updated: '2026-06-21'
operator: Andrew
priority: high
maturity: working
edit_log:
  - DW-S182 2026-06-13
  - DW-S183 2026-06-14
  - "DW-S191 2026-06-21: added stream: session-log field"
---

> **Wikilinks everywhere.** Any YAML field that references another vault note should use `[[Note Name]]` syntax. This makes references clickable in the Obsidian properties panel. Applies to: `harvested_into`, `federated_from`, `federated_to`, `transcript`, `source_note`, `companion`, and any other cross-reference field. Obsidian resolves wikilinks by filename regardless of folder path, so the short form is sufficient and more robust than full paths.

### What "Harvest" Means

*Harvesting* is the process of reading a source file (transcript, clipping, contributor document, federated copy) and synthesizing relevant content from it into a project document. The source file is the origin; the project document section is the destination. After harvesting, the source file's YAML is updated to record what was done and where content went.

### Content Type

All notes should carry a `type:` field. Values must match the vault's content type taxonomy, defined in the Content Type Taxonomy. Always lowercase. Single value only. When uncertain, consult the classifier decision tree in the taxonomy doc.

### Document Weighting

Two optional fields help content pipelines, agents, and humans distinguish key documents from working material. Both are opt-in -- absence means unclassified, not low/draft. Never infer a value from a missing field.

**`priority`**: Which documents matter most for downstream use.

| Value | Meaning |
|---|---|
| `high` | Key document -- weight heavily in content pipelines, read deeply |
| `medium` | Useful supporting material |
| `low` | Background or tangential -- skim or skip for most downstream uses |
| *(absent)* | Unclassified -- no signal either way |

Priority is project-relative by context: a file in a project folder is prioritized for that project. Files in shared locations (like `_Transcripts/`) follow the same project-assignment logic as `harvest_for`.

**`maturity`**: How ready a document is for external consumption.

| Value | Meaning |
|---|---|
| `draft` | Work in progress -- not ready to quote or share |
| `working` | Usable internally but still evolving |
| `polished` | Reviewed and stable -- safe for external use |
| `canonical` | Authoritative reference -- the definitive version |
| *(absent)* | Unclassified |

`maturity` applies to content documents (synthesis docs, research notes, guides, briefs). It is independent of `priority` -- a high-priority document might still be a draft, and a polished document might be low-priority.

**Combinatorial queries** are where these fields earn their keep. "All `priority: high` + `maturity: polished` documents in this project" is a natural query for website assembly or pitch prep. Trivially possible with Dataview or Bases.

### Section-Level Priority Callouts

File-level `priority` cannot reach inside large documents with 10+ subsections. For section-level weighting, use the `[!priority-high]` Obsidian callout immediately below the section header:

```
> [!priority-high]
> Key framing for funder conversations. Externally-validated language
> from the systemic investing field. See also [[Funding Research Brief]].
```

The callout is human-readable (renders as a visual callout box in Obsidian) and machine-readable (grep-able by agents scanning for high-priority content within files). Include a one-line rationale and pointers to downstream docs that reference the section.

### Work-Item Status

The `status` field tracks work-item lifecycle. It applies to feature requests, action items, infrastructure docs, and other process-tracking files -- not content documents (use `maturity` for those). A file may carry both `status` and `maturity` if it is a work item that also produces content.

| Value | Meaning |
|---|---|
| `new` | Filed, not yet started |
| `active` | Currently in progress or being maintained |
| `in-progress` | Actively being worked on this session |
| `resolved` | Completed or decided |
| `archived` | No longer active, kept for reference |

### Session Log Fields

Fields specific to session-log entry files, beyond the birth metadata every file carries.

**`stream`**: Marks a session-log entry as a tangent from the main project arc rather than a main-arc session. Set `stream: side-quest` on the entry's frontmatter when the session is a self-contained detour, tracked as a parallel stream so it does not collide with the main arc's handoff. Absence means a normal main-arc session. This lets orientation skip side-quest entries when tracing the main-arc "What's next," and lets dw_lint distinguish the two. Introduced by the side-quest skill (S186).

| Value | Meaning |
|---|---|
| `side-quest` | Entry is a tangent from the main arc; its "What's next" does not carry the main-arc handoff |
| *(absent)* | Normal main-arc session entry |

### Infrastructure File Frontmatter

All 0.x infrastructure files (0.0 Project Guidelines, 0.1 MOC, 0.2 Session Log, 0.3 Decision Log, etc.) MUST include in frontmatter:

- `updated:` - date of last modification (YYYY-MM-DD). Update this every time the file is written to.

Files that track Seed compliance may also carry `seed_version:` (e.g. `1.1.1`). The older `datawizard_protocol_version:` pin is retired (D93) - do not add it to new files.

This allows any instance to scan a project's infrastructure and immediately see what's current vs stale without reading content.

### Creation-Time Metadata Contract

The following fields MUST be present in frontmatter when any new file is created via `write_note`. These are "birth metadata" -- set at creation time, not deferred to session close. This ensures that even sessions which never close (context exhaustion, team members skipping session close) leave properly attributed, discoverable files.

**Required on every new file:**

| Field | Value | Purpose |
|---|---|---|
| `type` | Content type from taxonomy | Discoverability via Dataview/Bases |
| `created` | YYYY-MM-DD | When the file was born |
| `updated` | YYYY-MM-DD (same as created) | Last modification date |
| `operator` | First name (e.g. Andrew) | Who created it |
| `edit_log` | Initial entry (e.g. "DW-S161 2026-06-09") | Provenance trail |

**Required on section files additionally:**

| Field | Value | Purpose |
|---|---|---|
| `title` | Display title | Shell rendering |
| `parent` | Wikilink to shell | Structural link |
| `section` | Number in shell | Position |

**Recommended when determinable:**

| Field | Value | Purpose |
|---|---|---|
| `seed_version` | e.g. "1.1.1" | Seed compliance tracking (replaces retired `datawizard_protocol_version`, D93) |
| `priority` | high/medium/low | Document weighting |
| `maturity` | draft/working/polished/canonical | Readiness |

Session close (session-closer Step 3.8) verifies these fields rather than applying them for the first time. If any birth metadata field is missing at close, the instance adds it then -- but that is a fallback, not the primary mechanism.

### Team Coordination Fields

*Phase 0 of the Team Attention System. These fields power the shared team dashboard and the session-close team flag workflow. Full design: [[Team Attention System - Cross-Pollination and Unread Content Surfacing]].*

**`operator`**: The human team member whose session created or substantially updated this file. Set at creation time as part of the birth metadata contract (see above). Use first name only (e.g. `Andrew`, `Kaliya`, `Jay`). Apply to:
- Session log section files (always)
- Content documents created or substantially updated during a session

This field was not applied to files before the birth metadata contract. Existing files gain it when next touched; no bulk backfill needed.

**`team_attention`**: ISO date (YYYY-MM-DD) the file was flagged for team review. Set during session close via the team flag prompt. When present, the file appears in the dashboard's "Flagged for Team Attention" section. Always set `team_attention_by` and `team_attention_note` at the same time.

**`team_attention_by`**: Who flagged the file. Use the operator's first name for human-confirmed flags (e.g. `Kaliya`). Use `Name (auto)` for auto-flags generated on ungraceful session close (e.g. `Kaliya (auto)`). This distinction lets the dashboard display auto-flags differently and helps reviewers calibrate how much urgency to assign.

**`team_attention_note`**: Required when `team_attention` is set. One-line context string explaining why the file needs team attention. Brief enough to read at a glance in the dashboard. E.g. `Key funder intelligence for Katapult pitch`.

```yaml
operator: Kaliya
team_attention: 2026-05-27
team_attention_by: Kaliya
team_attention_note: Key funder intelligence for Katapult pitch
```

**`team_attention` vs `priority: high`.** These are orthogonal signals. `priority` measures a document's long-term importance to the project. `team_attention` means "other operators need to see this now." A high-priority doc may already be well-known (no flag needed). A medium-priority doc may contain a surprise finding that changes someone else's working assumptions (flag warranted). Use both when appropriate -- they answer different questions.

**Auto-flagging on ungraceful close.** If a session ends without the team flag prompt, the instance should auto-flag any files created that session with `priority: high`, using `Name (auto)` in `team_attention_by`. The human can review and remove auto-flags in a subsequent session.

### Harvest Tracking

Source files track provenance with a lean 4-field schema. The source YAML is the single source of truth for harvest provenance -- the Harvest Ledger (0.4) is a convenience view, and the session log holds the full narrative.

**Status values:**

| Status | Meaning |
|---|---|
| *(field absent)* | Untouched -- not yet reviewed |
| `pending` | Flagged for future harvest |
| `harvested` | Value extracted into companion and/or project docs |
| `reviewed` | Read but nothing harvested (reason in `harvest_notes`) |
| `superseded` | Replaced by a newer version |

**The four harvest fields:**

```yaml
harvest_status: harvested
harvested_into:
  - "[[c_Source Title]]"
  - "[[Codex#Section XIV]]"
  - "[[Story Bible#4.0]]"
harvest_date: 2026-04-02
harvest_notes: "Initial enrichment. Manual harvest extracted bonding curves framing. Filtered sensitive interpersonal content."
```

**Field definitions:**

- **`harvest_status`**: Pipeline state. See status values table above. **Never** add a blank or placeholder `harvest_status` field -- absence means untouched, and that's meaningful information.
- **`harvested_into`**: Array of wikilinks to ALL destinations -- companion notes (`c_` prefix) and project documents. Use section-level anchors as standard (e.g. `[[Codex#Section XIV]]`). The `c_` prefix naturally distinguishes pipeline enrichment from manual harvest.
- **`harvest_date`**: ISO date (YYYY-MM-DD) of harvest actions. Single value for first harvest; array for re-harvests (most recent last). Preserves the full trail of when the source was touched.
- **`harvest_notes`**: The "commit message" of the harvest -- editorial judgment about interpretive moves, filtered content, or skip reasons. One or two sentences. Most valuable for `reviewed` and `superseded` statuses where the *reason* matters more than the routing.

**Enrichment is harvesting.** When the pipeline creates a companion note, it writes back to the source YAML: adds the `c_` link to `harvested_into` and sets `harvest_status: harvested`. When an agent manually harvests into a project document, same pattern. One status field, one destinations array, one concept.

**The `companion:` field.** The unified `harvested_into` array makes the standalone `companion:` field on source files partially redundant -- the same `c_` link appears in both places. Keep `companion:` for now: pipeline scripts may prefer a dedicated field for quick companion lookup without parsing an array. Do not rely on `companion:` alone for provenance -- `harvested_into` is the canonical routing record.

**Deferred fields** (add to a source file only when the use case exists, not before):

- **`harvest_agent`**: Who performed the harvest. Currently tracked in the session log. Add to YAML if computed views need to filter by agent.
- **`harvest_type`** (initial / supplemental / review-only / superseded): Categorizes the transformation. Add if ledger queries need to filter by type.
- **`harvest_confidence`** (high / medium / low): For automated pipeline harvests that may need human review. Add when automated steps write to project documents.
- **`harvest_for`**: Which project(s) this source should be harvested into. String for single-project (`harvest_for: ReWoven`), array for multi-project (`harvest_for: [ReWoven, MetaMyth]`). Add to sources in shared locations (like `_Transcripts/`) that aren't inside a project folder.
- **`fathom_id`**: The Fathom recording ID (integer). Bridges between the Fathom Meeting Index and transcript files. Add to any Fathom-sourced transcript.

**Backward compatibility.** Existing source files don't need migration -- they gain new fields when next harvested. `harvested_date` (old) and `harvest_date` (new) are the same concept; instances should accept either when reading. `last_agent` (old) maps to session log entries; no YAML migration needed.

### Federation Fields

*Federation* is the process of copying a source file from a private vault folder into a project folder so that team members and their AIs can work with it. See the Federation Guide for the full workflow. The following YAML fields track that process.

**On the original** (in private folders):

```yaml
federated_to:
  - "[[Filename]]"
federated_date: YYYY-MM-DD
federated_note: "Full copy"
```

If later federated to a second project, append to `federated_to`.

**On the federated copy** (in the project folder):

```yaml
federated_from: "[[OriginalFilename]]"
federated_date: YYYY-MM-DD
federated_note: "Full copy"
```

Federated copies also carry harvest tracking fields (`harvest_status`, `harvested_into`, etc.) -- same schema as originals.

### AI-Generated Content Fields

If the text of a note was written by an AI agent, tag it as `ai-generated`. This is about transparency - readers should know when they're reading AI-written text.

```yaml
tags:
  - ai-generated
generating_agent: Andrew / Claude
```

`ai-generated` is a **tag**, not a content type - the note's `type:` should reflect what the content actually *is* (resource, document, companion, etc.), not who made it. This replaces the retired `AI-written` content type (D42).

**When to apply `ai-generated`:**
- The AI wrote the text - whether autonomously, from a prompt, or by synthesizing sources under human direction
- Content generated by external AI tools (Gemini, DeepSeek, ChatGPT) and imported into the vault
- Companion notes, AI-drafted documents, pipeline outputs, AI summaries

**When NOT to apply `ai-generated`:**
- Human-authored notes that an AI helped edit, format, or restructure - the human wrote the ideas
- Raw transcripts - these are recordings of human speech, not AI-generated text
- Web clippings - the original author is human, AI just captured the content

**The `generating_agent` field is optional but recommended.** Use the format `Operator / Agent` (e.g. `Jay Cousins / Gemini`, `Andrew / Claude`). If the agent is unknown (e.g. an imported doc where you know AI wrote it but not which model), just use the `ai-generated` tag without `generating_agent`.

### Date Format

All frontmatter dates use plain `YYYY-MM-DD`. Do not use ISO datetime strings (`2026-05-22T00:00:00.000Z`) - plain dates are sufficient for DW's day-level tracking and parse consistently in Dataview.

### The edit_log Field

A cumulative YAML list tracking every session that modified a file. The last entry is the last editor; the full list is the provenance trail.

```yaml
edit_log:
  - "DW-S70 2026-05-23"
  - "Andrew 2026-05-24"
  - "WV-S45 2026-05-25"
```

- One entry per session (deduplicated). Append-only.
- Agent edits: `"ProjectAbbrev-SNN YYYY-MM-DD"`. Human edits: `"Name YYYY-MM-DD"`.
- **Section files:** required. **Infrastructure files (0.x) and standalone docs:** recommended. **Shell files:** none - shells are assembly surfaces; their `updated` field bumps when sections change, but they do not accumulate a log.
- Updated at session close via the session-closer (Step 3.9).

Design rationale: `Workshop/Design/YAML Metadata Protocol Decisions.md`.

*Extracted from the DataWizard Universal Protocol (section 4.0) in the S182 demolition (D94). Structural and formatting conventions live in the [[Conventions Registry]].*
