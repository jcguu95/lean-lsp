# lean-lsp

A client/server wrapper for the Lean Language Server.

The `lean-lsp` script acts as a client/server wrapper for the actual Lean Language Server Protocol (LSP) server (`lake serve`). It starts the LSP server as a daemon on the host and exposes a simple TCP socket interface. This allows a client on a different machine or in a container to send requests to the LSP server.

## Architecture

The development and primary use case for this tool involves:
1.  A Docker container where a client application (such as a software developer agent) runs.
2.  The host machine (e.g., macOS) where LEAN and mathlib are installed.

The client in the container uses `lean-lsp` to send requests to a TCP socket. The `lean-lsp` server process, running on the host, forwards these requests to the real LSP server.

## Installation

On your host machine, you need to install the Lean toolchain, which includes `lake`, the Lean build manager and language server. The recommended way to do this is using `elan`, the Lean toolchain manager.

1.  **Install elan:**
    You can install `elan` using Homebrew on macOS:
    ```bash
    brew install elan-init
    ```

2.  **Set up the Lean toolchain:**
    Run `elan-init` and follow the on-screen instructions. It will install the latest stable version of Lean and `lake`, and configure your shell's PATH environment variable.
    ```bash
    elan-init
    ```
    After running it, you may need to restart your terminal or source your shell's configuration file (e.g., `source ~/.zshrc`) for the PATH changes to take effect.

3.  **Verify the installation:**
    You can check that `lake` is installed and in your PATH by running:
    ```bash
    lake --version
    ```
    This should print the version of Lake that was installed.

Once `elan` and `lake` are installed, you can proceed to the usage section to start the server within a Lean project.

## Building Project Dependencies

When you use a Lean project with dependencies like `mathlib`, you need to download and build them.

1.  **Update dependencies:**
    This command downloads the source code for your dependencies (like `mathlib`). From inside your Lean project directory, run:
    ```bash
    lake update
    ```
    If you've just added a dependency and this command appears to do nothing, you may need to delete the `lake-manifest.json` file first to force `lake` to re-resolve dependencies.

2.  **Download the mathlib cache (recommended):**
    To avoid long build times, `mathlib` provides pre-compiled binary files.
    ```bash
    lake exe mathlib/cache get
    ```

3. **Build the project:**
   This will compile your project and its dependencies.
   ```bash
   lake build
   ```

## Quick Start: Verifying Your Setup

The repository includes a test script (`bin/test.sh`) to verify the entire toolchain. It sets up a test project, starts the Lean LSP server, and runs tests to confirm communication.

1.  **Make the script executable:**
    ```bash
    chmod +x bin/test.sh
    ```

2.  **Run the test:**
    Run the script from the root of the repository.
    ```bash
    ./bin/test.sh
    ```
    You should see "✅ Host Test PASSED" and "✅ Docker Test PASSED". If the test succeeds, your environment is configured correctly.

## Usage

The `./bin/lean-lsp` script can be run as a server (on the host machine) or as a client.

### Server Commands
The server must be run from within a Lean project directory.

- **Start the server daemon:**
  ```bash
  cd /path/to/lean/project
  /path/to/lean-lsp/bin/lean-lsp start --host 0.0.0.0
  ```
- **Check server status:**
  ```bash
  /path/to/lean-lsp/bin/lean-lsp check --host <host>
  ```
- **Stop the server:**
  ```bash
  /path/to/lean-lsp/bin/lean-lsp stop --host <host>
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

### Notes
- **This is not the LSP server itself.** It's a wrapper around `lake serve`.
- The server (`start` command) must be running from within a Lean project directory.
- The client commands are typically run from the repository root.
- For a detailed example of using `lean-lsp` with a Docker-based AI agent, see [docs/AGENT_SETUP.md](./docs/AGENT_SETUP.md).
