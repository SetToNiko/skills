# Refactor Kit (interactive skill)

A Claude Code skill that guides you through an incremental refactor of a project. You install it one time. Then, in any project, you type `/refactor-kit`. Claude interviews you, writes the refactor files into the project, and does the refactor with you, one action at a time.

You make the decisions. Claude does the work and places all files. You copy nothing by hand.

Each change is **atomic**: one `git revert` of a commit undoes that step completely and leaves a working project. This is the real limit of a step. The number of files is only a guideline. When one commit is not possible, each commit of the change gets a `Change-Group:` trailer. The trailers mark the first and the last commit, so you can revert the whole group at once.

This is the interactive version of the sequential refactor kit. The procedure is the same: plan, safety net, refactor steps, reviews, documentation, final review. The differences:

| Sequential kit | This kit |
|---|---|
| You copy files and complete placeholders | The setup interview writes all files |
| One fixed set of principles, with a beginner audience | You select the audience, the targets, and the limits for each project |
| You paste a prompt for each step | You type `/refactor-kit`. The skill finds the next action |
| `REFACTOR_PLAN.md` in the project root | All refactor files in one folder that you select, default `docs/refactor/` |

---

## Install

Copy this folder into your Claude Code skills folder. The folder name must be `refactor-kit`:

```bash
mkdir -p ~/.claude/skills
cp -r ~/Downloads/refactor-kit-interactive ~/.claude/skills/refactor-kit
```

To install the kit for one project only, copy it to `<project>/.claude/skills/refactor-kit` instead.

Start a new Claude Code session. Type `/refactor-kit status` to check that Claude finds the skill.

**Required skill:** `asd-ste100` (Simplified Technical English). The kit writes all its text with this skill. This includes the project files, the documents, the comments, the commit messages, the agent instructions, and the messages to you. Each agent of the kit preloads it. The kit stops if the skill is not installed. Install it in `~/.claude/skills/asd-ste100`.

---

## Use

In the root of the project, type:

```
/refactor-kit
```

The skill reads the project, finds the state of the refactor, and proposes the next action. After each action, it recommends `/clear` and then `/refactor-kit` again. The files keep the state, so each action starts with a clean context.

You can also name an action:

| Command | Action |
|---|---|
| `/refactor-kit status` | Shows the state and the next action. Changes nothing. |
| `/refactor-kit setup` | The interview: goal, audience, principles, stack, settings. Writes the project files. |
| `/refactor-kit plan` | Analyzes the codebase and writes the plan. You approve it first. |
| `/refactor-kit tests` | Writes characterization tests for Phase 0. |
| `/refactor-kit next` | Does the next refactor step, simplifies it, and shows you the diff. |
| `/refactor-kit review` | Reviews a finished phase. |
| `/refactor-kit revise` | Changes the remaining plan with the notes of the review. |
| `/refactor-kit docs` | Writes ARCHITECTURE.md, README.md, and doc comments. |
| `/refactor-kit final` | Reviews the full branch against the success criteria. Writes BEFORE_AFTER.md: the modules before and after the refactor, with their purpose and responsibilities. Writes CONTRIBUTING.md: the gates, the rules, and a map of the codebase for later contributors and contributor agent teams. |
| `/refactor-kit goal` | Changes the goal during the refactor, for example to remove parts of the project. Removals become `[removal]` steps in a phase directly after Phase 0, with a handover list. |
| `/refactor-kit library` | Lists your saved goal packs. You can show, rename, or remove a pack. |

### The setup interview

The first `/refactor-kit` in a project starts the setup. It takes approximately 10 to 20 minutes:

1. **Scan.** Claude reads the build files, the folder structure, and the git history. It runs the tests and the linters one time. It shows a short summary. You fix the wrong facts. If the project has refactor files from the earlier kit, Claude offers them as drafts.
   **Contributor guide.** If the project has a `CONTRIBUTING.md`, Claude reads its settings: the gates, the rules, the limits, the commit rules, and the map of the code. Claude checks each setting against the code, and marks the stale settings. Then you select, group by group, which settings this refactor applies. The applied settings become the drafts of the next parts.
2. **Goal.** What must be possible after the refactor, why, the success criteria, the scope, new behavior, the constraints, and the verification. Claude proposes checkable criteria.
3. **Audience and principles.** Who maintains the code (beginner, mixed team, or experienced maintainers), which targets apply, the priority, and the limits. A limit can be hard, or a guideline with a verified reason. Claude assembles them from the catalog.
4. **Stack and settings.** The commands and the language profile. For Rust, the profile gives the clippy groups and the rustdoc style. Then the workflow: the refactor folder, the branch, the commit policy, the models, the simplify step, the documentation, and the step size.
5. **Success criteria (optional).** Claude runs the measure commands and records the baseline.
6. **Write.** Claude shows the file list, creates the branch, and writes the files after your approval.

