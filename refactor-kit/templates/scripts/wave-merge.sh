#!/usr/bin/env bash
# Merges the steps of a wave into the integration branch.
#
# Usage: {{REFACTOR_FOLDER}}scripts/wave-merge.sh [--careful] P2.1 P2.2 P2.3
# The variable COMMIT_TRAILERS adds trailers to each commit (see commit_message in common.sh).
#
# Fast mode (the default) runs the tests one time for the whole wave:
#   1. For each step, in the order that you give: commit the changes of the step
#      in its worktree, check that the step changed only the files that it owns,
#      merge the branch of the step, and mark the step as done in the plan.
#   2. Run the tests one time on the integration branch.
#   3. If the tests fail, undo all merges of this run and continue in careful mode.
# Careful mode (--careful, or after a fast run fails) tests each step:
#   a. Runs the tests in the worktree of the step. Then commits the changes of the step.
#   b. Checks that the step changed only the files that it owns.
#   c. Merges the branch of the step into the integration branch.
#   d. Runs the tests on the integration branch. If they fail, undoes the merge.
#   e. Marks the step as done in the plan and commits the plan.
# Each step is one commit on its branch and one merge, in both modes.
# The steps of one wave are independent (no shared file, no dependency), so one test run is enough.
# If a check fails, the script skips the step and continues with the next step.
# The skipped steps stay in their worktrees. You can examine them, then run wave-clean.sh.

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

careful="no"
if [ "${1:-}" = "--careful" ]; then careful="yes"; shift; fi
if [ $# -lt 1 ]; then die "Give one or more step IDs. Example: wave-merge.sh P2.1 P2.2"; fi

cd "$PROJECT_ROOT" || exit 1

if [ "$(git branch --show-current)" != "$INTEGRATION_BRANCH" ]; then
  die "Switch to the branch $INTEGRATION_BRANCH first."
fi
if [ -n "$(git status --porcelain)" ]; then
  die "The project has uncommitted changes. Commit them first."
fi

mkdir -p "$LOG_DIR"
merged=()
skipped=()

# Records a skipped step and its reason.
skip_step() {
  skipped+=("$1: $2")
  echo "  SKIPPED $1: $2"
}

# Commits the changes of a step in its worktree.
# With "test" as the second argument, it runs the tests in the worktree first.
# Returns 1 and records the step as skipped if a check fails.
commit_step() {
  local step="$1" mode="$2" path log
  path="$(worktree_path "$step")"
  log="$LOG_DIR/$step.log"
  if [ ! -d "$path" ]; then skip_step "$step" "no worktree at $path"; return 1; fi
  # Some test commands see only the files that git tracks (example: nix flake check).
  # Thus, record each new file as intent-to-add before the tests. This stages no content.
  git -C "$path" add --intent-to-add --all
  if [ "$mode" = "test" ] && ! (cd "$path" && bash -c "$TEST_CMD") > "$log" 2>&1; then
    skip_step "$step" "tests fail in the worktree. Log: $log"
    return 1
  fi
  if [ -n "$(git -C "$path" status --porcelain)" ]; then
    git -C "$path" add -A
    git -C "$path" commit --quiet -m "$(commit_message "Refactor: $step $(step_title "$step")")"
  fi
}

# Checks the ownership of each changed file, then merges the branch of the step.
# Returns 1 and records the step as skipped if a check fails.
merge_step() {
  local step="$1" branch base changed_files not_owned="" file log
  branch="$(branch_name "$step")"
  log="$LOG_DIR/$step.log"
  base="$(git merge-base "$INTEGRATION_BRANCH" "$branch")"
  changed_files="$(git diff --name-only "$base" "$branch")"
  if [ -z "$changed_files" ]; then skip_step "$step" "the step changed no files"; return 1; fi
  while read -r file; do
    if ! step_owns_file "$step" "$file"; then not_owned="$not_owned $file"; fi
  done <<< "$changed_files"
  if [ -n "$not_owned" ]; then
    skip_step "$step" "it changed files that it does not own:$not_owned"
    return 1
  fi
  if ! git merge --quiet --no-ff -m "$(commit_message "Merge $step: $(step_title "$step")")" "$branch" >> "$log" 2>&1; then
    git merge --abort
    skip_step "$step" "merge conflict. Run the step again on the new integration branch."
    return 1
  fi
}

# Marks the step as done in the plan and commits the plan.
mark_step() {
  sed -i "s/^- \[ \] $(step_regex "$1") /- [x] $1 /" "$PLAN_FILE"
  git commit --quiet -am "$(commit_message "Plan: mark $1 as done")"
  merged+=("$1")
  echo "  MERGED"
}

# Careful mode: tests each step in its worktree and after its merge.
careful_merge() {
  local step
  for step in "$@"; do
    echo "Step $step"
    commit_step "$step" test || continue
    merge_step "$step" || continue
    if ! bash -c "$TEST_CMD" >> "$LOG_DIR/$step.log" 2>&1; then
      # ORIG_HEAD is the commit before the merge. This removes only the merge of this step.
      git reset --quiet --hard ORIG_HEAD
      skip_step "$step" "tests fail after the merge. Log: $LOG_DIR/$step.log"
      continue
    fi
    mark_step "$step"
  done
}

# Fast mode: merges all steps, then tests one time.
# Returns 1 if the tests fail. Then the integration branch is as before the run.
fast_merge() {
  local step start
  start="$(git rev-parse HEAD)"
  for step in "$@"; do
    echo "Step $step"
    commit_step "$step" no-test || continue
    merge_step "$step" || continue
    mark_step "$step"
  done
  if [ ${#merged[@]} -eq 0 ]; then return 0; fi
  echo "Testing the wave: ${merged[*]}"
  if bash -c "$TEST_CMD" > "$LOG_DIR/wave.log" 2>&1; then return 0; fi
  echo "  The tests of the wave fail (log: $LOG_DIR/wave.log). Undo the merges and test each step."
  git reset --quiet --hard "$start"
  merged=()
  skipped=()
  return 1
}

if [ "$careful" = "yes" ] || ! fast_merge "$@"; then
  careful_merge "$@"
fi

echo
echo "Merged: ${merged[*]:-none}"
if [ ${#skipped[@]} -gt 0 ]; then
  echo "Skipped:"
  for line in "${skipped[@]}"; do echo "  $line"; done
  exit 1
fi
