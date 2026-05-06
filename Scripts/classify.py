#!/usr/bin/env python3
"""
DataWizard Content Classifier (Step 1 of Pipeline)
====================================================
Classifies .md notes in your vault by content type using:
  1. Deterministic rules (folder path, YAML fields, URL patterns) — fast & certain
  2. LLM fallback via Ollama — for ambiguous notes

Implements D29 (classification-first batch processing) from the Decision Log.
Uses the Content Type Taxonomy v2.5 (21 active types).

No heavy dependencies — uses regex-based YAML parsing (same as taxonomy_migrate.py)
and `requests` for Ollama API calls.

Usage:
    # Classify everything in _Clippings/ (dry run — default)
    python3 classify.py --vault ~/path/to/vault --folder _Clippings/

    # Classify specific files
    python3 classify.py --vault ~/path/to/vault --files "note1.md" "note2.md"

    # Apply results after review
    python3 classify.py --vault ~/path/to/vault --folder _!nbox/ --execute

    # Apply from a previous dry run log (no LLM calls needed)
    python3 classify.py --vault ~/path/to/vault --apply-log "_DataWizard/Workshop/Classification Logs/classification_log_dryrun.md"

    # Use a different model or Ollama URL
    python3 classify.py --vault ~/path/to/vault --folder _Clippings/ --model qwen3:32b

    # Recursive scan (include subfolders)
    python3 classify.py --vault ~/path/to/vault --folder _!nbox/ --recursive
"""

import argparse
import json
import re
import os
import sys
import time
from pathlib import Path
from datetime import datetime

try:
    import requests
except ImportError:
    print("ERROR: 'requests' library required. Install with: pip install requests")
    sys.exit(1)


# ─────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────

# The 21 active types from Content Type Taxonomy v2.5
VALID_V2_TYPES = {
    "article",
    "entity",
    "event",
    "person",
    "document",
    "video-transcript",
    "podcast-transcript",
    "meeting-transcript",
    "voice-memo-transcript",
    "meeting-note",
    "seedpod",
    "seed",
    "message",
    "resource",
    "resource-list",
    "multi-part",
    "video",
    "companion",
}

# Retired types that should NOT count as "already classified"
RETIRED_TYPES = {
    "concept",
    "capture",
    "reference",
    "meeting",
    "summary",
    "AIsummary",
    "AI",
    "AI_generated",
    "transcript",       # → video-transcript (D38)
    "voice-memo",       # → voice-memo-transcript (D38)
    "event-capture",    # → seedpod (D38)
    "AI-written",      # → tag: ai-generated (D42)
}

# Content preview length for LLM classification
CONTENT_PREVIEW_CHARS = 3000

# Default Ollama settings
DEFAULT_OLLAMA_URL = "http://localhost:11434"
DEFAULT_MODEL = "qwen3.5:27b"
DEFAULT_CONFIDENCE_THRESHOLD = "medium"  # low-confidence → Review Queue

# Fathom URL pattern
FATHOM_PATTERN = re.compile(r'fathom\.video', re.IGNORECASE)

# YouTube URL pattern
YOUTUBE_PATTERN = re.compile(r'(youtube\.com|youtu\.be)', re.IGNORECASE)

# Podcast / RSS URL pattern
PODCAST_PATTERN = re.compile(r'(podcasts\.apple\.com|open\.spotify\.com/episode|overcast\.fm|pocketcasts\.com|pod\.link|anchor\.fm|buzzsprout\.com|simplecast\.com|transistor\.fm|feeds\.|rss\.|/podcast/|/episodes?/)', re.IGNORECASE)

# Event date pattern — specific dates suggest an event listing, not an entity
EVENT_DATE_PATTERN = re.compile(
    r'(\b(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|'
    r'Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)'
    r'\s+\d{1,2}(?:[-–]\d{1,2})?[,\s]+20\d{2}\b)'
    r'|(\b20\d{2}-\d{2}-\d{2}\b)',  # ISO date
    re.IGNORECASE
)

# Event location keywords (suggest a gathering with a physical venue)
EVENT_LOCATION_PATTERN = re.compile(
    r'\b(venue|location|address|tickets?|register|registration|agenda|programme?|'
    r'lineup|speakers?|schedule|converge|convergence|festival|summit|conference|'
    r'unconference|gathering|workshop|retreat)\b',
    re.IGNORECASE
)

# Speaker email pattern (common in Fathom transcripts)
SPEAKER_EMAIL_PATTERN = re.compile(r'\b[\w.-]+@[\w.-]+\.\w{2,}\b')

# Frontmatter pattern
FM_PATTERN = re.compile(r'^---\s*\n(.*?)\n---\s*\n', re.DOTALL)


# ─────────────────────────────────────────────────────────
# YAML / File Utilities (no external dependencies)
# ─────────────────────────────────────────────────────────

def read_file(path):
    """Read file contents."""
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()


def write_file(path, content):
    """Write file contents."""
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)


