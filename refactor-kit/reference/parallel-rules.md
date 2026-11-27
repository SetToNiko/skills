# Rules for parallel waves

Back to `kit:workflow/parallel.md`.

These rules let several agents change one project at the same time without damage to the work of other agents. The kit session is the **coordinator**. It applies the rules when it writes the plan and when it runs a wave. The wave scripts in `<refactor folder>/scripts/` enforce the most important rules.

## 1. Terms

| Term | Meaning |
|---|---|
| **Coordinator** | The kit session, or in the coordination mode "relay agent" the `coordinator` agent. It runs the scripts and is the only writer of the plan. |
| **Relay** | The kit session in the coordination mode "relay agent". It starts the agents that the coordinator requests, asks the user the questions of the coordinator, and gives the results to the coordinator (`kit:workflow/parallel.md`, section C). |
| **Step** | One line in section 6 of the plan. One agent does one step. |
| **Wave** | A group of steps that run in parallel. Each step has a `Wave:` number. |
| **Owns** | The files and folders that a step can change. A folder entry ends with `/` and includes all files in the folder. |
| **Depends** | The steps that must be merged before this step starts. |
| **Worktree** | A second working folder of the same git repository, on its own branch. Each step gets one worktree. |
| **Integration branch** | The refactor branch of the project-conventions skill. The wave scripts merge each step into it. |

## 2. Wave rules

The plan must obey these rules. `wave-start.sh` checks rules 1 to 4.

1. In one wave, no two steps own the same file. A folder overlaps with each file in it.
2. Each step in a wave depends only on steps in earlier waves.
3. A wave has `MAX_PARALLEL` steps or fewer. If `MAX_PARALLEL` is `0`, the maximum is dynamic (see "Dynamic maximum" below).
4. No step owns the plan file.
5. A step owns its test files too. If two steps add tests to the same test file, put them in different waves.
6. A step that defines an interface comes in an earlier wave than the steps that use it.

**Do not run steps in parallel in these cases:**
- The steps change the same file. Make them separate waves, or merge them into one step.
- One step renames or moves code that another step uses.
- A step changes the build, the dependencies, the dev shell, or a shared configuration. Make it the only step in its wave. The Phase 0 foundation steps are usually such steps.

A wave can have one step. If the code is strongly connected, give each step its own wave. Do not force parallel work.

**Exception: several steps divide one large file.** Each step moves different functions out of the same file into new files. The rule 1 check fails, but the steps can run in parallel if the coordinator merges them by hand:
- Tell each agent the functions of the other steps. Each agent moves only its functions. Each agent adds its `mod` lines at the end of the module list.
- At each merge, a conflict block shows the old file on both sides: one side keeps the code that the other side moved out. Remove both sides of these blocks. Keep the `mod` and `use` lines of both sides.
- Git can put the last lines of a block (for example the closing braces `}`) outside the conflict markers, because both sides have them. Build after you remove the markers, and remove these lines.
- Then remove the imports that the build reports as unused.

**Dynamic maximum** (`MAX_PARALLEL=0`). The coordinator selects the number of agents for each wave:
1. Start with the number of steps of the wave whose dependencies are merged.
2. Use fewer agents if the machine load is too high. Each agent builds and tests in its own worktree, so several builds run at the same time. If the builds or the tests become slow, or time out, use fewer agents.
3. If a test failed only in parallel before, use 1 agent until a step fixes the shared resource (section 5).
4. Use the same rule for parallel checks: one mapper or reviewer for each part, and fewer if the machine load is too high.
At the start of each wave, show the number and the reason in one line. Example: "5 agents: 5 independent steps, light builds." The user can set a fixed number at any time.

**One step for each ownership unit.** A phase can have several jobs for the same files. Example: lint fixes and long functions, in the same folders. Do not make one step for each job: the steps then own the same files. Make one step for each folder group. Each step does all the jobs of the phase for its files.

**Steps of a later phase.** A step of a later phase can run in a wave of the current phase. Its conditions: it owns no file that an open step owns, and it depends on no open step. Example: an install script and its documentation, during a lint phase in the source folders. Each phase still gets its own review.

## 3. Shared files

Many steps edit some files. Examples: a module list (`mod.rs`, `main.rs`, `__init__.py`, `index.ts`), a registry, a dependency file (`Cargo.toml`, `package.json`), a lockfile, or a central configuration.

