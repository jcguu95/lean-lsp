# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Added path mapping flags (`--map-root-from`, `--map-root-to`) to support client/server running on different filesystems (e.g. Docker container and host).

### Changed
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