def parse_frontmatter(content):
    """Extract frontmatter fields as a dict (simple regex-based parser)."""
    match = FM_PATTERN.match(content)
    if not match:
        return {}, content

    fm_text = match.group(1)
    body = content[match.end():]
    fields = {}

    # Extract simple key: value pairs (handles quoted and unquoted values)
    for line in fm_text.split('\n'):
        kv_match = re.match(r'^(\w[\w-]*)\s*:\s*(.+)$', line.strip())
        if kv_match:
            key = kv_match.group(1)
            value = kv_match.group(2).strip().strip('"').strip("'")
            fields[key] = value

    # Also grab the raw frontmatter text for modification
    fields['_raw_fm'] = fm_text
    fields['_fm_match'] = match

    return fields, body


def get_type_field(fields):
    """Get the type value from frontmatter, checking both 'type' and 'Type' keys."""
    return fields.get('type') or fields.get('Type') or None


def get_url_field(fields):
    """Get URL from frontmatter."""
    return fields.get('URL') or fields.get('url') or fields.get('source') or None


def get_body_text(body, max_chars=CONTENT_PREVIEW_CHARS):
    """Get first N characters of body content for classification."""
    return body[:max_chars].strip()


def add_type_to_frontmatter(content, type_value):
    """Add type field to existing frontmatter, or create frontmatter if none exists."""
    match = FM_PATTERN.match(content)
    if match:
        fm_text = match.group(1)
        # Check if type already exists
        if re.search(r'^type\s*:', fm_text, re.MULTILINE):
            # Replace existing type line
            new_fm = re.sub(r'^type\s*:.*$', f'type: {type_value}', fm_text, count=1, flags=re.MULTILINE)
        elif re.search(r'^Type\s*:', fm_text, re.MULTILINE):
            # Replace capital-T Type line with lowercase
            new_fm = re.sub(r'^Type\s*:.*$', f'type: {type_value}', fm_text, count=1, flags=re.MULTILINE)
        else:
            # Add type as first field
            new_fm = f'type: {type_value}\n{fm_text}'
        return content[:match.start(1)] + new_fm + content[match.end(1):]
    else:
        # No frontmatter — create it
        return f'---\ntype: {type_value}\n---\n{content}'


# ─────────────────────────────────────────────────────────
# Rule-Based Classification
# ─────────────────────────────────────────────────────────

def classify_by_rules(rel_path, fields, body):
    """
    Apply deterministic rules. Returns (type, rule_description) or (None, None).

    Rule order matches the Classifier Decision Tree from Content Type Taxonomy v2.5.
    """
    url = get_url_field(fields) or ""
    rel_str = str(rel_path)
    title = fields.get('title', '') or rel_path.stem
    source_field = fields.get('source', '')
    body_preview = body[:1500]

    # 1. Has source: field pointing to a vault note → companion
    if source_field and ('[[' in source_field or source_field.endswith('.md')):
        return 'companion', 'has source: field pointing to vault note'

    # 2. Lives in _Summary/ or _Companions/, or title starts with Summary_ or c_
    if '_Summary/' in rel_str or '_Companions/' in rel_str:
        return 'companion', f'in {rel_str.split("/")[0]}/ folder'
    if title.startswith('Summary_') or title.startswith('c_'):
        return 'companion', f'title prefix: {title[:10]}...'

    # 3. In _Transcripts/ folder OR has Fathom URL → meeting-transcript
    if '_Transcripts/' in rel_str:
        return 'meeting-transcript', '_Transcripts/ folder'
    if FATHOM_PATTERN.search(url):
        return 'meeting-transcript', 'Fathom URL detected'
    # Also check body for Fathom URLs (sometimes in content, not YAML)
    if FATHOM_PATTERN.search(body_preview) and SPEAKER_EMAIL_PATTERN.search(body_preview):
        return 'meeting-transcript', 'Fathom URL + speaker emails in content'

    # 4. In _Meetings/ folder → meeting-note
    if '_Meetings/' in rel_str:
        return 'meeting-note', '_Meetings/ folder'

    # 5. Podcast/RSS URL → podcast-transcript (check before YouTube rule)
    if PODCAST_PATTERN.search(url):
        return 'podcast-transcript', 'podcast/RSS URL detected'

    # 6. YouTube/Vimeo URL → always video (D35)
    if YOUTUBE_PATTERN.search(url):
        return 'video', 'YouTube/Vimeo URL detected (D35: always video)'

    # 7. URL + specific dates + event location keywords → event (D38)
    # Check before entity — event pages often look like entity pages
    if url:
        body_and_title = title + ' ' + body_preview
        if EVENT_DATE_PATTERN.search(body_and_title) and EVENT_LOCATION_PATTERN.search(body_and_title):
            return 'event', 'URL + specific dates + event location keywords (D38)'

    # 8. No URL + short content → seed (D36)
    if not url:
        body_stripped = body.strip()
        if len(body_stripped) < 300:
            return 'seed', f'no URL + short body ({len(body_stripped)} chars) (D36)'

    return None, None


# ─────────────────────────────────────────────────────────
# LLM Classification via Ollama
# ─────────────────────────────────────────────────────────

