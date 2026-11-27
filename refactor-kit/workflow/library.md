# Draft library

Back to `kit:SKILL.md`.

The draft library keeps the decisions of earlier setups as **goal packs**. A new project with a similar goal starts from a pack. Then the setup asks fewer questions, and projects with the same goal follow the same rules.

## Location

- User library: `~/.claude/refactor-kit/library/`. The setup writes packs here. A new install of the kit does not change this folder.
- Kit library: `kit:library/`. Packs that come with the kit. The setup reads them, but never changes them.

Each pack is one file: `<slug>.md`. The slug is a short name of the goal, for example `junior-readable-maintainability`. Template: `kit:templates/PACK.md`.

## What a pack contains, and what it does not contain

A pack contains decisions that are true for each project with this goal:
- the goal, the reason, the success criteria, the scope rules, the new-behavior rules, the constraints, and the verification steps, with **slots** for project facts
- the audience profile, the targets, the priority, the limits with their kinds, the exception markers, and the project rules
- the language-profile decisions, for example the lint policy
- the success-criteria rows: the criterion and the measure command, with slots
- the workflow settings
- lessons from earlier refactors with this goal

A pack never contains:
- baselines or other measured values
- file names, paths, line numbers, commit counts, or tool versions of one project. Replace each with a slot.
- secrets, user names, or private URLs

**Slot format:** `<<slot: description>>`. Example: `<<slot: the module that owns all system paths, for example src/paths.rs>>`. The setup fills each slot from the scan of the new project, or asks the user.

## Use a pack (setup, part 3)

1. Ask topic 1 of part 3: the goal, in one or two sentences.
2. Read the frontmatter of each pack in the user library and the kit library. Compare the `goal` and `tags` fields with the goal of the user. Also compare `languages` with the languages of the scan.
3. If one or more packs are similar, ask with AskUserQuestion. Show the 3 most similar packs and "Start fresh". For each pack, give the name, the goal in one line, and the source projects. Recommend the most similar pack.
4. If the user selects a pack, use it as a draft for parts 3 to 6, like an old file:
   - For each section, show the pack content in a short form. Ask the user to approve it or to change it.
   - Fill each slot from the scan. If the scan cannot fill a slot, ask the user.
   - Measure each baseline again. Never copy a value from the pack.
   - Show the "Lessons" of the pack in part 3. Apply a lesson only after the user approves it.
5. Record the slug of the pack in GOAL.md: `Draft pack: <slug>`.

## Save a pack (setup, part 7, and the final action)

**After the setup (part 7, after the commit):** ask with AskUserQuestion:
- **Save as a new pack (Recommended)** if no pack was used
- **Update the pack `<slug>`** if a pack was used and the user changed some decisions
- **Do not save**

To save:
1. Copy the decisions of the approved files into the pack template.
2. Replace each project fact with a slot. Remove each measured value.
3. Show the pack to the user. Point out each slot. Ask if a decision is specific to this project. If it is, replace it with a slot or remove it.
4. Write the pack to the user library after approval. Then add the line `Draft pack: <slug>` to GOAL.md, so the final action can add lessons to the pack. Commit, if the Commits setting permits it.
5. If you update a pack, keep its lessons. Add this project to `sources`. If the user changed a decision, ask: change it in the pack for all later projects, or keep the old decision?

**After the final action:** if GOAL.md has a `Draft pack:` line, offer to add lessons to that pack. A lesson is one or two sentences. Example: "Add clippy to the dev shell before the first step. A system clippy fails with E0514." Ask the user to approve each lesson.

## The action library

The argument `library` lists the packs in both libraries: the slug, the goal in one line, the languages, and the sources. Then ask what the user wants:
- **Show a pack:** show its full text.
- **Remove a pack:** only from the user library. Ask before you remove it.
- **Rename a pack:** change its file name and its `name` field.
Do not change a pack in the kit library.
