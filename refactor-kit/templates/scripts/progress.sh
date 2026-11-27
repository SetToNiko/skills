#!/usr/bin/env bash
# Prints the progress report of the refactor as Markdown. It reads the plan and changes no file.
#
# Usage: {{REFACTOR_FOLDER}}scripts/progress.sh [--active IDs] [--done IDs] [--step ID] [--board] [--line]
#   --active  The steps that an agent does now. They go into the column InProgress.
#             In parallel mode, the script also adds each open step that has a worktree.
#   --line    Print only one line for a push notification. Example:
#             Phase 4: 27 % (3/11 steps, wave 1/3)
#   --done    The steps whose agent replied DONE, but that are not merged yet.
#             They go into the column Completed, with the mark "(merging)".
#   --step    The step that is now completed. The board is for its phase.
#             With --line, the line is the board in one line. Example:
#             P4.12 done · Phase 4: 86 % (13/15) · in progress 2 · to do 0
#   --board   Print only the board, not the table of all phases.
#
# The report has two parts:
#   1. A table with one row for each phase: steps, waves, review, and status.
#   2. A board for the current phase (the first phase that is not done):
#      the columns ToDo, InProgress, and Completed.
# The percent of a phase in the table is: checked steps / all steps of the phase.
# The percent of the board also counts the steps of --done.
# A wave is done when all of its steps are checked.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
PLAN_FILE="{{REFACTOR_FOLDER}}PLAN.md"
WORKTREE_ROOT=""
# In parallel mode, config.sh gives PLAN_FILE and WORKTREE_ROOT.
if [ -f "$SCRIPT_DIR/config.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/config.sh"
fi

active=""
done_ids=""
step=""
board_only=0
line_only=0
while [ $# -gt 0 ]; do
  case "$1" in
    --active)
      if [ $# -lt 2 ]; then echo "ERROR: --active needs step IDs. Example: --active P4.1,P4.2" >&2; exit 1; fi
      active="$2"
      shift 2
      ;;
    --done)
      if [ $# -lt 2 ]; then echo "ERROR: --done needs step IDs. Example: --done P4.12" >&2; exit 1; fi
      done_ids="$2"
      shift 2
      ;;
    --step)
      if [ $# -lt 2 ]; then echo "ERROR: --step needs one step ID. Example: --step P4.12" >&2; exit 1; fi
      step="$2"
      shift 2
      ;;
    --board) board_only=1; shift ;;
    --line) line_only=1; shift ;;
    *) echo "ERROR: unknown argument: $1. Use --active, --done, --step, --board, or --line." >&2; exit 1 ;;
  esac
done

plan="$PROJECT_ROOT/$PLAN_FILE"
if [ ! -f "$plan" ]; then echo "ERROR: the plan $plan does not exist. Check PLAN_FILE." >&2; exit 1; fi