# NOTE: Customize the domain description below for your vault's content focus.
# The default reflects a regenerative systems knowledge base.
CLASSIFICATION_PROMPT = """You are a content classifier for a knowledge management system focused on
regenerative systems, bioregionalism, decentralized governance, and related fields.

Given the following content, determine its type.

Types (Content Type Taxonomy v2.5):
- article: Prose content — essays, blog posts, reports, opinion pieces, academic writing. Published for general readership.
- entity: Organization, company, collective, project, or initiative homepage. Persistent — no specific event dates.
- event: A clipped event listing page — gathering, conference, festival with specific dates, location, and agenda. Time-bounded.
- person: Individual's personal page, bio, portfolio, LinkedIn profile.
- document: Purposefully constructed working doc — proposals, pitches, strategy docs, plans. Not published prose; constructed toward a specific goal or audience.
- video-transcript: Public video transcript — YouTube/Vimeo. Timestamps, speaker labels, conversational/lecture structure.
- podcast-transcript: Published podcast episode transcript. Guest/host dynamic, episode metadata (show name, number).
- meeting-transcript: Personal meeting transcript from Fathom or similar. Speaker emails in content. PRIVATE.
- voice-memo-transcript: Personal voice memo transcribed via Whisper. Single speaker, no URL, informal/stream-of-consciousness, possible transcription artifacts.
- meeting-note: Personal notes from a meeting — informal bullets, observations, no Fathom URL.
- seedpod: Multi-idea personal notes — multiple distinct ideas with line breaks. Longer than a seed. Covers: gathering notes, video watch notes with timecodes, multi-idea scratchpads.
- seed: Raw idea, observation, question, or fragment. 1–3 lines max, no URL, title often IS the content.
- message: Async communication (voice note, text, audio message) directed at a specific person.
- resource: Reference material, frameworks, foundational documents, methodology docs. Not project-specific.
- resource-list: Curated collection of 5+ links/resources with minimal prose per item.
- multi-part: One chapter/section of a larger work (numbered titles, sequential content, shared source).
- video: Video page — YouTube/Vimeo with description/metadata. Transcript may be appended.
- companion: AI-generated summary of a source note. Has source: field in YAML pointing to another note.

NOTE: AI-written/AI-generated content is NOT a content type. If a note was generated by AI, classify it by what it actually IS (resource, document, article, etc.) and the pipeline will add an `ai-generated` tag. Do not classify anything as `AI-written`.

Key signals:
- YouTube or Vimeo URL → video (always)
- Podcast/RSS URL → podcast-transcript
- Fathom URL + speaker emails → meeting-transcript
- URL + specific dates + venue/tickets/agenda/lineup → event (not entity)
- No URL + multiple distinct ideas with line breaks → seedpod
- No URL + 1–3 lines, single idea → seed
- No URL + single speaker + informal + Whisper artifacts → voice-memo-transcript
- Directed at specific person + async (voice note, text) → message
- Homepage with "about us", mission, programs, no specific dates → entity
- Proposal, pitch, strategy doc, plan → document (not article)
- List of 5+ URLs with brief labels → resource-list
- Framework/methodology/reference material → resource
- Biographical language, headshot, role/title → person
- source: field pointing to vault note → companion
- AI-generated content → classify by what it IS (resource, document, article, etc.), not by authorship

CRITICAL classification biases:
- When in doubt between seedpod and document/article/entity, CHOOSE SEEDPOD. Seedpods get harvested for ideas later; misclassifying as document/article means they may never be reviewed. Err toward seedpod.
- No URL is a STRONG signal against entity and article. Entity pages almost always have a URL (clipped from a website). If there is no URL and the title sounds like an organization name, it is most likely a seedpod containing personal notes ABOUT that organization — not the entity's homepage.
- No URL is also a strong signal against article. Articles are published prose clipped from the web — they have URLs. No URL + prose = more likely seedpod or document.
- person type REQUIRES the person's actual name as the note title (e.g., "John Smith", "Jane Doe"). A note listing someone's projects or work is NOT a person note — it's a seedpod or resource-list. If the title contains multiple words that are not a person's name (e.g., "Syntony Times - Togetherland - Transmedium Productions"), it is NOT a person note.
- Notes dominated by [[wikilinks]] to other vault notes (double-bracket links) are likely seedpod or personal index, not entity/article/person.
- seedpod vs document: The distinction is INTENT, not quality of writing. A document has a specific external audience and purpose (pitch deck for investors, strategy doc for a team, proposal for a funder). A seedpod is personal thinking/notes, regardless of how polished, dense, or organized the writing is. If there is no clear external audience, it's a seedpod.
- STRUCTURAL FORMATTING signals document or resource, NOT seedpod. Notes with numbered sections ("1. ...", "2. ..."), markdown headers (## Section Name), formal outlines, or structured formatting are more likely `resource` or `document`. Seedpods are informal — bullet points, line breaks between ideas, freeform notes. If the note looks like it was organized with an intentional structure, it is probably not a seedpod.

IMPORTANT distinctions:
- event vs entity: event has specific dates + location + agenda; entity is persistent with no event dates
- seed vs seedpod: seed is 1–3 lines, one idea; seedpod has multiple ideas with line breaks
- document vs article: document is a working doc with a specific goal/audience (pitch, proposal, plan); article is published prose for general readership
- voice-memo-transcript vs seedpod: voice-memo-transcript is transcribed audio (single speaker, informal speech patterns); seedpod is typed personal notes
- video-transcript vs podcast-transcript: video-transcript is from YouTube/Vimeo; podcast-transcript has host/guest dynamic and episode metadata

Respond with ONLY the type value followed by a pipe and your confidence level.
Example: article|high

Confidence levels:
- high: Very clear match, strong signals present
- medium: Reasonable classification but some ambiguity
- low: Best guess, could plausibly be another type

---

FILE PATH: {file_path}
SOURCE URL: {url}

YAML FRONTMATTER:
{frontmatter}

CONTENT (first ~3000 chars):
{content}"""


