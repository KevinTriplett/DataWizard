---
title: Content Type Taxonomy
type: project-doc
created: '2026-03-02'
updated: '2026-03-08'
version: v2.6
decision: 'D33, D38, D42, D43'
last_session_date: '2026-03-08'
last_session_summary: >-
  v2.6 — Retired AI-written as type, replaced with ai-generated tag. Added
  structural formatting signal to classifier. 20 active types.
status: active
---

# Content Type Taxonomy v2.6

> The canonical reference for all YAML `type:` values. Used by the enrichment pipeline classifier, review queues, and human editors.

---

## YAML Conventions

- Always lowercase key: `type:` (not `Type:`)
- Values are lowercase with hyphens: `meeting-note`, `video-transcript`, `seedpod`
- Single value only — no comma-separated types
- All pipeline outputs referencing vault notes use `[[wikilinks]]`

---

## Active Types (20)

---

### article
Prose content — essays, blog posts, reports, opinion pieces, speculative fiction, academic writing.

**Signals**: Narrative paragraphs, byline/author, publication date, no product/service offerings.
**Example**: [[A Future History of the Environment – The Solutions Journal]]

---

### entity
Organization, company, collective, project, or initiative homepage. **Persistent** — not time-bounded. Distinguish from `event` (which has specific dates).

**Signals**: "About us" language, mission statement, team listings, programs/services, calls to action (join, donate, partner). No specific event dates.
**Example**: [[r3.0 - Redesign for Resilience & Regeneration]]

---

### event
A clipped event listing page — gathering, conference, festival, or convergence with specific dates, location, and program. Would otherwise be misclassified as `entity`. **Time-bounded**.

**Signals**: URL + specific dates + physical location + agenda, lineup, or speaker list. Ticket/registration links common.
**YAML additions**: `event_date:`, `event_location:` — useful for future queries ("events I'm tracking in Lisbon").
**Example**: [[Parallel Society]]

---

### person
Individual's personal page, LinkedIn profile, bio, portfolio.

**Signals**: First-person or biographical language, headshot, role/title, personal projects.

---

### document
A purposefully constructed working doc — proposals, pitches, strategy docs, plans. Authorship is a signal but not the definition: a proposal written *about* your project by someone else still qualifies.

**Signals**: Constructed toward a specific goal or audience. No publication intent. Project-specific. Not reference material (that's `resource`). Not published prose (that's `article`).
**Example**: [[Logic of Life Proposal - v01]], [[Phased Investment Strategy (Alex)]]

---

### video-transcript
Transcript of a public video — YouTube, Vimeo, or similar. Raw captions, pre-processed bullet points, or manual notes from a recording. **Public/published content**.

**Signals**: YouTube/Vimeo URL in source, timestamps, speaker labels, conversational or lecture structure.
**Example**: [[_Clippings/Jeff Emmett on Design Patterns from Commons Stack]]

*(Replaces `transcript` — retired in v2.5)*

---

### podcast-transcript
Transcript of a published podcast episode. Distinct from `video-transcript`: guest/host dynamic, episode metadata (show name, number), RSS/podcast URL.

**Signals**: Podcast or RSS URL, show + episode structure, host introducing a guest, multi-speaker dialogue with clear interviewer role.
**YAML additions**: `show:`, `episode:` fields recommended.
**Example**: [[Daniel Christian Wahl - Leading By Nature Podcast]]

---

### meeting-transcript
Raw transcript from a personal meeting (via Fathom or similar). **Private** — your conversations with your network. Lives in `_Transcripts/`.

**Signals**: Fathom URL, speaker labels with email addresses, personal conversational tone, action items.
**Example**: [[2026-02-19 Max Pangerl- Sumbios Transcript]]

---

### voice-memo-transcript
Transcript of a personal voice memo, transcribed via Whisper. Single speaker. Often has transcription artifacts from noisy/unclear source audio.

**Signals**: No URL, no speaker labels (or just one speaker — you), informal/stream-of-consciousness structure, possible Whisper transcription artifacts.

*(Replaces `voice-memo` — retired in v2.5)*

---

### meeting-note
Your personal notes taken during or after a meeting. Distinct from `meeting-transcript` (raw Fathom output). Lives in `_Meetings/` or vault root.

**Signals**: In `_Meetings/` folder, date-prefixed filenames, informal bullet points, personal observations, no Fathom URL or speaker email labels.
**Example**: [[2025-07-15 Boomer Media Meet Up]]

---

### seedpod
Multi-idea personal notes — longer than a `seed`, not formal content. Multiple distinct ideas in one note, separated by line breaks. Covers: gathering notes, video watch notes with timecodes, multi-idea scratchpads, brainstorm dumps.

**Delineation from `seed`**: A seed is 1–3 lines, one idea. A seedpod has multiple ideas with line breaks between them.
**Signals**: No URL (or URL is incidental), multiple distinct ideas, personal/informal tone, line breaks between ideas, may have timecodes or loose structure.
**Enrichment**: Tags and themes only. No companion note. Ideas may be individually linked to lexicon entries or other notes during Step 5 (link).
**Example**: [[Paul Wheaton]], [[Pete Meyers]]

*(Replaces `event-capture` — retired in v2.5)*

---

