# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-09

### Added
- `README.md` documenting the architecture for interacting with LEAN from within a Docker container via a TCP socket.
- `CHANGELOG.md` to track changes to the project.

### Changed
- `lean-lsp` now uses TCP sockets instead of Unix sockets. This allows a client in a Docker container to communicate with a server running on the host machine.
- Replaced `--socket` argument with `--host` and `--port`.
- The `lean-lsp` script now has explicit client and server commands, and no longer auto-starts the daemon.
- Updated `README.md` with instructions for running the server and client.
