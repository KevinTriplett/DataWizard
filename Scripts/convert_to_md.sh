#!/bin/bash
# DataWizard Document Converter
# Converts PDF, DOCX, and other documents to clean Markdown
# Part of the DataWizard pipeline (Step 0: Ingest)
#
# Usage:
#   convert_to_md.sh <input_file> [output_dir]
#
# If output_dir is not specified, outputs to the same directory as input.
# For ProtonDrive files: copy to ~/Desktop first (CLI can't access ProtonDrive directly).
#
# Tools used:
#   PDF  → Docling via batch_pdf_convert.py (~/docling-env/)
#   DOCX → Custom Python converter with auto heading detection from font sizes
#   TXT/RTF → direct copy with .md extension + minimal cleanup
#   EPUB/HTML/PPTX → pandoc (with --wrap=none)
#
# Install requirements:
#   brew install pandoc
#   ~/.pyenv/versions/3.10.16/bin/python3 -m venv ~/docling-env
#   ~/docling-env/bin/pip install docling pymupdf4llm
#
# Canonical location: _DataWizard/Seed/Scripts/convert_to_md.sh

set -e

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BATCH_PDF_SCRIPT="$SCRIPT_DIR/batch_pdf_convert.py"
DOCLING_PYTHON="$HOME/docling-env/bin/python3"
PANDOC_BIN="pandoc"
PYTHON_BIN="python3"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Functions ---

usage() {
    echo "DataWizard Document Converter"
    echo ""
    echo "Usage: $0 <input_file> [output_dir]"
    echo ""
    echo "Supported formats: .pdf .docx .doc .txt .rtf .epub .html .pptx"
    echo ""
    echo "Examples:"
    echo "  $0 document.pdf"
    echo "  $0 document.pdf ~/Vaults/MyVault/_Docs/"
    echo "  $0 presentation.docx /path/to/output/"
    exit 1
}

check_tools() {
    local missing=0

    if [ ! -f "$DOCLING_PYTHON" ]; then
        echo -e "${YELLOW}Warning: Docling venv not found at $DOCLING_PYTHON${NC}"
        echo "  PDF conversion will not be available."
        echo "  Install: ~/.pyenv/versions/3.10.16/bin/python3 -m venv ~/docling-env && ~/docling-env/bin/pip install docling pymupdf4llm"
        missing=1
    fi

    if [ ! -f "$BATCH_PDF_SCRIPT" ]; then
        echo -e "${YELLOW}Warning: batch_pdf_convert.py not found at $BATCH_PDF_SCRIPT${NC}"
        echo "  PDF conversion will not be available."
        missing=1
    fi

    if ! command -v $PANDOC_BIN &> /dev/null; then
        echo -e "${YELLOW}Warning: pandoc not found${NC}"
        echo "  DOCX/EPUB/HTML conversion will not be available."
        echo "  Install: brew install pandoc"
        missing=1
    fi

    return 0
}

