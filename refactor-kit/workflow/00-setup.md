# Action: setup

Back to `kit:SKILL.md`.

You prepare the refactor for this project together with the user. At the end, the project has all the files that the later actions need. The user copies nothing by hand.

The setup has 7 parts, and part 2b if the project has a contributor guide. Do them in order. After each part, show the draft and get approval before you continue.

| Part | Topic | Output |
|---|---|---|
| 1 | Execution mode, preconditions, and old files | the execution mode |
| 2 | Project scan | a summary for the user |
| 2b | Contributor guide (only if the project has a CONTRIBUTING.md) | the settings that the user applies |
| 3 | Goal | `<refactor folder>/GOAL.md` |
| 4 | Audience and principles | `<refactor folder>/PRINCIPLES.md` |
| 5 | Stack, language profile, and workflow settings | `.claude/skills/project-conventions/SKILL.md` |
| 6 | Success criteria (optional) | `<refactor folder>/SUCCESS_CRITERIA.md` |
| 7 | Write the files | all files above, and `.claude/agents/*.md` |

Keep the approved drafts in the conversation until part 7. Exception: if the user wants to stop early, write the approved files at that time. The next setup session then continues from the first missing file.

**Resume.** If some output files exist, show the user which ones. For each one, ask: keep it, or do that part again?

**Answers that you already have.** If a draft, an old file, or an earlier answer already answers a question, do not ask the full question. Show the answer in one line and ask the user to approve it.

**A later answer changes an approved file.** Example: in part 4, the user removes a target and wants it out of scope in GOAL.md. Show the change to the approved draft in one or two lines. Apply it after the user agrees.

---

## Part 1: Execution mode, preconditions, and old files

0. **Execution mode (the first question).** Ask with AskUserQuestion: "Do you want one agent or several agents to do the refactor?"
   - **Sequential (one agent):** one agent does one step at a time. Recommended for a small project, or for code with strong connections between the modules. It uses the fewest tokens.
   - **Parallel (several agents):** several agents do the steps of one wave at the same time, each in its own git worktree. Recommended for a project with modules that are mostly independent, and for a usage plan with high limits. It takes less time, but it uses more tokens in total.
   Record the answer. It is the "Execution mode" setting of part 5. If the user selects parallel, read `kit:workflow/parallel.md`, section S, now.

   **The maximum number of agents (parallel only).** If the user selects parallel, ask the next question at once, with AskUserQuestion: "How many agents can work at the same time?"
   - **Dynamic (Recommended):** the coordinator selects the number for each wave from the task. The rules are in `kit:reference/parallel-rules.md`, section 2, "Dynamic maximum". At the start of each wave, the coordinator shows the number and the reason in one line.
   - **4 agents**
   - **5 agents**
   - **3 agents**
   The user can type another number with "Other". Record the answer as `MAX_PARALLEL`: the number, or `0` for dynamic. The user can change it before any wave.

   **The coordination mode (parallel only).** Then ask with AskUserQuestion: "Who coordinates each wave?"
   - **Relay agent (Recommended):** a fresh `coordinator` agent (model opus) does each action. The kit session starts the agents that the coordinator requests, and asks you its questions. One session can do several actions, without `/clear` after each action. Rules: `kit:workflow/parallel.md`, section C.
   - **Session:** the kit session is the coordinator. Do one action in each session, and `/clear` after each action.
   Record the answer. It is the "Coordination" setting of part 5. The user can change it before any action.
1. Run `git rev-parse --show-toplevel`. If the project is not a git repository, ask the user to make one. Offer to run `git init` and to commit the current files.
2. **Old files.** Look for refactor files from an earlier kit version or from an earlier refactor: `REFACTOR_GOAL.md`, `REFACTOR_PLAN.md`, `SUCCESS_CRITERIA.md`, and files with "refactor" in the name in `docs/`. If you find one, read it. Then ask with AskUserQuestion:
   - **Use as drafts (Recommended):** the interview starts from their content. In part 7, their content moves to the new files, and the old files are removed.
   - **Ignore, start fresh:** the old files stay where they are, untouched.
   - **Commit them first:** commit them unchanged, then use them as drafts. The history keeps the old version.
