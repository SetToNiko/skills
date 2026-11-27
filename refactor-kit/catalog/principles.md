# Principles Catalog

Back to `kit:workflow/00-setup.md`, part 4.

This catalog has modules. The setup selects modules for one project and copies them into `<refactor folder>/PRINCIPLES.md`. Each module has an ID.

The setup changes the text of a module only in these cases:
- It replaces the limit placeholders with the approved values.
- It applies the words of the language profile (`kit:catalog/languages.md`).
- The user asks for a change. Then the heading of the module gets "(changed for this project: <what>)".

The modules are **targets, not rules to apply without thought**. Make a change only if it makes the code easier to read, change, or extend *in this project*.

---

# Part A: Audience profiles (select ONE)

The audience profile defines the **audience test**. The refactorer applies it to each change. The reviewer reports each change that fails it. The audience test has a higher priority than all other checks, except correctness.

## A1: Beginner

Use this profile when a beginner programmer will maintain the code. Examples: a learning project, a hobby project, a team with junior members.

**The reader:**
- knows the basics of the language: variables, functions, classes, loops, collections, and simple interfaces
- can read a stack trace
- possibly does *not* know design patterns by name, advanced generics, reflection, annotation behavior, DI frameworks, async internals, long functional chains, or metaprogramming

**The audience test:** without help from another person, can the reader do these three things?
1. Open the file.
2. Understand what the file does and why, in a few minutes.
3. Make a small change safely.

**Rules:**
- **Advanced techniques need an explanation.** The refactorer can use a pattern, a generic, or a language feature above beginner level when it gives a clear benefit. In that case, the refactorer must:
  1. Hide the technique behind a simple interface with a plain name.
  2. Add a short comment at that location. The comment gives the name of the technique, the reason for it, and how to work with it. Example: `// Strategy pattern: each AttackType has its own class, so you can add new types without a change to this file. To add one: ...`
  3. List the technique in the glossary "Concepts used in this codebase" in ARCHITECTURE.md.
- **Few layers of indirection.** To understand one behavior, a reader follows a maximum of `{{MAX_JUMPS}}` jumps of the type interface → implementation → delegate.
- **Explicit code, not clever code.** A plain `for` loop is better than a dense chain of 5 functional operators. A named variable is better than a nested expression. A simple `if` is better than a ternary in a lambda.
- **Clear structure.** Folder names and file names tell the reader where to look. Use names such as `battle/` and `save/`, not `core/impl/internal/`.
- **Comments give the intent.** Each public class has a one-line comment that gives its purpose. Logic that is not obvious has a comment that gives the reason.
- **Each implicit framework behavior has a pointer.** If behavior occurs implicitly (annotations, DI wiring, reflection, generated code), add a comment that gives the location of the wiring.
- **Documentation.** The docs use plain language. ARCHITECTURE.md has a "How to read this codebase" guide and a glossary of each advanced concept.

## A2: Mixed team

Use this profile when developers with different levels of experience maintain the code. Examples: a product team, an open-source project with occasional contributors.

**The reader:** knows the language well and knows common design patterns. Possibly does not know this project, its domain, or the less common features of the language.

**The audience test:** can a new team member find the code for a behavior, understand it, and change it safely in their first week?

**Rules:**
- Use common patterns freely. Add a comment for a technique that is uncommon in this language or this team.
- To understand one behavior, a reader follows a maximum of `{{MAX_JUMPS}}` jumps.
- Prefer explicit code over clever code when the two have the same length.
- Each module has a one-paragraph comment or README that gives its responsibility.
- Each implicit framework behavior has a comment that gives the location of the wiring.
- ARCHITECTURE.md describes the modules, the dependency direction, and the extension points.

## A3: Experienced maintainers

Use this profile when a small group of experienced developers maintains the code. Examples: a library with a core team, a personal tool of an expert.

**The reader:** knows the language, its idioms, and this project. Possibly does not remember why someone made a decision.

**The audience test:** can a maintainer who did not write the code change it safely after a short read?

**Rules:**
- Use the idioms of the language. Do not explain them.
- Comments give the reason for decisions that are not obvious. Comments never repeat what the code says.
- Each public API has a doc comment.
- Record each important design decision in a short note: in ARCHITECTURE.md or in an ADR.

---

# Part B: Target modules (select one or more)

Modules marked **default** fit most refactors. The others are optional.