- List these files in section 12 "Shared files" of the plan.
- In each wave, a maximum of one step owns each shared file.
- Prefer a separate **wiring step** after the wave. The wiring step adds all new entries to the shared file at one time.
- A refactorer that must change a shared file that it does not own stops. It replies NEEDS with the change. The coordinator adds the change to a later wiring step.
- **Release a file.** An agent can reply NEEDS for a file outside its `Owns` field. If no other open step owns that file, the coordinator can add the file to the step, and tell the agent to continue. Example: a bug fix whose old test expects the bug. Record the change in the plan.
- **Signatures.** A step does not change the signature of an item that another unit uses. It replies NEEDS. The coordinator makes a later step for the change and for its callers.

## 4. Who writes what

| Item | Writer | Rule |
|---|---|---|
| The plan | Coordinator, `wave-merge.sh` | The agents never edit the plan. The merge script marks each merged step as done. |
| Source and test files | One agent, in its own worktree | The agent changes only the files that its step owns. |
| Commits on step branches | `wave-merge.sh` | The agents do not commit. |
| Integration branch | `wave-merge.sh`, coordinator | The agents never change the integration branch. |

## 5. Shared resources during tests

All worktrees run their tests at the same time. Tests that use a shared resource can fail for reasons that are not in the code. The setup checks these resources:

- **Network ports.** Use port 0 (the system selects a free port), or calculate the port from the worktree name.
- **Databases and services.** Give each worktree its own database name, or use an in-memory database.
- **Temporary files.** Use a temporary folder for each test run. Do not use fixed paths such as `/tmp/test.db`.
- **Build caches.** Each worktree builds in its own folder by default, for example `target/` or `node_modules/`. This uses more disk space and time. A shared cache can make the builds wait for each other.
- **Machine load.** Four builds and four test runs at the same time can be slow. Decrease `MAX_PARALLEL` if the tests time out.

If tests fail only in parallel, set `MAX_PARALLEL=1` for that wave. Then fix the shared resource in a separate step.

## 6. Merges

`wave-merge.sh` merges the steps of a wave one at a time, in the order that you give. For each step, it does these checks:

1. The tests pass in the worktree of the step.
2. The step changed only the files that it owns.
3. The merge has no conflicts.
4. The tests pass on the integration branch after the merge.

If a check fails, the script skips that step and continues. A skipped step stays in its worktree. The coordinator then does one of these actions:

- **Ownership failure:** examine the extra files. If the change is necessary, propose to add the files to `Owns` in a later wave. Then do the step again.
- **Merge conflict or test failure after the merge:** the step conflicts with a step that the script merged before it. Do the step again in the next wave, on the new integration branch.
- **Conflict only in import lines, `mod` lines, or a list of tests:** the coordinator resolves it by hand. Keep the lines of both sides. Then build, remove the imports that the build reports as unused, and run all gates. Do not do the step again for this kind of conflict.
- **Test failure in the worktree:** the agent did not finish the step. Read the log. Divide the step, or do it again.

**Check the result yourself.** Run all gates after each merge. Use the exit code of the command to decide. Do not trust the check results in a reply of an agent: the agent can run the checks on another state, or misread the output.

Give the steps to `wave-merge.sh` in plan order. Then the result is the same each time.

## 7. Usage and context

- Each agent starts with an empty context and loads the plan and the project-conventions skill. Thus, N agents use approximately N times the tokens of one agent.
- The coordinator receives one reply from each agent. Keep the replies short. Each agent file sets a line limit.
- Do one wave in each session. The plan file and the git history keep the state. Exception: in the coordination mode "relay agent", a fresh `coordinator` agent does each wave, and the kit session only relays (`kit:workflow/parallel.md`, section C).
- Run `wave-clean.sh` after each wave. Old worktrees use disk space.
- **An interrupted agent.** If a session ends while agents run, their worktrees keep the uncommitted work. In the next session, send each agent a message with SendMessage: "Continue the step. First run `git status` and the checks of the step, to see where you are." Do not start a new agent for the same step: it starts from zero.
- **A partial result.** A large step can end with the reply PARTIAL: the agent stages what is done, and all checks pass. Merge the partial result. Make a new step for the rest.
- **Verification in parallel.** A large check can run in parallel too. Examples: the reviewers of a phase, with one for each folder group. A check of each long-function reason. The check of CONTRIBUTING.md, with one reviewer for each section. The reviewers do not edit files. Each reviewer replies with only the false or missing statements.

> Claude Code can also give an agent its own worktree. This kit makes the worktrees with `wave-start.sh` instead. Then the scripts know the paths, and `wave-merge.sh` can check the file ownership.
