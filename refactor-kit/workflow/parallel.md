# Parallel mode

Back to `kit:SKILL.md`.

Use this file only if the "Execution mode" setting of the project-conventions skill is "parallel waves". Each action file points to the section that it needs. Rules: `kit:reference/parallel-rules.md`. Read the rules one time in each session that runs a wave.

In parallel mode, several agents do the steps of one **wave** at the same time. Each agent works in its own git worktree. The wave scripts in `<refactor folder>/scripts/` make the worktrees, check the file ownership, test, and merge.

Start all agents of a wave in ONE message. Agents that start in one message run in parallel.

**Coordination mode.** The project-conventions skill gives the Coordination setting:
- **session:** the kit session is the coordinator. It does sections T, W, R, D, and F itself.
- **relay agent:** a `coordinator` agent does sections T, W, R, D, and F. The kit session is the relay. Use section C.

---

## Section C: Relay coordinator

In this mode, the kit session does not do the work of the coordinator. It starts one fresh `coordinator` agent for each action, and relays the requests of that agent. Thus, the context of the kit session grows only by the requests and the summaries, and the user does not need `/clear` after each action.

**Start an action.**
1. Find the state and the action (`kit:SKILL.md`, sections 1 and 2). Get the approval of the user as usual.
2. Start one `coordinator` agent. Give it:
   - the kit folder (the absolute path)
   - the action, for example "next (wave 15)" or "review (phase 3)"
   - the user decisions that you already have, for example "the user approved the start of this wave"
   - a scratch folder for long output
   - the commit trailers of the session, if the system gives them
   - the writing mode: strict
3. Tell the user that the coordinator runs, in one line.

**Relay the requests.** The coordinator stops at each request. Do the request, then continue the coordinator with SendMessage.
- **`REQUEST AGENT`:** start each agent with the given type and the exact instruction. Start all agents of one block in ONE message. Keep a list of the label and the agent ID of each agent. Send each reply to the coordinator without changes, with its label. If the agents are the refactorers of the first wave of a phase (`kit:workflow/progress.md`, section "Calculation"), also show the progress report with `--active <their step IDs>` (`kit:workflow/progress.md`).
- **`REQUEST CONTINUE`:** send the exact message to the agent of the label. Send the reply to the coordinator without changes. If the label is a step that replied DONE, the step goes back to InProgress on the board (`kit:workflow/progress.md`, "A step that goes back").
- **A DONE reply of a refactorer:** show the step board and send its push notification (`kit:workflow/progress.md`, section "How to show it"). Then send the reply to the coordinator.
- **`REQUEST USER`:** if the PushNotification tool is available, send a push notification first. Name the action and the number of questions, in one line. Then ask the questions with AskUserQuestion. Keep the text and the order of the options. If the block has facts outside the questions, put them, without changes, at the start of the first question. If an option has a `Preview:` line, use the examples of all options in each `preview` field of that question. Put the label of each option above its example. Mark the label of the option of this field with `▶` and the other labels with a space. For an option without a `Preview:` line, show the text `No change`. If the columns fit in 90 characters or fewer, put the examples side by side, with ` │ ` between the columns. Otherwise, put them one below the other. Keep the code of each example without changes. Send the answers to the coordinator without changes.
- **`ACTION DONE`:** show the summary to the user. Then do `kit:SKILL.md`, section 3, but do not recommend `/clear`.

**Rules for the relay.**
- **What the user sees.** Show the user only these items: the step board and the full report, the summary of each `ACTION DONE`, the questions of a `REQUEST USER`, and blockers. Do not tell the user that you sent a request, a reply, or an answer. Relay these in silence.
- Never answer a `REQUEST USER` yourself, also when the answer looks clear. Only the user decides.
- Never change the text of a request, a reply, or an answer. Add only the label.
- Do not do the work of the coordinator: no wave scripts, no checks, no plan changes. Read the project only if the user asks a question.
- If a request does not follow the format of `kit:templates/agents/coordinator.md`, send the coordinator a message: give the problem and ask again.
- **`WAITING`:** do nothing now. Send each reply of the named labels to the coordinator when it comes.
- If the coordinator stops without a request block, without `WAITING`, and without `ACTION DONE`, continue it with "Continue the action. Reply with a request block, `WAITING`, or `ACTION DONE`."
- After `ACTION DONE`, start the next action. If the field "Auto-continue" of the project-conventions skill is "yes", start it at once, without a question, unless a user decision is open. Otherwise, ask the user to start it. Start a NEW coordinator for it. Do not continue the old coordinator: its context holds the old action.
- Recommend `/clear` only when the context of the kit session is large, for example after each phase review.

