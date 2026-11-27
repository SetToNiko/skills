# Refactor Goal

<!-- Example: change a single-distro Linux project into a distro-agnostic project. -->

## Goal
Make the project work on many Linux distributions, not only on <current distro, for example Arch>. All interaction with the operating system goes through distro-agnostic interfaces. Each distribution has one implementation.

## Reason
OS-specific calls are scattered through the codebase: package manager commands, service management, configuration file paths, and distro detection. Thus, to support another distro, you must edit many files. Each edit can break the project on the current distro.

## Success criteria
- No code outside `os/` (or the agreed module) calls a package manager, an init system, or a hardcoded distro path directly.
- Small interfaces that a beginner can read contain all OS interaction. Examples:
  - `PackageManager` (install, remove, is_installed)
  - `ServiceManager` (enable, start, status)
  - `SystemPaths` (configuration directory and other paths)
  - `DistroInfo` (detect the distro and its version)
- The current distro is only one implementation of those interfaces.
- ONE location selects the active implementation (detection → registry or factory). Where possible, data controls the selection. Example: a table that maps distro IDs from `/etc/os-release` to implementations.
- To add a new distro, you add one implementation file, one registry or configuration entry, and the tests for the implementation. You edit no other files.
- You can test the business logic with fake OS implementations. The tests do not touch the real system.

## Scope
- In scope: each location that runs shell commands, reads or writes system paths, or checks the distro.
- Out of scope: <for example UI, operating systems other than Linux, packaging and distribution of the project>.

## Is new behavior permitted?
Phases 1 to N are a pure refactor. They add the interfaces with the current distro as the ONLY implementation. The behavior must stay identical.
After these phases, a separate **feature phase** adds implementations for: <for example Debian/Ubuntu (apt, systemd), Fedora (dnf, systemd)>. Each implementation is a separate step with its own tests. On a distro without support, the program stops with a clear error message.

## Constraints
- The project must continue to work on <current distro> after each step.
- No new runtime dependencies.
- Use one small interface for each OS concern, not one large "OS" interface. This follows interface segregation and is easier for beginners.

## Verification
- Unit tests: test the business logic with fake implementations of each interface.
- Distro tests: test each implementation on the real distro in a container. Example: `docker run --rm -v "$PWD":/app <distro-image> <test command>`. As a minimum, assert the generated commands in unit tests.