You can stop at any part. The next `/refactor-kit` continues from the first missing file.

### Parallel mode

The first question of the setup is the execution mode. One kit does both:
- **Sequential (one agent):** one agent does one step at a time. It uses the fewest tokens.
- **Parallel (several agents):** several agents do the steps of one wave at the same time. Each agent works in its own git worktree. Use this mode for a project with modules that are mostly independent. It uses more tokens in total, but it takes less time. Then you select the maximum number of agents at the same time: a fixed number, or dynamic. With dynamic, the coordinator selects the number for each wave from the task, and tells you the number and the reason.

In parallel mode, the plan gives each step a wave number, the steps that it depends on, and the files that it owns. In one wave, no two steps own the same file. The setup writes three wave scripts into `<refactor folder>/scripts/`. They make the worktrees, check the file ownership, run the tests, and merge each step. Mapping, reviews, the checks of the long-function reasons, and the check of CONTRIBUTING.md also run in parallel. An interrupted agent continues from its worktree. The rules are in `reference/parallel-rules.md`.

### Reuse decisions: goal packs

At the end of the setup, Claude offers to save your decisions as a **goal pack** in `~/.claude/refactor-kit/library/`. A pack keeps the goal, the principles, the language decisions, the success-criteria rows, and the settings. It replaces project facts with slots, and it never keeps measured values.

In the next project, you give your goal in one sentence. Claude then offers the packs with a similar goal. If you select one, each part of the interview starts from the pack, and you approve or change each section in one line. The scan fills the slots, and Claude measures each baseline again.

After the final review, Claude offers to add the lessons of the refactor to the pack. Then the next project with the same goal starts with those lessons.

### Files that the kit writes into the project

```
<refactor folder>/          default: docs/refactor/
  GOAL.md                   what the refactor changes
  PRINCIPLES.md             how the code is written: audience, targets, limits, priority
  SUCCESS_CRITERIA.md       optional: measures with baseline and result
  PLAN.md                   the plan, the findings, the progress (written by the plan action)
  BEFORE_AFTER.md           the modules before and after, with key numbers (written by the final action)
CONTRIBUTING.md               gates, rules, codebase map, parallel-work guide (final action)
.claude/skills/project-conventions/SKILL.md   stack, commands, settings, short rules
.claude/agents/refactorer.md                  does one plan step
.claude/agents/reviewer.md                    reviews a diff, never edits
.claude/agents/simplifier.md                  optional: simplifies one step
.claude/agents/docs.md                        optional: writes the documentation
.claude/agents/mapper.md, test-writer.md      parallel mode only
<refactor folder>/scripts/wave-*.sh           parallel mode only
```

The agents are generic. They read the project-conventions skill for the refactor folder, the audience, and the rules. Thus, the same agent files work in each project.

---

## Contents of this kit

| Path | Purpose |
|---|---|
| `SKILL.md` | The entry point. Finds the state and selects the action. |
| `workflow/00-setup.md` … `05-final-review.md` | The instructions for each action. The skill reads only the file of the current action. |
| `catalog/principles.md` | The menu of audience profiles, target modules, limits (hard or guideline), the default priority, and the verified-exception process. |
| `catalog/languages.md` | Language profiles: lint rules, documentation style, exception syntax, and measure notes. Rust and Bash are included. |
| `workflow/library.md`, `templates/PACK.md` | The draft library: how to save, find, and reuse goal packs. |
| `library/` | Goal packs that come with the kit (empty for now). |
| `workflow/parallel.md`, `reference/parallel-rules.md` | Parallel mode: how each action runs as waves, and the rules for waves, file ownership, and merges. |
| `templates/scripts/` | The wave scripts that the setup writes into a project in parallel mode. |
| `templates/` | The templates of the project files and the agents. |
| `examples/goal-distro-agnostic.md` | An example of a completed goal. |

## Change the kit

- **Add a principle module:** add a section to `catalog/principles.md` in Part B. Give it an ID and mark it as default or optional. The setup then offers it.
- **Add an audience profile:** add a section in Part A. Give the reader, the audience test, and the rules.
- **Add a language profile:** add a section to `catalog/languages.md`. Use the fields in "Other languages".
- **Change an agent:** edit `templates/agents/`. Projects that already have the agent keep their copy. Run `/refactor-kit setup` in a project to write the agents again.