---

## Section S: Setup (part 5 and part 7)

**Part 1, item 0.** The user selects the execution mode with the first question of the setup. Read this section then.

**Part 5.** If the execution mode is parallel:
1. The Commits setting must not be "never". The coordinator commits each step on its own branch. Tell the user if it is "never". Ask them to select another value or the sequential mode.
2. The maximum number of agents is the answer of part 1, item 0: a number, or dynamic (`MAX_PARALLEL=0`). Do not ask again. Show it in one line. More agents finish a wave sooner, but they use more tokens, and the machine runs more builds at the same time.
3. Check the shared resources of the tests (`kit:reference/parallel-rules.md`, section 5). Use Grep in the test code for fixed ports, fixed temporary paths, and database names. Report what you find. A test that uses a fixed resource gets a Phase 0 step that fixes it, or the wave limit becomes 1 until it is fixed.
4. Add the worktree rules to the project-conventions draft (refer to `kit:templates/project-conventions.md`, section "Parallel mode").

**Part 7, more files.** In parallel mode, also write these files:

| Project file | Source |
|---|---|
| `<refactor folder>/scripts/config.sh` | `kit:templates/scripts/config.sh` |
| `<refactor folder>/scripts/common.sh` | `kit:templates/scripts/common.sh` |
| `<refactor folder>/scripts/wave-start.sh` | `kit:templates/scripts/wave-start.sh` |
| `<refactor folder>/scripts/wave-merge.sh` | `kit:templates/scripts/wave-merge.sh` |
| `<refactor folder>/scripts/wave-clean.sh` | `kit:templates/scripts/wave-clean.sh` |
| `.claude/agents/mapper.md` | `kit:templates/agents/mapper.md` |
| `.claude/agents/test-writer.md` | `kit:templates/agents/test-writer.md` |
| `.claude/agents/coordinator.md` | `kit:templates/agents/coordinator.md` (only in the coordination mode "relay agent") |

Replace the placeholders in the scripts: `{{TEST_CMD}}`, `{{REFACTOR_FOLDER}}`, `{{BRANCH}}`, `{{MAX_PARALLEL}}`. `{{TEST_CMD}}` is the command that runs all gates, for example `nix flake check`. Do not add `git add` to it: `wave-merge.sh` records the new files of a worktree before it runs the tests. Run `chmod +x <refactor folder>/scripts/*.sh`. Include `<refactor folder>/scripts` in the placeholder check of part 7.

---

## Section P: Plan action

**Before the analysis: map the project in parallel.**
1. Find the top-level modules. Read only the build file, the entry points, and the folder structure. If there are more than 6 modules, put the small modules into groups.
2. Start one `mapper` agent for each module or group, all in ONE message. Give each agent the module paths and the goal in 3 lines or fewer.
3. Use the replies of the mappers as the input of the analysis (`kit:workflow/01-plan.md`, section 3). Read a source file only to fill a gap in the replies.

**The plan format.** Each step has these fields in place of `Files:`:
`- [ ] P<phase>.<n> <title>: <what changes> | Wave: <n> | Depends: <step IDs or none> | Owns: <paths, comma-separated> | Target: <criterion or target> | Check: <how to test>`
- Number the waves across all phases: 1, 2, 3, and so on.
- Obey the wave rules (`kit:reference/parallel-rules.md`, section 2).
- Each Phase 0 foundation step is the only step in its wave.
- Fill section 12 "Shared files" of the plan.

**The approval.** Also show a table of the waves: the wave number, the step IDs, and the reason why the steps are independent.

---

## Section T: Tests action

1. Do the foundation steps of Phase 0 first, one at a time, directly on the integration branch, as in the sequential mode. No worktree is necessary, because each foundation step is alone in its wave. Mark each step as done in the plan and commit.
2. For the test steps, use the wave procedure of section W with these changes:
   - Start one `test-writer` agent for each step, in place of the refactorer.
   - Do not start a simplifier.
3. After each wave, add the "incorrect behavior" of the agent replies to section 4 "Findings". Add the "code that I could not test" to section 5 "Test coverage". Commit the plan.

---

## Section W: Next action (one wave)

