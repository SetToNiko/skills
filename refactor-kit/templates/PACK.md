---
name: {{SLUG}}
goal: {{GOAL: the goal in one sentence, without project names}}
tags: [{{TAGS: 3 to 6 words that describe the goal. Examples: maintainability, junior-readable, data-driven, remove-dependency}}]
languages: [{{LANGUAGES: the main languages of the source projects}}]
sources: [{{SOURCES: the project names that used this pack, and the date of each}}]
---
# Goal pack: {{SLUG}}

<!--
The refactor-kit setup wrote this file. It is a reusable draft, not the files of one project.
<<slot: ...>> marks a project fact. The setup fills it from the scan of the new project.
A pack never contains measured values.
-->

## Goal
{{GOAL_DRAFT: the goal and the reason, with slots for project facts}}

## Success criteria
{{CRITERIA: the criteria, with slots. Example: "No code outside <<slot: the module that owns system paths>> contains a hard-coded system path."}}

## Scope rules
{{SCOPE: the rules for scope. Example: "Name each known later project as out of scope."}}

## New behavior
{{NEW_BEHAVIOR: "No, pure refactor." OR the feature phases, with slots}}

## Constraints
{{CONSTRAINTS}}

## Verification
{{VERIFICATION: the kinds of checks, with slots for commands}}

## Principles
- Audience: {{AUDIENCE}}
- Targets: {{TARGETS: the IDs, and each change to a module text}}
- Priority: {{PRIORITY}}
- Limits: {{LIMITS: each limit with its value, kind, and later target}}
- Exceptions: {{EXCEPTIONS: the marker name and the process, or "none"}}
- Project rules: {{PROJECT_RULES: with slots}}

## Language decisions
{{LANGUAGE_DECISIONS: for each language: the lint groups, the lint policy, the documentation style, and each change to the profile defaults}}

## Success-criteria rows
| Criterion | How to measure |
|---|---|
{{ROWS: one row for each criterion, with slots. No baselines.}}

## Workflow settings
{{SETTINGS: the refactor folder, the commit policy, the models, the simplify step, the documentation, the step size, and the execution mode}}

## Lessons
{{LESSONS: one or two sentences for each lesson, with the source project. Or "None yet."}}
