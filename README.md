# jeffnippard-coach

A personal **Jeff Nippard training coach** that cites every claim for real. Built on 285
[Jeff Nippard](https://www.youtube.com/@JeffNippard) videos loaded into NotebookLM, it interviews you
one question at a time, scores your real workout data against Jeff's evidence-based criteria, and
writes you a program — and **every single recommendation is backed by a verbatim passage from an
actual Jeff video.** No freestyling, no made-up sources. If Jeff never covered something, the coach
says so instead of inventing an answer.

```
You:   interview me to get jacked
Coach: For most muscles the growth sweet spot is ~10–20 hard sets per week, and past that
       you hit junk volume that just costs recovery.
       📎 Source: "How Much Training Volume Do You Really Need? (Science Explained)"
          "once you get into the 20 to 30 sets per week zone you start running into
           overtraining issues which could actually dampen your gains…"

       So, one question: how many days a week can you realistically train?
```

> **Self-contained.** Channel-loading (`scripts/load_channel.py`) is vendored from the
> [notebooklm-coach](https://github.com/artemnovitckii/notebooklm-coach) skill (MIT) — clone this
> repo and you have everything. This is the opinionated Jeff *coaching app*: the hard-citation
> interview, the auto-onboarding, the program builder. Works for any expert: swap the notebook id and
> rewrite the persona (see [below](#use-it-for-a-different-expert)).

## Why it's different

- **Everything is cited — for real.** Every claim carries a source returned from the notebook *this
  session* via `scripts/ask_cited.py` (prints answer + real titles + verbatim quotes). Never from memory.
- **No fabrication, by design.** If the helper returns no source for a claim, the coach **drops the
  claim**. There is no uncited assertion — that's the whole point.
- **Auto-onboards new users.** A fresh clone (no workout data yet) auto-starts the interview via a
  Claude Code `SessionStart` hook.
- **Your data, scored against Jeff's criteria** — not invented thresholds.

## Quickstart

1. **Install + auth the CLIs** and **load Jeff's channel** into NotebookLM — see
   [docs/SETUP.md](docs/SETUP.md) (uses the `notebooklm-coach` base skill's `load_channel.py`).
2. **Test it's cited:** `python3 scripts/ask_cited.py "How much volume does Jeff recommend?"`
3. **Add your data:** drop a Strong-app export at `data/strong_workouts.csv` (gitignored).
4. **Coach yourself:** open the folder in Claude Code and say **"interview me"**.

Full step-by-step (NotebookLM, Claude Code, hooks, data): **[docs/SETUP.md](docs/SETUP.md)**.

## What's in here

```
jeffnippard-coach/
├── README.md                       # this file
├── CLAUDE.md                       # the Jeff coach persona/primer (the everything-cited rule)
├── CLAUDE.md.template              # blank persona for adapting to another expert
├── .notebooklm-id.example          # override the default notebook id (→ .notebooklm-id)
├── .claude/
│   ├── settings.json               # SessionStart hook (auto-onboarding) — Claude Code
│   ├── hooks/onboard.sh            # detects a fresh clone → starts the interview
│   └── skills/coach-interview/     # the cited interview skill
├── scripts/
│   ├── ask_cited.py                # the live-citation engine (defaults to the Jeff notebook)
│   └── load_channel.py             # scrape a YouTube channel → bulk-load into NotebookLM
└── docs/
    ├── SETUP.md                    # full setup: NotebookLM + nlm + notebooklm-py + Claude Code
    └── LIMITATIONS.md              # auth expiry, source caps, coverage gaps, what can break
```

## The no-fabrication rule

LLMs will happily produce a plausible-sounding Jeff video title that doesn't exist — and that single
behavior destroys the trust this tool is built on. So the rule is absolute: **a claim is either
backed by a title + quote the notebook returned this session, or it isn't made.** The coach
pre-fetches the core training topics once (so it's fast), cites from those real results, and for
anything off-topic it queries live or admits the notebook doesn't cover it. See
[docs/LIMITATIONS.md](docs/LIMITATIONS.md).

## Use it for a different expert

Nothing here is hardwired to Jeff except the content:

1. Load a different channel into a new NotebookLM notebook (see SETUP step 3).
2. Point the coach at it: `cp .notebooklm-id.example .notebooklm-id` and paste the new id (or
   `export NOTEBOOKLM_ID=<id>`). `ask_cited.py` and the skill pick it up automatically.
3. Rewrite the persona: `cp CLAUDE.md.template CLAUDE.md` and fill in the expert, domain, and the
   interview "spine" (the core topics + pre-fetch questions for your field).

## Credit

Coaching layer by [@artemnovitckii](https://github.com/artemnovitckii). Built on
[notebooklm-coach](https://github.com/artemnovitckii/notebooklm-coach) and the
[notebooklm-mcp-cli](https://github.com/jacob-bd/notebooklm-mcp-cli) / `notebooklm-py` projects. MIT.
