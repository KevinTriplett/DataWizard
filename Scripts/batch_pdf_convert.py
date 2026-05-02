#!/usr/bin/env python3
"""
DataWizard PDF-to-Markdown Converter
=====================================
Converts PDF files to clean markdown. Accepts a single PDF file or a
directory (recursively converts all PDFs found).

Primary tool: Docling (IBM document understanding)
Fallback tool: pymupdf4llm (lightweight text extraction)

Features:
- Single file or batch mode
- Fault-tolerant: failures are logged and skipped
- Adds YAML frontmatter tracking conversion tool and status
- Shell+sections pattern for outputs >5000 words
- Skips PDFs that already have a corresponding .md file
- Progress logging to a timestamped log file

Usage:
    ~/docling-env/bin/python3 batch_pdf_convert.py "/path/to/document.pdf"
    ~/docling-env/bin/python3 batch_pdf_convert.py "/path/to/pdf/folder"
    ~/docling-env/bin/python3 batch_pdf_convert.py "/path/to/pdf/folder" --dry-run
    ~/docling-env/bin/python3 batch_pdf_convert.py "/path/to/pdf/folder" --force

Options:
    --dry-run   List PDFs that would be converted, don't actually convert
    --force     Re-convert even if .md already exists
    --log-dir   Directory for log file (default: same as input directory)

Canonical location: _DataWizard/Seed/Scripts/batch_pdf_convert.py
"""

import os
import sys
import time
import argparse
import traceback
from pathlib import Path
from datetime import datetime


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

WORD_COUNT_THRESHOLD = 5000  # Above this, apply shell+sections pattern
MIN_WORDS_RATIO = 0.5       # If word_count < pages * this, flag as partial
SECTION_TARGET_WORDS = 2000  # Target words per section chunk


# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

