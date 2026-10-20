#!/usr/bin/env bash
# SessionStart hook: print the "Current state" section of the private progress log
# so every session starts oriented. Prints a hint if the notes aren't present.
notes="${PIECEFUL_NOTES:-$CLAUDE_PROJECT_DIR/../pieceful-notes}/planning/progress.md"

if [[ -f "$notes" ]]; then
  echo "Pieceful: current state (from private progress log)"
  awk '/^## Current state/{f=1; next} /^## /{f=0} f' "$notes"
  echo "Tip: run /next to continue."
else
  echo "Pieceful: no private progress log found. Read AGENTS.md and docs/README.md, or run /next."
fi
