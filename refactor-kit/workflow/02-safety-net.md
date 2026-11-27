# Action: tests (safety net)

Back to `kit:SKILL.md`.

**Parallel mode:** if the Execution mode setting is "parallel waves", also follow `kit:workflow/parallel.md`, section T.

You do the unchecked Phase 0 steps. Phase 0 has two kinds of steps:
- **Foundation steps:** make tools available, measure the "Phase 0" baselines, and add the lint configuration. They change development files only, for example the dev shell or the lint settings. They never change production code or behavior.
- **Test steps:** characterization tests. The tests record the CURRENT behavior. Then the refactor can prove that it changes no behavior.

Do the foundation steps first. After each foundation step, run the tool once to show that it works. Record each measured baseline in SUCCESS_CRITERIA.md. Then remove the tool from "Tools not available yet" in the project-conventions skill.

**Commit after each step**, if the Commits setting permits it. Message: "Phase 0: <step ID> <title>". Each commit is atomic (the global rule in `kit:SKILL.md`): one revert of it leaves a working project.

**Safety before you run code under test.** Before you run a script or a program in a test, read what it writes and what it starts. It can write outside HOME and the temporary folder, for example to `/etc`, `/var/lib`, or a mounted device. Or it can change the real desktop. Then do not run it as it is. Isolate it first. Examples: stub commands, a temporary HOME, and a read-only mount in a private namespace (`unshare --user --map-root-user --mount`). Check that the isolation works with a harmless command first. If you cannot isolate it, stop and tell the user.

## Process
1. Read `<refactor folder>/PLAN.md`: the section "5. Test coverage" and the unchecked Phase 0 steps.
2. For each test step, write the tests that it describes. Rules:
   - Record the current behavior, also where the behavior looks incorrect.
   - If a behavior looks incorrect, write a comment in the test. Add the behavior to section "4. Findings". Do not fix it.
   - Do not change production code. If you cannot test some code without a change, list that code. Do not change it.
   - Test through the public interfaces, not the private internals. Then the tests stay valid after the refactor.
   - Test the main paths and the edge cases that the code explicitly handles. Full coverage is not necessary.
   - Use the test style of the project-conventions skill.
3. Run the tests. They must pass on the unchanged code.
4. Mark each finished step as done (`- [x]`).
5. Update section "5. Test coverage". If you finished all Phase 0 steps, mark the row "Phase 0 safety net" in section 11 as done.

## Finish
1. Tell the user these items, in 10 lines or fewer:
   - the tests that you added
   - the incorrect behavior that you found
   - the code that you could not test
2. Ask the user to run the tests one time. The user must see that they pass.
3. Make sure that each step has its own commit.
4. Next action: next (the first refactor step). Recommend `/clear`, then `/refactor-kit`.
