# Action: goal

Back to `kit:SKILL.md`.

Use this action when the user changes the goal during the refactor. Examples: a new criterion, a smaller scope, or features to remove from the project. Do NOT change code in this action.

## 1. Understand the change
1. Read `<refactor folder>/GOAL.md` and the unchecked steps of the plan.
2. Find each location in the code that the change touches. Use Grep. Show the user a short table: the component, where it is, and what you think the user means (remove, keep, or change). Ask about each line that is not clear.
3. A removal stops a behavior that users have now. For each removal, ask:
   - What replaces it, if anything? Example: the user's dotfiles take over a menu.
   - Does a package, a module, or a configuration of the user depend on it?
   Offer to record a **handover list** in the plan: what must exist outside the project after the removal.

## 2. Change GOAL.md
Show each change to GOAL.md as a short diff. Apply it after approval. Typical changes:
- The goal sentence, if the purpose of the project changes.
- The section "New behavior and removals": one line for each removal.
- The constraints, if a removed part was in them. Example: "the NixOS module continues to work".
- The success criteria and the verification, if they name a removed part.

## 3. Change the plan
Propose the plan changes as a short diff-style summary. Use these rules:
- **Removals come first**, in a phase "Phase R: Removals" directly after Phase 0. Reason: a removal makes the later steps smaller.
- Each removal step has the tag `[removal]`. In a `[removal]` step, the expected values of the characterization tests and golden files can change, but only for the removed behavior. The commit message says so.
- Each removal step also changes the user documentation of the removed part.
- Each removal step is atomic (the global rule in `kit:SKILL.md`): one revert of it brings the removed part back completely, with its documentation and tests.
- Remove or change the later steps that become unnecessary. Do not change checked steps.
- Add the handover list to section 7 "Out of scope", under the heading "Handover".
- Add rows for Phase R to section 11 "Progress".
- Record the change in section 10 "Plan changelog": `Goal | <change> | ACCEPT | <reason>`.
- Section 2 does not change. It keeps the state before the refactor.

After approval, write the changes. Also update SUCCESS_CRITERIA.md if a row names a removed part. Commit, if the Commits setting permits it. Message: "Change goal: <change in a few words>".

## 4. Next
The next action is the one that the state table of `kit:SKILL.md` selects. Usually it is next, which starts Phase R.
