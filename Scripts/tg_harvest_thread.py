#!/usr/bin/env python3
"""
tg_harvest_thread.py - DataWizard enhanced Telegram thread harvester.

Downloads TEXT artifacts from a single Telegram thread/topic:
  - long messages (>= LONG_MSG_CHARS) saved as individual .md files
  - text/markdown/doc attachments (.txt .md .csv .json .pdf .docx ...)
  - anything from/about "Crush", "bonfire", or "transcript" (flagged)
Skips audio/video and oversized files. Also writes a full thread
transcript (_thread_full_transcript.md) and a structured dump
(_messages.json).

Reads TG_API_ID / TG_API_HASH from the environment or a .env file next to
this script. First run prompts for phone + login code (and your 2FA
password if enabled); the session is cached locally in dw_tg_session.session.

Usage:
    python3 tg_harvest_thread.py          # just the topic-22 thread
    python3 tg_harvest_thread.py --all    # whole chat (if topic filter is thin)
"""

import os, re, json, sys
from pathlib import Path
from datetime import datetime, timezone

# ---- Config -----------------------------------------------------------
CHAT_ID  = -1001234567890   # t.me/c/1234567890  (private supergroup)
CHANNEL  = 1234567890       # same chat, bare id (fallback resolution)
TOPIC_ID = 22               # thread root from t.me/c/1234567890/22
OUT_DIR  = Path("/Users/USERNAME/Vaults/Regen Vault/_Regenerativa/"
                "EXAMPLE-ORG/Events/EXAMPLE-EVENT/Artifacts")
SESSION  = "dw_tg_session"

LONG_MSG_CHARS = 400
MAX_DOC_BYTES  = 15 * 1024 * 1024
TEXT_EXTS = {".txt",".md",".markdown",".mdown",".rtf",".csv",".tsv",
             ".json",".log",".org",".text",".pdf",".doc",".docx",".odt"}
FLAG_TERMS = ("crush", "bonfire", "transcript")
HARVEST_ALL = "--all" in sys.argv
# -----------------------------------------------------------------------

def load_env():
    p = Path(__file__).with_name(".env")
    if p.exists():
        for line in p.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())

load_env()
try:
    API_ID = int(os.environ["TG_API_ID"]); API_HASH = os.environ["TG_API_HASH"]
except KeyError:
    sys.exit("Missing TG_API_ID / TG_API_HASH (set them in .env or the environment).")

from telethon.sync import TelegramClient
from telethon.tl.types import (DocumentAttributeFilename, DocumentAttributeAudio,
                               DocumentAttributeVideo, PeerChannel)

def safe(s, n=60):
    s = re.sub(r'[\\/:*?"<>|\t\r\n]+', "_", (s or "")).strip(" ._")
    return s[:n] or "untitled"

def sender_label(msg):
    try:
        s = msg.sender
        if s is None:
            return f"id{msg.sender_id}"
        name = " ".join(filter(None, [getattr(s, "first_name", None),
                                       getattr(s, "last_name", None)]))
        return name or getattr(s, "username", None) or getattr(s, "title", None) or f"id{msg.sender_id}"
    except Exception:
        return f"id{msg.sender_id}"

def doc_info(msg):
    doc = getattr(msg, "document", None)
    if not doc:
        return None
    mime = getattr(doc, "mime_type", "") or ""
    size = getattr(doc, "size", 0) or 0
    fname = None
    is_av = mime.startswith(("audio/", "video/"))
    for a in doc.attributes:
        if isinstance(a, DocumentAttributeFilename):
            fname = a.file_name
        if isinstance(a, (DocumentAttributeAudio, DocumentAttributeVideo)):
            is_av = True
    if getattr(msg, "voice", False) or getattr(msg, "video_note", False):
        is_av = True
    return fname, mime, size, is_av

def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    saved, skipped, transcript = [], [], []
    with TelegramClient(str(Path(__file__).with_name(SESSION)), API_ID, API_HASH) as client:
        client.get_dialogs()  # populate entity cache so a private id resolves
        try:
            entity = client.get_entity(CHAT_ID)
        except Exception:
            entity = client.get_entity(PeerChannel(CHANNEL))
        kwargs = {} if HARVEST_ALL else {"reply_to": TOPIC_ID}
        print(f"Fetching from '{getattr(entity, 'title', 'chat')}' "
              f"({'ALL messages' if HARVEST_ALL else 'topic ' + str(TOPIC_ID)}) ...")
        msgs = list(client.iter_messages(entity, **kwargs))
        msgs.reverse()  # chronological
        print(f"  {len(msgs)} messages")
        for m in msgs:
            date = (m.date or datetime.now(timezone.utc)).astimezone().strftime("%Y-%m-%d")
            who = sender_label(m)
            text = m.message or ""
            transcript.append(f"### {date} - {who} (msg {m.id})\n\n{text or '[no text]'}\n")
            flagged = any(t in (text.lower() + who.lower()) for t in FLAG_TERMS)

            di = doc_info(m)
            if di:
                fname, mime, size, is_av = di
                label = fname or f"doc_{m.id}"
                ext = Path(fname or "").suffix.lower()
                if is_av:
                    skipped.append((label, f"audio/video ({mime})"))
                elif size > MAX_DOC_BYTES:
                    skipped.append((label, f"too large ({size//1024} KB)"))
                elif ext in TEXT_EXTS or mime.startswith("text/") or flagged:
                    out = OUT_DIR / f"{m.id:05d}_{date}_{safe(Path(label).stem)}{ext or '.bin'}"
                    client.download_media(m, file=str(out))
                    saved.append((out.name, f"attachment {mime or ext or ''}".strip()))
                else:
                    skipped.append((label, f"non-text ({mime or ext or 'unknown'})"))

            if text and (len(text) >= LONG_MSG_CHARS or flagged):
                tag = "_FLAG" if flagged else ""
                out = OUT_DIR / f"{m.id:05d}_{date}_{safe(who)}{tag}.md"
                header = (f"---\nsource: telegram\nchat_id: {CHAT_ID}\n"
                          f"message_id: {m.id}\nsender: {who}\ndate: {date}\n---\n\n")
                out.write_text(header + text, encoding="utf-8")
                saved.append((out.name, "long message" + (" [flagged]" if flagged else "")))

        (OUT_DIR / "_thread_full_transcript.md").write_text(
            f"# EXAMPLE-EVENT thread transcript\n\nChat {CHAT_ID}, "
            f"{'all messages' if HARVEST_ALL else 'topic ' + str(TOPIC_ID)}, "
            f"harvested {datetime.now().strftime('%Y-%m-%d')}\n\n" + "\n".join(transcript),
            encoding="utf-8")
        dump = [{"id": m.id,
                 "date": (m.date.isoformat() if m.date else None),
                 "sender": sender_label(m),
                 "text": m.message or "",
                 "has_media": bool(getattr(m, "media", None))} for m in msgs]
        (OUT_DIR / "_messages.json").write_text(
            json.dumps(dump, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"\nSaved {len(saved)} artifact(s) to:\n  {OUT_DIR}")
    for n, why in saved:
        print(f"  + {n}  ({why})")
    if skipped:
        print(f"\nSkipped {len(skipped)} (audio/video/large/non-text):")
        for n, why in skipped:
            print(f"  - {n}  ({why})")
    print("\nAlso wrote _thread_full_transcript.md and _messages.json")

if __name__ == "__main__":
    main()