# Post-process pandoc DOCX output to detect headings from font sizes
fix_docx_headings() {
    local input_docx="$1"
    local output_md="$2"

    $PYTHON_BIN << 'PYEOF' "$input_docx" "$output_md"
import sys
from zipfile import ZipFile
from xml.etree import ElementTree as ET
from collections import Counter

input_docx = sys.argv[1]
output_md = sys.argv[2]

z = ZipFile(input_docx)
doc = ET.parse(z.open('word/document.xml'))
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

# First pass: collect all font sizes to determine heading thresholds
all_sizes = []
for para in doc.findall('.//w:p', ns):
    text = ''.join(t.text or '' for r in para.findall('.//w:r', ns) for t in r.findall('w:t', ns)).strip()
    if not text:
        continue
    for r in para.findall('.//w:r', ns):
        rPr = r.find('w:rPr', ns)
        if rPr is not None:
            sz_el = rPr.find('w:sz', ns)
            if sz_el is not None:
                sz = int(sz_el.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val'))
                all_sizes.append((sz, len(text)))
            break

# Determine body text size (most common size for long paragraphs)
body_sizes = [s for s, length in all_sizes if length > 100]
if body_sizes:
    body_size = Counter(body_sizes).most_common(1)[0][0]
else:
    body_size = 22  # fallback

# Heading thresholds: anything significantly larger than body text
h1_threshold = body_size * 2.2  # ~2.2x body = H1
h2_threshold = body_size * 1.4  # ~1.4x body = H2

output = []

for para in doc.findall('.//w:p', ns):
    runs = para.findall('.//w:r', ns)
    text = ''.join(t.text or '' for r in runs for t in r.findall('w:t', ns)).strip()
    if not text:
        output.append('')
        continue

    # Get first run formatting
    sz = None
    bold = False
    for r in runs:
        rPr = r.find('w:rPr', ns)
        if rPr is not None:
            sz_el = rPr.find('w:sz', ns)
            if sz_el is not None:
                sz = int(sz_el.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val'))
            if rPr.find('w:b', ns) is not None:
                bold = True
            break

    # Apply heading detection
    is_short = len(text) < 80

    if sz and sz >= h1_threshold and is_short:
        output.append(f'# {text}')
    elif sz and sz >= h2_threshold and is_short:
        output.append(f'## {text}')
    elif bold and sz and sz > body_size and is_short:
        output.append(f'### {text}')
    else:
        # Body text — strip whole-paragraph bold, preserve inline
        all_bold = all(
            r.find('w:rPr', ns) is not None and r.find('w:rPr', ns).find('w:b', ns) is not None
            for r in runs if ''.join(t.text or '' for t in r.findall('w:t', ns)).strip()
        )

        if all_bold and len(text) > 100:
            # Whole paragraph is bold — this is body text styled bold, strip the bold
            output.append(text)
        elif all_bold and len(text) <= 100:
            output.append(f'**{text}**')
        else:
            # Mixed formatting — preserve inline bold/italic
            parts = []
            for r in runs:
                rtext = ''.join(t.text or '' for t in r.findall('w:t', ns))
                if not rtext:
                    continue
                rPr = r.find('w:rPr', ns)
                is_b = rPr is not None and rPr.find('w:b', ns) is not None
                is_i = rPr is not None and rPr.find('w:i', ns) is not None
                if is_b and is_i:
                    parts.append(f'***{rtext}***')
                elif is_b:
                    parts.append(f'**{rtext}**')
                elif is_i:
                    parts.append(f'*{rtext}*')
                else:
                    parts.append(rtext)
            output.append(''.join(parts))

# Clean up multiple blank lines
result = []
prev_blank = False
for line in output:
    if line == '':
        if not prev_blank:
            result.append('')
        prev_blank = True
    else:
        prev_blank = False
        result.append(line)

with open(output_md, 'w') as f:
    f.write('\n'.join(result))

print(f"  Wrote {len(result)} lines with heading detection")
PYEOF
}

# Post-process: fix common LaTeX artifacts
fix_latex_artifacts() {
    local file="$1"
    if [ -f "$file" ]; then
        # Replace LaTeX arrows with unicode
        sed -i '' 's/\$\\rightarrow\$/→/g' "$file" 2>/dev/null || true
        sed -i '' 's/\$\\leftarrow\$/←/g' "$file" 2>/dev/null || true
        sed -i '' 's/\$\\Rightarrow\$/⇒/g' "$file" 2>/dev/null || true
        # Replace LaTeX dashes
        sed -i '' 's/---/—/g' "$file" 2>/dev/null || true
        sed -i '' 's/--/–/g' "$file" 2>/dev/null || true
    fi
}

convert_pdf() {
    local input="$1"
    local outdir="$2"

    if [ ! -f "$DOCLING_PYTHON" ]; then
        echo -e "${RED}Error: Docling venv not found. Cannot convert PDF.${NC}"
        echo "  Install: ~/.pyenv/versions/3.10.16/bin/python3 -m venv ~/docling-env"
        echo "           ~/docling-env/bin/pip install docling pymupdf4llm"
        exit 1
    fi

    if [ ! -f "$BATCH_PDF_SCRIPT" ]; then
        echo -e "${RED}Error: batch_pdf_convert.py not found at $BATCH_PDF_SCRIPT${NC}"
        exit 1
    fi

    echo -e "${GREEN}Converting PDF with Docling (via batch_pdf_convert.py)...${NC}"
    echo "  Typical speed: ~27s per PDF on M3."

    # batch_pdf_convert.py accepts both single files and directories
    $DOCLING_PYTHON "$BATCH_PDF_SCRIPT" "$input" --force

    local basename=$(basename "$input" .pdf)
    local md_file="$outdir/$basename.md"
    if [ -f "$md_file" ]; then
        echo -e "${GREEN}Done: $md_file${NC}"
    else
        echo -e "${YELLOW}Conversion may have completed but couldn't find output at: $md_file${NC}"
        echo "  Check the conversion log in: $outdir"
    fi
}

convert_docx() {
    local input="$1"
    local outdir="$2"
    local basename=$(basename "$input" .docx)
    basename=$(basename "$basename" .doc)
    local output="$outdir/$basename.md"

    echo -e "${GREEN}Converting DOCX with heading detection...${NC}"

    # Use our custom Python converter for proper heading detection
    fix_docx_headings "$input" "$output"
    fix_latex_artifacts "$output"

    echo -e "${GREEN}Done: $output${NC}"
}

convert_with_pandoc() {
    local input="$1"
    local outdir="$2"
    local ext="$3"
    local basename=$(basename "$input" ".$ext")
    local output="$outdir/$basename.md"

    echo -e "${GREEN}Converting .$ext with pandoc...${NC}"
    $PANDOC_BIN "$input" -o "$output" --wrap=none --markdown-headings=atx
    fix_latex_artifacts "$output"

    echo -e "${GREEN}Done: $output${NC}"
}

convert_text() {
    local input="$1"
    local outdir="$2"
    local ext="$3"
    local basename=$(basename "$input" ".$ext")
    local output="$outdir/$basename.md"

    echo -e "${GREEN}Copying text file as markdown...${NC}"
    cp "$input" "$output"

    echo -e "${GREEN}Done: $output${NC}"
}

# --- Main ---

if [ $# -lt 1 ]; then
    usage
fi

INPUT="$1"
if [ ! -f "$INPUT" ]; then
    echo -e "${RED}Error: File not found: $INPUT${NC}"
    echo ""
    echo "Note: ProtonDrive files can't be accessed from CLI."
    echo "Copy the file to ~/Desktop first, then convert from there."
    exit 1
fi

# Determine output directory
if [ $# -ge 2 ]; then
    OUTPUT_DIR="$2"
else
    OUTPUT_DIR=$(dirname "$INPUT")
fi
mkdir -p "$OUTPUT_DIR"

# Check tools
check_tools

# Get file extension (lowercase)
EXT="${INPUT##*.}"
EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DataWizard Document Converter"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Input:  $INPUT"
echo "  Output: $OUTPUT_DIR"
echo "  Format: .$EXT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

case "$EXT" in
    pdf)
        convert_pdf "$INPUT" "$OUTPUT_DIR"
        ;;
    docx|doc)
        convert_docx "$INPUT" "$OUTPUT_DIR"
        ;;
    epub|html|htm|pptx)
        convert_with_pandoc "$INPUT" "$OUTPUT_DIR" "$EXT"
        ;;
    txt|rtf)
        convert_text "$INPUT" "$OUTPUT_DIR" "$EXT"
        ;;
    *)
        echo -e "${RED}Unsupported format: .$EXT${NC}"
        echo "Supported: .pdf .docx .doc .epub .html .pptx .txt .rtf"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Conversion complete.${NC}"
