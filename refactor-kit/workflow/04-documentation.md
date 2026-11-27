# Action: docs

Back to `kit:SKILL.md`.

**Parallel mode:** if the Execution mode setting is "parallel waves", also follow `kit:workflow/parallel.md`, section D.

Do this action only when the plan has no unchecked steps. If you do it earlier, later phases make the documentation wrong.

1. Read the "Documentation" setting in the project-conventions skill. If it is "none", mark the row "Documentation" in section 11 as skipped. Then stop.
2. Start the `docs` agent. Give it this instruction: "Document the project after the refactor. Follow the Documentation setting. Put the extension of the refactor goal first in 'How to extend'. The goal is in section 0 of `<refactor folder>/PLAN.md`."
3. Check the result before you show it to the user:
   - Each term that the audience possibly does not know has an explanation.
   - The glossary includes each technique that has a comment in the code. Use Grep to find these comments.
   - Each "How to extend" example matches the code.
   - The documents describe no feature that does not exist.
   Fix each problem with the docs agent, or fix it yourself.
4. Show the user the list of changed files and the TODO items. Ask the user to read ARCHITECTURE.md as a member of the audience.
5. Mark the row "Documentation" in section 11 as done.
6. Commit, if the Commits setting permits it. Message: "Document the refactor".
7. Next action: final. Recommend `/clear`, then `/refactor-kit`.