class ConversionLogger:
    """Logs progress to both console and a timestamped file."""

    def __init__(self, log_path: Path):
        self.log_path = log_path
        self.start_time = datetime.now()
        self.results = []
        # Write header
        with open(self.log_path, "w") as f:
            f.write(f"# PDF Batch Conversion Log\n")
            f.write(f"Started: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}\n\n")

    def log(self, message: str, level: str = "INFO"):
        timestamp = datetime.now().strftime("%H:%M:%S")
        line = f"[{timestamp}] [{level}] {message}"
        print(line)
        with open(self.log_path, "a") as f:
            f.write(line + "\n")

    def log_result(self, pdf_path: str, tool: str, status: str, word_count: int = 0,
                   elapsed: float = 0, error: str = ""):
        self.results.append({
            "pdf": pdf_path,
            "tool": tool,
            "status": status,
            "word_count": word_count,
            "elapsed": elapsed,
            "error": error,
        })
        with open(self.log_path, "a") as f:
            f.write(f"\n---\n")
            f.write(f"**{Path(pdf_path).name}**\n")
            f.write(f"- Tool: {tool}\n")
            f.write(f"- Status: {status}\n")
            if word_count:
                f.write(f"- Words: {word_count}\n")
            if elapsed:
                f.write(f"- Time: {elapsed:.1f}s\n")
            if error:
                f.write(f"- Error: {error}\n")

    def write_summary(self):
        elapsed_total = (datetime.now() - self.start_time).total_seconds()
        success = [r for r in self.results if r["status"] in ("success", "fallback-success")]
        failed = [r for r in self.results if r["status"] == "failed"]
        partial = [r for r in self.results if r["status"] == "partial"]
        skipped = [r for r in self.results if r["status"] == "skipped"]

        summary = f"""
## Summary
- Total PDFs found: {len(self.results)}
- Successful (Docling): {len([r for r in success if r['tool'] == 'docling'])}
- Successful (fallback): {len([r for r in success if r['tool'] == 'pymupdf4llm'])}
- Partial extractions: {len(partial)}
- Failed: {len(failed)}
- Skipped (already converted): {len(skipped)}
- Total time: {elapsed_total / 60:.1f} minutes

Finished: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""
        if failed:
            summary += "\n### Failed files\n"
            for r in failed:
                summary += f"- {r['pdf']}: {r['error']}\n"

        if partial:
            summary += "\n### Partial extractions (review recommended)\n"
            for r in partial:
                summary += f"- {r['pdf']} ({r['word_count']} words via {r['tool']})\n"

        print(summary)
        with open(self.log_path, "a") as f:
            f.write(summary)


# ---------------------------------------------------------------------------
# YAML Frontmatter
# ---------------------------------------------------------------------------

def build_frontmatter(title: str, source_file: str, tool: str, status: str,
                      word_count: int, is_shell: bool = False) -> str:
    date_str = datetime.now().strftime("%Y-%m-%d")
    lines = [
        "---",
        f'title: "{title}"',
        f"type: converted-document",
        f"source_file: \"{source_file}\"",
        f"conversion_date: {date_str}",
        f"conversion_tool: {tool}",
        f"conversion_status: {status}",
        f"word_count: {word_count}",
    ]
    if is_shell:
        lines.append("has_sections: true")
    lines.append("---\n")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Conversion: Docling
# ---------------------------------------------------------------------------

def convert_with_docling(pdf_path: Path, output_md_path: Path) -> str:
    """Convert PDF to markdown using Docling. Returns markdown text."""
    import tempfile
    from docling.document_converter import DocumentConverter

    converter = DocumentConverter()
    result = converter.convert(str(pdf_path))
    md_text = result.document.export_to_markdown()
    return md_text


# ---------------------------------------------------------------------------
# Conversion: pymupdf4llm (fallback)
# ---------------------------------------------------------------------------

def convert_with_pymupdf4llm(pdf_path: Path) -> str:
    """Convert PDF to markdown using pymupdf4llm. Returns markdown text."""
    import pymupdf4llm
    md_text = pymupdf4llm.to_markdown(str(pdf_path))
    return md_text


# ---------------------------------------------------------------------------
# Shell + Sections Pattern
# ---------------------------------------------------------------------------

def _is_good_heading(text: str) -> bool:
    """Check if a heading is a proper section title (not a sentence fragment)."""
    text = text.strip()
    if not text:
        return False
    # Sentence fragments: end with period, comma, colon, or dash
    if text.endswith(('.', ',', '-', ':')):
        return False
    # Very long "headings" are probably sentences, not titles
    if len(text) > 100:
        return False
    # Starts with lowercase (unless it's a number like "3.1")
    if text[0].islower() and not text[0].isdigit():
        return False
    return True


def _clean_heading_for_filename(heading: str) -> str:
    """Sanitize a heading for use as a filename."""
    safe = heading.replace("/", "-").replace("\\", "-")
    safe = safe.replace('"', '').replace("'", "")
    safe = safe.replace(":", " -").replace("?", "").replace("*", "")
    safe = safe.replace("<", "").replace(">", "").replace("|", "-")
    safe = safe.replace("\n", " ").strip()
    # Collapse multiple spaces/dashes
    while "  " in safe:
        safe = safe.replace("  ", " ")
    while "--" in safe:
        safe = safe.replace("--", "-")
    if len(safe) > 60:
        safe = safe[:60].rsplit(" ", 1)[0]
    return safe.strip()


def _parse_heading_level(line: str) -> int:
    """Return heading level (1 for #, 2 for ##, etc.) or 0 if not a heading."""
    stripped = line.strip()
    if not stripped.startswith("#"):
        return 0
    level = 0
    for ch in stripped:
        if ch == "#":
            level += 1
        else:
            break
    # Must have a space after the hashes
    if level < len(stripped) and stripped[level] == " ":
        return level
    return 0


def _extract_heading_text(line: str) -> str:
    """Extract the text content from a markdown heading line."""
    return line.strip().lstrip("#").strip()


def split_into_sections(md_text: str, title: str, source_file: str,
                        tool: str, status: str, output_dir: Path,
                        pdf_stem: str = "") -> str:
    """
    Split a large markdown file into a shell note + section files.

    Strategy:
    1. Parse heading hierarchy to understand document structure
    2. Split at ## level headings as primary section boundaries
    3. Merge small ## sections together (preserving the first heading as name)
    4. If a merged section is still too large, sub-split at ### level
    5. Use clean, descriptive section names from the ## heading

    Returns the shell note content.
    """
    lines = md_text.split("\n")
    total_words = len(md_text.split())

    # --- Step 1: Find all ## headings and their positions ---
    h2_positions = []  # [(line_index, heading_text), ...]
    for i, line in enumerate(lines):
        level = _parse_heading_level(line)
        if level == 2:
            h2_positions.append((i, _extract_heading_text(line)))

    # If fewer than 2 headings, try # level, then fall back to word count
    if len(h2_positions) < 2:
        h1_positions = []
        for i, line in enumerate(lines):
            level = _parse_heading_level(line)
            if level == 1:
                h1_positions.append((i, _extract_heading_text(line)))
        if len(h1_positions) >= 2:
            h2_positions = h1_positions
        else:
            return _split_by_word_count(md_text, title, source_file, tool, status, output_dir, pdf_stem)

    # --- Step 2: Extract raw sections at ## boundaries ---
    raw_sections = []

    # Preamble (before first ##)
    first_h2_line = h2_positions[0][0]
    preamble = "\n".join(lines[:first_h2_line]).strip()
    if preamble and len(preamble.split()) > 50:
        raw_sections.append(("Preamble", preamble))

    # Each ## section
    for idx, (pos, heading) in enumerate(h2_positions):
        if idx + 1 < len(h2_positions):
            next_pos = h2_positions[idx + 1][0]
        else:
            next_pos = len(lines)
        section_text = "\n".join(lines[pos:next_pos]).strip()
        if section_text and len(section_text.split()) > 20:
            raw_sections.append((heading, section_text))

    # --- Step 3: Merge small sections, keeping the first heading as the label ---
    merged_sections = []
    buffer_heading = None
    buffer_text = ""
    buffer_subheadings = []  # Track what got merged in

    for heading, text in raw_sections:
        if buffer_heading is None:
            buffer_heading = heading
            buffer_text = text
            buffer_subheadings = [heading]
        elif len(buffer_text.split()) < SECTION_TARGET_WORDS:
            # Merge into current buffer
            buffer_text += "\n\n" + text
            buffer_subheadings.append(heading)
        else:
            # Flush buffer, start new one
            merged_sections.append((buffer_heading, buffer_text, buffer_subheadings))
            buffer_heading = heading
            buffer_text = text
            buffer_subheadings = [heading]

    if buffer_heading:
        merged_sections.append((buffer_heading, buffer_text, buffer_subheadings))

    # --- Step 4: Choose clean names for each section ---
    named_sections = []
    for heading, text, subheadings in merged_sections:
        # Use the first good heading from the merged set
        chosen_name = None
        for h in subheadings:
            if _is_good_heading(h):
                chosen_name = h
                break

        if not chosen_name:
            # All headings were fragments — use a generic name
            chosen_name = f"Part {len(named_sections) + 1}"

        # Track merge count for display (but not filename)
        merge_note = ""
        if len(subheadings) > 2:
            merge_note = f" (and {len(subheadings) - 1} more)"

        named_sections.append((chosen_name, text, merge_note))

    # --- Step 5: Write section files ---
    stem_folder_name = _clean_heading_for_filename(pdf_stem or title)
    sections_dir = output_dir / "PDF Sections" / stem_folder_name
    sections_dir.mkdir(parents=True, exist_ok=True)

    date_str = datetime.now().strftime("%Y-%m-%d")
    section_links = []

    for i, (heading, text, merge_note) in enumerate(named_sections, 1):
        # Filename uses clean heading only (no merge count)
        safe_heading = _clean_heading_for_filename(heading)
        section_filename = f"S{i:02d} - {safe_heading}.md"
        section_path = sections_dir / section_filename
        section_word_count = len(text.split())

        section_fm = build_frontmatter(
            title=f"{title} - {heading}",
            source_file=source_file,
            tool=tool,
            status=status,
            word_count=section_word_count,
        )

        with open(section_path, "w", encoding="utf-8") as f:
            f.write(section_fm)
            f.write(f"\n{text}\n")

        # Display text in shell note includes merge count, filename doesn't
        display_name = f"{heading}{merge_note}"
        section_links.append(f"- [[PDF Sections/{stem_folder_name}/{section_filename}|S{i:02d} - {display_name}]] ({section_word_count} words)")

    # --- Step 6: Build shell note ---
    shell_fm = build_frontmatter(
        title=title,
        source_file=source_file,
        tool=tool,
        status=status,
        word_count=total_words,
        is_shell=True,
    )

    shell_content = shell_fm
    shell_content += f"\n# {title}\n\n"
    shell_content += f"*Converted from `{source_file}` on {date_str} using {tool}.*\n"
    shell_content += f"*{total_words} words across {len(named_sections)} sections.*\n\n"
    shell_content += "## Sections\n\n"
    shell_content += "\n".join(section_links)
    shell_content += "\n"

    return shell_content


def _split_by_word_count(md_text: str, title: str, source_file: str,
                         tool: str, status: str, output_dir: Path,
                         pdf_stem: str = "") -> str:
    """Fallback: split by word count when no headings are present."""
    words = md_text.split()
    total_words = len(words)
    date_str = datetime.now().strftime("%Y-%m-%d")

    stem_folder_name = _clean_heading_for_filename(pdf_stem or title)
    sections_dir = output_dir / "PDF Sections" / stem_folder_name
    sections_dir.mkdir(parents=True, exist_ok=True)

    section_links = []
    chunk_num = 0

    for start in range(0, total_words, SECTION_TARGET_WORDS):
        chunk_num += 1
        chunk_words = words[start:start + SECTION_TARGET_WORDS]
        chunk_text = " ".join(chunk_words)
        chunk_word_count = len(chunk_words)

        section_filename = f"S{chunk_num:02d} - Part {chunk_num}.md"
        section_path = sections_dir / section_filename

        section_fm = build_frontmatter(
            title=f"{title} - Part {chunk_num}",
            source_file=source_file,
            tool=tool,
            status=status,
            word_count=chunk_word_count,
        )

        with open(section_path, "w", encoding="utf-8") as f:
            f.write(section_fm)
            f.write(f"\n{chunk_text}\n")

        section_links.append(f"- [[PDF Sections/{stem_folder_name}/{section_filename}|S{chunk_num:02d} - Part {chunk_num}]] ({chunk_word_count} words)")

    shell_fm = build_frontmatter(
        title=title,
        source_file=source_file,
        tool=tool,
        status=status,
        word_count=total_words,
        is_shell=True,
    )

    shell_content = shell_fm
    shell_content += f"\n# {title}\n\n"
    shell_content += f"*Converted from `{source_file}` on {date_str} using {tool}.*\n"
    shell_content += f"*{total_words} words across {chunk_num} sections (split by word count - no headings detected).*\n\n"
    shell_content += "## Sections\n\n"
    shell_content += "\n".join(section_links)
    shell_content += "\n"

    return shell_content


# ---------------------------------------------------------------------------
# Main conversion logic per file
# ---------------------------------------------------------------------------

def convert_single_pdf(pdf_path: Path, logger: ConversionLogger,
                       force: bool = False) -> None:
    """Convert a single PDF, with fallback and shell+sections logic."""

    pdf_name = pdf_path.name
    stem = pdf_path.stem
    output_dir = pdf_path.parent
    output_md = output_dir / f"{stem}.md"

    # Skip if already converted (unless --force)
    if output_md.exists() and not force:
        logger.log(f"SKIP (already exists): {pdf_name}")
        logger.log_result(str(pdf_path), "n/a", "skipped")
        return

    # Also check for shell+sections pattern (named sections dir)
    stem_folder_name = _clean_heading_for_filename(stem)
    sections_dir = output_dir / "PDF Sections" / stem_folder_name
    if sections_dir.exists() and not force:
        logger.log(f"SKIP (sections exist): {pdf_name}")
        logger.log_result(str(pdf_path), "n/a", "skipped")
        return

    logger.log(f"Converting: {pdf_name}")
    start_time = time.time()

    # --- Try Docling first ---
    md_text = None
    tool_used = "docling"
    status = "success"

    try:
        logger.log(f"  Trying Docling...")
        md_text = convert_with_docling(pdf_path, output_md)
        elapsed = time.time() - start_time
        logger.log(f"  Docling succeeded ({elapsed:.1f}s)")
    except Exception as e:
        elapsed = time.time() - start_time
        error_msg = str(e)[:200]
        logger.log(f"  Docling FAILED ({elapsed:.1f}s): {error_msg}", "WARN")

        # --- Fall back to pymupdf4llm ---
        try:
            logger.log(f"  Trying pymupdf4llm fallback...")
            fallback_start = time.time()
            md_text = convert_with_pymupdf4llm(pdf_path)
            tool_used = "pymupdf4llm"
            status = "fallback-success"
            elapsed = time.time() - start_time
            logger.log(f"  pymupdf4llm succeeded ({time.time() - fallback_start:.1f}s)")
        except Exception as e2:
            elapsed = time.time() - start_time
            error_msg2 = str(e2)[:200]
            logger.log(f"  pymupdf4llm ALSO FAILED: {error_msg2}", "ERROR")
            logger.log_result(str(pdf_path), "both", "failed",
                              elapsed=elapsed,
                              error=f"Docling: {error_msg} | pymupdf4llm: {error_msg2}")
            return

    if not md_text or len(md_text.strip()) < 50:
        logger.log(f"  Output too short or empty — marking as failed", "ERROR")
        logger.log_result(str(pdf_path), tool_used, "failed",
                          elapsed=elapsed, error="Empty or near-empty output")
        return

    # --- Check quality ---
    word_count = len(md_text.split())

    # Flag suspiciously short conversions
    file_size_kb = pdf_path.stat().st_size / 1024
    if file_size_kb > 100 and word_count < 100:
        status = "partial"
        logger.log(f"  WARNING: Only {word_count} words from {file_size_kb:.0f}KB PDF", "WARN")

    # --- Write output ---
    title = stem.replace("-", " ").replace("_", " ")

    if word_count > WORD_COUNT_THRESHOLD:
        # Shell + sections pattern
        logger.log(f"  Large file ({word_count} words) — applying shell+sections")
        shell_content = split_into_sections(
            md_text, title, pdf_name, tool_used, status, output_dir, stem
        )
        with open(output_md, "w", encoding="utf-8") as f:
            f.write(shell_content)
    else:
        # Single file
        frontmatter = build_frontmatter(title, pdf_name, tool_used, status, word_count)
        with open(output_md, "w", encoding="utf-8") as f:
            f.write(frontmatter)
            f.write(f"\n{md_text}\n")

    elapsed = time.time() - start_time
    logger.log(f"  Done: {word_count} words, {elapsed:.1f}s ({tool_used})")
    logger.log_result(str(pdf_path), tool_used, status,
                      word_count=word_count, elapsed=elapsed)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="DataWizard PDF-to-Markdown Converter"
    )
    parser.add_argument("input_path", help="PDF file or directory to scan for PDFs")
    parser.add_argument("--dry-run", action="store_true",
                        help="List PDFs without converting")
    parser.add_argument("--force", action="store_true",
                        help="Re-convert even if .md exists")
    parser.add_argument("--log-dir", default=None,
                        help="Directory for log file (default: input directory)")
    args = parser.parse_args()

    input_path = Path(args.input_path).resolve()

    # Accept either a single PDF file or a directory
    if input_path.is_file():
        if input_path.suffix.lower() != ".pdf":
            print(f"Error: {input_path} is not a PDF file")
            sys.exit(1)
        pdfs = [input_path]
        input_dir = input_path.parent
        print(f"\nSingle file mode: {input_path.name}\n")
    elif input_path.is_dir():
        input_dir = input_path
        pdfs = sorted(input_dir.rglob("*.pdf"))
        print(f"\nFound {len(pdfs)} PDFs under {input_dir}\n")
    else:
        print(f"Error: {input_path} not found")
        sys.exit(1)

    if not pdfs:
        print("Nothing to convert.")
        sys.exit(0)

    # Dry run mode
    if args.dry_run:
        for i, pdf in enumerate(pdfs, 1):
            rel = pdf.relative_to(input_dir)
            md_exists = pdf.with_suffix(".md").exists()
            status = " [SKIP - .md exists]" if md_exists and not args.force else ""
            print(f"  {i:3d}. {rel}{status}")

        to_convert = len([p for p in pdfs if not p.with_suffix(".md").exists() or args.force])
        print(f"\nWould convert: {to_convert} / {len(pdfs)} PDFs")
        return

    # Set up logging
    log_dir = Path(args.log_dir) if args.log_dir else input_dir
    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M")
    log_path = log_dir / f"conversion_log_{timestamp}.md"
    logger = ConversionLogger(log_path)

    logger.log(f"Input: {input_path}")
    logger.log(f"Total PDFs found: {len(pdfs)}")
    logger.log(f"Force mode: {args.force}")
    logger.log(f"Log file: {log_path}\n")

    # Convert each PDF
    for i, pdf in enumerate(pdfs, 1):
        rel = pdf.relative_to(input_dir)
        logger.log(f"\n[{i}/{len(pdfs)}] {rel}")

        try:
            convert_single_pdf(pdf, logger, force=args.force)
        except KeyboardInterrupt:
            logger.log("\nInterrupted by user!", "WARN")
            logger.write_summary()
            sys.exit(1)
        except Exception as e:
            # Catch absolutely everything — never let one file kill the batch
            error_msg = traceback.format_exc()[-300:]
            logger.log(f"  UNEXPECTED ERROR: {error_msg}", "ERROR")
            logger.log_result(str(pdf), "unknown", "failed",
                              error=f"Unexpected: {str(e)[:200]}")

    # Write summary
    logger.write_summary()
    print(f"\nLog saved to: {log_path}")


if __name__ == "__main__":
    main()
