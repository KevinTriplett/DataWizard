#!/usr/bin/env python3
"""
tg_harvest_thread.py - DataWizard Telegram thread/topic harvester.

Download TEXT artifacts from a Telegram chat, or from a single forum
topic / reply thread:
  - long messages (>= --long-chars) saved as individual .md files
  - text/markdown/doc attachments (.txt .md .csv .json .pdf .docx ...)
  - anything from/about the flag terms (default: crush, bonfire, transcript)
Skips audio/video and oversized files (override with --include-audio / --max-mb).
Also writes a full thread transcript (_thread_full_transcript.md) and a
structured dump (_messages.json).

Credentials: TG_API_ID / TG_API_HASH from the environment or a .env file
next to this script. First run prompts for phone + login code (and your
2FA password if set); the session is cached locally.

    pip install telethon

Examples:
  # one forum topic, straight from its Telegram link
  python3 tg_harvest_thread.py "https://t.me/c/1234567890/22" --out "/path/to/Artifacts"

  # a whole private chat by id
  python3 tg_harvest_thread.py -1001234567890 --all --out ./output

  # a public group by @username, topic 22, also grab audio
  python3 tg_harvest_thread.py https://t.me/mygroup/22 --out ./output --include-audio
"""

import argparse, os, re, json, sys
from pathlib import Path
from datetime import datetime, timezone

DEFAULT_FLAGS = ["crush", "bonfire", "transcript"]
TEXT_EXTS = {".txt", ".md", ".markdown", ".mdown", ".rtf", ".csv", ".tsv",
             ".json", ".log", ".org", ".text", ".pdf", ".doc", ".docx", ".odt"}


def parse_target(s):
    """Return (peer, topic_id). peer is an int chat_id or a str username."""
    s = (s or "").strip()
    m = re.search(r"t\.me/c/(\d+)(?:/(\d+))?", s)
    if m:
        return int("-100" + m.group(1)), (int(m.group(2)) if m.group(2) else None)
    m = re.search(r"t\.me/([A-Za-z][\w]{3,})(?:/(\d+))?", s)
    if m:
        return m.group(1), (int(m.group(2)) if m.group(2) else None)
    if re.fullmatch(r"-?\d+", s):
        return int(s), None
    return s.lstrip("@"), None


def load_env():
    p = Path(__file__).with_name(".env")
    if p.exists():
        for line in p.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())


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


