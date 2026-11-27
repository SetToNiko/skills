# Success Criteria: {{PROJECT_NAME}}

<!--
The refactor-kit setup (part 6) selects the rows that fit the goal, writes the measure command of each row, and records the baseline.
The setup removes the rows that do not apply. A value without a baseline proves nothing.
The review action measures again after each phase. The final action records the results.
-->

## How to use this file

1. For each criterion, the kit runs the measure command and records the result in the "Baseline" column. A baseline is one of these values:
   - the measured value
   - **Phase 0:** the tool is not available yet. The plan makes it available and measures the baseline in Phase 0.
   - **manual:** a person measures it. Example: a check on the real desktop, or a sample change on a temporary branch.
   Each measure command shows each item that it counts. Some tools hide output by default. The language profiles list these cases.
2. You approve a value in the "Target" column.
3. After each phase, the kit runs the measure commands again. It records the results in the "Result" column.
4. Add the hard checks (greps, cycle checks, complexity limits) to CI. Then the criteria stay true after the refactor.

Not all criteria have the same weight:
- Sections 1 and 2 show if the refactor achieves its goal. They have the highest weight.
- Section 4 gives only an indication. You can improve these numbers without better code. Example: you divide code into many very small files. That makes the code more difficult to read, not easier.

---

## 1. Extensibility: the cost to add a variant

This section measures the goal directly. Give it the highest weight.

| Criterion | How to measure | Baseline | Target | Result |
|---|---|---|---|---|
| To add a new variant (type, provider, rule), you change N files or fewer. Usually this is 1 new file and 1 registry or configuration entry. | On a temporary branch, add a real or sample variant. Run `git diff --stat`. | | | |
| To add a variant, you edit no existing logic files. You edit only a registry, configuration, or data file. | Use the same diff. List the modified files, not the added files. | | | |
| No type-switches that grow: zero `switch`, `when`, or `if-else` chains on kind or type outside the registry. | Grep for patterns such as `when (type)`, `instanceof`, `switch (kind)`, `if type ==`. | | | |
| Exactly one location selects the implementation. | Grep for the code that creates the implementations. | | | |

## 2. Change locality: maintainability in practice

| Criterion | How to measure | Baseline | Target | Result |
|---|---|---|---|---|
| No code outside module Y calls X directly. Example: no `subprocess` or `os.system` outside `os/`. | A grep that must return no results. Add it to CI. | | | |
| No dependency cycles between modules. | A dependency tool: `madge --circular`, `pydeps`, `jdeps`, `go vet`, or an ArchUnit or import-linter rule. | | | |
| Dependencies go in one direction (UI → domain → data). | An import-linter, ArchUnit, or dependency-cruiser rule in CI. | | | |
| Fewer files change together. This is how often the same group of files changes in one commit. | Compare the co-change counts from `git log` before and after the refactor. Alternative: code-maat. | | | |

## 3. Testability

| Criterion | How to measure | Baseline | Target | Result |
|---|---|---|---|---|
| You can test the business logic without real I/O (network, disk, database, shell). | Count the logic tests that need a container, a network, or the real file system. The target is zero. | | | |
| The coverage of the changed modules is equal to or more than the baseline, or equal to or more than X%. | A coverage tool. Measure only the changed modules, not the full repository. | | | |
| The unit test suite is fast enough to run after each step. | The duration of the unit test suite. Example target: less than 30 seconds. | | | |
| The characterization tests pass without changes from the start to the end. | No commit changes the expected values in these tests. Examine `git log -p` on the test files. | | | |

## 4. Size and complexity (indication only)

| Criterion | Typical threshold | Baseline | Target | Result |
|---|---|---|---|---|
| Maximum cyclomatic complexity for each function. Tools: lizard, radon, or the eslint rule `complexity`. | 10 or less | | | |
| Function length. | Approximately 30 lines or fewer | | | |
| File length. | Approximately 300 lines or fewer | | | |
| Nesting depth. | 3 or less | | | |
| Duplicate code. Tools: jscpd or PMD CPD. | Less than the baseline | | | |
| Linter warnings and dead code. Tools: vulture, ts-prune, or detekt. | No new warnings. Less than the baseline is better. | | | |
| Public API surface for each module: the number of exported symbols. | Less than the baseline, or equal to it | | | |

## 5. Audience test (from PRINCIPLES.md)

These criteria are more difficult to measure. The checks below make them checkable.

| Criterion | How to measure | Baseline | Target | Result |
|---|---|---|---|---|
| Indirection depth: from the entry point to the result of one feature, a reader needs 3 jumps or fewer. | Follow 2 or 3 key features manually. Count the jumps. | | | |
| Each advanced technique has a comment at its location and an entry in the ARCHITECTURE.md glossary. | Grep for pattern names in the code. Compare the results with the glossary. | | | |
| Each public class has a one-line comment that gives its purpose. | A linter rule that counts public classes without a doc comment. Example: missing docstrings. | | | |
| The "How to extend" walk-through in ARCHITECTURE.md works. | A person or a new agent follows ARCHITECTURE.md step by step and adds a variant without other help. | | | |
