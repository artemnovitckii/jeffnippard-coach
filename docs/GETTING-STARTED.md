# Getting started

No coding needed. Two easy paths — pick one.

## Easiest: let Claude do it

1. Download this folder (green **`< > Code` → Download ZIP** on the
   [repo page](https://github.com/artemnovitckii/jeffnippard-coach), then unzip), or
   `git clone https://github.com/artemnovitckii/jeffnippard-coach.git`.
2. Open the folder in **Claude Code** (`claude` in a terminal inside it, or *Open Folder* in the app).
3. Say:
   ```
   set me up
   ```
   Claude installs the tools, walks you through a one-time Google login (you'll click through two
   browser windows), loads Jeff's videos, and tests it. Then say **`interview me`** and you're coaching.

## Or: one command in a terminal

From inside the folder:

```bash
bash setup.sh
```

It installs everything, opens the two Google logins, loads Jeff's channel, saves your notebook id,
and runs a citation test. Press Enter to accept the defaults. When it finishes, open the folder in
Claude Code and say **`interview me`**.

---

### The two things to know

- **You need a Google account** (NotebookLM) and **Claude Code**. Free NotebookLM holds 50 videos per
  notebook; Plus/Pro holds 300 — the setup asks which.
- **The NotebookLM login lasts ~20 min.** If the coach ever says "authentication expired," just run
  `nlm login` again (or `! nlm login` inside Claude Code). That's normal.

Want the manual, step-by-step version instead? See [SETUP.md](SETUP.md). Things that can break are in
[LIMITATIONS.md](LIMITATIONS.md).
