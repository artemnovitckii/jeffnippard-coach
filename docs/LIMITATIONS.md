# Limitations & gotchas

Read this before you rely on the coach for anything important. Most of these are inherent to driving
NotebookLM from outside — they're not bugs you can fix, just things to plan around.

## Authentication

- **Two separate logins.** `nlm` (read/query) and `notebooklm` (write/load) are different projects
  with independent sessions. Both must use the **same Google account**.
- **`nlm` sessions are short (~20 min).** Mid-interview you'll eventually hit
  `Authentication expired`. Fix: run `nlm login` again. The coach is told to surface this rather
  than guess. The `notebooklm` write session lasts weeks.
- **Interactive auth only.** Both logins use a browser. Headless/cron/CI runs that can't open a
  browser will fail to authenticate.

## NotebookLM account & ingestion

- **Source cap by tier:** free = **50 sources/notebook**, Plus/Pro = **300**. A large channel needs
  Plus/Pro. Load newest-first and accept the cap; the coach can only cite what's loaded.
- **Loading can produce "red rows."** High concurrency makes some video adds fail (their title shows
  as a raw URL). Use `--concurrency 1`, then delete and re-add any reds. (See SETUP step 3.)
- **Unofficial tooling.** `nlm` / `notebooklm-py` automate NotebookLM's private endpoints/UI. If
  Google changes things, they can break until the upstream projects catch up.

## Citations & coverage

- **Citations are only as good as the notebook.** If your expert never covered a topic, the coach
  **will not** cite it — it says "the notebook doesn't cover this directly" and drops the claim.
  Example: the Jeff (training) notebook has little on VO2-max / the interference effect (that's
  Huberman territory), so the coach won't fake a source for it.
- **No-fabrication means visible gaps.** This is the core design choice: the coach refuses uncited
  claims, so you'll sometimes get "I can't source that" instead of a confident answer. That's
  correct behavior, not a failure.
- **Transcript quality varies.** YouTube auto-captions can be garbled, so a verbatim `cited_text`
  quote may contain ASR errors (mis-heard words). The **source title is reliable**; treat the quote
  as "roughly what was said in this video," and click through to verify exact wording if it matters.
- **Latency.** Each live query is ~20–30s. The coach pre-fetches the core topics once to stay fast,
  but off-topic questions, "show me the proof," and the final build still pause while it queries.
- **Single notebook per setup.** This template wires one notebook id. You can run a multi-expert
  setup (the original Jeff example pairs a training notebook with a Huberman health notebook), but
  that's manual configuration, not built in here.

## Claude Code specifics

- **Auto-run is Claude-Code-only.** The `SessionStart` hook + project skills are Claude Code
  features. In other agents the `coach-interview` skill still works when invoked manually, but it
  won't auto-start.
- **Hook approval.** Claude Code may prompt before running `.claude/hooks/onboard.sh`. Review it
  (it only echoes a one-line instruction when `data/` is empty) and approve.
- **Fresh-clone detection** keys off a data file being absent. If your domain doesn't use the same
  data path, edit `onboard.sh` to check for whatever marks an un-onboarded user.

## Privacy

- **Your data and protocol are gitignored** (`data/`, `private/`, `analysis/`). Never commit them —
  the coach is personalized to you. Only the template, skill, scripts, and docs are meant to be
  public.
