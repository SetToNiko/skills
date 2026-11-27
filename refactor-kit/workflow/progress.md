# Progress report

Back to `kit:SKILL.md`.

The progress report tells the user how far the refactor is. It has 2 parts:
1. A table with one row for each phase: the steps (checked / all, with a percent), the waves (done / all), the review, and the status.
2. A board for the current phase, with 3 columns: ToDo, InProgress, and Completed.

The script `<refactor folder>/scripts/progress.sh` makes the report from the plan. It changes no file. Do not write the report by hand.

## Calculation
- The percent of a phase: checked steps / all steps of the phase.
- A wave is done when all of its steps are checked. Sequential mode has no waves. The column shows "-".
- The current phase: the first phase that is not done. A phase is done when all of its steps are checked and its review is done or skipped.
- The first wave of a phase: the wave that starts when no step of the phase is checked. Check this in the plan. Do not use the text of a request. A later wave can be the lowest open wave, but it is not the first wave.
- The column InProgress: the steps in the argument `--active`. In parallel mode, the script also adds each open step that has a worktree.

## When to show the report

| Execution mode | Show the report |
|---|---|
| parallel waves | Each time a phase changes its state. There are 3 changes. The first wave of the phase starts. The last step of the phase merges. The review of the phase ends. |
| sequential | After each N-th next action. N is the field "Progress report" of the project-conventions skill (default: 2). Also each time a phase changes its state. |

Count the next actions with the "Progress" table of the plan, not with the context of the session. Example: in sequential mode with N = 2, show the report when the number of checked steps of the current phase is even.

## How to show the report
1. Run `<refactor folder>/scripts/progress.sh`. Add `--active <step IDs>` for the steps that an agent does now.
2. Show the output to the user without changes.
3. If the PushNotification tool is available, send one push notification. Use the output of `progress.sh --line`. Example: `Phase 4: 27 % (3/11 steps, wave 1/3)`.

## Who shows the report
- **Coordination "session" and sequential mode:** the kit session.
- **Coordination "relay agent":** the kit session, also in relay mode. The script only reads the plan, so this is not the work of the coordinator. Run it after `ACTION DONE`, and after a `REQUEST AGENT` that starts the first wave of a phase (use `--active` with the step IDs of the request).

## The argument "status"
The argument "status" of `kit:SKILL.md` also shows the report. It does not send a push notification.
