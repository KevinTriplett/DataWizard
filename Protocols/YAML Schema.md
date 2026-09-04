---
title: YAML Schema
type: protocol
created: '2026-06-13'
updated: 2026-09-04
operator: Andrew
priority: high
maturity: working
edit_log:
  - DW-S182 2026-06-13
  - DW-S183 2026-06-14
  - "DW-S191 2026-06-21: added stream: session-log field"
  - "DW-S198 2026-06-23: added claim_id stub field"
  - "DW-S262 2026-08-08: added embed_targets field (embeddable synth-note
    harvest; D116)"
  - "DW-S272 2026-08-18: Section 4 reconciled to flag* canonical (F1); added
    flag_due/flag_default/flag_status + flag_note content requirement +
    team_attention* deprecation mapping + flagged_for non-canonical note"
  - "DW-S279 2026-08-18: generic-names sweep of examples (C2, Seed
    depersonalization; Flag Surfacing Chain B2)"
  - "DW-S309 2026-08-30: placeholder sweep completed - Alice/Ben/Cara ->
    Operator-A/B/C (16 residual uses the S279 sweep missed; S289
    role-placeholder rule; meta-learning review S288-S300)"
  - DW-S324 2026-09-04 - edit_log rolling window + origin field (D127)
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

**`claim_id`**: A short random token (e.g. a 6-8 char hex nonce) stamped on a session-log *stub* at claim time to make session-claiming collision-evident under concurrency. After writing the stub, the claiming instance re-reads it and checks `claim_id`: if the on-disk value is not the one it wrote, a parallel instance won the slot, so it claims the next free identifier instead (PI Orientation Step 3, verify-after-claim). Ephemeral - present only while `status: in-progress`; the session-closer strips it when it overwrites the stub with the full entry at close. Design: [[Session Claiming Under Concurrency]].

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
| `operator` | First name (e.g. Operator-A) | Who created it |
| `origin` | Creation entry (e.g. 'DW-S161 2026-06-09'), immutable | Creation provenance |
| `edit_log` | Seeded with the same entry as `origin`; thereafter a rolling last-5 window (D127) | Recent-touch window |

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

*These fields power multi-operator coordination: the shared team dashboard, the session-close flag workflow, and the orientation-time flag sweep. The canonical cluster is `flag*` (below). The older `team_attention*` names are deprecated -- see the mapping at the end of this section.*

**`operator`**: The human team member whose session created or substantially updated this file. Set at creation time as part of the birth metadata contract (see above). Use first name only (e.g. `Operator-A`, `Operator-B`, `Operator-C`). Apply to:
- Session log section files (always)
- Content documents created or substantially updated during a session

This field was not applied to files before the birth metadata contract. Existing files gain it when next touched; no bulk backfill needed.

**The `flag*` cluster.** A flag is a request for a specific operator's attention on a specific file, surfaced to them at orientation (the flag sweep) and on the team dashboard. The cluster is the delivery interface: queries read it, session close writes it.

**`flag`**: ISO date (YYYY-MM-DD) the file was flagged. When present, the file is a live flag. Set `flag_by`, `flag_note`, and `flag_for` at the same time.

**`flag_by`**: Who flagged the file. First name for human-confirmed flags (e.g. `Operator-A`). Use `Name (auto)` for auto-flags generated on ungraceful session close (e.g. `Operator-A (auto)`) -- this lets the dashboard render auto-flags differently and helps reviewers calibrate urgency.

**`flag_for`**: The operators the flag is addressed to, as a YAML list of first names (e.g. `[Operator-A, Operator-B]`). This is the routing field the orientation sweep matches against. When an operator acts on their item, remove their name (union-merge discipline). A conscious defer KEEPS the name -- the item re-surfaces due-first next session (marked `flag_status: deferred`) rather than vanishing, so a deferral is never mistaken for a handled item. Clear the whole cluster when the list empties. A single name may be written inline (`flag_for: Operator-A`) or as a one-item list.

**`flag_note`**: Required when `flag` is set. The context string, and it must **state the decision needed and what is blocked until it is made**. "Please review the tiers" fails; "Approve or amend the priority tiers -- outreach proceeds in the current order by default on silence" passes. Keep it to one line at a glance on the dashboard. If the note runs long or contains characters that stress YAML (colons, quotes, brackets), fold it -- use a block scalar (`flag_note: >-`) or a single-quoted string -- because an over-long or unescaped quoted note has broken frontmatter parsing in practice, after which a parser returns empty frontmatter silently and the flag reads as absent. A flag whose note breaks parsing is an undelivered flag.

**`flag_due`** (optional): ISO date by which a response is needed. The sweep orders due-first and surfaces overdue items with their default in effect.

**`flag_default`** (optional): What happens on silence after `flag_due` -- the text that turns an unanswered flag into a decision rather than an indefinite block (e.g. `outreach proceeds in the listed order`). Pairs with `flag_due`.

**`flag_status`** (optional): Lifecycle marker. `deferred` = the operator saw it and consciously deferred; the name stays on `flag_for` and the item re-surfaces due-first next session. `expired-unread` = past `flag_due` with no response; the expiry pass sets this and clears the names, recording that the default is now in effect.

```yaml
operator: Operator-A
flag: 2026-05-27
flag_by: Operator-A
flag_for: [Operator-B, Operator-C]
flag_note: "Approve or amend the funder shortlist -- outreach proceeds in listed order on silence"
flag_due: 2026-06-03
flag_default: outreach proceeds in the listed order
```

