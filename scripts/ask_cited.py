#!/usr/bin/env python3
"""Ask the Jeff Nippard NotebookLM notebook a question and print the answer with REAL citations.

Every [N] marker in the answer is resolved to the actual source title and the verbatim passage
NotebookLM quoted. This is the heart of notebooklm-coach: nothing it prints is from the model's
memory — titles and quotes come straight from the notebook, so the coach can cite for real.

Ships pointed at the Jeff Nippard - Training Coach notebook. To use a DIFFERENT expert, override the
notebook id (no code change needed). Resolution order:
  1. --notebook <id>
  2. $NOTEBOOKLM_ID
  3. a `.notebooklm-id` file in the repo root (first line)
  4. the built-in Jeff Nippard default below
Find any notebook's id with `nlm notebook list`. See docs/SETUP.md.

Usage:
    python3 scripts/ask_cited.py "How many sets per muscle per week does Jeff recommend?"
    python3 scripts/ask_cited.py --json "..."          # machine-readable (for caching)
    python3 scripts/ask_cited.py --notebook <id> "..."
"""
import json
import os
import subprocess
import sys
from pathlib import Path

# Default: "Jeff Nippard - Training Coach". Swap via --notebook / $NOTEBOOKLM_ID / .notebooklm-id
# to point the coach at your own expert's notebook.
DEFAULT_NOTEBOOK = "c1b879f0-efe1-4e6c-a150-d612a13abcc2"


def resolve_notebook(cli_arg):
    if cli_arg:
        return cli_arg
    if os.environ.get("NOTEBOOKLM_ID"):
        return os.environ["NOTEBOOKLM_ID"]
    for d in [Path.cwd(), *Path.cwd().parents]:
        f = d / ".notebooklm-id"
        if f.exists():
            lines = [ln.strip() for ln in f.read_text().splitlines()
                     if ln.strip() and not ln.strip().startswith("#")]
            if lines:
                return lines[0]
    return DEFAULT_NOTEBOOK


def run(cmd):
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.returncode != 0 or not p.stdout.strip():
        sys.exit(f"command failed: {' '.join(cmd)}\n{p.stderr or p.stdout}\n"
                 "If this says auth expired, run `nlm login`.")
    return p.stdout


def main():
    args = sys.argv[1:]
    as_json = False
    notebook_arg = None
    if "--json" in args:
        as_json = True
        args.remove("--json")
    if "--notebook" in args:
        i = args.index("--notebook")
        notebook_arg = args[i + 1]
        del args[i:i + 2]
    if not args:
        sys.exit(__doc__)
    notebook = resolve_notebook(notebook_arg)
    question = " ".join(args)

    d = json.loads(run(["nlm", "notebook", "query", notebook, question, "--json"]))
    if d.get("status") == "error" or "answer" not in d:
        sys.exit(d.get("error", "query failed — try `nlm login`"))

    titles = {s["id"]: s.get("title", "?") for s in json.loads(
        run(["nlm", "source", "list", notebook, "--json"]))}

    refs = {r["citation_number"]: r for r in d.get("references", [])}
    used = sorted(refs) or sorted(int(n) for n in d.get("citations", {}))
    sources = []
    for n in used:
        r = refs.get(n, {})
        sid = r.get("source_id") or d.get("citations", {}).get(str(n), "")
        sources.append({
            "n": n,
            "title": titles.get(sid, "UNKNOWN SOURCE — do not cite"),
            "cited_text": (r.get("cited_text") or "").strip(),
        })

    if as_json:
        print(json.dumps({"answer": d["answer"], "sources": sources}, indent=2))
        return

    print(d["answer"])
    print("\n" + "=" * 70 + "\nREAL SOURCES (verbatim from the notebook):\n")
    for s in sources:
        print(f'[{s["n"]}] 📎 {s["title"]}')
        if s["cited_text"]:
            q = s["cited_text"]
            print(f'      "{q[:240]}{"…" if len(q) > 240 else ""}"')
        print()


if __name__ == "__main__":
    main()