# Add each step that has a worktree folder (parallel mode).
if [ -n "$WORKTREE_ROOT" ]; then
  case "$WORKTREE_ROOT" in /*) ;; *) WORKTREE_ROOT="$PROJECT_ROOT/$WORKTREE_ROOT" ;; esac
  if [ -d "$WORKTREE_ROOT" ]; then
    for dir in "$WORKTREE_ROOT"/P*; do
      if [ -d "$dir" ]; then active="$active,$(basename "$dir")"; fi
    done
  fi
fi

awk -v active="$active" -v done_ids="$done_ids" -v step="$step" -v board_only="$board_only" -v line_only="$line_only" '
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
# Cuts a long title. If the cut leaves an open code span, close it.
function short(s,   t) {
  if (length(s) <= 40) return s
  s = substr(s, 1, 37); t = s
  if (gsub(/`/, "", t) % 2 == 1) s = s "`"
  return s "..."
}
BEGIN {
  n = split(active, list, ",")
  for (i = 1; i <= n; i++) if (list[i] != "") is_active[list[i]] = 1
  n = split(done_ids, list, ",")
  for (i = 1; i <= n; i++) if (list[i] != "") is_done[list[i]] = 1
  phases = 0
}
# Section 6 holds the phases and the steps.
/^## 6\./ { in_plan = 1; next }
/^## [0-9]+\./ { in_plan = 0 }
in_plan && /^### Phase [0-9]+:/ {
  phases++
  num[phases] = $3; sub(/:$/, "", num[phases])
  name[phases] = $0; sub(/^### Phase [0-9]+: */, "", name[phases])
  next
}
in_plan && /^- \[[ x]\] P[0-9]+\.[0-9]+ / && phases > 0 {
  p = phases
  done = ($0 ~ /^- \[x\]/)
  match($0, /P[0-9]+\.[0-9]+/); id = substr($0, RSTART, RLENGTH)
  title = $0; sub(/^- \[[ x]\] [^ ]+ /, "", title); sub(/[:|].*/, "", title)
  wave = ""
  if (match($0, /\| *Wave: *[0-9]+/)) { wave = substr($0, RSTART, RLENGTH); gsub(/[^0-9]/, "", wave) }
  steps[p]++
  if (done) checked[p]++
  key = p SUBSEP steps[p]
  sid[key] = id; stitle[key] = trim(title); sdone[key] = done
  if (wave != "") {
    if (!((p, wave) in wave_steps)) { waves[p]++ }
    wave_steps[p, wave]++
    if (done) wave_checked[p, wave]++
  }
  next
}
# Section 11: the rows "| Phase N review | status |".
/^\| Phase [0-9]+ review *\|/ {
  split($0, cell, "|"); r = trim(cell[2]); sub(/^Phase /, "", r); sub(/ .*/, "", r)
  review[r] = trim(cell[3])
}
END {
  current = 0
  for (p = 1; p <= phases; p++) {
    c = checked[p] + 0; s = steps[p] + 0
    wd = 0
    for (k in wave_steps) {
      split(k, part, SUBSEP)
      if (part[1] == p && (wave_checked[k] + 0) == wave_steps[k]) wd++
    }
    wdone[p] = wd
    started = (c > 0)
    for (i = 1; i <= s; i++) if (is_active[sid[p, i]]) started = 1
    rv = (num[p] in review) ? review[num[p]] : "-"
    rev[p] = rv
    if (c == s && (rv == "-" || rv == "done" || rv == "skipped")) st = "done"
    else if (started || c == s) st = "in progress"
    else st = "open"
    status[p] = st
    pct[p] = (s > 0) ? int(c * 100 / s) : 100
    if (current == 0 && st != "done") current = p
  }
  # The board phase: the phase of --step, or else the current phase.
  bp = current
  if (step != "") {
    for (p = 1; p <= phases; p++) for (i = 1; i <= steps[p]; i++) if (sid[p, i] == step) bp = p
  }
  # Fill the 3 columns of the board. A step of --done counts as completed.
  nt = 0; ni = 0; nc = 0
  for (i = 1; i <= steps[bp]; i++) {
    item = sid[bp, i] " " short(stitle[bp, i])
    if (sdone[bp, i]) col_c[++nc] = item
    else if (is_done[sid[bp, i]]) col_c[++nc] = item " (merging)"
    else if (is_active[sid[bp, i]]) col_i[++ni] = item
    else col_t[++nt] = item
  }
  bpct = (steps[bp] > 0) ? int(nc * 100 / steps[bp]) : 100
  if (line_only && step != "") {
    printf "%s done · Phase %s: %d %% (%d/%d) · in progress %d · to do %d\n", step, num[bp], bpct, nc, steps[bp], ni, nt
    exit
  }
  if (line_only) {
    if (current == 0) { print "Refactor: all phases done"; exit }
    p = current
    out = "Phase " num[p] ": " pct[p] " % (" (checked[p] + 0) "/" steps[p] " steps"
    if (waves[p] > 0) out = out ", wave " wdone[p] "/" waves[p]
    if (checked[p] + 0 == steps[p]) out = out ", review " rev[p]
    print out ")"
    exit
  }
  if (!board_only) {
    print "## Refactor progress"
    print ""
    print "| Phase | Steps | Waves | Review | Status |"
    print "|---|---|---|---|---|"
    for (p = 1; p <= phases; p++) {
      w = (waves[p] > 0) ? wdone[p] "/" waves[p] : "-"
      mark = (p == current) ? "**" : ""
      printf "| %s%s %s%s | %d/%d (%d %%) | %s | %s | %s |\n", mark, num[p], name[p], mark, checked[p] + 0, steps[p] + 0, pct[p], w, rev[p], status[p]
    }
    if (bp == 0) { print ""; print "All phases are done."; exit }
    print ""
  }
  if (bp == 0) { print "All phases are done."; exit }
  printf "### Phase %s board (%d %%)\n\n", num[bp], bpct
  rows = nt; if (ni > rows) rows = ni; if (nc > rows) rows = nc
  print "| ToDo | InProgress | Completed |"
  print "|---|---|---|"
  for (r = 1; r <= rows; r++) printf "| %s | %s | %s |\n", col_t[r], col_i[r], col_c[r]
  if (rows == 0) print "| | | |"
}
' "$plan"
