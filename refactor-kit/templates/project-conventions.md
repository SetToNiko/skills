---
name: project-conventions
description: Gives the stack, commands, refactor settings, coding rules, and documentation style of this project. Load this skill before you write, refactor, review, or document code in this project.
---
<!-- The refactor-kit setup wrote this file. Each agent preloads it. Keep it shorter than approximately 60 lines. -->

## Stack and commands
- Language and framework: {{LANGUAGE}}
- Build: `{{BUILD_CMD}}`
- Test: `{{TEST_CMD}}`
- Lint and format: `{{LINT_CMD}}`
- Test style: {{TEST_STYLE}}
- Naming: {{NAMING}}
- Tools not available yet: {{MISSING_TOOLS: the tools that the scan could not run, or "none". The plan makes them available in Phase 0.}}

## Refactor settings
- Refactor folder: `{{REFACTOR_FOLDER}}`
- Goal: `{{REFACTOR_FOLDER}}GOAL.md`. Principles: `{{REFACTOR_FOLDER}}PRINCIPLES.md`. Plan: `{{REFACTOR_FOLDER}}PLAN.md`.
- Branch: `{{BRANCH}}`
- Commits: {{COMMITS: "after each approved action" OR "ask before each commit" OR "never"}}
- Simplify step: {{SIMPLIFIER: "simplifier agent" OR "code-simplifier plugin" OR "none"}}
- Auto-approve: {{AUTO_APPROVE: the decisions that the coordinator makes without a question. Default: 2 decisions. "A file release to a step when no other open step owns the file." "A test for a MISSED mutant." Or "none".}}
- Auto-continue: {{AUTO_CONTINUE: in the coordination mode "relay agent" only. "yes" (the kit session starts the next action without a question, unless a user decision is open) OR "no" (it asks first). Default: "yes". In other modes, remove this line.}}
- Documentation: {{DOCS: "ARCHITECTURE.md + README.md + doc comments" OR "doc comments only" OR "none"}}
- Atomic steps (the rule): one `git revert` of a step's commit undoes it completely and leaves a working project (tests pass). If one commit is not possible: a change group (`Change-Group:` trailers that mark the first and the last commit, see the refactor-kit skill).
- Step size (a guideline): {{STEP_SIZE}} files or fewer. Not counted: a pure move (`git mv`), new test-data files, files whose only change is an access path. An atomic step can be larger.
- Execution mode: {{MODE: one of these values. "sequential". "parallel waves, {{MAX_PARALLEL}} steps or fewer in each wave". "parallel waves, dynamic maximum" (the coordinator selects the number for each wave).}}
{{COORDINATION_LINE: in parallel mode only. "- Coordination: session" (the kit session is the coordinator) OR "- Coordination: relay agent" (a `coordinator` agent does each action, and the kit session relays its requests). In sequential mode, remove this line.}}
{{PROGRESS_LINE: in sequential mode only. "- Progress report: every {{N}} steps" (default 2, `kit:workflow/progress.md`). In parallel mode, remove this line: the report shows at each phase change.}}

## Audience: {{AUDIENCE_NAME}}
{{AUDIENCE_SUMMARY: 3 to 6 lines. The reader, the audience test, and the most important rules of the profile.}}

## Rules
{{RULES_SUMMARY: 25 lines or fewer. A short version of the targets, limits (with their kinds), the exception markers, the priority, and the project rules in PRINCIPLES.md.}}
- Line limits count lines of code only: no empty lines, no comment lines (doc comments too). Group the code by purpose, with one empty line between two groups.

## Language rules
{{LANGUAGE_RULES: from the language profile, approved in setup part 5. The lint groups and policy, the exception syntax, and the measure notes. If the profile has them: the module layout, the test locations, the guidelines file, and the checks for each change, with their commands. 14 lines or fewer for each language.}}

## Code rules
- A refactor does not change behavior. Exception: a step with the tag `[feature]`.
- Ask before you add a new dependency.

{{PARALLEL_SECTION: in parallel mode, copy the section "Parallel mode" below. In sequential mode, remove it.}}

## Documentation style
{{DOCS_STYLE: the documentation style of the language profile, and 1 or 2 lines that fit the audience. Include the check command. Example for a beginner audience: "Use plain language. Define each term that a beginner possibly does not know."}}
- Write all text with the `asd-ste100` skill: documents, comments, doc comments, commit messages, and replies. Strict mode for text that an agent or a script reads. Flavored mode for text for people. Run its linter (`scripts/ste-lint.py`) on each changed document.

<!-- Section for parallel mode. The setup moves it above "Documentation style", or removes it. -->
## Parallel mode (agents that get a worktree path)
- Work only in your worktree. Start each Bash command with `cd <worktree path> &&`.
- Change only the files that your step lists in `Owns:`.
- Never edit the plan. Never commit. Never change other branches.
- Tests run in other worktrees at the same time. Use no fixed ports, fixed temporary paths, or shared databases.
- Your own files (scripts, logs, diffs, command output) go only into your own scratch folder. The instruction gives it, for example `<scratch>/<step ID>/`. If it does not, make one with `mktemp -d`. Never write into a folder that other agents use. Never run a script that you did not write.
- Wave scripts: `{{REFACTOR_FOLDER}}scripts/wave-start.sh`, `wave-merge.sh`, `wave-clean.sh`. Only the coordinator runs them.