def classify_with_llm(rel_path, fields, body, ollama_url, model):
    """
    Send note to Ollama for classification.
    Returns (type, confidence, reasoning) or (None, None, error_message).
    """
    url = get_url_field(fields) or "(none)"

    # Build frontmatter summary for the prompt (exclude internal keys)
    fm_display = "\n".join(
        f"{k}: {v}" for k, v in fields.items()
        if not k.startswith('_')
    )

    body_preview = get_body_text(body)

    prompt = CLASSIFICATION_PROMPT.format(
        file_path=str(rel_path),
        url=url,
        frontmatter=fm_display or "(no frontmatter)",
        content=body_preview or "(empty)",
    )

    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False,
        "think": False,  # Disable thinking mode (Qwen3/3.5, DeepSeek, etc.)
        "options": {
            "num_ctx": 4096,
            "temperature": 0.1,
            "num_predict": 50,
        },
    }

    try:
        start = time.time()
        resp = requests.post(
            f"{ollama_url}/api/generate",
            json=payload,
            timeout=120,
        )
        elapsed = time.time() - start
        resp.raise_for_status()

        data = resp.json()
        raw_response = data.get("response", "").strip()

        # Parse type|confidence from response
        # Handle various response formats the LLM might produce
        # Clean up any thinking artifacts or extra text
        clean = raw_response.split('\n')[0].strip()
        clean = re.sub(r'^[`\s]*', '', clean)
        clean = re.sub(r'[`\s]*$', '', clean)

        if '|' in clean:
            parts = clean.split('|', 1)
            predicted_type = parts[0].strip().lower()
            confidence = parts[1].strip().lower()
        else:
            # Model didn't follow format — treat as the type with medium confidence
            predicted_type = clean.lower()
            confidence = "medium"

        # Validate the predicted type
        if predicted_type not in VALID_V2_TYPES:
            # Try fuzzy matching for common issues
            type_map = {t.lower(): t for t in VALID_V2_TYPES}
            if predicted_type in type_map:
                predicted_type = type_map[predicted_type]
            else:
                return None, None, f"Invalid type '{predicted_type}' from LLM (raw: {raw_response})"

        # Validate confidence
        if confidence not in ('high', 'medium', 'low'):
            confidence = "medium"

        reasoning = f"LLM ({model}, {elapsed:.1f}s): raw='{raw_response}'"

        return predicted_type, confidence, reasoning

    except requests.exceptions.ConnectionError:
        return None, None, f"Cannot connect to Ollama at {ollama_url} — is it running?"
    except requests.exceptions.Timeout:
        return None, None, f"Ollama request timed out (120s)"
    except Exception as e:
        return None, None, f"Ollama error: {e}"


# ─────────────────────────────────────────────────────────
# File Discovery
# ─────────────────────────────────────────────────────────

def find_md_files(vault_path, folder=None, files=None, recursive=False):
    """
    Find .md files to classify.
    Returns list of Path objects (relative to vault root).
    """
    targets = []

    if files:
        for f in files:
            p = Path(f)
            if not p.is_absolute():
                p = vault_path / p
            if p.exists() and p.suffix == '.md':
                targets.append(p.relative_to(vault_path))
            else:
                print(f"  WARNING: File not found or not .md: {f}")

    elif folder:
        folder_path = vault_path / folder
        if not folder_path.exists():
            print(f"ERROR: Folder not found: {folder_path}")
            sys.exit(1)

        if recursive:
            md_files = sorted(folder_path.rglob("*.md"))
        else:
            md_files = sorted(folder_path.glob("*.md"))

        targets = [f.relative_to(vault_path) for f in md_files]

    return targets


# ─────────────────────────────────────────────────────────
# Main Classification Pipeline
# ─────────────────────────────────────────────────────────

CONFIDENCE_RANK = {"high": 3, "medium": 2, "low": 1}


