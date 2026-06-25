# Getting started (for absolute beginners)

No coding experience needed. You'll copy-paste a few commands, log into Google twice, and then just
**talk to your coach in plain English.** Budget ~30–45 minutes the first time (most of it is the
computer downloading videos in the background).

**What you need:** a Mac or Windows computer, a Google account, and a free
[Anthropic account](https://claude.com) for Claude Code.

> Throughout, "open a terminal" means: **Mac** → open the **Terminal** app (Cmd+Space, type
> "Terminal"). **Windows** → open **PowerShell** (Start menu, type "PowerShell"). You'll paste
> commands there and press Enter.

---

## Step 1 — Install Claude Code

Claude Code is the app you'll actually chat with. Easiest way:

1. Go to **[claude.com/claude-code](https://claude.com/claude-code)** and follow the install button
   for your computer, **or** if you have Node.js, paste this in a terminal:
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```
2. Log in when it asks (use your Anthropic/Claude account).

That's the chat part done. Now we give it superpowers.

---

## Step 2 — Download the coach

1. Go to **[github.com/artemnovitckii/jeffnippard-coach](https://github.com/artemnovitckii/jeffnippard-coach)**.
2. Click the green **`< > Code`** button → **Download ZIP**.
3. Unzip it. You'll get a folder called `jeffnippard-coach`. Put it somewhere easy, like your Desktop.

*(Comfortable with git? Instead just run `git clone https://github.com/artemnovitckii/jeffnippard-coach.git`.)*

---

## Step 3 — Install the two helper tools

These let the coach talk to NotebookLM (Google's notebook app). Paste these into a terminal, one
block at a time, pressing Enter after each:

```bash
# 1. Install "uv" (a tool installer). Mac/Linux:
curl -LsSf https://astral.sh/uv/install.sh | sh
```
*(On Windows PowerShell instead run: `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`)*

```bash
# 2. Install the two NotebookLM tools
uv tool install notebooklm-mcp-cli
uv tool install "notebooklm-py[browser]"
uvx --from "notebooklm-py[browser]" playwright install chromium
```

If a command "isn't found" right after installing, close the terminal and open a new one, then continue.

---

## Step 4 — Log into Google (twice)

NotebookLM has no official app for this, so two small tools log in for you. Run each and finish the
Google login window that pops up:

```bash
nlm login          # a browser window opens — pick your Google account
notebooklm login   # another window — pick the SAME Google account
```

✅ Check it worked: run `nlm notebook list`. If you see `[]` (empty brackets), you're logged in.

> **Remember this:** the `nlm` login only lasts about **20 minutes**. If the coach later says
> "authentication expired," just run `nlm login` again. That's normal.

---

## Step 5 — Load Jeff's videos into a notebook

This creates your own copy of Jeff's content (you can't use someone else's). In the terminal, go into
the folder from Step 2 first:

```bash
cd ~/Desktop/jeffnippard-coach      # adjust if you put it elsewhere
```

Then run these three commands (copy-paste each block):

```bash
# a) grab the list of Jeff's videos
python3 scripts/load_channel.py scrape \
  --channel "https://www.youtube.com/@JeffNippard" \
  --output /tmp/jeff-videos.json

# b) create the notebook — it prints a long id, COPY IT
notebooklm create "Jeff Nippard - Training Coach"

# c) load the videos (paste the id from step b where it says <notebook-id>)
uv run --with "notebooklm-py[browser]" python3 scripts/load_channel.py load \
  --videos /tmp/jeff-videos.json \
  --notebook <notebook-id> \
  --count 300 --concurrency 1
```

> Free NotebookLM only holds **50** videos per notebook; **Plus/Pro holds 300**. On a free account,
> change `--count 300` to `--count 50`. Loading takes a while — let it finish.

---

## Step 6 — Tell the coach which notebook is yours

Paste the id you copied into a small settings file:

```bash
cp .notebooklm-id.example .notebooklm-id
```

Now open `.notebooklm-id` in any text editor and replace the first line with **just your notebook id**
(the long code from Step 5b). Save it.

✅ Test that citations are real:
```bash
python3 scripts/ask_cited.py "How much training volume does Jeff recommend per muscle per week?"
```
You should see an answer followed by **real Jeff video titles and exact quotes**. 🎉

---

## Step 7 — Start coaching

1. Open the `jeffnippard-coach` folder in **Claude Code**:
   - In a terminal inside the folder, type `claude` and press Enter, **or** in the Claude Code app
     use *Open Folder* and pick `jeffnippard-coach`.
2. The first time it may ask to **approve a hook** (`onboard.sh`). Say yes — it just greets new users.
3. Type:
   ```
   interview me to get jacked
   ```
4. Answer its questions one at a time. Every recommendation it gives will have a 📎 source from a real
   Jeff video. When you're done, it writes you a program.

That's it. If you ever get stuck, see [LIMITATIONS.md](LIMITATIONS.md) (the "what can break" list) or
the detailed [SETUP.md](SETUP.md).

---

## Quick troubleshooting

| Problem | Fix |
|--------|-----|
| "authentication expired" | Run `nlm login` again (the ~20-min thing). |
| `python3` / `nlm` "not found" | Close the terminal, open a new one, try again. |
| Videos show as red/empty rows in NotebookLM | You loaded more than your tier allows, or too fast — use `--count 50` (free) and `--concurrency 1`. |
| Coach says "the notebook doesn't cover this" | That's on purpose — it won't make up a source Jeff never said. |
| Want a different expert (not Jeff)? | Repeat Step 5 with another channel, put that id in `.notebooklm-id`, and copy `CLAUDE.md.template` to `CLAUDE.md`. |