3. Run `git status --porcelain`. Ignore the old files from item 2. If there are other uncommitted changes, tell the user. Ask them to commit or stash the changes. Do not continue until the working tree is clean.
4. Check for these paths: `<refactor folder>/`, `.claude/agents/refactorer.md`, `.claude/agents/reviewer.md`, `.claude/agents/docs.md`, `.claude/agents/simplifier.md`, `.claude/skills/project-conventions/`. List each one that exists. In part 7, ask before you overwrite it.

**Old drafts and the earlier kit.** The earlier kit used other names. When you copy text from an old file, change these names:

| Old name | New name |
|---|---|
| `REFACTOR_GOAL.md`, `REFACTOR_PLAN.md` | `<refactor folder>/GOAL.md`, `<refactor folder>/PLAN.md` |
| "Step 1" (plan) | the plan action |
| "Step 2" (safety net) | the tests action, Phase 0 |
| "Step 3" (refactor loop) | the next, review, and revise actions |
| "Step 4" (documentation) | the docs action |
| "Step 5" (final review) | the final action |
| "TBD" in a baseline | a measured value, "Phase 0", or "manual" (refer to part 6) |

## Part 2: Project scan

Find the facts that you can find without help from the user. Read only what you need:
- Build and package files. Examples: `Cargo.toml`, `package.json`, `pyproject.toml`, `build.gradle`, `go.mod`, `Makefile`, `flake.nix`.
- The language or languages, by file count: `git ls-files | sed 's/.*\.//' | sort | uniq -c | sort -rn | head`.
- The top-level folders and the entry points.
- The test framework, the test folders, and the test command.
- The lint and format commands.
- The size: the number of source files and lines.
- Churn: `git log --format= --name-only | sort | uniq -c | sort -rn | head -10`
- Existing documents: `README.md`, `ARCHITECTURE.md`, `CLAUDE.md`, and documents in `docs/`.

**Run the tools.** Finding a command is not sufficient. Run each command one time if it is fast and safe. A safe command writes only inside the project, HOME, and the temporary folder. It changes nothing on the real desktop. Do not run the project's own scripts in the scan. Run these commands: the test command, the lint commands, and the format check. Run a slow command in the background and continue the scan. For each command, record one of these results:
- **works:** record the result. Example: "115 passed, 4 ignored".
- **fails because of the code:** record the number of failures or warnings.
- **tool not available:** the tool is missing, or it does not match the toolchain of the project. Example: a system clippy that is built for a different rustc. Record it. The plan makes the tool available in Phase 0.

Show the user a summary of 12 lines or fewer. Ask the user to fix each wrong fact.

Do not read the full codebase. The plan action does the deep analysis later.

## Part 2b: Contributor guide

Do this part only if the project has a contributor guide. Look for `CONTRIBUTING.md` in the project root, in `docs/`, and in `.github/`. If you find none, go to part 3.

A contributor guide holds settings that the project already uses: gates, rules, limits, and a map of the code. An earlier refactor with this kit can write it (the final action, step 7). The user decides which settings this refactor applies.

1. **Read the guide.** Read the full file. Put each setting into one of these groups. Skip a group that the guide does not have.

| Group | Examples | The part that uses it |
|---|---|---|
| Commands and gates | the build, test, lint, and check commands, and the CI gates | part 2 (facts), part 3 (verification), part 5 (stack) |
| Architecture rules | the layers, the dependency direction, no cycles, no re-exports | part 4 (project rules) |
| Limits | the file, function, and folder limits, with their kinds, and the long-function rule with its marker | part 4 (limits) |
| Comment and documentation rules | the file header, the doc comments, the required sections, the language | part 5 (language profile) |
| Code rules | data-driven variation, paths, errors, casts | part 4 (project rules) |
| Test rules | the test kinds, when an expected value can change | part 3 (verification), part 5 (test style) |
| Commit rules | atomic commits, change groups, commit tags | part 5 (workflow) |
| Parallel-work settings | the ownership units, the shared files, the agent roles, the merge protocol, the safety rules | part 5 (execution mode), `kit:workflow/parallel.md` |
| Codebase map | the modules, the public API, the boundaries, the extension points | part 2 (facts), the plan action |
| Open items | the deferred notes and the open findings | part 3 (goal and scope) |

