# lean-lsp

A client/server wrapper for the Lean Language Server.

The `lean-lsp` script acts as a client/server wrapper for the actual Lean Language Server Protocol (LSP) server (`lake serve`). It starts the LSP server as a daemon on the host and exposes a simple TCP socket interface. This allows a client on a different machine or in a container to send requests to the LSP server.

## Prerequisites

`lean-lsp` is a wrapper and requires a working Lean installation managed by `elan`. You must have `elan` and `lake` installed and available in your `PATH`.

## Usage

The `./bin/lean-lsp` script can be run as a server (on the host machine) or as a client.

### Server Commands
The server must be run from within a Lean project directory.

- **Start the server daemon:**
  ```bash
  ./bin/lean-lsp start --host 0.0.0.0
  ```
- **Check server status:**
  ```bash
  ./bin/lean-lsp check --host <host>
  ```
- **Stop the server:**
  ```bash
  ./bin/lean-lsp stop --host <host>
  ```

### Client Commands
Client commands connect to the running server to send LSP requests. When the client and server are on different filesystems (e.g., Docker and host), you must provide path mappings.

- **Hover info:**
  ```bash
  ./bin/lean-lsp hover --host <host> --map-root-from <client_path> --map-root-to <host_path> <file> <line> <col>
  ```
- **Get plain goal:**
  ```bash
  ./bin/lean-lsp plain-goal --host <host> --map-root-from <client_path> --map-root-to <host_path> <file> <line> <col>
  ```
- **Get diagnostics:**
  ```bash
  ./bin/lean-lsp diagnostics --host <host> --map-root-from <client_path> --map-root-to <host_path> <file> <line> <col>
  ```
- **Get all of the above:**
  ```bash
  ./bin/lean-lsp all --host <host> --map-root-from <client_path> --map-root-to <host_path> <file> <line> <col>
  ```
- **Send a raw LSP request:**
  ```bash
  ./bin/lean-lsp request --host <host> --method <method> --params <json>
  ```

### Notes & Tips
- **This is not the LSP server itself.** It's a wrapper around `lake serve`.
- The server (`start` command) must be running from within a Lean project directory.
- The client commands are typically run from the repository root because the examples use relative paths (e.g. `./bin/lean-lsp`).
- **Tip:** The `agent/` directory contains a complete Docker-based setup for a development environment with Aider, Lean, `mathlib`, and `lean-lsp`. See [`agent/README.md`](./agent/README.md) for details.
- **Tip:** For instructions on how to install Lean and verify your setup, see the [Installation and Setup Guide](./docs/INSTALLATION.md).
