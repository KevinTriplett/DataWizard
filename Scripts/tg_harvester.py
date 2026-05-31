#!/usr/bin/env python3
"""
DW Telegram Harvester
Pulls messages from Telegram groups and extracts URLs.

Usage:
  python tg_harvester.py                    # Interactive: lists your groups, pick one
  python tg_harvester.py "Group Name"       # Pull from a specific group by name
  python tg_harvester.py -id 1234567890     # Pull from a specific group by ID
  python tg_harvester.py "Group" --limit 50 # Limit to last N messages
  python tg_harvester.py "Group" --links-only  # Only extract URLs, skip full dump

First run will ask for phone number + auth code (cached after that).
Credentials loaded from .env file in same directory, or set TG_API_ID / TG_API_HASH env vars.

Output:
  output/<group_name>_messages.json   - Full message dump
  output/<group_name>_links.txt       - Extracted URLs, one per line
  output/<group_name>_links.json      - URLs with context (sender, date, surrounding text)
"""

import argparse
import asyncio
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

from telethon import TelegramClient
from telethon.tl.types import (
    MessageEntityUrl,
    MessageEntityTextUrl,
    Channel,
    Chat,
    User,
)


SCRIPT_DIR = Path(__file__).parent.resolve()
SESSION_FILE = SCRIPT_DIR / "tg_harvester_session"
OUTPUT_DIR = SCRIPT_DIR / "output"


def load_credentials():
    """Load API credentials from .env file or environment variables."""
    api_id = os.environ.get("TG_API_ID")
    api_hash = os.environ.get("TG_API_HASH")

    # Try .env file in script directory
    env_file = SCRIPT_DIR / ".env"
    if env_file.exists():
        with open(env_file) as f:
            for line in f:
                line = line.strip()
                if line.startswith("#") or "=" not in line:
                    continue
                key, val = line.split("=", 1)
                key, val = key.strip(), val.strip().strip('"').strip("'")
                if key == "TG_API_ID":
                    api_id = val
                elif key == "TG_API_HASH":
                    api_hash = val

    if not api_id or not api_hash:
        print("ERROR: Missing API credentials.")
        print(f"Create {env_file} with:")
        print("  TG_API_ID=your_api_id")
        print("  TG_API_HASH=your_api_hash")
        print("Or set TG_API_ID and TG_API_HASH environment variables.")
        sys.exit(1)

    return int(api_id), api_hash


def extract_urls_from_message(message):
    """Extract all URLs from a message, including inline text URLs."""
    urls = []
    if not message.message:
        return urls

    # URLs from entities (hyperlinks, text URLs)
    if message.entities:
        for entity in message.entities:
            if isinstance(entity, MessageEntityUrl):
                url = message.message[entity.offset : entity.offset + entity.length]
                urls.append(url)
            elif isinstance(entity, MessageEntityTextUrl):
                urls.append(entity.url)

    # Fallback: regex for any URLs missed by entities
    url_pattern = re.compile(
        r"https?://[^\s<>\"')\]]+|www\.[^\s<>\"')\]]+"
    )
    for match in url_pattern.finditer(message.message):
        url = match.group()
        # Clean trailing punctuation
        url = url.rstrip(".,;:!?)")
        if url not in urls:
            urls.append(url)

    return urls


def sanitize_filename(name):
    """Make a string safe for use as a filename."""
    # Replace unsafe chars
    name = re.sub(r'[\\/*?:"<>|]', "_", name)
    name = re.sub(r"\s+", "_", name)
    name = name.strip("._")
    return name[:100]  # Truncate long names


async def list_groups(client):
    """List all groups/channels the user is part of."""
    groups = []
    async for dialog in client.iter_dialogs():
        entity = dialog.entity
        if isinstance(entity, (Channel, Chat)):
            groups.append(
                {
                    "id": entity.id,
                    "name": dialog.name,
                    "type": "channel" if isinstance(entity, Channel) else "group",
                    "members": getattr(entity, "participants_count", None),
                }
            )
    return groups


async def harvest_messages(client, target, limit=None):
    """Pull all messages from a group/channel."""
    messages = []
    count = 0

    async for message in client.iter_messages(target, limit=limit):
        sender_name = None
        if message.sender:
            if isinstance(message.sender, User):
                parts = [message.sender.first_name, message.sender.last_name]
                sender_name = " ".join(p for p in parts if p)
            else:
                sender_name = getattr(message.sender, "title", str(message.sender_id))

        urls = extract_urls_from_message(message)

        msg_data = {
            "id": message.id,
            "date": message.date.isoformat() if message.date else None,
            "sender_id": message.sender_id,
            "sender_name": sender_name,
            "text": message.message,
            "urls": urls,
            "reply_to": message.reply_to_msg_id if message.reply_to else None,
            "forwards": message.forwards,
            "views": message.views,
        }
        messages.append(msg_data)
        count += 1
        if count % 500 == 0:
            print(f"  ...pulled {count} messages")

    print(f"  Total: {count} messages")
    return messages