def run_classification(vault_path, targets, ollama_url, model, confidence_threshold, dry_run, rules_only=False):
    """
    Classify all target files. Returns structured results.
    """
    threshold_rank = CONFIDENCE_RANK.get(confidence_threshold, 2)

    results = {
        "skipped": [],       # Already has valid v2 type
        "rules": [],         # Classified by deterministic rules
        "llm_high": [],      # LLM classified, above threshold
        "review_queue": [],  # LLM classified, below threshold (or error)
        "errors": [],        # File read errors
        "llm_times": [],     # Per-file LLM elapsed times (seconds)
    }

    total = len(targets)
    llm_needed = []

    print(f"\n{'='*60}")
    print(f"Phase 1: Rules-based classification ({total} files)")
    print(f"{'='*60}\n")

    for i, rel_path in enumerate(targets, 1):
        full_path = vault_path / rel_path

        try:
            content = read_file(full_path)
        except Exception as e:
            results["errors"].append({
                "path": str(rel_path),
                "error": str(e),
            })
            continue

        fields, body = parse_frontmatter(content)
        current_type = get_type_field(fields)

        # Skip if already has a valid v2 type
        if current_type and current_type in VALID_V2_TYPES:
            results["skipped"].append({
                "path": str(rel_path),
                "current_type": current_type,
            })
            continue

        # Flag if it has a retired type (will still try to classify)
        has_retired = current_type and current_type in RETIRED_TYPES

        # Try rules first
        rule_type, rule_desc = classify_by_rules(rel_path, fields, body)

        if rule_type:
            results["rules"].append({
                "path": str(rel_path),
                "predicted_type": rule_type,
                "method": f"rule: {rule_desc}",
                "had_retired_type": current_type if has_retired else None,
            })
            print(f"  [{i}/{total}] RULE -> {rule_type:20s} {rel_path}")
        else:
            # Queue for LLM
            llm_needed.append((rel_path, fields, body, current_type))
            print(f"  [{i}/{total}] -> LLM  (no rule match)  {rel_path}")

    # Phase 2: LLM classification
    if llm_needed and not rules_only:
        print(f"\n{'='*60}")
        print(f"Phase 2: LLM classification ({len(llm_needed)} files)")
        print(f"Model: {model} | Ollama: {ollama_url}")
        print(f"Confidence threshold: {confidence_threshold}")
        print(f"{'='*60}\n")

        # Test Ollama connectivity first
        try:
            test_resp = requests.get(f"{ollama_url}/api/tags", timeout=5)
            test_resp.raise_for_status()
            available_models = [m["name"] for m in test_resp.json().get("models", [])]
            # Check if requested model is available (handle tag variations)
            model_base = model.split(':')[0]
            model_found = any(model_base in m for m in available_models)
            if not model_found:
                print(f"  WARNING: Model '{model}' may not be available.")
                print(f"  Available models: {', '.join(available_models[:10])}")
                print(f"  Continuing anyway (Ollama will pull if needed)...\n")
        except Exception as e:
            print(f"  ERROR: Cannot reach Ollama at {ollama_url}: {e}")
            print(f"  All {len(llm_needed)} files will go to Review Queue.\n")
            for rel_path, fields, body, current_type in llm_needed:
                results["review_queue"].append({
                    "path": str(rel_path),
                    "predicted_type": None,
                    "confidence": None,
                    "reasoning": f"Ollama unavailable: {e}",
                    "had_retired_type": current_type if current_type in RETIRED_TYPES else None,
                })
            llm_needed = []

        for j, (rel_path, fields, body, current_type) in enumerate(llm_needed, 1):
            print(f"  [{j}/{len(llm_needed)}] Classifying: {rel_path}...", end=" ", flush=True)

            call_start = time.time()
            predicted_type, confidence, reasoning = classify_with_llm(
                rel_path, fields, body, ollama_url, model
            )
            call_elapsed = time.time() - call_start
            results["llm_times"].append(call_elapsed)

            has_retired = current_type and current_type in RETIRED_TYPES

            if predicted_type is None:
                # Error during classification
                results["review_queue"].append({
                    "path": str(rel_path),
                    "predicted_type": None,
                    "confidence": None,
                    "reasoning": reasoning,
                    "had_retired_type": current_type if has_retired else None,
                })
                print(f"ERROR -> Review Queue")
            elif CONFIDENCE_RANK.get(confidence, 0) >= threshold_rank:
                # Above threshold
                results["llm_high"].append({
                    "path": str(rel_path),
                    "predicted_type": predicted_type,
                    "confidence": confidence,
                    "reasoning": reasoning,
                    "had_retired_type": current_type if has_retired else None,
                })
                print(f"{predicted_type} ({confidence})")
            else:
                # Below threshold -> Review Queue
                results["review_queue"].append({
                    "path": str(rel_path),
                    "predicted_type": predicted_type,
                    "confidence": confidence,
                    "reasoning": reasoning,
                    "had_retired_type": current_type if has_retired else None,
                })
                print(f"{predicted_type}? ({confidence}) -> Review Queue")

    return results


# ─────────────────────────────────────────────────────────
# Execute Mode: Write YAML Changes
# ─────────────────────────────────────────────────────────

def apply_classifications(vault_path, results, dry_run):
    """
    Apply classifications to files (rules + high-confidence LLM).
    Review Queue items are NEVER auto-applied.
    """
    if dry_run:
        return 0

    applied = 0
    to_apply = results["rules"] + results["llm_high"]

    for item in to_apply:
        full_path = vault_path / item["path"]
        try:
            content = read_file(full_path)
            new_content = add_type_to_frontmatter(content, item["predicted_type"])
            if content != new_content:
                write_file(full_path, new_content)
                applied += 1
        except Exception as e:
            print(f"  ERROR writing {item['path']}: {e}")

    return applied


