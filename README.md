# LEAN Interaction Setup

This document outlines the plan for setting up the environment to interact with the LEAN theorem prover.

## Architecture

The development environment consists of:
1.  A Docker container where this software developer agent runs.
2.  The host machine (macOS) where LEAN and mathlib are installed.

Communication between the agent in the Docker container and the LEAN process on the host machine will be handled via a TCP socket.

## Rationale

An initial attempt was made to install LEAN and mathlib directly within the Docker container. This approach was abandoned because the size of these dependencies exhausted the available disk space in the container.

The current approach of running LEAN on the host machine and communicating over a socket avoids this storage issue while still allowing the agent to interact with the LEAN runtime.

## Installation

On your macOS host machine, you need to install the Lean toolchain, which includes `lake`, the Lean build manager and language server. The recommended way to do this is using `elan`, the Lean toolchain manager.

1.  **Install elan:**
    You can install `elan` using Homebrew:
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

Once `elan` and `lake` are installed, you can proceed to the usage section to start the server within a Lean project. `mathlib` is managed on a per-project basis and should be added as a dependency in your project's `lakefile.lean`.

## Usage

The `lean-lsp` script acts as both a server and a client.

### On the host machine (macOS)

1.  Create or navigate to a Lean project directory.
2.  Start the server:
    ```bash
    ./lean-lsp start --host 0.0.0.0
    ```
    This will start the Lean LSP server and listen for connections on all network interfaces on the default port.

### In the Docker container

To communicate with the server running on the host, you will need the host's IP address as seen from the container. Inside a Docker container, you can often use `host.docker.internal` to refer to the host machine.

Run client commands by specifying the host:
```bash
./lean-lsp hover --host host.docker.internal path/to/MyTheorem.lean 10 5
```

This will connect to the server on the host machine and execute the `hover` command.