2. **Check each setting against the scan.** Use the results of part 2. A setting is **stale** if the code does not agree with it. Examples: a command fails, a gate does not exist, a module in the map does not exist. Mark each stale setting, and give the reason in a few words.

3. **Ask the user, one group at a time.** Show the settings of the group, one line each. Show the stale settings with the mark "stale". Then ask with AskUserQuestion:
   - **Apply all (Recommended):** the later parts use each setting of the group as the draft answer. If the group has a stale setting, do not recommend this option. Recommend "Choose one by one".
   - **Choose one by one:** ask with AskUserQuestion, multiSelect, with each setting as an option. A question has 4 options or fewer, and a call has 4 questions or fewer. Use more questions or calls for a large group.
   - **Do not apply:** this refactor does not use the settings of this group.
   For a setting that differs from the default of the kit, show both values in the option text. Example: "Files: 500 lines, hard (the guide). The kit default: 300."

4. **Record the decisions.** Keep a table until part 7: the group, the setting, and the decision (apply, do not apply, stale). The later parts use each applied setting as an answer that you already have. Show it in one line and ask the user to approve it (refer to "Answers that you already have"). In part 7, add a section "Contributor guide" to GOAL.md. It gives the path of the guide. It also lists each setting that this refactor does not apply, with the reason.

5. **The guide after the refactor.** The final action writes the guide again from the code (step 7). It shows the user the settings that the refactor changed.

## Part 3: Goal

Template: `kit:templates/GOAL.md`. Example: `kit:examples/goal-distro-agnostic.md`.

Ask about these topics, one at a time:

1. **Goal.** Ask: "After the refactor, what must be possible that is not possible or not easy now?" If the user is not sure, propose 2 or 3 goals from the scan. Example: churn shows that one file changes in most commits.
   **Draft packs.** After the user gives the goal, search the draft library. Follow `kit:workflow/library.md`, section "Use a pack". If the user selects a pack, use it as the draft for the other topics of parts 3 to 6.
2. **Reason.** Ask for the problem that the goal solves. The planner uses it to make trade-offs. Offer to add one measured fact from the scan as evidence. Example: "`app.rs` has 4,948 lines and changed in 46 of 96 commits."
3. **Success criteria.** Each criterion must be checkable. If a criterion is vague, propose a checkable version. Examples:
   - "Cleaner code" → "No function in `src/` is longer than 40 lines."
   - "Easier to add providers" → "To add a provider, you add 1 file and 1 registry entry."
   - "It installs" → "It installs, and the main command works after the install."
4. **Scope.** Propose the in-scope modules from the scan. Ask what is out of scope. Propose to name each known later project as out of scope, so the planner does not start it.
5. **New behavior and removals.** Ask with AskUserQuestion: "No, pure refactor (Recommended)", "Yes, new features", or "Yes, remove parts of the project". For each feature: it becomes a `[feature]` phase after the refactor phases. For each removal: it becomes a `[removal]` step in Phase R, directly after Phase 0. Ask what replaces it, and offer a handover list (`kit:workflow/06-goal-change.md`, section 1).
6. **Constraints.** Propose these defaults. The user can change them.
   - The project works after each step: the tests pass, and the build passes.
   - No new runtime dependencies. New development tools are permitted, for example linters in the dev environment.
7. **Verification.** Propose the test command from the scan, with the baseline result. Propose that the counts of skipped and ignored tests must not increase. Ask for other environments. Examples: containers, devices, a manual check.

Show the full GOAL.md draft. Get approval.

## Part 4: Audience and principles

Catalog: `kit:catalog/principles.md`. Template: `kit:templates/PRINCIPLES.md`.

