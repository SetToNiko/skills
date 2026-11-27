# Action: final

Back to `kit:SKILL.md`.

**Parallel mode:** if the Execution mode setting is "parallel waves", also follow `kit:workflow/parallel.md`, section F.

1. Find the base of the refactor branch. Use `git merge-base <branch> <main branch>`. The Branch setting gives the branch.
2. Start the `reviewer` agent. Give it this instruction:
   "Review the full refactor branch (`git diff <base>...HEAD`). Do the usual checks. Also do these checks:
   1. Compare the result with the target architecture in `<refactor folder>/PLAN.md` and with the targets in `<refactor folder>/PRINCIPLES.md`. Use the priority order of PRINCIPLES.md.
   2. If ARCHITECTURE.md exists, check that the audience can find their way in the code with it. The glossary explains each technique in the code. The walk-through matches the code.
   3. Examine each success criterion in section 0 of the plan. Mark it as met, partly met, or not met. Give evidence, for example a grep that shows that no direct calls remain.
   Report these items:
   - (0) the success-criteria checklist
   - (1) 10 findings or fewer
   - (2) one line for each target: improved, unchanged, or worse, with a short reason
   - (3) the 3 files that are most difficult for the audience, and the change that makes each file easier
   - (4) architecture notes"
3. If `<refactor folder>/SUCCESS_CRITERIA.md` exists, run its measure commands. Record the results.
4. Show the report to the user. Fix the findings that the user selects. Run the test command and the lint command.
5. Complete section "8. Outcome" of the plan in 20 lines or fewer:
   - what changed
   - what the refactor deferred
   - the recommended next steps. Include the final architecture notes and all notes that remain in section 9.
   Then remove all notes from section 9.
6. **Before and after.** Write `<refactor folder>/BEFORE_AFTER.md` from `kit:templates/BEFORE_AFTER.md`:
   - "Before": copy each row of section 2 of the plan. Add the column "Became".
   - "After": one row for each module in the code now. Read the purpose comment at the top of each file. Do not read full files. Add the column "Came from".
   - Key numbers: measure them again with the commands of the plan action. Use the numbers of section 2 as "Before".
   Show the user the key numbers and the section "In short" in chat.
7. **Contributor guide.** Write `CONTRIBUTING.md` at the project root from `kit:templates/CONTRIBUTING.md`. A contributor skill reads this file to plan parallel work, so each statement must be true for the code now. If a `CONTRIBUTING.md` exists, read the section "Contributor guide" of GOAL.md first. Write the new guide from the code. Keep each setting that the user did not apply in the setup (part 2b), if it is still true for the code. Then show the user each setting that changed, as a short list of old and new values. Ask for approval before you replace the file.
   - **Commands and gates (sections 1 and 2):** read the gates from the CI configuration or the check command of the project. Examples: the `flake.nix` checks, a CI workflow, a `Makefile`. One row for each gate. Run the command of each gate one time. Write only the gates that pass now.
   - **Review rules (section 3):** copy each rule from `<refactor folder>/PRINCIPLES.md` and the project-conventions skill. Include these rules:
     - the architecture rules, and the size limits with their kinds. Include the line-count definition (lines of code only, catalog Part C) and the command or gate that counts them.
     - the long-function rule, with the verified marker
     - the comment and documentation rules, the code rules, and the test rules
     - the commit rules: atomic steps, change groups, and commit tags
     Write the rule, not the history.
   - **Codebase map (section 4):** if the project has no `.claude/agents/mapper.md`, write it from `kit:templates/agents/mapper.md` first. Start one `mapper` agent for each top-level module, in parallel, with "Mode: contributing". Give each agent the paths of its module. Make the module table, the dependency graph, the communication table, the boundaries, and the extension points from the replies. Check the dependency direction with the cycle or dependency tool of the plan.
   - **Parallel work (section 5):** the ownership units are the modules that no other module changes. The shared files come from the "Shared files" headings of the mapper replies and from section 12 of the plan. The conflict areas come from the merge conflicts of this refactor (the plan changelog and the commit messages). Copy the safety rule of the refactorer agent, with the path variables of this project.
   - **Open items (section 7):** the deferred notes and the open findings of the plan.
   - The map is large. Divide the check into parts, for example one part for each section, and start one reviewer for each part, in parallel.
   - Then start the `reviewer` agent with this instruction: "Check each statement of CONTRIBUTING.md against the code. Run each command of sections 1 and 2. Check each file and item that the map names with Grep. Report each false statement with the fix." Fix each false statement.
   - **Style (a MUST):** write CONTRIBUTING.md with the `asd-ste100` skill. Load the skill with the Skill tool before you write the first sentence, and use its strict mode: an agent team reads this file. If an agent writes the file, its instruction must say: "Load the asd-ste100 skill first, and use its strict mode." Before the commit, run the linter of the skill (`scripts/ste-lint.py`) on the file. Fix each hard finding. Keep each fact, name, and path when you change a sentence. If the skill is not available, stop and tell the user. Do not write the file without it.
   Show the user the list of sections and the number of modules in the map.
8. Mark the row "Final review" in section 11 as done.
9. Commit, if the Commits setting permits it. Message: "Complete refactor: <goal in a few words>".
10. Tell the user that the refactor is complete. Offer to open a pull request or to merge. Do it only after the user agrees.
11. If GOAL.md has a `Draft pack:` line, offer to add the lessons of this refactor to that pack. If it has no such line, offer to save a new pack. Follow `kit:workflow/library.md`.
