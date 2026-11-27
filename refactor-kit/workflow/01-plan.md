# Action: plan

Back to `kit:SKILL.md`.

**Parallel mode:** if the Execution mode setting is "parallel waves", also follow `kit:workflow/parallel.md`, section P.

You write `<refactor folder>/PLAN.md`. Do NOT change code in this action. This is the only action that explores the full codebase. All later actions read the plan.

Model: if the session runs a small model, recommend that the user changes to a stronger model for this action. A good plan saves work in all later actions.

## 1. Read the inputs
1. `<refactor folder>/GOAL.md`: WHAT the refactor must achieve.
2. `<refactor folder>/PRINCIPLES.md`: HOW to write the code, the audience, the limits, and the priority.
3. `.claude/skills/project-conventions/SKILL.md`: the commands and the step size.

Each step in the plan must serve the goal or prepare for it. Examples of preparation: tests, or code that you must separate before the goal can change it.
Put general improvements outside the goal scope under "Out of scope". Exception: a very small improvement in a file that the goal already changes.

## 2. Explore efficiently
- Start with the build file, the entry points, and the folder structure.
- Use Grep or Glob before you read a full file.
- Do not read generated code, assets, or vendored dependencies.
- Use churn as evidence: `git log --format= --name-only | sort | uniq -c | sort -rn | head -20`. Give the files with the most churn a higher priority.

## 3. Analyze
0. Find all locations that the goal changes. Use Grep. List each location with file:line.
1. Map the architecture: the modules, the purpose of each, its responsibilities, and the dependencies between them. Record all cycles and the key numbers: modules, source lines, files over the file limit, the largest file. This map goes into section 2 as the "before" state. Write one row for each module, also for small modules and scripts. Section 2 does not change after this action.
2. Identify the public interfaces between modules. Record where they expose internals.
3. Find specific problems. For each problem, give the file paths and the target ID from PRINCIPLES.md. Look for:
   - classes and files with mixed responsibilities
   - conditionals on type or kind that must be data or polymorphism
   - concrete dependencies that business logic creates
   - duplicate logic, dead code, magic values
   - logic that you cannot test without UI, network, or database
   - code that fails the audience test
   - code that breaks a limit in PRINCIPLES.md
   - problems for each optional target that PRINCIPLES.md selects
   - code over a guideline limit. List it as a finding. Do not plan a step only to add reason comments. The refactorer adds them when a step changes that code.
4. Record where tests exist and where tests are missing.
5. Identify where real variation exists. Real variation is a thing that developers added many times. Only these locations get extension points.

## 4. Draft the plan
Use the structure of `kit:templates/PLAN.md`. Keep the section numbers.
- Section 6: phases with checklists. Use this order:
  1. Phase 0: the foundation. Use this order:
     1. Make each tool in "Tools not available yet" (project-conventions skill) available. Example: add clippy and shellcheck to the dev shell.
     2. Measure each "Phase 0" baseline in SUCCESS_CRITERIA.md with the new tools. Record the values.
     3. Add the lint configuration of the language profile, if it is not in the project. Example: `[lints.clippy]` in `Cargo.toml`.
     4. Safety-net tests for the modules that the first phases change and that have no tests.
  2. steps that separate the code that the goal changes
  3. structural changes that achieve the goal
  4. `[feature]` phases, only if GOAL.md permits new behavior
  Exception: `[removal]` steps form "Phase R: Removals", directly after Phase 0. A removal makes the later steps smaller.
  5. other improvements
- Each step is atomic (the global rule in `kit:SKILL.md`): one revert of its commit leaves a working project. Each step must be testable. The "Step size" setting is a guideline for the number of files. Pure moves, new test-data files, and access-path-only edits do not count. An atomic step can be larger. Divide a step when its parts can be reverted separately, not only because it has many files.
- At the end of each phase, write the success criteria that the phase completes.
- Section 11 "Progress": one row for the plan, one row for Phase 0, and two rows for each later phase (steps and review). Add a row for the documentation and a row for the final review.

Keep the plan shorter than approximately 250 lines. Use fewer, high-value steps.

## 5. Get approval
Show the user a short version first:
- the summary (section 1)
- the target architecture (section 3), in 10 lines or fewer
- the phases, with the titles of their steps
- the out-of-scope items

Ask the user to change, remove, or move steps. Make sure that each step is small and testable. Do the changes. Show the short version again if the changes are large.

## 6. Write and finish
After approval:
1. Write `<refactor folder>/PLAN.md`. Mark the "Plan" row in section 11 as done.
   Run `grep -n "{{" <refactor folder>/PLAN.md`. The result must be empty. Fix each placeholder that remains.
2. Commit, if the Commits setting permits it. Message: "Add refactor plan".
3. Next action: tests. Recommend `/clear`, then `/refactor-kit`.