async def main():
    parser = argparse.ArgumentParser(description="DW Telegram Harvester")
    parser.add_argument("group", nargs="?", help="Group name to harvest (interactive if omitted)")
    parser.add_argument("-id", "--group-id", type=int, help="Group ID to harvest")
    parser.add_argument("--limit", type=int, help="Max messages to pull (default: all)")
    parser.add_argument("--links-only", action="store_true", help="Only extract and save links")
    parser.add_argument("--list", action="store_true", help="List all groups and exit")
    args = parser.parse_args()

    api_id, api_hash = load_credentials()
    client = TelegramClient(str(SESSION_FILE), api_id, api_hash)

    print("Connecting to Telegram...")
    await client.start()
    print("Connected.\n")

    # List mode
    if args.list:
        groups = await list_groups(client)
        print(f"Found {len(groups)} groups/channels:\n")
        for g in sorted(groups, key=lambda x: x["name"].lower()):
            members = f" ({g['members']} members)" if g["members"] else ""
            print(f"  [{g['type']:>7}] {g['name']}{members}  (id: {g['id']})")
        await client.disconnect()
        return

    # Resolve target group
    target = None
    group_name = None

    if args.group_id:
        target = args.group_id
        # Resolve name for filename
        try:
            entity = await client.get_entity(args.group_id)
            group_name = getattr(entity, "title", str(args.group_id))
        except Exception:
            group_name = str(args.group_id)

    elif args.group:
        # Search by name
        groups = await list_groups(client)
        matches = [g for g in groups if args.group.lower() in g["name"].lower()]
        if not matches:
            print(f"No group found matching '{args.group}'")
            print("Use --list to see all groups.")
            await client.disconnect()
            return
        elif len(matches) == 1:
            target = matches[0]["id"]
            group_name = matches[0]["name"]
        else:
            print(f"Multiple matches for '{args.group}':")
            for i, g in enumerate(matches, 1):
                print(f"  {i}. {g['name']} (id: {g['id']})")
            choice = input("Pick a number (or group ID): ").strip()
            choice_int = int(choice)
            # If the number matches a group ID, use it directly
            id_match = [g for g in matches if g["id"] == choice_int]
            if id_match:
                target = id_match[0]["id"]
                group_name = id_match[0]["name"]
            else:
                idx = choice_int - 1
                target = matches[idx]["id"]
                group_name = matches[idx]["name"]

    else:
        # Interactive mode
        groups = await list_groups(client)
        print(f"Your groups/channels ({len(groups)}):\n")
        for i, g in enumerate(sorted(groups, key=lambda x: x["name"].lower()), 1):
            members = f" ({g['members']} members)" if g["members"] else ""
            print(f"  {i:3}. [{g['type']:>7}] {g['name']}{members}")

        choice = input("\nPick a number: ").strip()
        idx = int(choice) - 1
        sorted_groups = sorted(groups, key=lambda x: x["name"].lower())
        target = sorted_groups[idx]["id"]
        group_name = sorted_groups[idx]["name"]

    safe_name = sanitize_filename(group_name)
    print(f"\nHarvesting: {group_name}")
    if args.limit:
        print(f"Limit: {args.limit} messages")

    # Pull messages
    messages = await harvest_messages(client, target, limit=args.limit)

    # Create output directory
    OUTPUT_DIR.mkdir(exist_ok=True)

    # Extract all links with context
    all_links = []
    unique_urls = set()
    for msg in messages:
        for url in msg["urls"]:
            unique_urls.add(url)
            all_links.append(
                {
                    "url": url,
                    "sender": msg["sender_name"],
                    "date": msg["date"],
                    "context": (msg["text"][:200] + "...") if msg["text"] and len(msg["text"]) > 200 else msg["text"],
                    "message_id": msg["id"],
                }
            )

    # Save links (always)
    links_file = OUTPUT_DIR / f"{safe_name}_links.txt"
    with open(links_file, "w") as f:
        for url in sorted(unique_urls):
            f.write(url + "\n")
    print(f"\nSaved {len(unique_urls)} unique URLs to {links_file}")

    links_json = OUTPUT_DIR / f"{safe_name}_links.json"
    with open(links_json, "w") as f:
        json.dump(all_links, f, indent=2, ensure_ascii=False, default=str)
    print(f"Saved {len(all_links)} link occurrences (with context) to {links_json}")

    # Save full messages (unless --links-only)
    if not args.links_only:
        msgs_file = OUTPUT_DIR / f"{safe_name}_messages.json"
        with open(msgs_file, "w") as f:
            json.dump(messages, f, indent=2, ensure_ascii=False, default=str)
        print(f"Saved {len(messages)} messages to {msgs_file}")

    # Summary
    print(f"\n--- Summary ---")
    print(f"Group: {group_name}")
    print(f"Messages: {len(messages)}")
    print(f"Unique URLs: {len(unique_urls)}")
    print(f"Total link mentions: {len(all_links)}")

    await client.disconnect()


if __name__ == "__main__":
    asyncio.run(main())
