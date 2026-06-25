# Setup

End-to-end: get the CLIs installed and authed, build your expert's notebook in NotebookLM, then wire
the coach into Claude Code. Budget ~30–45 min the first time (most of it is NotebookLM ingesting
videos).

## 0. Prerequisites

- **Python 3.9+** and **`uv`** (`curl -LsSf https://astral.sh/uv/install.sh | sh`).
- **A NotebookLM account.** Free works but caps at **50 sources per notebook**; **Plus/Pro allows
  300** — strongly recommended for a real catalog. Same Google account will be used for both CLIs.
- **Claude Code** (for the interview + auto-onboarding). The skill also works in other agents that
  read `SKILL.md`, but the auto-run hook is Claude-Code-specific.

## 1. Install the two CLIs

NotebookLM has **no public API**. Two community tools automate it via your Google session — they are
separate projects with separate logins:

```bash
# Read side — queries + source listing (this is what ask_cited.py calls)
uv tool install notebooklm-mcp-cli            # gives you `nlm`

# Write side — create notebooks + bulk-load a channel
uv tool install "notebooklm-py[browser]"      # gives you `notebooklm`
uvx --from "notebooklm-py[browser]" playwright install chromium
```

## 2. Authenticate (two logins, same Google account)

```bash
nlm login           # read side. Borrows cookies from a Chromium browser you're signed into.
                    # SESSION IS SHORT (~20 min) — you'll re-run this when queries fail.
notebooklm login    # write side. Opens its own Chromium for a fresh Google login. Lasts weeks.
```

Verify: `nlm notebook list` (an empty `[]` means authed but no notebooks yet).

> If `nlm` queries later fail with **"Authentication expired"**, just run `nlm login` again. This is
> the #1 gotcha — see [LIMITATIONS.md](LIMITATIONS.md).

## 3. Create the notebook and load Jeff's channel

This repo defaults to the **Jeff Nippard** notebook. Build your own copy (you can only query notebooks
your own account owns). `scripts/load_channel.py` is included — swap the channel URL for any other expert:

```bash
# a) scrape the channel's videos (stdlib only)
python3 scripts/load_channel.py scrape \
  --channel "https://www.youtube.com/@JeffNippard" \
  --output /tmp/jeff-videos.json

# b) create the notebook — copy the printed <notebook-id>
notebooklm create "Jeff Nippard - Training Coach"

# c) load the newest 300 episodes (Plus/Pro). Keep concurrency LOW to avoid failed "red" rows.
uv run --with "notebooklm-py[browser]" python3 scripts/load_channel.py load \
  --videos /tmp/jeff-videos.json \
  --notebook <notebook-id> \
  --count 300 --concurrency 1
```

> `scripts/load_channel.py` ships in this repo (vendored from the
> [notebooklm-coach](https://github.com/artemnovitckii/notebooklm-coach) base skill, MIT).
> On a **free** account use `--count 50`. After loading, sanity-check how many ingested cleanly:
> ```bash
> nlm source list <notebook-id> --json | python3 -c "import json,sys;d=json.load(sys.stdin);r=[s for s in d if s['title'].strip().startswith('http')];print(f'good {len(d)-len(r)}  red {len(r)}')"
> ```

## 4. Point the coach at your notebook

`scripts/ask_cited.py` **defaults to the Jeff notebook id**, so if you're using Jeff you can skip
ahead. To use your own notebook (your own Jeff copy, or a different expert):

```bash
nlm notebook list                       # copy your notebook's "id"
cp .notebooklm-id.example .notebooklm-id
# edit .notebooklm-id → paste just the id on line 1   (or: export NOTEBOOKLM_ID=<id>)
```

Test that citations are real:

```bash
python3 scripts/ask_cited.py "How much training volume does Jeff recommend per muscle per week?"
# → answer + [N] 📎 Real Video Title + the verbatim passage quoted
```

## 5. (Only for a different expert) Customize the persona

For Jeff, the committed `CLAUDE.md` is ready to go. To adapt to another expert:

```bash
cp CLAUDE.md.template CLAUDE.md
```

Edit `CLAUDE.md`: set the expert's name, the domain (training, product, cooking…), where your
personal data lives, and the interview spine. The **everything-cited rule and the interview flow are
already written in** — don't loosen them.

## 6. Add your own data (optional but recommended)

The coach is best when it scores *your* data against the expert's criteria. Drop your data under
`data/` (gitignored) and describe it in `CLAUDE.md` (paths, columns). The Jeff example uses a Strong
app workout-log CSV plus a Python analysis; adapt to whatever your domain produces.

## 7. Use it in Claude Code

- **Open the folder in Claude Code.** On a fresh clone with no data, the `SessionStart` hook
  auto-starts the interview. With data already present it stays quiet — just say **"interview me"**.
- **Enable the hook:** Claude Code reads `.claude/settings.json` from the project. The first run may
  prompt you to approve the hook command — approve it. (Hooks run local shell, so review
  `.claude/hooks/onboard.sh` first — it only echoes a one-line instruction when `data/` is empty.)
- **Skill location:** project skills live in `.claude/skills/`. To make the coach available in every
  project instead, copy `.claude/skills/coach-interview/` into `~/.claude/skills/`.

That's it. Say "interview me" and every claim it makes will trace to a real video. If something
isn't covered, it'll tell you — that's the feature, not a bug.
