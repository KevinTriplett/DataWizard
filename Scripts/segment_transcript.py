#!/usr/bin/env python3
"""
segment_transcript.py - Add ## section headers to transcripts using Ollama/Qwen.

Reads a transcript .md file, sends it to a local Ollama model to identify
topic boundaries, and inserts ## headers at those boundaries.

The script does NOT rewrite the transcript — it only inserts headers.
The original text, timestamps, and speaker labels are preserved exactly.

Usage:
    python3 segment_transcript.py --file <transcript.md>
    python3 segment_transcript.py --file <transcript.md> --model qwen3:32b
    python3 segment_transcript.py --dir <folder> --pending   # process all pending
    python3 segment_transcript.py --file <transcript.md> --dry-run

Requires: ollama (pip install ollama --break-system-packages)
"""

import os
import sys
import re
import json
import argparse
from pathlib import Path

try:
    import ollama as ollama_client
except ImportError:
    print("ERROR: ollama library required. Install with: pip install ollama --break-system-packages")
    sys.exit(1)

# Config
OLLAMA_HOST = "http://localhost:11434"
DEFAULT_MODEL = "qwen3:32b"
MAX_CHUNK_CHARS = 12000  # chars per chunk sent to LLM

MODEL_PREFERENCE = [
    "qwen3:32b", "qwen3.5:27b", "qwen3:8b",
    "qwen2.5:32b", "qwen2.5:14b", "qwen2.5:7b",
]

SEGMENT_PROMPT = """You are a transcript segmentation expert. Your job is to identify major topic shifts in a conversation transcript and suggest section headers.

Read this transcript carefully. Identify 5-15 natural topic boundaries where the conversation shifts to a new subject. For each boundary, provide:
1. The timestamp where the new topic begins (just the time, e.g., "0:00" or "12:53" or "1:02:30")
2. A short, descriptive section header (2-6 words, no special characters)

Rules:
- Look for genuine topic shifts, not just speaker changes
- The first section should start at or near the beginning
- Headers should be descriptive of the topic being discussed, not generic ("Introduction" is fine for the first one, but after that be specific)
- Return JUST the time value (e.g., "0:00", "12:53", "1:02:30") — no @ signs, no brackets, no bold markers
- Aim for sections of roughly 3-8 minutes each, but follow natural topic flow
- Do NOT include : / \\ in header text (these break Obsidian filenames)

Respond with ONLY a JSON array, no other text. Example:
[
  {"timestamp": "0:00", "header": "Introduction and Background"},
  {"timestamp": "5:23", "header": "The Coordination Problem"},
  {"timestamp": "12:45", "header": "AI-Assisted Foraging Interfaces"},
  {"timestamp": "25:10", "header": "Economic Models for Creator Compensation"}
]

Here is the transcript:

"""


def detect_model():
    """Auto-detect the best available Ollama model."""
    try:
        client = ollama_client.Client(host=OLLAMA_HOST)
        models = client.list()
        available = [m.model for m in models.models]
        if not available:
            print("Ollama is running but no models installed.")
            sys.exit(1)
        for preferred in MODEL_PREFERENCE:
            for avail in available:
                if avail.startswith(preferred):
                    return avail
        return available[0]
    except Exception as e:
        print(f"Cannot connect to Ollama at {OLLAMA_HOST}: {e}")
        sys.exit(1)


def extract_frontmatter(content):
    """Split content into frontmatter and body."""
    if content.startswith('---'):
        parts = content.split('---', 2)
        if len(parts) >= 3:
            return '---' + parts[1] + '---', parts[2]
    return '', content


def get_segments(model, transcript_text):
    """Send transcript to Ollama and get back segment boundaries."""
    # Truncate if very long — send first and last portions
    if len(transcript_text) > MAX_CHUNK_CHARS * 2:
        # Send first chunk + last chunk with ellipsis
        text = transcript_text[:MAX_CHUNK_CHARS] + "\n\n[... middle portion omitted for length ...]\n\n" + transcript_text[-MAX_CHUNK_CHARS:]
    else:
        text = transcript_text

    prompt = SEGMENT_PROMPT + text

    try:
        client = ollama_client.Client(host=OLLAMA_HOST)
        resp = client.generate(
            model=model,
            prompt=prompt,
            options={"temperature": 0.3},
            think=False  # disable thinking mode for speed
        )
        raw = resp.response.strip()
        
        # Extract JSON from response (may have markdown code fences)
        json_match = re.search(r'\[.*\]', raw, re.DOTALL)
        if json_match:
            segments = json.loads(json_match.group())
            return segments
        else:
            print(f"  ERROR: Could not parse JSON from LLM response")
            print(f"  Raw response: {raw[:500]}")
            return None
    except json.JSONDecodeError as e:
        print(f"  ERROR: Invalid JSON from LLM: {e}")
        return None
    except Exception as e:
        print(f"  ERROR: Ollama call failed: {e}")
        return None


