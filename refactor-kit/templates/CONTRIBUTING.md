# Contributing to {{PROJECT_NAME}}

<!-- The refactor-kit final action wrote this file from the code at the end of the refactor, with the asd-ste100 skill (strict mode). Keep it true: a change that moves a boundary, adds a module, or changes a gate also changes this file, in the same commit. Write each change with the asd-ste100 skill. -->

This file is for two readers:
- a person who contributes to the project
- a contributor skill or agent team that reads this file to plan parallel work

Each rule here is a rule of this project. A gate is a rule that a command checks. A review rule is a rule that a reviewer checks. A change must pass all gates and all review rules.

## 1. Commands

| Job | Command |
|---|---|
| Development environment | {{DEV_SHELL}} |
| Build | {{BUILD}} |
| Tests | {{TEST}} |
| All gates (run before each commit) | {{ALL_CHECKS}} |
| One gate | {{ONE_CHECK: for example `nix build .#checks.<system>.<name>`}} |

## 2. Gates

The command of section 1 runs all gates. A change that fails one gate is not done.

| Gate | What fails it | How to fix a failure |
|---|---|---|
| {{GATE}} | {{FAILURE}} | {{FIX}} |

Allowed exceptions: {{EXCEPTIONS: for example "an allowed lint uses `#[expect(<lint>, reason = "...")]` on the smallest item, with a true reason"}}.

## 3. Review rules

A reviewer checks these rules. No command checks them.

### Architecture
- Layers and dependency direction: {{DIRECTION: for example "ui → app → model and system. Model imports nothing above it."}}.
- {{LAYER_RULES: one line for each layer: what it may do and what it must not do}}
- No dependency cycles. {{CYCLE_GATE: the gate that checks it}}

### Size limits
| Item | Limit | Kind | Exception |
|---|---|---|---|
| {{ITEM}} | {{LIMIT}} | {{hard or guideline}} | {{EXCEPTION_RULE}} |

### Long functions
{{LONG_FUNCTIONS: the guideline, the reason comment, the verified form `<verified marker of the project>`, and when a reviewer checks a verified marker again}}

### Comments and documentation
{{DOC_RULES: the file header, the item doc comments, the required sections (for example `# Errors`), the language of the comments}}

### Code rules
{{CODE_RULES: one line for each project rule: data-driven variation, one source of truth, error handling, paths, no re-exports, naming, and so on}}

### Tests
{{TEST_RULES: the test kinds (unit, characterization, golden files, install test), which test a change must add, and when an expected value can change}}

### Commits
- Each commit is atomic: one revert undoes it completely and leaves a working project.
- {{CHANGE_GROUPS: the change-group trailer rule, if the project uses it}}
- {{COMMIT_TAGS: `[feature]`, `[removal]`, `[bug fix]`, `[behavior]`: what each tag allows}}

## 4. Codebase map

### Modules

| Module | Job | Files | Public API | Depends on | Used by |
|---|---|---|---|---|---|
| {{MODULE}} | {{one sentence}} | {{files or folder}} | {{the items that other modules use}} | {{modules}} | {{modules}} |

### Dependency graph
```
{{GRAPH: a short text graph of the module dependencies, in the allowed direction}}
```

### How the modules communicate
| From | To | How | What crosses the boundary |
|---|---|---|---|
| {{FROM}} | {{TO}} | {{function call, channel, file, process, environment variable}} | {{the data or the event}} |

### API boundaries
For each boundary: the entry points, the rule for callers, and what a caller must not do.
- **{{MODULE}}:** {{ENTRY_POINTS}}. {{CALLER_RULES}}.

### Extension points
| To add | Change these files | Example |
|---|---|---|
| {{EXTENSION}} | {{FILES}} | {{EXAMPLE}} |

## 5. Parallel work

A contributor skill uses this section to divide a change into steps for parallel agents.

### Ownership units
Two agents can change two different units at the same time.
| Unit | Files | Notes |
|---|---|---|
| {{UNIT}} | {{FILES}} | {{NOTES}} |

### Shared files
Many changes touch these files. In one wave, a maximum of one step changes each shared file. Prefer one wiring step after the wave.
- {{SHARED_FILE}}: {{why many changes touch it}}

### Conflict areas
- {{HOTSPOT}}: {{what conflicts and how to merge it}}

### Agent roles
| Role | Job | Reads | Writes |
|---|---|---|---|
| Implementer | One step in one ownership unit | this file, the step | the files of its unit |
| Test writer | Tests for one unit before or after a change | this file, the unit | the tests of its unit |
| Reviewer | Checks the review rules of section 3 | this file, the diff | nothing |
| Docs writer | Keeps this file and the architecture document true | this file, the diff | the documents |
| Coordinator | Divides the work into waves, merges, runs the gates | everything | the plan, the merges |

### Merge protocol
1. Each step works in its own worktree and branch.
2. The coordinator merges one step at a time and runs all gates after each merge. It decides by the exit code of the command.
3. A step that fails a gate after the merge goes back to its agent. Other steps continue.
4. {{PROJECT_MERGE_NOTES}}

### Safety rules for agents
- Run the project only in a temporary folder. Before you run a script that installs, removes, or writes files, set each target to a temporary folder: {{TARGET_VARIABLES}}.
- {{PROJECT_SAFETY_NOTES}}

## 6. Definition of done
- All gates of section 2 pass.
- The review rules of section 3 hold for the changed code.
- New behavior has a test and documentation.
- Section 4 of this file is still true. If the change moved a boundary or added a module, this file changes in the same commit.

## 7. Open items
{{OPEN_ITEMS: the deferred notes and the open findings from the plan, one line each, with the reason}}