## T1: SOLID (default)

| Principle | Target | Sign of a violation |
|---|---|---|
| **S**ingle Responsibility | Each class or module has one reason to change | "Manager" or "Util" classes, files that mix UI, logic, and I/O, functions with "and" in their description |
| **O**pen/Closed | You add new behavior with new code, not with changes to existing code | `when`, `switch`, or `if-else` chains on a type or kind that grow with each feature |
| **L**iskov Substitution | A subtype works at each location where the code expects the parent type | Overrides that throw "not supported", `instanceof` checks on subtypes |
| **I**nterface Segregation | Interfaces are small and focused. Clients depend only on the methods that they use | Interfaces with many methods, where implementations leave some methods empty |
| **D**ependency Inversion | High-level logic depends on abstractions. Callers inject the concrete classes | `new ConcreteThing()` in business logic, static singletons, hardcoded database or network calls in logic |

## T2: Data-driven design (default)

Move *variation* out of the code and into *data*.
- **Data controls behavior, not branches.** Replace long conditionals on kinds or types with a lookup table, a registry, or a configuration.
- **Keep data separate from logic.** Put constants, rules, content, and tuning values in data structures or configuration files.
- **Model the domain explicitly.** Use typed data classes or records. Do not use loose maps, tuples, or parallel arrays.
- **Single source of truth.** Define each piece of data one time.
- **Keep the completeness check.** A `match` on an enum fails to compile when a variant is missing. A table does not. When a table replaces such a `match`, keep one exhaustive check. Example: a `match` with no default arm that lists each variant. A test that gets the variants from another source is also good. A test that loops over the table cannot find a missing row.
- **Use evidence to set priorities.** Churn, file size, duplication, bug history, and test coverage show where to start.

## T3: Readability (default)

- Names tell *what* and *why*, not *how*. Example: `calculateDamage`, not `doCalc2`.
- Each function does one thing. Limit: `{{MAX_FUNCTION_LINES}}` lines of code (Part C).
- **Group the code by purpose.** Put the lines that do one task together, and put one empty line between two groups. In a file, put related items next to each other, for example a type and then its functions. A short comment above a group can give its purpose. Empty lines and comments do not count toward a line limit (Part C), so a limit is never a reason to remove them.
- Shallow nesting: use early returns and guard clauses. Limit: `{{MAX_NESTING}}` levels.
- No magic numbers or strings: use named constants or data.
- Comments tell *why*. The code tells *what*. Remove commented-out code.
- Formatting and patterns are consistent across the codebase.

## T4: Maintainability (default)

- **DRY, but not too early.** Extract duplicate code at the third occurrence, or when the copies must change together.
- **Small units.** Limit: files of `{{MAX_FILE_LINES}}` lines of code or fewer (Part C).
- **Low coupling, high cohesion.** Related code is in the same location. Modules communicate through narrow interfaces.
- **Testability.** You can test logic without a UI, network, or database.
- **No dead code.** Remove unused functions, flags, and parameters.
- **Explicit errors.** Handle or propagate each failure on purpose. Never ignore a failure silently.

## T5: Modularity (default)

- Each module has a clear boundary and a defined public API. Its internals are private.
- Dependencies go in one direction, for example UI → domain → data. There are no cycles.
- You can understand, test, and replace a module independently.
- The folder structure follows features or layers consistently.

## T6: Extensibility (default)

- **Extension points** exist where variation is expected: interfaces, registries, plugin hooks, and configuration.
- To add a new variant, you **add a file or a data entry**. You do not edit many existing files.
- Use composition, not inheritance, where possible.
- **YAGNI:** add extension points only where the plan or the history shows real variation.

## T7: Error handling (optional)

Use this module when failures are frequent or difficult to diagnose.
- Each error message says what failed, with which input, and what the user can do.
- Errors keep their cause. Do not replace a detailed error with a general error.
- One location per layer converts low-level errors into domain errors.
- Expected failures (bad input, missing file) use the normal error type of the language, not a crash.

## T8: Performance (optional)

Use this module when speed or memory use is part of the goal, or when the refactor must not make it worse.
- Measure before and after each step that touches a hot path. Record the numbers in the plan.
- A refactor step must not make a measured hot path slower than `{{MAX_SLOWDOWN}}`.
- Prefer the simple version. Add an optimization only with a measurement that proves its benefit.