def main():
    ap = argparse.ArgumentParser(
        description="Harvest text artifacts from a Telegram chat or forum topic.",
        formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__)
    ap.add_argument("target", nargs="?",
                    help="Telegram chat/thread link, @username, or numeric chat id")
    ap.add_argument("--chat", help="override chat (numeric id or @username)")
    ap.add_argument("--topic", type=int, help="forum topic / thread root message id")
    ap.add_argument("--all", action="store_true",
                    help="whole chat; ignore any topic filter")
    ap.add_argument("--out", default="output", help="output directory (default: ./output)")
    ap.add_argument("--long-chars", type=int, default=400,
                    help="save messages at least this long as .md (default: 400)")
    ap.add_argument("--max-mb", type=float, default=15.0,
                    help="skip attachments larger than this (default: 15)")
    ap.add_argument("--include-audio", action="store_true",
                    help="also download audio/video attachments")
    ap.add_argument("--flags", default=",".join(DEFAULT_FLAGS),
                    help="comma-separated flag terms; pass '' to disable")
    ap.add_argument("--limit", type=int, default=None,
                    help="only the most recent N messages")
    ap.add_argument("--session", default=None, help="Telethon session name/path")
    args = ap.parse_args()

    peer, topic = parse_target(args.target) if args.target else (None, None)
    if args.chat:
        peer, _ = parse_target(args.chat)
    if args.topic is not None:
        topic = args.topic
    if args.all:
        topic = None
    if peer is None:
        ap.error("provide a target link/id/@username, or --chat")

    load_env()
    try:
        api_id = int(os.environ["TG_API_ID"]); api_hash = os.environ["TG_API_HASH"]
    except KeyError:
        sys.exit("Missing TG_API_ID / TG_API_HASH (set them in .env or the environment).")

    from telethon.sync import TelegramClient
    from telethon.tl.types import (DocumentAttributeFilename, DocumentAttributeAudio,
                                   DocumentAttributeVideo, PeerChannel)

    out_dir = Path(args.out).expanduser()
    out_dir.mkdir(parents=True, exist_ok=True)
    max_bytes = int(args.max_mb * 1024 * 1024)
    flag_terms = [t.strip().lower() for t in args.flags.split(",") if t.strip()]
    session = args.session or str(Path(__file__).with_name("dw_tg_session"))

    def doc_info(msg):
        doc = getattr(msg, "document", None)
        if not doc:
            return None
        mime = getattr(doc, "mime_type", "") or ""
        size = getattr(doc, "size", 0) or 0
        fname, is_av = None, mime.startswith(("audio/", "video/"))
        for a in doc.attributes:
            if isinstance(a, DocumentAttributeFilename):
                fname = a.file_name
            if isinstance(a, (DocumentAttributeAudio, DocumentAttributeVideo)):
                is_av = True
        if getattr(msg, "voice", False) or getattr(msg, "video_note", False):
            is_av = True
        return fname, mime, size, is_av

    saved, skipped, transcript = [], [], []
    with TelegramClient(session, api_id, api_hash) as client:
        client.get_dialogs()  # populate entity cache so private ids resolve
        try:
            entity = client.get_entity(peer)
        except Exception:
            if isinstance(peer, int) and str(peer).startswith("-100"):
                entity = client.get_entity(PeerChannel(int(str(peer)[4:])))
            else:
                raise
        kwargs = {}
        if topic is not None:
            kwargs["reply_to"] = topic
        if args.limit:
            kwargs["limit"] = args.limit
        print(f"Fetching from '{getattr(entity, 'title', peer)}' "
              f"({'topic ' + str(topic) if topic is not None else 'all messages'}) ...")
        msgs = list(client.iter_messages(entity, **kwargs))
        msgs.reverse()  # chronological
        print(f"  {len(msgs)} messages")
        for m in msgs:
            date = (m.date or datetime.now(timezone.utc)).astimezone().strftime("%Y-%m-%d")
            who = sender_label(m)
            text = m.message or ""
            transcript.append(f"### {date} - {who} (msg {m.id})\n\n{text or '[no text]'}\n")
            flagged = bool(flag_terms) and any(t in (text.lower() + who.lower()) for t in flag_terms)

            di = doc_info(m)
            if di:
                fname, mime, size, is_av = di
                label = fname or f"doc_{m.id}"
                ext = Path(fname or "").suffix.lower()
                if is_av and not args.include_audio:
                    skipped.append((label, f"audio/video ({mime})"))
                elif size > max_bytes:
                    skipped.append((label, f"too large ({size // 1024} KB)"))
                elif ext in TEXT_EXTS or mime.startswith("text/") or flagged or is_av:
                    dest = out_dir / f"{m.id:05d}_{date}_{safe(Path(label).stem)}{ext or '.bin'}"
                    client.download_media(m, file=str(dest))
                    saved.append((dest.name, f"attachment {mime or ext or ''}".strip()))
                else:
                    skipped.append((label, f"non-text ({mime or ext or 'unknown'})"))

            if text and (len(text) >= args.long_chars or flagged):
                tag = "_FLAG" if flagged else ""
                dest = out_dir / f"{m.id:05d}_{date}_{safe(who)}{tag}.md"
                header = (f"---\nsource: telegram\nchat: {peer}\n"
                          f"message_id: {m.id}\nsender: {who}\ndate: {date}\n---\n\n")
                dest.write_text(header + text, encoding="utf-8")
                saved.append((dest.name, "long message" + (" [flagged]" if flagged else "")))

        (out_dir / "_thread_full_transcript.md").write_text(
            f"# Telegram harvest transcript\n\nChat {peer}, "
            f"{'topic ' + str(topic) if topic is not None else 'all messages'}, "
            f"harvested {datetime.now().strftime('%Y-%m-%d')}\n\n" + "\n".join(transcript),
            encoding="utf-8")
        dump = [{"id": m.id,
                 "date": (m.date.isoformat() if m.date else None),
                 "sender": sender_label(m),
                 "text": m.message or "",
                 "has_media": bool(getattr(m, "media", None))} for m in msgs]
        (out_dir / "_messages.json").write_text(
            json.dumps(dump, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"\nSaved {len(saved)} artifact(s) to:\n  {out_dir}")
    for n, why in saved:
        print(f"  + {n}  ({why})")
    if skipped:
        print(f"\nSkipped {len(skipped)}:")
        for n, why in skipped:
            print(f"  - {n}  ({why})")
    print("\nAlso wrote _thread_full_transcript.md and _messages.json")


if __name__ == "__main__":
    main()
