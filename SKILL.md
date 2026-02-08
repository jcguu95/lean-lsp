---
name: lean-lsp
description: Query Lean goals, diagnostics and other information.
metadata:
  tool: scripts/lean-lsp
  domain: lean
---
## What I do
- Query Lean goals and diagnostics at a 1-based line/column.
- Use the daemon socket to fetch results quickly (auto-starting if needed).
- Provide JSON output when needed for structured processing.

## When to use me
Use this when an agent needs goal state, term goals, or diagnostics from a Lean
file at a specific cursor position.

## Requirements
- `lean` and `lake` must be installed and available in your `PATH`.
- The `lake serve` command is used by default to start the LSP server.
- The recommended way to install Lean and Lake is via the `elan` toolchain manager.
- A base Lean installation is several hundred megabytes. Project dependencies will require additional space.
- For Docker environments, it's recommended to add the `elan` installation to your `Dockerfile` to avoid re-installing on every container start.

## Commands
- Start the daemon:
  - `scripts/lean-lsp start --root .`
- Check daemon status:
  - `scripts/lean-lsp check`
- Stop the daemon:
  - `scripts/lean-lsp stop`
- Plain goal:
  - `scripts/lean-lsp plain-goal <file> <line> <col>`
- Term goal:
  - `scripts/lean-lsp plain-term-goal <file> <line> <col>`
- Hover info:
  - `scripts/lean-lsp hover <file> <line> <col>`
- Diagnostics at a position:
  - `scripts/lean-lsp diagnostics <file> <line> <col>`
- All of the above:
  - `scripts/lean-lsp all <file> <line> <col>`
- Raw LSP request:
  - `scripts/lean-lsp request --method <method> --params <json>`
- Notification:
  - `scripts/lean-lsp notify --method <method> --params <json>`
- Batch ops:
  - `scripts/lean-lsp batch --ops @ops.json`
- JSON output (structured):
  - add `--json`

## Notes
- The daemon auto-starts when you run queries, or you can start it manually.
- Auto-start uses the current working directory and default server command.
- For custom root or server cmd, run `scripts/lean-lsp start` first.
- Socket path defaults to `LEAN_LSP_SOCKET` or `./lean-lsp.sock`.
