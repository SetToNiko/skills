# Before and after: {{PROJECT_NAME}}

<!-- The refactor-kit final action wrote this file. "Before" comes from section 2 of PLAN.md. "After" comes from the code at the end of the refactor. -->

Goal: {{GOAL: one line from GOAL.md}}

## Key numbers

| Measure | Before | After |
|---|---|---|
| Modules | {{n}} | {{n}} |
| Source lines | {{n}} | {{n}} |
| Files over the file limit | {{n}} | {{n}} |
| Largest file | {{path, lines}} | {{path, lines}} |
| Dependency cycles | {{n}} | {{n}} |

## Before

| Module | Purpose | Responsibilities | Became |
|---|---|---|---|
| {{path}} | {{one line}} | {{the things it did}} | {{the new module or modules, or "unchanged", or "removed"}} |

## After

| Module | Purpose | Responsibilities | Came from |
|---|---|---|---|
| {{path}} | {{one line}} | {{the things it does}} | {{the old module or modules, or "new"}} |

## In short
{{3 to 5 sentences: what moved where, and what is now easier. Example: "To add an app integration, you now add one entry to share/integrations.json and one generator file."}}
