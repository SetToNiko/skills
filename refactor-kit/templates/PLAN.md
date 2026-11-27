# Refactor Plan: {{PROJECT_NAME}}

<!--
The refactor-kit plan action wrote this file. You can edit it. The agents read it.
Keep the section numbers. The kit finds the sections by their numbers.
-->

## 0. Goal
{{The goal and the success criteria from GOAL.md, in 8 lines or fewer. Agents read this section, not GOAL.md.}}
Goal locations: {{each location that the goal changes, as file:line}}

## 1. Summary
{{3 to 5 sentences about the current state and the main problems.}}

## 2. Architecture map (before the refactor)
<!-- The plan action writes this section one time. Do not change it later. The final action compares it with the code after the refactor (BEFORE_AFTER.md). -->

| Module | Purpose | Responsibilities | Depends on |
|---|---|---|---|
| {{path}} | {{one line}} | {{the things it does, separated by commas}} | {{modules}} |

Cycles: {{each dependency cycle, or "none"}}
Key numbers: {{modules, source lines, files over the file limit, the largest file, cycles}}

## 3. Target architecture
- {{The modules, the key interfaces, and the extension points after the refactor. Give interface names and the location of data and configuration.}}

Advanced techniques that the refactor adds:
- {{technique}} | {{location}} | {{why a simpler option is not sufficient}}

## 4. Findings
| # | File(s) | Problem | Target violated | Impact |
|---|---|---|---|---|
| 1 | {{path}} | {{problem}} | {{target ID from PRINCIPLES.md}} | H/M/L |

## 5. Test coverage
- {{module}}: {{good / partial / none}}

## 6. Plan

Step format (one line for each step):
`- [ ] P<phase>.<n> <title>: <what changes> | Files: <paths> | Target: <criterion or target> | Check: <how to test>`
A feature step has the tag `[feature]` before the title.
Parallel mode: each step has `Wave: <n> | Depends: <step IDs or none> | Owns: <paths>` in place of `Files: <paths>`.

### Phase 0: Safety net
- [ ] P0.1 {{title}}: {{characterization tests for module X}} | Files: {{test paths}} | Target: correctness | Check: tests pass on unchanged code

### Phase 1: {{name}}
- [ ] P1.1 {{title}}: {{what changes}} | Files: {{paths}} | Target: {{target}} | Check: {{how to test}}
Completes: {{success criteria that this phase completes, or "none"}}

## 7. Out of scope
- {{item}}: {{reason}}

## 8. Outcome
<!-- The final action completes this section. -->

## 9. Architecture notes (pending)
<!-- The review action adds notes here. The revise action processes them. -->

## 10. Plan changelog
| Phase | Note | Decision | Reason |
|---|---|---|---|

## 11. Progress
<!-- The kit updates this table after each action. -->
| Item | Status |
|---|---|
| Plan | done |
| Phase 0 safety net | open |
| Phase 1 steps | open |
| Phase 1 review | open |
| Documentation | {{open, or "skipped" if the Documentation setting is "none"}} |
| Final review | open |

## 12. Shared files (parallel mode only)
<!-- Remove this section in sequential mode. -->
| File | Steps that change it | Rule |
|---|---|---|
| {{path}} | {{step IDs}} | {{for example: wiring steps only}} |
