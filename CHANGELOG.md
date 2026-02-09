# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Moved `lean-lsp` and `test.sh` scripts into a `bin/` directory for better organization.
- Updated `project-1/test.sh` to verify proofs by building and checking for `sorry`, instead of using LSP hover commands.
- Refactored the main `test.sh` to be minimal and only test `example-project`.

### Added
- Created `project-1/test.sh` for a dedicated project-1 test suite.

### Fixed
- Scoped the `sorry` check in `project-1/test.sh` to only search project source files, not dependencies.
- Corrected relative paths to `lean-lsp` in `project-1/test.sh`.
- Restructured `project-1` to follow standard Lean library layout, fixing LSP analysis issues.
- Removed debug output from `test.sh`.

## [0.5.1] - 2026-02-09

### Fixed
- Corrected the line and column numbers in `test.sh` for the `project-1` hover query to correctly target the theorem name.

### Changed
- Updated `SKILL.md` to reflect the current TCP-based client/server architecture.
- Clarified the role of the `lean-lsp` script as a wrapper for the Lean LSP server in `README.md` and the script's docstring.
- Updated `test.sh` to set up and run tests against both `example-project` and `project-1`.

### Added
- Created `project-1` and completed the proof for `sum_of_first_n_odd_numbers`.

## [0.5.0] - 2026-02-09

This release establishes a stable, verifiable client-server architecture for interacting with the Lean LSP. The primary focus has been on creating a robust development and testing workflow that allows an agent within a Docker container to communicate with a Lean server running on the host machine.

The next phase of development (v0.5.x) will focus on leveraging this setup for the agent to begin writing and querying real proofs in Lean.

### Added
- Added a Docker-based test to `test.sh` to simulate and verify the agent's environment.
- Added `test.sh` for a "one-click" verification of the client-server setup.

### Changed
- Restructured `README.md` to guide new users to the verification script and document the full agent workflow.
- Aligned `test.sh` Docker command with the user's specific `lean-aider` environment.

### Fixed
- Fixed Docker test by overriding the container's entrypoint to correctly execute `lean-lsp`.
- Updated `test.sh` to run a host-only test by default, removing the need for Docker-specific hostnames and path configurations.
- Renamed `test-project` to `example-project` and included it in the repository to serve as a ready-to-use test case.

## [0.4.0] - 2026-02-09

### Added
- Achieved stable client-server communication between the agent in a Docker container and the Lean LSP server on the host machine.

### Fixed
- Corrected the `mathlib` import in the test project to point to a specific file (`Prime.Basic`) instead of a directory module.
- Improved path-mapping logic to be more robust by using string operations instead of filesystem-dependent path resolution.

## [0.3.0] - 2026-02-09

### Added
- Added path mapping flags (`--map-root-from`, `--map-root-to`) to support client/server running on different filesystems (e.g. Docker container and host).

### Changed
- Updated the test project to use a standard definition instead of `#check` to get more reliable hover info from the server.
- Updated `README.md` to include a `lake build` step to ensure dependencies are loaded by the server.
- Updated `README.md` with more robust instructions for downloading dependencies and using the `mathlib` cache.
- Updated `README.md` to clarify that client commands must be run from the project root.
- Added `mathlib` as a dependency to the test project.
- Updated test project to import and check a `mathlib` definition.

### Fixed
- Updated `README.md` and `test-project/lakefile.toml` with correct dependency syntax (`[[require]]`) and `mathlib` cache command (`lake exe mathlib/cache get`) based on troubleshooting with Lake v5.0.0.

## [0.2.0] - 2026-02-09

### Added
- Added validation to ensure the `start` command is run from a Lean project directory.
- Added more detailed instructions to `README.md` on how to create a Lean project and run the server from it.
- Added installation instructions for setting up the LEAN toolchain on macOS to `README.md`.
- Added a `--verbose` flag to the `start` command to show daemon logs for debugging.

### Fixed
- The `start` command now provides feedback that it is starting, instead of hanging silently.
- Fixed a bug where the daemon process was spawned with incorrect argument order, causing a crash.

## [0.1.0] - 2026-02-09

### Added
- `README.md` documenting the architecture for interacting with LEAN from within a Docker container via a TCP socket.
- `CHANGELOG.md` to track changes to the project.

### Changed
- `lean-lsp` now uses TCP sockets instead of Unix sockets. This allows a client in a Docker container to communicate with a server running on the host machine.
- Replaced `--socket` argument with `--host` and `--port`.
- The `lean-lsp` script now has explicit client and server commands, and no longer auto-starts the daemon.
- Updated `README.md` with instructions for running the server and client.
