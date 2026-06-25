---
name: setup
description: Use when the user wants to set up / install this coach, says "set me up", "setup", "get me started", "install", or hasn't loaded a notebook yet (no .notebooklm-id and no data). Walks them through one-command setup inside Claude Code.
---

# Setup (one command)

Get a brand-new user from zero to a working, cited coach. The heavy lifting is in `setup.sh`; the
only thing you can't do for them is the two Google logins (they open a browser), so you delegate
those via the `!` prefix.

## Do this, in order

1. **Run the installer's non-interactive parts** with Bash (installs uv + the NotebookLM CLIs):
   ```bash
   command -v uv >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh
   export PATH="$HOME/.local/bin:$PATH"
   uv tool install notebooklm-mcp-cli
   uv tool install "notebooklm-py[browser]"
   uvx --from "notebooklm-py[browser]" playwright install chromium
   ```

2. **Hand the two logins to the user.** You can't complete a browser login from a tool call, so tell
   them to paste these into the Claude Code prompt (the `!` runs it in their session so the browser
   opens for them), one at a time, same Google account:
   ```
   ! nlm login
   ! notebooklm login
   ```
   Wait for them to confirm. Verify with `nlm notebook list` (an empty `[]` = logged in).

3. **Load the channel + wire the notebook** by running the rest of setup:
   ```bash
   bash setup.sh
   ```
   It scrapes Jeff's channel, creates the notebook, writes the id to `.notebooklm-id`, loads the
   videos, and runs a citation test. (It skips the install/login steps you already did.) Defaults:
   `@JeffNippard`, 300 videos — ask the user if they want a different channel or are on free
   NotebookLM (then use 50).

4. **Confirm it's cited:** show them the output of
   `python3 scripts/ask_cited.py "How much volume does Jeff recommend?"` — real titles + quotes.

5. **Tell them what's next:** "Setup's done — just say **interview me** and I'll build your program,
   citing a real Jeff video for every claim." If the `nlm` login expires (~20 min), they re-run
   `! nlm login`.

## Notes
- If `.notebooklm-id` already exists, setup is done — skip straight to the interview.
- Already have data + a notebook? Don't run setup; just coach.
- Different expert: same flow, give a different channel URL, then `cp CLAUDE.md.template CLAUDE.md`.
