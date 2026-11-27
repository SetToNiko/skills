---
name: refactor-kit
description: Guides a refactor of the current project together with the user, one action at a time. Interviews the user to define the goal, principles, and conventions of this project. Writes all refactor files and agents into the project. Then runs the plan, the safety-net tests, the refactor steps, the reviews, and the documentation. Use when the user types /refactor-kit, or asks to start, plan, continue, or check the status of a refactor with this kit.
argument-hint: "[status | setup | plan | tests | next | review | revise | docs | final | goal | library]"
---
# Refactor Kit

You guide the user through an incremental refactor of the project in the current working directory. You do the work. The user makes the decisions.

**Paths.** A kit path starts with `kit:` and is relative to the folder of this skill. Example: `kit:workflow/00-setup.md`. All other paths are relative to the project root.

## Rules for each session
- Do one action in each session. The project files keep the state, so a new session can continue the work. Exception: in the coordination mode "relay agent", one session can do several actions, because a fresh `coordinator` agent does each action (`kit:workflow/parallel.md`, section C).
- Talk with the user about one topic at a time. Before you ask a question, look for the answer in the project. Then propose that answer as a draft.
- Use the AskUserQuestion tool for choices. Put the recommended option first. Use plain text for open questions.
- Write or change a project file only after the user approves its content.
- Never overwrite a file that you did not write in this kit. If a file exists, show it and ask.
- Commit only if the "Commits" field in the project-conventions skill permits it.
- **Atomic changes (global rule).** Each commit of this kit is atomic: one `git revert` of it undoes it completely and leaves a working project (the tests pass). This is the real limit of a step. A file count is only a guideline. Never commit half-done work, and never put two unrelated changes in one commit.
- **Change groups.** If one change cannot be atomic in one commit, mark its first and its last commit. Each commit of the group gets the git trailer `Change-Group: <name> (<n>/<total>)`, with ", first" on the first commit and ", last" on the last commit. Only the last commit must leave a working project. To undo the whole group: `git revert --no-commit <first>^..<last>` and one commit, or `git reset --hard <first>^` on a branch that nobody else uses. Find a group with `git log --grep "Change-Group: <name>"`. Use a group only when one commit is not possible. Tell the user why.
- Keep your messages short. Show drafts as short Markdown blocks, not as long explanations.
- **Writing (a MUST):** write all text of the kit with the `asd-ste100` skill. See "Writing rule" below.

## Writing rule
The kit MUST use the `asd-ste100` skill for each text that it writes, of any kind. Load the skill at the start of each action, before you write the first sentence.
- **What:** all text, of each kind:
  - each project file: GOAL.md, PRINCIPLES.md, SUCCESS_CRITERIA.md, PLAN.md, BEFORE_AFTER.md, CONTRIBUTING.md, ARCHITECTURE.md, README.md, the user guide, the agent files, and the project-conventions skill
  - code comments, doc comments, commit messages, and error and status texts
  - the instructions to agents, the replies of agents, and the messages to the user
- **Strict mode:** text that an agent, a script, or a procedure reads. Examples: the agent files, the instructions to agents and their replies, the plan, the conventions, CONTRIBUTING.md, error texts, and code comments.
- **Flavored mode:** text for people: README.md, ARCHITECTURE.md, the user guide, BEFORE_AFTER.md, commit messages, the messages to the user.
- **Check:** run the linter of the skill (`scripts/ste-lint.py`) on each file that you write. Fix each hard finding. Keep each fact, name, path, and number when you change a sentence. Text in backticks and code do not change.
- **Agents:** each agent of the kit preloads the skill (`skills:` in its frontmatter). An instruction to an agent also says which mode to use.
- **No skill:** if the `asd-ste100` skill is not available, stop and tell the user. Do not write text without it.

## 1. Find the state

The project root is the git root of the current working directory. If the user names another project path, use that path. Then tell the user that the project agents load only in a session that starts in the project root.

Read `.claude/skills/project-conventions/SKILL.md`. Its field "Refactor folder" gives `<refactor folder>`. If the file does not exist, use `docs/refactor/` and go to the setup.

Select the FIRST row that matches:

| # | State | Action | Instructions |
|---|---|---|---|
| 1 | The project-conventions skill, `<refactor folder>/GOAL.md`, or `<refactor folder>/PRINCIPLES.md` does not exist | setup | `kit:workflow/00-setup.md` |
| 2 | `<refactor folder>/PLAN.md` does not exist | plan | `kit:workflow/01-plan.md` |
| 3 | The plan has unchecked Phase 0 steps | tests | `kit:workflow/02-safety-net.md` |
| 4 | A phase has all steps checked, and the "Progress" table shows no review for it | review | `kit:workflow/03-refactor-loop.md`, part C |
| 5 | Section "Architecture notes (pending)" of the plan has notes | revise | `kit:workflow/03-refactor-loop.md`, part D |
| 6 | The plan has unchecked steps | next | `kit:workflow/03-refactor-loop.md`, parts A and B |
| 7 | The "Progress" table shows that the documentation is open | docs | `kit:workflow/04-documentation.md` |
| 8 | The "Progress" table shows that the final review is open | final | `kit:workflow/05-final-review.md` |
| 9 | All rows of the "Progress" table show done or skipped | status | Report the outcome. Ask if the user wants a new refactor goal. |

If the user gives an argument, do that action. First check that the state permits it. Example: "next" needs a plan. If the state does not permit it, tell the user which action must come first.

**Execution mode.** The project-conventions skill gives the Execution mode setting. In the mode "parallel waves", the action next runs one wave of steps, not one step. Each instructions file says which section of `kit:workflow/parallel.md` to use.

The argument "status" only reports. It changes nothing. It shows the progress report (`kit:workflow/progress.md`).

The argument "goal" changes the goal during the refactor, for example to remove features from the project. It does not depend on the state. Instructions: `kit:workflow/06-goal-change.md`. If the user asks to change the goal or the scope without the argument, also use this action.

The argument "library" shows the saved goal packs. It does not depend on the state. Instructions: `kit:workflow/library.md`, section "The action library".

## 2. Before the action
Tell the user, in 3 lines or fewer:
- the state that you found
- the action that you will do
- what the action changes

If the user named the action (an argument, or a request such as "run the plan action"), do not ask again. Otherwise, ask the user to continue. Read the instructions file of the action only after the user agrees.

## 3. After the action
1. Update the "Progress" table in the plan, if the action changed the progress.
2. Commit, if the "Commits" field permits it.
3. Show the progress report, if `kit:workflow/progress.md`, section "When to show the report", selects this action.
4. Tell the user the next action. Recommend `/clear` and then `/refactor-kit`. Reason: each action works best with a small, clean context. In the coordination mode "relay agent", start the next action in this session instead (`kit:workflow/parallel.md`, section C). The field "Auto-continue" selects if you ask first.
