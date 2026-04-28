---
name: engram-sync
description: Sync Engram persistent memory across machines via Git. Use when the user asks to sync, push, pull or share Engram memory between devices. Handles export→push and pull→import workflows automatically.
license: MIT
metadata:
  author: FelipePepe
  version: "1.0.0"
---

# Engram Memory Sync

Engram stores persistent AI memory in SQLite locally. This skill syncs that memory across machines using a private Git repository as transport.

## Setup

- Sync repo: `~/engram-memory`
- Remote: `https://github.com/FelipePepe/engram-memory`
- `.gitignore` includes `engram.db` (never commit the DB, only chunks)

## Workflow

### Export — send this machine's memories to the repo

```bash
cd ~/engram-memory
engram sync --all
git add -A
git commit -m "sync: $(hostname) $(date '+%Y-%m-%d %H:%M')"
git push
```

### Import — receive memories from other machines

```bash
cd ~/engram-memory
git pull
engram sync --import
```

### Full bidirectional sync (export + import)

```bash
cd ~/engram-memory
engram sync --all
git add -A
git commit -m "sync: $(hostname) $(date '+%Y-%m-%d %H:%M')" --allow-empty
git pull --rebase
git push
engram sync --import
```

## How It Works

- `engram sync --all` exports all memories as compressed JSONL chunks in `chunks/` and updates `manifest.json`
- Each chunk has a SHA-256 ID — no duplicates on import
- `engram sync --import` reads `manifest.json` and imports any chunks not yet in the local DB
- Multiple machines can push independently; chunks never conflict (append-only)

## When to Run Each Command

| Situation | Command |
|---|---|
| Before ending a session | export + push |
| Starting a session on a different machine | pull + import |
| Sharing memories with raspi | full bidirectional sync |

## Instructions for Claude

When the user invokes this skill:
1. Ask whether they want to **export** (send), **import** (receive), or **both**
2. Run the appropriate commands above using the Bash tool
3. Report how many chunks/observations were synced
4. If `git pull` causes conflicts (unlikely but possible), show the conflict and ask how to proceed