def insert_headers(body, segments):
    """Insert ## headers at the specified timestamps in the transcript body."""
    if not segments:
        return body
    
    lines = body.split('\n')
    insertions = {}  # line_index -> header text
    
    for seg in segments:
        ts = seg.get('timestamp', '').strip()
        header = seg.get('header', '').strip()
        if not ts or not header:
            continue
        
        # Clean the timestamp — strip any formatting the LLM may have added
        ts_clean = ts.replace('[', '').replace(']', '').replace('@', '').replace('*', '').strip()
        
        # Build multiple search patterns to match different transcript formats:
        #   Fathom:  [@12:53]  or  @12:53
        #   YouTube: **12:53** ·
        #   Plain:   12:53
        search_variants = [
            f'@{ts_clean}',         # Fathom: @12:53
            f'[@{ts_clean}]',       # Fathom: [@12:53]
            f'**{ts_clean}**',      # YouTube: **12:53**
            ts_clean,               # Plain: 12:53 (last resort)
        ]
        
        # Find the line containing this timestamp
        found = False
        for i, line in enumerate(lines):
            for variant in search_variants:
                if variant in line:
                    # Insert header BEFORE this timestamp line
                    # But skip back past any blank lines to put it at a natural break
                    insert_at = i
                    while insert_at > 0 and lines[insert_at - 1].strip() == '':
                        insert_at -= 1
                    insertions[insert_at] = f"\n## {header}\n"
                    found = True
                    break
            if found:
                break
    
    if not insertions:
        print("  WARNING: No timestamp matches found — headers not inserted")
        return body
    
    # Build new content with headers inserted (process in reverse order to preserve indices)
    for line_idx in sorted(insertions.keys(), reverse=True):
        lines.insert(line_idx, insertions[line_idx])
    
    return '\n'.join(lines)


def update_yaml_segmented(content):
    """Add segmented: true to YAML frontmatter."""
    if 'segmented: true' in content:
        return content
    
    if content.startswith('---'):
        # Insert before the closing ---
        parts = content.split('---', 2)
        if len(parts) >= 3:
            fm = parts[1]
            if 'segmented:' not in fm:
                fm = fm.rstrip() + '\nsegmented: true\n'
            else:
                fm = fm.replace('segmented: false', 'segmented: true')
            return '---' + fm + '---' + parts[2]
    
    return content


# Headers that are Fathom metadata, not topic segmentation
METADATA_HEADERS = {
    'meeting details', 'participants', 'summary', 'meeting purpose',
    'key takeaways', 'topics', 'action items', 'transcript',
    'highlights', 'next steps', 'decisions', 'questions',
}


def has_topic_sections(content):
    """Check if transcript has topic-level ## section headers in the conversation body.
    
    Fathom exports have ## headers for metadata (Meeting Details, Participants,
    Summary, Topics, etc.) — these don't count as segmentation.
    YT scrapes may have a single '## Transcript' label — that doesn't count either.
    
    We look for ## headers that are NOT in the metadata set. If we find 3+
    non-metadata headers, the transcript is already segmented.
    """
    headers = re.findall(r'^## (.+)', content, re.MULTILINE)
    topic_headers = [h for h in headers if h.strip().lower() not in METADATA_HEADERS]
    return len(topic_headers) >= 3


def is_pending(filepath):
    """Check if file has harvest_status: pending and no existing sections."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read(3000)
        return 'harvest_status: pending' in content and not has_topic_sections(content)
    except Exception:
        return False


def process_file(filepath, model, dry_run=False, force=False):
    """Process a single transcript file."""
    filepath = Path(filepath)
    print(f"\nProcessing: {filepath.name}")
    
    content = filepath.read_text(encoding='utf-8')
    
    # Check if already segmented with topic headers
    if not force and has_topic_sections(content):
        print("  SKIP: already has topic section headers (use --force to override)")
        return False
    
    fm_block, body = extract_frontmatter(content)
    
    # Check transcript length
    word_count = len(body.split())
    print(f"  Length: {word_count} words")
    
    if word_count < 200:
        print("  SKIP: too short to segment (< 200 words)")
        return False
    
    # Get segments from LLM
    print(f"  Sending to {model} for segmentation...")
    segments = get_segments(model, body)
    
    if not segments:
        print("  FAILED: no segments returned")
        return False
    
    print(f"  Got {len(segments)} sections:")
    for seg in segments:
        print(f"    {seg.get('timestamp', '?')} — {seg.get('header', '?')}")
    
    if dry_run:
        print("  DRY RUN: would insert headers and update YAML")
        return True
    
    # Insert headers
    new_body = insert_headers(body, segments)
    new_content = fm_block + new_body
    
    # Update YAML
    new_content = update_yaml_segmented(new_content)
    
    # Write back
    filepath.write_text(new_content, encoding='utf-8')
    print(f"  DONE: {len(segments)} section headers inserted")
    return True


def main():
    parser = argparse.ArgumentParser(description='Segment transcripts with LLM-generated section headers')
    parser.add_argument('--file', '-f', help='Process a single transcript file')
    parser.add_argument('--dir', '-d', help='Process all transcripts in a directory')
    parser.add_argument('--pending', action='store_true', help='Only process files with harvest_status: pending')
    parser.add_argument('--model', '-m', default=None, help=f'Ollama model to use (default: auto-detect)')
    parser.add_argument('--dry-run', action='store_true', help='Preview without modifying files')
    parser.add_argument('--force', action='store_true', help='Skip section check — process even if headers exist')
    
    args = parser.parse_args()
    
    if not args.file and not args.dir:
        parser.error("Must specify --file or --dir")
    
    # Detect or use specified model
    model = args.model or detect_model()
    print(f"Model: {model}")
    
    if args.file:
        process_file(args.file, model, dry_run=args.dry_run, force=args.force)
    elif args.dir:
        directory = Path(args.dir)
        files = sorted(directory.glob('*.md'))
        
        if args.pending:
            files = [f for f in files if is_pending(f)]
            print(f"Found {len(files)} pending transcripts")
        else:
            print(f"Found {len(files)} markdown files")
        
        processed = 0
        skipped = 0
        failed = 0
        
        for f in files:
            result = process_file(f, model, dry_run=args.dry_run)
            if result:
                processed += 1
            elif result is False:
                skipped += 1
            else:
                failed += 1
        
        print(f"\nDone! Processed: {processed}, Skipped: {skipped}, Failed: {failed}")


if __name__ == '__main__':
    main()
