# Progress report

Back to `kit:SKILL.md`.

The kit shows the progress to the user in 2 forms:
1. **The full report.** A table with one row for each phase: the steps (checked / all, with a percent), the waves (done / all), the review, and the status. Then the board of the current phase.
2. **The step board.** Only the board of one phase, with 3 columns: ToDo, InProgress, and Completed. The kit shows it each time a step is completed.

The script `<refactor folder>/scripts/progress.sh` makes both forms from the plan. It changes no file. Do not write a report or a board by hand.

## Calculation
- The percent of a phase in the table: checked steps / all steps of the phase.
- The percent of the board: the steps in the column Completed / all steps of the phase.
- A wave is done when all of its steps are checked. Sequential mode has no waves. The column shows "-".
- The current phase: the first phase that is not done. A phase is done when all of its steps are checked and its review is done or skipped.
- The first wave of a phase: the wave that starts when no step of the phase is checked. Check this in the plan. Do not use the text of a request. A later wave can be the lowest open wave, but it is not the first wave.
- The column InProgress: the steps in the argument `--active`. In parallel mode, the script also adds each open step that has a worktree.
- The column Completed: the checked steps, and the steps in the argument `--done`. A step of `--done` has the mark "(merging)".

## When a step is completed
- **Parallel mode:** when the refactorer of the step replies DONE. The step is not merged yet. Give it in `--done`, with each other step of the same wave that replied DONE.
- **Sequential mode:** when the commit of the step is made. The plan then has the step checked.

## When to show what

| Event | Show | Push notification |
|---|---|---|
| A step is completed (both modes) | the step board | the board in one line |
| Parallel mode: a phase changes its state. There are 3 changes. The first wave of the phase starts. The last step of the phase merges. The review of the phase ends. | the full report | the phase in one line |
| Sequential mode: after each N-th next action, and each time a phase changes its state. N is the field "Progress report" of the project-conventions skill (default: 2). | the full report | the phase in one line |

Count the next actions with the "Progress" table of the plan, not with the context of the session. Example: in sequential mode with N = 2, show the full report when the number of checked steps of the current phase is even.

## How to show it
- **The step board:** run `progress.sh --board --step <ID> --done <IDs>`. In sequential mode, omit `--done`. Show the output without changes. Then send the push notification with the output of `progress.sh --line --step <ID> --done <IDs>`. Example: `P4.12 done · Phase 4: 86 % (13/15) · in progress 2 · to do 0`.
- **The full report:** run `progress.sh`. Add `--active <step IDs>` for the steps that an agent does now. Show the output without changes. Then send the push notification with the output of `progress.sh --line`. Example: `Phase 4: 27 % (3/11 steps, wave 1/3)`.
- A push notification is one line of 200 characters or fewer. It cannot hold a table. Send it only if the PushNotification tool is available.

## Who shows it
- **Coordination "session" and sequential mode:** the kit session.
- **Coordination "relay agent":** the kit session, also in relay mode. The script only reads the plan, so this is not the work of the coordinator.
  - The step board: when you receive a DONE reply of a refactorer. Show the board before you send the reply to the coordinator.
  - The full report: after `ACTION DONE`, and after a `REQUEST AGENT` that starts the first wave of a phase (use `--active` with the step IDs of the request).

## The argument "status"
The argument "status" of `kit:SKILL.md` also shows the full report. It does not send a push notification.