## T9: Security (optional)

Use this module when the code handles untrusted input, secrets, or privileges.
- Check untrusted input at the boundary, one time.
- Secrets never appear in code, logs, or error messages.
- Shell commands, SQL, and paths use safe APIs, not string concatenation.
- Use the smallest privileges that work.

---

# Part C: Limits

The setup copies this table with the values that the user approves. Each limit has a kind:
- **hard:** code over the limit is a finding. The reviewer reports it.
- **guideline:** code over the limit needs a reason comment. The reason goes through the verified-exception process of Part E.

A limit can also have a **later target**. Use it when the code is far over the default today. Example: 27 of 35 files are over 300 lines. Then the value for this refactor is 500, and the later target is 300.

| Limit | Default value | Default kind | Placeholder |
|---|---|---|---|
| Jumps of indirection to understand one behavior | 3 | hard | `{{MAX_JUMPS}}` |
| Lines of code in one function | 30 | guideline | `{{MAX_FUNCTION_LINES}}` |
| Levels of nesting | 3 | hard | `{{MAX_NESTING}}` |
| Lines of code in one file | 300 | hard | `{{MAX_FILE_LINES}}` |
| Slowdown of a hot path (T8 only) | 5% | hard | `{{MAX_SLOWDOWN}}` |

**Lines of code (the definition for each line limit).** A line limit counts only lines of code. A line of code is a line that has code on it. These lines do not count:
- empty lines, and lines with only spaces or tabs
- lines with only a comment: line comments, doc comments (for example `//`, `///`, `//!`, `#`), and each line of a block comment

A line with code and a comment at its end counts as one line of code. Function length counts the lines of code in the body, between the braces. It does not count the signature or the closing brace. (clippy's `too_many_lines` also ignores empty lines and comments.)

Empty lines and comments are free, so a limit is never a reason to remove them. Use them to group the code by purpose (T3). Measure with a tool that counts lines of code, for example `lizard` (the NLOC column) or `tokei` (the Code column). The language profiles give the commands.

When a module text says "Limit: `{{...}}`", write the kind with the value. Examples:
- hard: "Limit: 4 levels."
- guideline: "Guideline: 30 lines. Longer only with a verified reason (section 3)."
- with a later target: "Limit: 500 lines. Later target: 300."

---

# Part D: Default priority

If targets conflict, use this order:

1. **Correctness:** the behavior stays the same. Tests prove it.
2. **Audience test:** the code passes the audience test of the selected profile.
3. **Readability:** an experienced reader understands the code quickly.
4. **Maintainability and modularity:** changes stay local.
5. **Extensibility:** only where variation is real.

Put T7, T8, and T9 into this order where the user wants them. Security usually comes directly after correctness.

A simpler design that is slightly less "pure" is better than a textbook pattern that the audience cannot follow.

---

# Part E: Verified exceptions

Use this process for each limit of the kind "guideline", and for each lint that a project rule permits with a reason. It lets a reasoned exception stay without a new discussion in each review.

1. **The refactorer writes a reason.** Code over a guideline gets a reason comment directly above it. Use this form:
   `<comment> Exception (<limit>): <reason>.`
   Example in Rust: `// Exception (function length): one match over all 14 key actions. Splitting it hides the mapping.`
   If a lint also reports the exception, use the exception syntax of the language profile. Example: `#[expect(clippy::too_many_lines, reason = "...")]`.
2. **The reviewer checks the reason.** It reports one of these results:
   - **verified:** the reason is true and specific. Dividing the code would make it harder for the audience to read.
   - **finding:** the reason is missing, vague, or false. The finding gives a proposal to divide the code.
3. **The review action adds the marker.** For each verified exception, it changes the comment to:
   `<comment> Exception (<limit>, reason verified, phase <N>): <reason>.`
   The reviewer never edits files. Thus, the review action writes the marker.
4. **Later reviews accept a verified exception.** They check it again only in these cases:
   - **An architecture rewrite:** a plan step or a phase whose stated purpose is to restructure the module that contains the exception.
   - **The code grows:** the code is longer or deeper than at the verification. Then the reviewer checks the reason again.
   - **The reason is no longer true.** Example: the 14 key actions became data.

The setup can give the marker a project-specific name. Example: "Long function" in place of "Exception (function length)". The name must be the same everywhere in the project.
