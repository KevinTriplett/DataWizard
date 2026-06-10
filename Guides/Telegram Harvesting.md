---
title: Telegram Harvesting
type: guide
created: '2026-05-31'
updated: '2026-05-31'
status: active
tags:
  - protocol
  - harvesting
  - DataWizard
  - telegram
---

# Telegram Harvesting

Pull messages and links from any Telegram group or channel you belong to. Uses the Telegram API via the `tg_harvester.py` script in `Seed/Scripts/`.

## Prerequisites

- Python 3.8+
- A Telegram account
- `pip install telethon`

## One-Time Setup - API Credentials

You need a Telegram API app (free, takes 30 seconds):

1. Go to https://my.telegram.org and log in with your phone number
2. Click "API development tools"
3. Fill in the form (title and short name are just labels for your reference -- use anything)
4. Select "Desktop" as the platform
5. Click "Create application"
6. Note your **api_id** (a number) and **api_hash** (a hex string)

Create a `.env` file next to the script:

```
TG_API_ID=12345678
TG_API_HASH=abcdef1234567890abcdef1234567890
```

Alternatively, set `TG_API_ID` and `TG_API_HASH` as environment variables.

**Security notes:**
- These are app-level credentials, not your account password. They identify your app to Telegram's API.
- User authentication (phone + one-time code) happens on first run and is cached in a `.session` file.
- Do not commit `.env` or `.session` files to git. The Seed's `.gitignore` excludes `Scripts/.env`, `Scripts/*.session`, and `Scripts/output/` (added DW-S163).
- Keep any note recording these credentials OUT of git-tracked vault folders. Use a gitignored private folder (e.g. a vault-root `_Private/`) or a password manager.

## First Run - Authentication

The first time you run the script, Telethon will prompt for:
1. Your phone number (international format, e.g. +15551234567)
2. A confirmation code sent via Telegram (not SMS)

After this, a session file is created next to the script. Subsequent runs authenticate automatically.

## Usage

Run from the directory containing the script, or use the full path.

**List all your groups and channels:**
```bash
python tg_harvester.py --list
```

**Harvest a group by name (substring match):**
```bash
python tg_harvester.py "ARK"
```
If multiple groups match, you'll be prompted to pick one (by number or group ID).

**Harvest by group ID (no ambiguity):**
```bash
python tg_harvester.py -id 3991631043
```

**Limit to the most recent N messages:**
```bash
python tg_harvester.py "ARK" --limit 100
```

**Extract only URLs (skip the full message dump):**
```bash
python tg_harvester.py "ARK" --links-only
```

**Interactive mode (lists all groups, you pick):**
```bash
python tg_harvester.py
```

## Output

All output goes to an `output/` directory next to the script.

### group_name_messages.json

Full message dump. Each message includes:
- `id` -- Telegram message ID
- `date` -- ISO timestamp
- `sender_id`, `sender_name` -- who sent it
- `text` -- message content
- `urls` -- list of URLs extracted from the message
- `reply_to` -- message ID this replies to (if any)
- `forwards`, `views` -- engagement metrics (channels only)

Skipped when using `--links-only`.

### group_name_links.txt

Deduplicated list of all URLs found, sorted alphabetically, one per line. Useful for quick scanning or feeding into other tools.

### group_name_links.json

Every URL occurrence with context:
- `url` -- the link
- `sender` -- who posted it
- `date` -- when
- `context` -- first 200 characters of the message
- `message_id` -- for tracing back to the full message

This is the most useful file for research triage -- you can see who shared each link and what they said about it.

## Processing Output in DW

After harvesting, the output files are ready for research triage:

1. **Quick scan:** Open `_links.txt` to eyeball the URL landscape -- how many GitHub repos, articles, tools, etc.
2. **Contextual triage:** Use `_links.json` to understand why links were shared. The `context` field often contains the poster's assessment or recommendation.
3. **RTI integration:** Evaluate links against the Research Tracking Index to avoid duplicate research. Add new entries for items worth investigating.
4. **Batch processing:** For large link sets (100+), categorize by domain or topic first, then triage in batches.

The full `_messages.json` dump is useful when you need the complete conversation flow -- for example, to understand a multi-message discussion thread or find messages without links that still contain valuable ideas.

## Tips

- **Re-running is safe.** Output files are overwritten, not appended. Run as often as you want.
- **Large groups.** For groups with thousands of messages, use `--limit` on the first run to test, then run without it for the full pull.
- **Multiple groups.** Run the script once per group. Output files are named by group, so they don't collide.
- **Session persistence.** The `.session` file caches your auth. If you move the script, move the session file too (or re-authenticate).
- **Rate limits.** Telegram has API rate limits. For very large groups (10K+ messages), the script may slow down. This is normal.
