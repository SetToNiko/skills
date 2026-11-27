# Language Profiles

Back to `kit:workflow/00-setup.md`, part 5.

A language profile gives the default lint rules, documentation style, exception syntax, and measure notes for one language. The setup shows the defaults to the user. The user accepts or changes each one. The result goes into the project-conventions skill and into PRINCIPLES.md.

If a project uses more than one language, use one profile for each main language.

If no profile exists for a language, ask the user for each field of the profile. Offer to add the new profile to this file after the setup.

---

## Rust

**Words for the audience module.** Apply these words when you copy an audience profile into PRINCIPLES.md:

| Catalog word | Rust word |
|---|---|
| class | type (struct or enum) |
| interface | trait |
| subtype | type that implements the trait |
| annotation | attribute or derive macro |
| DI framework, injection | passing a value or a trait object into a function or constructor |
| reflection, metaprogramming | macros, `build.rs`, and procedural macros |
| advanced generics | generics with trait bounds, associated types, lifetimes in signatures |

Example comment for an advanced technique: `// Trait object: each app integration is a type that implements AppIntegration, so you can add a new app without a change to this file. To add one: ...`

**Lint (default).**
- Clippy groups: `pedantic`, `style`, and `correctness`. `style` and `correctness` are on by default. Enable `pedantic` in `Cargo.toml`:
  ```toml
  [lints.clippy]
  pedantic = { level = "warn", priority = -1 }
  ```
- Lint command: `cargo clippy --all-targets -- -D warnings`
- Measure command: `cargo clippy --all-targets -- -W clippy::pedantic -W clippy::style -W clippy::correctness`. Count the warnings in the "generated N warnings" line of the main target.
- Format: `cargo fmt --check`
- Policy if the code has many warnings today: ratchet to zero (recommended). The functions that a step writes or changes have no warnings, and the total never increases. A late phase makes whole files clean. (Do not ask each step to clean whole files: a one-line change in a file with 50 warnings becomes a large step.)
- The count script must give 0 when the tool reports nothing. Many tools print no summary line when there are no warnings, and a `grep` for that line then fails. With `set -o pipefail`, for example in a Nix build, the check fails at the exact moment that the count reaches zero. Test the script with a clean file before the ratchet starts.
- Add a gate for each limit of Part C, not only for the lints. Example: a script that fails when a file has more than the file limit of production lines of code. It counts as Part C says: no empty lines, no comment lines. Without a gate, later steps add helpers and doc comments, and files grow over the limit again. The final review then finds them.
- In a binary crate, clippy does not check `missing_errors_doc` and `missing_panics_doc`: these lints check only the public interface of a library. If the project requires `# Errors` sections, add a small check script for them, or the final review finds them missing.

**Documentation style (default: strict rustdoc).**
- Each file starts with `//!`: a one-line purpose, then details.
- Each item has `///`. The first line is a one-sentence summary. Details come after an empty line.
- Sections:
  - `# Errors` on each function that returns `Result`
  - `# Panics` on each function that can panic
  - `# Safety` on each `unsafe` function
  - `# Examples` where the use is not obvious
- Backticks for code. Intra-doc links (`[`Type`]`) for types and functions.
- Check: `RUSTDOCFLAGS="-D warnings" cargo doc --no-deps --document-private-items`

**Exception syntax.** For a verified exception that a lint also reports, use the lint attribute with a reason. The compiler then reports the attribute when the exception is no longer necessary.
- `#[expect(clippy::too_many_lines, reason = "...")]`
- Never use `#[allow(...)]` without a `reason`.