1. **Audience.** Ask with AskUserQuestion: "Who will read and change this code after the refactor?" Use the audience profiles of the catalog as the options. Recommend a profile from the scan and the goal.
2. **Targets.** A question can have 4 options or fewer. Ask with AskUserQuestion, multiSelect, with these options:
   - one option for all default modules together (T1 to T6), marked as recommended
   - one option for each optional module, up to 3. Mark the modules that fit the goal as recommended. Give the reason from the scan.
   If the catalog has more than 3 optional modules, put the 3 that fit best in the question. Name the others in the question text.
   **Removed targets.** If the user removes a target that you recommended, or a target that the scan shows as relevant, ask for the reason. Offer to add the target to the out-of-scope list in GOAL.md with that reason. Example: "Security hardening: before a public release, not in this refactor."
3. **Priority.** Show the default priority order of the catalog, with the selected optional modules in it. Ask if the order fits this project.
4. **Limits.** Measure each limit in the code first. Count lines of code, not all lines (the catalog, Part C). Example: count the functions and files over the default limit. Show a table: the limit, the default, the measured value, and your proposal. For each limit, propose:
   - a **value**
   - a **kind**: hard, or guideline (refer to the catalog, Part C)
   - a **later target**, if the code is far over the default. Example: files 500 lines now, 300 later.
   If the user selects a guideline, explain the verified-exception process of the catalog, Part E. Ask if it fits.
5. **Project rules.** Propose rules from the goal and the scan. Example: a success criterion that each step must keep, such as "all system paths go through `paths.rs`". Ask for other rules that are special to this project. This topic is optional.

**Assemble PRINCIPLES.md** from the template:
- Copy the selected audience profile and target modules from the catalog.
- Replace each limit placeholder with the approved value.
- Apply the words and the example comment of the language profile to the audience module (refer to part 5, item 2). Example for Rust: "class" becomes "type".
- If the user changes the text of a module, apply the change. Add "(changed for this project: <what>)" to the heading of that module. Do not change module text without approval.

Show a short summary to the user: the audience, the targets, the priority, the limits, the exceptions process, and the project rules. Offer the full text. Get approval.

## Part 5: Stack, language profile, and workflow settings

Templates: `kit:templates/project-conventions.md`, `kit:catalog/languages.md`.

1. **Stack.** Fill these fields from the scan: language and framework, build command, test command, lint and format command, test style, naming rules. Add the result of each command from the scan. Show them. Ask the user to fix each wrong value.
2. **Language profile.** For each main language, read its profile in `kit:catalog/languages.md`. Show the defaults of the profile: the lint groups, the documentation style, the exception syntax, and the measure notes. Measure the current state with the lint command of the profile. Then ask the user to accept or change each default. If no profile exists for the language, ask the user for the lint rules and the documentation style.
   - If the lint command reports many warnings today, ask for the policy with AskUserQuestion. The options: ratchet to zero (recommended), no new warnings only, or fix all in one early phase.
   - A ratchet to zero adds a success criterion to GOAL.md. A strict documentation style adds a checkable criterion. Show these changes to the approved GOAL.md.
3. **Workflow.** Ask with AskUserQuestion. A call can have 4 questions or fewer, so use two calls. Put the default first.

| Setting | Options (default first) |
|---|---|
| Refactor folder | `docs/refactor/` · `.refactor/` · other |
| Branch | `refactor/<short goal name>` · use the current branch |
| Commits | Commit after each approved action · Ask before each commit · Never commit (the user commits) |
| Models | refactorer sonnet, reviewer sonnet, docs haiku, simplifier sonnet · all sonnet · all inherit · custom |
| Simplify step | The `simplifier` agent of this kit · the official `code-simplifier` plugin · no simplify step |
| Documentation | ARCHITECTURE.md + README.md + doc comments · doc comments only · none |
| Step size (a guideline. Atomicity is the rule: `kit:SKILL.md`) | 5 files or fewer · 3 files or fewer · 8 files or fewer |
| Execution mode | The answer of part 1, item 0. Do not ask again. Show it in one line. |

If the execution mode is parallel, follow `kit:workflow/parallel.md`, section S, part 5, before you continue.

If the user selects the official plugin, tell them to type `/plugin install code-simplifier@claude-plugins-official`. You cannot run this command for them.