1. Read the plan. Find the lowest wave number that has unchecked steps. These steps are the wave. If `MAX_PARALLEL` is `0` (dynamic), select the number of agents for this wave (`kit:reference/parallel-rules.md`, section 2, "Dynamic maximum"). Show the wave to the user in 3 lines or fewer, with the number of agents and its reason. Ask to continue.
2. Run `<refactor folder>/scripts/wave-start.sh <step IDs>`. If the script prints an error, show it to the user and stop. Do not change the plan to remove the error without approval.
3. Start one `refactorer` agent for each step, all in ONE message. Give each agent: "Do step <ID> of `<refactor folder>/PLAN.md`. Your worktree: `<path>`. Your scratch folder: `<scratch>/<ID>/`."
4. When a refactorer replies DONE, first check that the reply gives the result of each check for each change (mutants included), or a reason. If a result is missing, send the step back at once. Then show the step board (`kit:workflow/progress.md`). Then start the simplifier for that step at once, if the Simplify setting selects one. Skip the simplifier if the diff only changes visibility, moves code, changes access paths, or adds tests or comments. Give it: "Simplify the uncommitted changes in the worktree `<path>`." Do not wait for the other refactorers.
5. Wait for all agents. Do not merge a step whose refactorer replied BLOCKED or NEEDS. Then do these actions:
   - **NEEDS, for a file outside `Owns`:** if no other open step owns the file, release it to the step. Tell the agent to continue (`kit:reference/parallel-rules.md`, section 3). Otherwise, make a later step.
   - **PARTIAL:** merge the part that is done, if all checks pass. Make a new step for the rest (section 7 of the rules).
   - **An agent that stopped because the session ended:** continue it with SendMessage (section 7 of the rules).
6. Run `<refactor folder>/scripts/wave-merge.sh <the other step IDs, in plan order>`. The script merges all steps and runs the tests one time. If the tests fail, it undoes the merges and tests each step. Use `--careful` to test each step from the start. If the session has commit trailers, give them in the variable `COMMIT_TRAILERS` (one trailer on each line). Each step becomes one commit on its branch and one merge, so each step stays atomic: one revert of its merge commit (`git revert -m 1`) undoes it. The script can skip a step because of a conflict only in import lines, `mod` lines, or a list of tests. Then merge that step by hand (`kit:reference/parallel-rules.md`, section 6). Run all gates after the merge, and decide by the exit code.
7. Update the plan:
   - Add the new findings of the agent replies to section 4.
   - For each NEEDS reply, propose a new step in a later wave. Add it after approval.
   Commit the plan.
8. Run `<refactor folder>/scripts/wave-clean.sh <the merged step IDs>`.
9. Show the user these items, in 12 lines or fewer:
   - the merged steps
   - the skipped and blocked steps, with the reason
   - the concepts introduced, the exceptions added, and the new findings Ask the user to read the diff of each merged step.
10. If the wave finished a phase, mark the row "Phase <N> steps" in section 11 as done. The next action is review. Otherwise, it is next.

**A skipped step.** Run `wave-clean.sh --force <ID>`. Read the reason in the merge summary and use `kit:reference/parallel-rules.md`, section 6. Then do the step again as a wave with one step, in the next session.

---

## Section R: Review action

1. Run `git diff --stat <commit-before-phase>..HEAD`. Put the changed files into 2 to 4 groups by module.
2. Start these `reviewer` agents in ONE message:
   - one for each group, with the scope "module" and the file paths of the group
   - one more, with the scope "architecture"
   Give each agent the diff range.
3. Merge the replies:
   - Remove duplicates. Keep the most specific finding.
   - Sort by the priority of the reviewer checks. Keep 10 findings or fewer.
   - Merge the "Exceptions" lists and the "Architecture notes".
4. Continue with `kit:workflow/03-refactor-loop.md`, part C, from item 3. If the fixes are in different modules, use a wave.

---

## Section D: Docs action

1. Add a phase "Phase D: Doc comments" to the plan. Add one step for each module:
   `- [ ] D.<n> Doc comments for <module>: comments on public interfaces and extension points | Wave: <n> | Depends: none | Owns: <module folder> | Target: docs | Check: tests and docs check pass`
   Use the next free wave numbers. Commit the plan.
2. Run the waves of Phase D with the procedure of section W. Start one `docs` agent for each step with "Mode: comments", the step ID, and the worktree path. Do not start a simplifier.
3. Collect the "Concepts found" of all replies. Then start one `docs` agent with "Mode: guides" in the project root. Give it the list of concepts for the glossary.
4. Continue with `kit:workflow/04-documentation.md`, from item 3.

---

## Section F: Final action

1. Put the changed source files of the branch into 2 or 3 groups by module.
2. Start these `reviewer` agents in ONE message, each with the diff range of the branch:
   - scope "criteria": the success criteria of the plan, section 0
   - scope "architecture": the target architecture, PRINCIPLES.md, and ARCHITECTURE.md
   - scope "module", one agent for each group
3. Merge the replies into the report of `kit:workflow/05-final-review.md`, item 2. Continue with item 3 of that file.
