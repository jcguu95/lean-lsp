---
name: lean-lsp
description: A client/server wrapper for the Lean Language Server.
metadata:
  tool: bin/lean-lsp
  domain: lean
---
## What I do
- Acts as a client/server wrapper around the real Lean LSP server (`lake serve`).
- Manages a daemon process for the LSP server on a host machine.
- Provides a simple TCP interface for clients (e.g., in Docker) to send LSP requests.
- Handles path mapping between client and server filesystems.

## When to use me
Use this skill when you are in an environment (like a Docker container) that is separate from the machine running the Lean LSP server. It allows you to query goals, diagnostics, and hover information from a Lean project.

## Commands
All commands use `./bin/lean-lsp`.

### Server Commands (run on the host)
- Start the daemon:
  - `cd /path/to/lean/project && ../bin/lean-lsp start --host 0.0.0.0`
- Check daemon status:
  - `./bin/lean-lsp check --host <host>`
- Stop the daemon:
  - `./bin/lean-lsp stop --host <host>`

### Client Commands (run by the agent, e.g., in Docker)
These commands require `--host`, and usually path mapping flags.

- Hover info:
  - `./bin/lean-lsp hover --host <host> --map-root-from <client_path> --map-root-to <host_path> <file> <line> <col>`
- Plain goal:
  - `./bin/lean-lsp plain-goal --host <host> --map-root-from <client_path> --map-root-to <host_path> <file> <line> <col>`
- Diagnostics at a position:
  - `./bin/lean-lsp diagnostics --host <host> --map-root-from <client_path> --map-root-to <host_path> <file> <line> <col>`
- All of the above:
  - `./bin/lean-lsp all --host <host> --map-root-from <client_path> --map-root-to <host_path> <file> <line> <col>`
- Raw LSP request:
  - `./bin/lean-lsp request --host <host> --method <method> --params <json>`

## Notes
- **This is not the LSP server itself.** It's a wrapper.
- The server (`start` command) must be running on the host machine from within a Lean project directory.
- The client (e.g., `hover` command) is run by the agent, typically from the repository root.
- The client must provide the correct hostname (`host.docker.internal` for Docker) and path mappings to translate file paths between the client's and server's filesystems.
