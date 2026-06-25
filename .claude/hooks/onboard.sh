#!/usr/bin/env bash
# Auto-onboarding for the notebooklm-coach (Claude Code SessionStart hook).
# A fresh clone has no workout data yet (data/ is gitignored). When the Strong export is
# missing we treat it as a NEW USER and tell Claude to start the cited interview immediately.
# Returning users (data already loaded) are never interrupted.
#
# Using a different expert/domain? Change DATA_FILE to whatever marks an onboarded user.

DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
DATA_FILE="data/strong_workouts.csv"

if [ ! -f "$DIR/$DATA_FILE" ]; then
  echo "NEW USER — no training data is loaded yet ($DATA_FILE is missing). On your VERY FIRST reply, act as this person's Jeff Nippard training coach (see CLAUDE.md): greet them in a sentence, then immediately invoke the 'coach-interview' skill to onboard them. Help them load their Strong workout export, then run the cited, ONE-question-at-a-time interview and build their protocol. Every claim must be cited via scripts/ask_cited.py — never from memory. Do not wait to be asked."
fi