# ─────────────────────────────────────────────────────────
# Apply from Previous Log
# ─────────────────────────────────────────────────────────

# Pattern to match log lines like:
#   - [[Note Title]] -> `type` (confidence)
#   - [[Note Title]] -> `type` (rule: description)
#   - [[Note Title]] -> `type` (confidence) (was: old_type)
LOG_LINE_PATTERN = re.compile(
    r'^- \[\[(.+?)\]\] -> `([a-zA-Z-]+)`'
)


def parse_log_classifications(log_content):
    """
    Parse a dry run log and extract (note_title, type) pairs.
    Only parses Rules-Based and LLM-Classified sections, skips Review Queue and Skipped.
    """
    classifications = []
    in_actionable_section = False

    for line in log_content.split('\n'):
        # Track which section we're in
        if line.startswith('## Rules-Based') or line.startswith('## LLM-Classified'):
            in_actionable_section = True
            continue
        if line.startswith('## Review Queue') or line.startswith('## Skipped') or line.startswith('## Errors'):
            in_actionable_section = False
            continue

        if not in_actionable_section:
            continue

        match = LOG_LINE_PATTERN.match(line.strip())
        if match:
            note_title = match.group(1)
            predicted_type = match.group(2)
            if predicted_type in VALID_V2_TYPES:
                classifications.append((note_title, predicted_type))

    return classifications


def apply_from_log(vault_path, log_path_str):
    """
    Apply classifications from a previous dry run log.
    Maps note titles back to file paths by scanning the vault.
    """
    # Resolve log path (relative to vault or absolute)
    log_path = Path(log_path_str)
    if not log_path.is_absolute():
        log_path = vault_path / log_path
    if not log_path.exists():
        print(f"ERROR: Log file not found: {log_path}")
        sys.exit(1)

    print(f"\nApplying classifications from log:")
    print(f"  {log_path}\n")

    # Parse the log
    log_content = read_file(log_path)
    classifications = parse_log_classifications(log_content)

    if not classifications:
        print("No classifications found in log.")
        return

    print(f"  Found {len(classifications)} classifications to apply.")

    # Build a map of note_stem -> file_path by scanning the vault
    # (notes could be in any folder)
    stem_to_path = {}
    for md_file in vault_path.rglob('*.md'):
        # Skip _DataWizard internals
        rel = md_file.relative_to(vault_path)
        if str(rel).startswith('_DataWizard/'):
            continue
        stem = md_file.stem
        if stem not in stem_to_path:
            stem_to_path[stem] = md_file
        # If duplicate stems exist, keep the first one found
        # (could be improved with folder hints from the log)

    # Apply classifications
    applied = 0
    skipped = 0
    not_found = 0
    already_set = 0

    for note_title, predicted_type in classifications:
        file_path = stem_to_path.get(note_title)
        if not file_path:
            print(f"  NOT FOUND: [[{note_title}]]")
            not_found += 1
            continue

        try:
            content = read_file(file_path)
            fields, body = parse_frontmatter(content)
            current_type = get_type_field(fields)

            # Skip if already has this exact type
            if current_type == predicted_type:
                already_set += 1
                continue

            new_content = add_type_to_frontmatter(content, predicted_type)
            if content != new_content:
                write_file(file_path, new_content)
                applied += 1
                rel = file_path.relative_to(vault_path)
                print(f"  APPLIED: {rel} -> {predicted_type}")
            else:
                skipped += 1
        except Exception as e:
            print(f"  ERROR: {note_title} — {e}")
            skipped += 1

    # Summary
    print(f"\n{'='*60}")
    print(f"APPLY FROM LOG COMPLETE")
    print(f"{'='*60}")
    print(f"  Applied:      {applied}")
    print(f"  Already set:  {already_set}")
    print(f"  Not found:    {not_found}")
    print(f"  Skipped/err:  {skipped}")


# ─────────────────────────────────────────────────────────
# Output: Reports & Logs
# ─────────────────────────────────────────────────────────