**`flag` vs `priority: high`.** Orthogonal signals. `priority` measures a document's long-term importance to the project. `flag` means "these operators need to see this now." A high-priority doc may already be well-known (no flag needed); a medium-priority doc may carry a surprise finding that changes someone else's working assumptions (flag warranted). Use both when appropriate -- they answer different questions.

**Auto-flagging on ungraceful close.** If a session ends without the flag prompt, the instance auto-flags any files it created that session with `priority: high`, using `Name (auto)` in `flag_by`. The human reviews and removes auto-flags in a later session.

**`flagged_for` is not canonical.** Some vaults use a `flagged_for` field as a wikilink pointer to a separate flags document -- that is unrelated to operator attention and must not be read as an attention flag. Use `flag_for` for attention routing.

**Deprecated: `team_attention*`.** Phase 0 shipped `team_attention` / `team_attention_by` / `team_attention_note`. These are superseded by the `flag*` cluster; no live consumer reads them. Migrate on next touch:

| Deprecated | Canonical |
|---|---|
| `team_attention` | `flag` |
| `team_attention_by` | `flag_by` |
| `team_attention_note` | `flag_note` |
| *(none)* | `flag_for` (new -- the routing field the sweep requires) |

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

### Embed Targets (synth-note harvest)

**`embed_targets`** lives on a *synth note* -- the `c_` companion a multi-destination harvest is written into under the embeddable synth-note pattern -- not on the source. It is an array of wikilinks to the destination docs that transclude the synth note's sections, recording the second provenance hop after the source's `harvested_into` points at the synth note. This keeps the onward embed flow machine-scannable.

```yaml
embed_targets:
  - "[[Working Plan Doc]]"
  - "[[Decision Log]]"
```

Present only on synth notes built for this pattern; absent on ordinary companions and sources. The synth note stays `type: companion`. Convention and full workflow (Embed Map, team-download header, heading-parity close step): [[Conventions Registry]] (Harvest via embeddable synth note). Provenance model: [[Harvest Provenance Architecture]].

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
generating_agent: Operator-A / Claude
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

**The `generating_agent` field is optional but recommended.** Use the format `Operator / Agent` (e.g. `Operator-B / Gemini`, `Operator-A / Claude`). If the agent is unknown (e.g. an imported doc where you know AI wrote it but not which model), just use the `ai-generated` tag without `generating_agent`.

### Date Format

All frontmatter dates use plain `YYYY-MM-DD`. Do not use ISO datetime strings (`2026-05-22T00:00:00.000Z`) - plain dates are sufficient for DW's day-level tracking and parse consistently in Dataview.

### The origin and edit_log Fields

**`origin`** is the immutable creation entry: which session (or person) created the file, in the same format as an edit_log entry. Written at birth, never modified thereafter.

```yaml
origin: 'DW-S161 2026-06-09 - created during the birth-metadata build'
```

**`edit_log`** is a rolling window of the last 5 sessions that modified the file, oldest first (append at the tail). It is a recency hint, not the history. The full per-file provenance trail's canonical home is the session log: every session entry's "Files created" / "Files updated" manifest (session-closer Output Format, Step 3.8), required at every close tier - plus git history where the vault is a repo. (D127; supersedes the earlier cumulative append-only contract.)

```yaml
edit_log:
  - 'DW-S70 2026-05-23'
  - 'Operator-A 2026-05-24'
  - 'WV-S45 2026-05-25 - repaired YAML break'
```

- **Always single-quote entries.** Unquoted colons and wrapped long lines have twice broken whole-file frontmatter parsing; quoting kills the failure class regardless of length.
- One entry per session (deduplicated), stamped once per file at session close - not on every touch.
- Entries are one compact line: session ID + date (agent edits `'ProjectAbbrev-SNN YYYY-MM-DD'`, human edits `'Name YYYY-MM-DD'`), plus an optional short clause of a few words. Narrative belongs in the session log entry, not here.
- When appending would exceed 5 entries, drop the oldest **in the same write**. Nothing is copied anywhere at trim time: the trimmed history is already recorded in the session log manifests.
- **Section files:** required. **Infrastructure files (0.x) and standalone docs:** recommended. **Shell files:** none - shells are assembly surfaces; their `updated` field bumps when sections change, but they do not accumulate a log.
- Preferred writer: `stamp_editlog.py` (quote-on-write, append-and-trim, `--manifest` batch mode). Hand edits are legal under the same contract: pass the full windowed list back in a single write (never a bare append via `update_frontmatter` merge - see the MCP Reliability guide's array-wipe warning).
- SKILL.md files that used edit_log as a version changelog keep that history in a body `## Changelog` section instead; their frontmatter edit_log rolls like everywhere else.
- Updated at session close via the session-closer (Step 3.8).
- Migration note: trimming begins only after a project's one-time cleanup pass has archived its pre-D127 history; until then, append-only continues.

Design rationale: D127 (rolling window + origin - link-don't-restate applied to provenance). Earlier: `Workshop/Design/YAML Metadata Protocol Decisions.md`.

*Extracted from the DataWizard Universal Protocol (section 4.0) in the S182 demolition (D94). Structural and formatting conventions live in the [[Conventions Registry]].*
