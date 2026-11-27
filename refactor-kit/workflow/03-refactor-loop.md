# Actions: next, review, revise

Back to `kit:SKILL.md`.

- Action **next** does parts A and B: one refactor step.
- Action **review** does part C: the review at the end of a phase.
- Action **revise** does part D: changes to the remaining plan after a review.

**Parallel mode:** if the Execution mode setting is "parallel waves", the action next runs one wave. Use `kit:workflow/parallel.md`, section W, in place of parts A and B. The action review starts with section R of that file.

---

## Part A: Refactor one step

1. Read `<refactor folder>/PLAN.md`. Find the next unchecked step. If the user named a step, use that step.
2. Show the step to the user in 2 lines. Ask to continue.
3. Start the `refactorer` agent. Give it this instruction: "Do step <ID> in `<refactor folder>/PLAN.md`."
4. Read the reply of the agent.
   - If the agent stopped because the code has no tests, tell the user. Propose a new Phase 0 step for that code. Add it to the plan after approval. Then stop this action.
   - If the agent stopped because the step is too large, show its proposal. Change the plan after approval. Then stop this action.
   - If the tests fail, tell the user. Offer two options: try again with a smaller change, or undo the step with `git checkout .` and divide the step.

## Part B: Simplify and check

1. Read the "Simplify step" setting.
   - If the diff of the step only removes code, skip the simplify step. Tell the user that there was nothing to simplify.
   - Also skip it if the diff only moves code without changes, or adds fewer than about 40 lines of new code. Read the new code yourself instead.
   - **simplifier agent:** start the `simplifier` agent. Give it this instruction: "Simplify the uncommitted changes of step <ID>."
   - **code-simplifier plugin:** start the `code-simplifier` agent. Give it this instruction: "Simplify only the uncommitted changes (git diff). Keep the behavior and the interfaces that the refactorer added. Make the code easy to read for the audience in the project-conventions skill. Keep the comments that explain techniques. Do not change other files."
   - **none:** skip this item.
2. Run the test command and the lint command yourself. If the step must not change expected test values, check that mechanically. Compare the string and number literals of each changed test file before and after the step. For example: `grep -oE` the literals, sort them, and diff. Do not trust a report that says "only access paths changed" without this check. The tests must pass. If the skill has a lint ratchet, the files of the step must be warning-free, and the total must not increase. Use the exit code of each command to decide. Do not filter the output for a word such as "error" and continue on a match. Such a filter succeeds when the word is in the output. Then a failed check looks like a pass.
3. Show the user:
   - `git diff --stat`
   - the "Concepts introduced" and the new findings from the refactorer reply
   - one changed file that the user should read, and why
4. Ask the user to read the diff. Ask: "Does this pass the audience test?" If the user finds a problem, fix it with the refactorer agent, or fix it yourself. Then run the tests again.
5. Check that the change is atomic (the global rule in `kit:SKILL.md`): it contains only this step, and nothing is half-done. If the refactorer proposed a change group, tell the user why one commit is not possible, then commit with the `Change-Group:` trailers. Then commit, if the Commits setting permits it. Message: "Refactor: <step ID> <step title>". Fixes from a review are a separate commit.
6. If this step was the last step of its phase, mark the row "Phase <N> steps" in section 11 as done. The next action is review. Otherwise, the next action is next.
7. Recommend `/clear`, then `/refactor-kit`.

---

## Part C: Phase review

1. Find the commit before the phase. Use `git log --oneline` and the commit messages of the phase.
2. Start the `reviewer` agent. Give it this instruction: "Review all changes of phase <N> in `<refactor folder>/PLAN.md`. The diff is `git diff <commit-before-phase>..HEAD`. Compare the changes with the target architecture in the plan."
3. Show the findings to the user. Recommend these decisions:
   - Always apply the correctness findings and the audience-test findings.
   - Apply the other findings if they give sufficient value.
4. Apply the findings that the user selects. Use the refactorer agent for a large fix. Run the tests.
5. **Exceptions.** Show the "Exceptions" list of the reviewer. The user accepts or rejects each verified exception. For each accepted exception, change its reason comment to the verified marker of the project-conventions skill, with phase <N>. Change only the comment. Run the tests.
6. If `<refactor folder>/SUCCESS_CRITERIA.md` exists, run its measure commands again. Record the results in the "Result" column. If a ratchet count increased, tell the user. It is a finding.
7. Copy the "Architecture notes" of the reviewer into section "9. Architecture notes (pending)". Use this format: `Phase <N> | <note>`.
8. Mark the row "Phase <N> review" in section 11 as done.
9. Commit, if the Commits setting permits it. Message: "Review phase <N>".
10. If section 9 has notes, the next action is revise. Otherwise, the next action is next. Recommend `/clear`, then `/refactor-kit`.

---

## Part D: Plan revision

Do NOT change code in this part.

1. Read `<refactor folder>/PLAN.md`: section "9. Architecture notes (pending)" and the unchecked steps.
2. Read the audience section and the priority section of `<refactor folder>/PRINCIPLES.md`.
3. Open a source file only to check a specific note.
4. For each note, select one decision:
   - **ACCEPT:** add steps or change steps.
   - **DEFER:** move the note to "Out of scope". Give a reason.
   - **REJECT:** give a reason.

   Rules for the decision:
   - A note that helps to meet the success criteria has a higher priority than a general improvement.
   - A note outside the goal scope gets DEFER. Exception: the note is small and applies to files that the goal already changes.
   - Accept a note only if it makes the code simpler, more modular, or both, AND the code still passes the audience test.
   - Prefer changes that remove layers or steps.
5. Propose an updated plan for the remaining phases. Include:
   - new or changed steps, in the usual format, in the step size limit
   - steps that are no longer necessary, marked for removal
   - the updated "Target architecture", if it changes
   - a Phase 0 step first, if an accepted change applies to code that has no tests
6. Show the proposal to the user as a short diff-style summary. Ask the user to approve each decision.
7. After approval:
   - Update the plan. Do not change checked steps (`- [x]`). Do not change section 2. It keeps the state before the refactor.
   - Move each processed note from section 9 to section "10. Plan changelog". Use this format: `Phase <N> | note | decision | reason`.
   - Add rows to section 11 for new phases.
8. Commit, if the Commits setting permits it. Message: "Revise plan after phase <N>".
9. Next action: next. Recommend `/clear`, then `/refactor-kit`.