### seed
A raw idea, observation, question, or fragment captured quickly. Proto-content — title often *is* the content.

**Signals**: Short content (1–3 lines, < 300 chars body, or empty), no URL/source field, reads like a thought, question, or observation. Common in `_!nbox/`.
**Enrichment**: Tags and themes in YAML only. No companion note. Too short for summarization or meme mining.

---

### resource
Reference material, frameworks, foundational documents, methodology docs.

**Signals**: Informational/educational tone, framework descriptions, not time-bound, not project-specific.
**Example**: [[Multiscalar Networks]], [[Omniwar]]

---

### resource-list
A curated collection of links to other resources.

**Signals**: Dominated by URLs/links, list structure, minimal prose per item.
**Example**: [[Tijn Tjoelker - Resources]]

---

### multi-part
One chapter/section of a larger work.

**Signals**: Numbered titles, shared source URL domain, shared author, sequential content.
**YAML additions**: `series:` field linking to parent series note, `chapter:` number.

---

### video
A video page — YouTube, Vimeo, or other platform. The source note contains the clipped page (title, description, metadata). If a transcript is available via yt-dlp, it is appended to the same note body.

**Signals**: YouTube/Vimeo URL in source, video embed, any content length.
**YAML additions**: `has_transcript: true | false`, `transcript_date:` (when extraction ran).

**Enrichment behavior**:
- `has_transcript: true` → full enrichment (overview summary, detailed summary, speakers, key topics, themes, tags, lexicon candidates)
- `has_transcript: false` → lighter enrichment from description only (overview summary, key topics, themes, tags)

**Classifier rule**: Any note with a YouTube or Vimeo URL → `video`, always. No LLM needed.

---

### companion
AI-generated summary/enrichment of a source note. Created by the enrichment pipeline. Always has a `source:` field pointing to the original note.

**Signals**: `source:` field in YAML, lives in `_Companions/`, title prefixed with `c_`.
**Example**: [[Summary_Voice Memo - 2026-01-29 14 45 22 - Rue Mercelis]]

**Not enriched further** — these ARE the enrichment output. The pipeline reads these to avoid re-processing.

---

### AI-written (RETIRED — v2.6)
~~AI-authored creative or analytical content — worldbuilding docs, generated reports, speculative pieces.~~

**Retired**: D42. AI authorship is metadata, not a content type. Classify by what the content IS (resource, document, article, etc.) and add `ai-generated` tag. Existing `type: AI-written` notes should be reclassified.

---

### message
An asynchronous communication — voice note, audio message, or text message sent to or received from someone. Distinct from `voice-memo-transcript` (to yourself) and `meeting-note`/`meeting-transcript` (live conversations).

**Signals**: Directed at a specific person, conversational but one-directional, often transcribed from audio message (WhatsApp, iMessage voice note), may contain links or references shared between people.
**Example**: [[2026-02-04 Zachary Marlow]], [[2026-02-07 Zachary Marlow]]

---

## Retired Types

| Old Type | Replacement | Notes |
|---|---|---|
| `concept` | `tags: [concept]` | Proto-lexicon entries, now a tag not a type (D33) |
| `capture` | `seedpod` | Renamed to event-capture (D33), then to seedpod (D38) |
| `reference` | `resource` | Renamed for clarity (D33) |
| `meeting` | `meeting-note` | Renamed; split from `meeting-transcript` (D33) |
| `summary` / `AIsummary` | `companion` | For AI summaries of source notes (D33) |
| `AI` / `AI_generated` | `AI-written` | Consolidated (D33) |
| `transcript` | `video-transcript` | Renamed for explicit *-transcript family convention (D38) |
| `voice-memo` | `voice-memo-transcript` | Renamed for explicit *-transcript family convention (D38) |
| `event-capture` | `seedpod` | Renamed — broader concept than events (D38) |
| `AI-written` | tag: `ai-generated` | AI authorship is metadata, not a content type (D42) |

---

## Classifier Decision Tree

```
Has source: field pointing to vault note?
  → YES → companion

In _Transcripts/ folder OR has Fathom URL + speaker emails?
  → YES → meeting-transcript

In _Meetings/ folder OR date-prefixed + informal meeting notes?
  → YES → meeting-note

Has podcast/RSS URL OR show + episode structure?
  → YES → podcast-transcript

YouTube or Vimeo URL in source?
  → YES → video

Has URL + specific dates + location + agenda or lineup?
  → YES → event

Has source: field, no URL, single speaker, Whisper artifacts?
  → YES → voice-memo-transcript

Async communication to/from a specific person (voice note, text, audio message)?
  → YES → message

Short content (1–3 lines, < 300 chars), no URL, one idea?
  → YES → seed

Multiple ideas with line breaks, personal/informal, no URL?
  → YES → seedpod

Biographical language, headshot, role/title?
  → YES → person

Homepage with "about us", mission, programs, no specific dates?
  → YES → entity

Constructed working doc — proposal, pitch, strategy, plan?
  → YES → document

List of 5+ URLs with brief labels?
  → YES → resource-list

Framework/methodology/reference document?
  → YES → resource

Numbered title, part of a series?
  → YES → multi-part

Default → article
```

---

*For version history and design decisions, see `_DataWizard/Workshop/Taxonomy Version History.md`*
