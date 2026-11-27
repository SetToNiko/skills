# Refactor Principles: {{PROJECT_NAME}}

<!-- The refactor-kit setup wrote this file from kit:catalog/principles.md. You can edit it. Run /refactor-kit setup to do the interview again. -->

These principles set HOW the refactor writes the code. `GOAL.md` sets WHAT the refactor changes.
- A principle never justifies work outside the goal scope.
- The goal never justifies a loss of correctness, or code that fails the audience test.

## 1. Audience: {{AUDIENCE_NAME}}

{{AUDIENCE_MODULE: the selected profile, with the words of the language profile}}

## 2. Targets

{{TARGET_MODULES: the selected modules. A changed module has "(changed for this project: <what>)" in its heading.}}

## 3. Limits

| Limit | Value | Kind | Later target |
|---|---|---|---|
{{LIMIT_ROWS: one row for each limit. Kind: hard or guideline.}}

Each line limit counts lines of code only. Empty lines and comment lines (doc comments too) do not count. A line with code and a comment counts as one line. Use empty lines and comments to group the code by purpose: a limit is never a reason to remove them.

### Verified exceptions

{{EXCEPTIONS: copy Part E of the catalog if a limit is a guideline or a lint permits exceptions. Use the marker name that the user approved. Otherwise write "None. All limits are hard."}}

## 4. Priority

If targets conflict, use this order:

{{PRIORITY_LIST}}

A simpler design that is slightly less "pure" is better than a textbook pattern that the audience cannot follow.

## 5. Project rules

{{PROJECT_RULES}}
