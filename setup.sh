#!/usr/bin/env bash
# One-command setup for jeffnippard-coach.
#   bash setup.sh
# Installs the tools, logs you into NotebookLM, loads Jeff's videos, and wires the
# notebook id — then you just open the folder in Claude Code and say "interview me".
set -euo pipefail
cd "$(dirname "$0")"

say() { printf "\n\033[1;32m▸ %s\033[0m\n" "$*"; }
ask() { local p="$1" d="$2" a; read -r -p "$p [$d]: " a || true; echo "${a:-$d}"; }

say "1/6  Installing uv (tool manager)…"
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

say "2/6  Installing the NotebookLM tools (nlm + notebooklm)…"
uv tool install -q notebooklm-mcp-cli || true
uv tool install -q "notebooklm-py[browser]" || true
uvx --from "notebooklm-py[browser]" playwright install chromium >/dev/null 2>&1 || true
export PATH="$HOME/.local/bin:$PATH"

say "3/6  Logging into Google (two browser windows — pick the SAME account)…"
echo "    A browser will open. Finish the login, then come back here."
nlm login || true
notebooklm login || true
if ! nlm notebook list >/dev/null 2>&1; then
  echo "  ⚠️  nlm isn't authenticated yet. Run 'nlm login' and re-run this script." ; exit 1
fi

if [ -f .notebooklm-id ]; then
  say "Notebook already configured ($(head -1 .notebooklm-id)). Skipping load."
else
  CH=$(ask "4/6  YouTube channel to load" "https://www.youtube.com/@JeffNippard")
  TITLE=$(ask "     Notebook name" "Jeff Nippard - Training Coach")
  CNT=$(ask "     How many videos? (free NotebookLM=50, Plus/Pro=300)" "300")

  say "Scraping channel…"
  python3 scripts/load_channel.py scrape --channel "$CH" --output /tmp/coach-videos.json

  say "Creating the notebook…"
  notebooklm create "$TITLE" || true
  NB=$(nlm notebook list --json | python3 -c "import json,sys;n=[x['id'] for x in json.load(sys.stdin) if x.get('title')=='$TITLE'];print(n[0] if n else '')")
  [ -n "$NB" ] || { echo "  ⚠️  Couldn't find the new notebook. Run 'nlm notebook list' and add its id to .notebooklm-id"; exit 1; }
  echo "$NB" > .notebooklm-id
  say "Notebook id saved → .notebooklm-id ($NB)"

  say "5/6  Loading $CNT videos (this takes a while — let it finish)…"
  uv run --with "notebooklm-py[browser]" python3 scripts/load_channel.py load \
    --videos /tmp/coach-videos.json --notebook "$NB" --count "$CNT" --concurrency 1 || true
fi

say "6/6  Testing that citations are real…"
python3 scripts/ask_cited.py "How much training volume does the expert recommend per muscle per week?" || true

cat <<'DONE'

✅ Setup complete.
   Next: open this folder in Claude Code and say:  interview me
   (Heads up: the nlm login lasts ~20 min — if it expires, run `nlm login` again.)
DONE