4. **Short principles.** The template has a section "Rules" with a short version of PRINCIPLES.md. Write it in 25 lines or fewer. Include the exception markers and the rules of the language profile. Each agent loads this skill each time it starts, so each line costs tokens on each run.

Show the full draft. Get approval.

## Part 6: Success criteria (optional)

Template: `kit:templates/SUCCESS_CRITERIA.md`.

If an old success-criteria file exists, use it as the draft. Ask in one line if the user wants to keep the measurements. Otherwise, ask with AskUserQuestion: "Measure the success criteria before the refactor?" Options: "Yes, I measure the baseline (Recommended)" or "No, skip".

If yes:
1. Select the rows of the template that fit the goal and the targets. Add one row for each success criterion in GOAL.md. Add one row for each lint policy and documentation criterion from part 5.
2. For each row, write the exact measure command. Example: `grep -rn "Command::new" src/ | grep -v "^src/os/" | wc -l`.
3. Run each measure command. **Measure honestly:**
   - Run the command in the form that shows each item that it counts. Some tools hide output by default. Example: Rust tests capture the output of passing tests, so count with `-- --nocapture`. The language profile lists these cases.
   - If a count is small or surprising, check it with a second method.
   - If a new measurement differs from a value in an old file or in an approved draft, tell the user. Show both values. Fix the approved draft after the user agrees.
4. Record the result in the "Baseline" column. Use one of these values:
   - the measured value
   - **Phase 0:** the tool is not available yet. The plan makes it available and measures the baseline in Phase 0.
   - **manual:** a person must measure it. Example: a check on the real desktop, or a sample change on a temporary branch.
5. Propose a target for each row.

Show the table, or only the changed rows if an old file exists. Get approval.

## Part 7: Write the files

1. Show the list of files that you will write. Mark each file that exists. Include the old files that part 1 removes.
2. Ask: "Write these files and create the branch?" For each existing file, ask separately: overwrite, or keep.
3. Create the branch from part 5, if the user selected a new branch.
4. Write the files:

| Project file | Source |
|---|---|
| `<refactor folder>/GOAL.md` | approved draft, part 3, with the approved changes from later parts |
| `<refactor folder>/PRINCIPLES.md` | approved draft, part 4 |
| `<refactor folder>/SUCCESS_CRITERIA.md` | approved draft, part 6 (only if the user selected it) |
| `.claude/skills/project-conventions/SKILL.md` | approved draft, part 5 |
| `.claude/agents/refactorer.md` | `kit:templates/agents/refactorer.md` |
| `.claude/agents/reviewer.md` | `kit:templates/agents/reviewer.md` |
| `.claude/agents/docs.md` | `kit:templates/agents/docs.md` (only if the user selected documentation) |
| `.claude/agents/simplifier.md` | `kit:templates/agents/simplifier.md` (only if the user selected it) |
| `<refactor folder>/scripts/progress.sh` | `kit:templates/scripts/progress.sh` (the progress report, `kit:workflow/progress.md`). Replace `{{REFACTOR_FOLDER}}`. Run `chmod +x`. |

In parallel mode, also write the files of `kit:workflow/parallel.md`, section S, part 7.

5. In each agent file, replace `{{MODEL}}` with the model from part 5.
   If a main language is Rust, also copy `kit:reference/rust-api-guidelines.md` to `.claude/skills/project-conventions/rust-api-guidelines.md`. The "Language rules" section of the conventions gives this path.
6. If the user selected "use as drafts" in part 1, remove the old files. If they are tracked, use `git rm`.
7. Run `grep -rn "{{" <refactor folder> .claude/agents .claude/skills/project-conventions`. The result must be empty. Fix each placeholder that remains. Also search the new files for "TBD" and for the old names of part 1.
8. Commit with the message "Prepare refactor: <goal in a few words>", if the Commits setting permits it.
9. Offer to save the decisions as a goal pack. Follow `kit:workflow/library.md`, section "Save a pack".

Then tell the user:
- the files that you wrote
- that Claude Code loads agent files when a session starts. The next action needs a NEW session that starts in the project root. `/clear` is possibly not sufficient.
- the next action: plan. Recommend: start a new session in the project root, then `/refactor-kit`.