**Measure notes.**
- `cargo test` captures the output of passing tests. To count printed lines (for example "skipped:"), run `cargo test -- --nocapture`.
- Count ignored tests in the "test result" line: `N ignored`.
- `cargo clippy` must use the clippy of the project toolchain. A system clippy for a different rustc fails with error E0514 ("compiled by an incompatible version of rustc"). Then the tool is not available. Phase 0 adds clippy to the toolchain or the dev shell.
- Function length and complexity: `lizard -l rust` (Python package `lizard`). Use the NLOC column: it counts lines of code without empty lines and comments. The `length` column counts all lines.
- File length in lines of code: `tokei <file>` (the Code column). A script also works: skip empty lines, lines that start with `//`, and the lines of `/* ... */` blocks.
- Dependency cycles between modules: `cargo modules dependencies --acyclic` sees only `use` statements, not inline paths such as `crate::hit::HitMap`, and it stops at the first cycle. Count the cycles with a small script: read `crate::<module>` in the production code of each file (before `#[cfg(test)]`) and count the strongly connected groups. Keep the script in the project, so later ratchets use the same method. Name each module by its full module path (`app/state/nav.rs` is `app::state::nav`, `mod.rs` takes its folder path), and read subfolders too. A reference counts for the longest known module path that it starts with. Do not count visibility paths such as `pub(in crate::app)`: they are not dependencies. Then two files with the same name stay apart, and a move into a folder does not add false cycles.
- Coverage: `cargo llvm-cov --summary-only`. It needs the `llvm-cov` and `llvm-profdata` of the LLVM that rustc uses. In a Nix dev shell: `LLVM_COV = "${pkgs.rustc.llvm}/bin/llvm-cov"` and `LLVM_PROFDATA` in the same way.
- Duplicates: `lizard -Eduplicate` (jscpd is not always packaged).
- Data tests in a build sandbox: tests that read the real data skip there. Add a test-only helper that returns the real data folder if it exists, else a fixtures folder in the crate (for example `tests/fixtures/data`). Add the fixtures folder to the package source. Then the sandbox runs the data tests, and a developer machine still tests the real data.

**Tools that are usually missing.** clippy, rustfmt, cargo-modules (dependency cycles), cargo-llvm-cov (coverage). If the scan shows one as not available, the plan adds it in Phase 0.

---

## Bash

**Lint (default).**
- `shellcheck` on each script. Lint command: `shellcheck <scripts>`
- Measure command: `shellcheck -f gcc <scripts> | wc -l`
- Policy: changed scripts pass shellcheck. The total never increases.

**Documentation style (default).**
- Each script starts with a comment block: the purpose, the usage, and the environment variables that it reads.
- Each function has a one-line comment above it that gives its purpose.

**Exception syntax.** `# shellcheck disable=SCxxxx  # reason: ...` on the line above. Never disable a check without a reason.

**Measure notes.**
- `set -euo pipefail` changes behavior. Adding it is a plan step with golden-file tests, not a convention.
- Function length: `lizard -l bash` (the NLOC column). File length: `tokei <file>` (the Code column). A script skips empty lines and lines that start with `#`, but not the `#!` line.

**Golden-file tests for scripts.** Characterization tests for scripts that write config files and start programs:
- Run each case in a temporary HOME, with copies of the fixture data. Compare the files under HOME, a log of the stub calls, stderr, and the exit code with golden files (`diff -r`). A `--update` mode writes the golden files from the unchanged scripts.
- Build the PATH from links to the real tools that the scripts need (bash, jq, awk, sed, ...) and stub commands for the desktop programs. Then a real program of the machine cannot leak into the result.
- Write the stubs with the full path of bash on the first line. A Nix build sandbox has no `/usr/bin/env`.
- Wait for the background jobs of the script (`cmd &`): give the run an extra file descriptor that points into a pipe, for example `( ... ) 9>&1 | cat > /dev/null`. The pipeline ends only when the last process that holds it ends.
- Remove empty folders from each result. git does not store empty folders, so the golden files have none.
- Replace the temporary paths in the outputs with fixed words, for example `<HOME>`.
- Run the cases several times. A result that changes between runs is a test bug.

---

## Other languages (fields to ask for)

- Words for the audience module, if the catalog words do not fit the language
- Lint tool, lint groups, lint command, and measure command
- Format check
- Documentation style and its check command
- Exception syntax, with a reason
- Measure notes: tools that hide output, tools that must match the toolchain