def generate_report(results, model, folder, confidence_threshold, dry_run):
    """Generate the Classification Results report as markdown."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    mode = "DRY RUN" if dry_run else "EXECUTED"

    lines = []
    lines.append(f"# Classification Results — {timestamp}\n")
    lines.append(f"**Mode**: {mode} | **Model**: {model} | **Folder**: {folder or '(specific files)'}")
    lines.append(f"**Confidence threshold**: {confidence_threshold}\n")
    lines.append("---\n")

    # Rules-based
    lines.append(f"## Rules-Based (no LLM needed) — {len(results['rules'])} notes\n")
    if results['rules']:
        for item in results['rules']:
            retired_note = f" (was: {item['had_retired_type']})" if item.get('had_retired_type') else ""
            lines.append(f"- [[{Path(item['path']).stem}]] -> `{item['predicted_type']}` ({item['method']}){retired_note}")
    else:
        lines.append("_(none)_")
    lines.append("")

    # LLM high confidence
    lines.append(f"## LLM-Classified (above threshold) — {len(results['llm_high'])} notes\n")
    if results['llm_high']:
        for item in results['llm_high']:
            retired_note = f" (was: {item['had_retired_type']})" if item.get('had_retired_type') else ""
            lines.append(f"- [[{Path(item['path']).stem}]] -> `{item['predicted_type']}` ({item['confidence']}){retired_note}")
    else:
        lines.append("_(none)_")
    lines.append("")

    # Review Queue
    lines.append(f"## Review Queue (needs human review) — {len(results['review_queue'])} notes\n")
    if results['review_queue']:
        for item in results['review_queue']:
            pt = item['predicted_type'] or '???'
            conf = item['confidence'] or 'error'
            retired_note = f" (was: {item['had_retired_type']})" if item.get('had_retired_type') else ""
            lines.append(f"- [[{Path(item['path']).stem}]] -> `{pt}`? ({conf}) — {item['reasoning']}{retired_note}")
    else:
        lines.append("_(none)_")
    lines.append("")

    # Skipped
    lines.append(f"## Skipped (already has valid v2 type) — {len(results['skipped'])} notes\n")
    if results['skipped']:
        # Group by type for readability
        by_type = {}
        for item in results['skipped']:
            t = item['current_type']
            by_type.setdefault(t, []).append(item['path'])
        for t in sorted(by_type.keys()):
            paths = by_type[t]
            lines.append(f"### `{t}` ({len(paths)})")
            for p in paths[:5]:
                lines.append(f"- [[{Path(p).stem}]]")
            if len(paths) > 5:
                lines.append(f"- _...and {len(paths) - 5} more_")
            lines.append("")
    else:
        lines.append("_(none)_")
    lines.append("")

    # Errors
    if results['errors']:
        lines.append(f"## Errors — {len(results['errors'])} notes\n")
        for item in results['errors']:
            lines.append(f"- `{item['path']}` — {item['error']}")
        lines.append("")

    # Summary
    lines.append("---\n")
    total = (len(results['rules']) + len(results['llm_high']) +
             len(results['review_queue']) + len(results['skipped']) +
             len(results['errors']))
    lines.append(f"**Total**: {total} | "
                 f"**Rules**: {len(results['rules'])} | "
                 f"**LLM-accepted**: {len(results['llm_high'])} | "
                 f"**Review**: {len(results['review_queue'])} | "
                 f"**Skipped**: {len(results['skipped'])} | "
                 f"**Errors**: {len(results['errors'])}")

    # LLM timing stats
    llm_times = results.get('llm_times', [])
    if llm_times:
        total_t = sum(llm_times)
        avg_t = total_t / len(llm_times)
        min_t = min(llm_times)
        max_t = max(llm_times)
        lines.append("")
        lines.append(f"**LLM timing**: {len(llm_times)} calls, "
                     f"{total_t:.1f}s total, {avg_t:.1f}s avg, "
                     f"{min_t:.1f}s min, {max_t:.1f}s max")

    return "\n".join(lines)


def write_outputs(vault_path, report, results, dry_run):
    """Write the classification report and review queue to vault."""
    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M")
    mode_tag = "dryrun" if dry_run else "executed"

    # Write main log
    log_path = vault_path / "_DataWizard" / "Workshop" / "Classification Logs" / f"classification_log_{timestamp}_{mode_tag}.md"
    os.makedirs(log_path.parent, exist_ok=True)
    write_file(log_path, report)
    print(f"\n  Report written to: {log_path}")

    # If there are Review Queue items, also write/append to the Review Queue file
    if results['review_queue']:
        rq_path = vault_path / "_DataWizard" / "Workshop" / "Classification Review Queue.md"
        rq_exists = rq_path.exists()

        rq_lines = []
        if not rq_exists:
            rq_lines.append("# Classification Review Queue\n")
            rq_lines.append("> Notes that need human review before type assignment.")
            rq_lines.append("> Mark with `✓` to accept, `x` to reject, or edit the type.\n")
            rq_lines.append("---\n")

        timestamp_nice = datetime.now().strftime("%Y-%m-%d %H:%M")
        rq_lines.append(f"\n## Batch: {timestamp_nice}\n")

        for item in results['review_queue']:
            pt = item['predicted_type'] or '???'
            conf = item['confidence'] or 'error'
            reasoning = item['reasoning']
            rq_lines.append(f"- [ ] [[{Path(item['path']).stem}]] -> `{pt}` ({conf})")
            rq_lines.append(f"  - Reason: {reasoning}")
            if item.get('had_retired_type'):
                rq_lines.append(f"  - Previous type: `{item['had_retired_type']}`")

        rq_content = "\n".join(rq_lines)

        if rq_exists:
            existing = read_file(rq_path)
            write_file(rq_path, existing + "\n" + rq_content)
        else:
            write_file(rq_path, rq_content)

        print(f"  Review Queue updated: {rq_path}")

    return log_path


# ─────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="DataWizard Content Classifier — Step 1 of the enrichment pipeline",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Dry run on _Clippings/
  python3 classify.py --vault ~/path/to/vault --folder _Clippings/

  # Classify specific files
  python3 classify.py --vault ~/path/to/vault --files note1.md note2.md

  # Apply after review
  python3 classify.py --vault ~/path/to/vault --folder _!nbox/ --execute

  # Different model
  python3 classify.py --vault ~/path/to/vault --folder _Clippings/ --model qwen3:32b
        """
    )

    parser.add_argument("--vault", required=True,
                        help="Path to vault root")
    parser.add_argument("--folder",
                        help="Folder to scan (relative to vault root)")
    parser.add_argument("--files", nargs="+",
                        help="Specific files to classify (relative to vault root)")
    parser.add_argument("--recursive", action="store_true",
                        help="Scan subfolders recursively")
    parser.add_argument("--dry-run", action="store_true", default=True,
                        help="Preview classifications without writing (default)")
    parser.add_argument("--execute", action="store_true",
                        help="Apply classifications to YAML frontmatter")
    parser.add_argument("--model", default=DEFAULT_MODEL,
                        help=f"Ollama model for LLM classification (default: {DEFAULT_MODEL})")
    parser.add_argument("--ollama-url", default=DEFAULT_OLLAMA_URL,
                        help=f"Ollama API URL (default: {DEFAULT_OLLAMA_URL})")
    parser.add_argument("--confidence-threshold", default=DEFAULT_CONFIDENCE_THRESHOLD,
                        choices=["high", "medium", "low"],
                        help=f"Minimum confidence to auto-apply (default: {DEFAULT_CONFIDENCE_THRESHOLD})")
    parser.add_argument("--rules-only", action="store_true",
                        help="Skip LLM, only apply deterministic rules")
    parser.add_argument("--apply-log",
                        help="Apply classifications from a previous dry run log (no LLM calls)")

    args = parser.parse_args()

    # Handle --apply-log mode
    if args.apply_log:
        apply_from_log(vault_path=Path(args.vault).expanduser().resolve(),
                       log_path_str=args.apply_log)
        return

    # Validate args
    if not args.folder and not args.files:
        parser.error("Must specify either --folder or --files")
    if args.folder and args.files:
        parser.error("Cannot specify both --folder and --files")
    if args.execute:
        args.dry_run = False

    vault_path = Path(args.vault).expanduser().resolve()
    if not vault_path.exists():
        print(f"ERROR: Vault path not found: {vault_path}")
        sys.exit(1)

    # Discover files
    targets = find_md_files(vault_path, folder=args.folder, files=args.files,
                            recursive=args.recursive)

    if not targets:
        print("No .md files found to classify.")
        sys.exit(0)

    mode = "EXECUTE" if args.execute else "DRY RUN"
    print(f"\nDataWizard Content Classifier")
    print(f"{'='*60}")
    print(f"  Vault:      {vault_path}")
    print(f"  Target:     {args.folder or 'specific files'}")
    print(f"  Files:      {len(targets)}")
    print(f"  Mode:       {mode}")
    print(f"  Model:      {args.model}")
    print(f"  Threshold:  {args.confidence_threshold}")
    if args.rules_only:
        print(f"  Rules only: YES (no LLM calls)")

    # Run classification
    results = run_classification(
        vault_path, targets,
        ollama_url=args.ollama_url,
        model=args.model,
        confidence_threshold=args.confidence_threshold,
        dry_run=args.dry_run,
        rules_only=args.rules_only,
    )



    # Apply if executing
    applied = 0
    if args.execute:
        applied = apply_classifications(vault_path, results, dry_run=False)

    # Generate report
    report = generate_report(
        results, args.model, args.folder,
        args.confidence_threshold, args.dry_run,
    )

    # Write outputs
    log_path = write_outputs(vault_path, report, results, args.dry_run)

    # Final summary
    print(f"\n{'='*60}")
    print(f"CLASSIFICATION COMPLETE")
    print(f"{'='*60}")
    print(f"  Rules-based:    {len(results['rules'])}")
    print(f"  LLM-accepted:   {len(results['llm_high'])}")
    print(f"  Review Queue:   {len(results['review_queue'])}")
    print(f"  Skipped:        {len(results['skipped'])}")
    print(f"  Errors:         {len(results['errors'])}")

    # LLM timing stats
    llm_times = results.get('llm_times', [])
    if llm_times:
        total_t = sum(llm_times)
        avg_t = total_t / len(llm_times)
        min_t = min(llm_times)
        max_t = max(llm_times)
        print(f"\n  LLM stats:      {len(llm_times)} calls, "
              f"{total_t:.1f}s total, {avg_t:.1f}s avg, "
              f"{min_t:.1f}s min, {max_t:.1f}s max")
        # Project full run time based on remaining LLM-needing files
        remaining = len(results['review_queue']) + len(results['llm_high'])
        if remaining < 271:  # Only show projection if this was a partial run
            projected_mins = (271 * avg_t) / 60
            print(f"  Projected full: ~271 files × {avg_t:.1f}s = ~{projected_mins:.0f} min")

    if args.execute:
        print(f"\n  Files written:  {applied}")
    else:
        print(f"\n  DRY RUN — no files modified.")
        print(f"  Run with --execute to apply {len(results['rules']) + len(results['llm_high'])} classifications.")


if __name__ == "__main__":
    main()
