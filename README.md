# LEAN Interaction Setup

This document outlines the plan for setting up the environment to interact with the LEAN theorem prover.

## Architecture

The development environment consists of:
1.  A Docker container where this software developer agent runs.
2.  The host machine (macOS) where LEAN and mathlib are installed.

The `lean-lsp` script acts as a client/server wrapper for the actual Lean Language Server Protocol (LSP) server (`lake serve`). It starts the LSP server as a daemon on the host and exposes a simple TCP socket interface. The agent, running in the container, uses `lean-lsp` as a client to send requests to this TCP socket, which are then forwarded to the real LSP server.

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

## Building Dependencies & Mathlib Cache

When you add a dependency like `mathlib`, running `lake update` only downloads its source code into the `lake-packages` directory. It does not compile the library, which is a very time-consuming process.

To avoid long build times, `mathlib` provides pre-compiled binary files (called a "cache"). The command to download this cache, `lake exe cache`, is provided by `mathlib` itself. Any standard Lean installation (e.g., via `elan-init`) that provides the `lake` command will suffice to use this feature.

Before you can run `lake exe cache`, you must download the dependency and build the tool:

1.  **Update dependencies:**
    This command downloads the source code for your dependencies (like `mathlib`).
    ```bash
    lake update
    ```
    If you've just added a dependency and this command appears to do nothing, you may need to delete the `lake-manifest.json` file first to force `lake` to re-resolve dependencies.

2.  **Download the cache:**
    Once `mathlib`'s source is downloaded, you can fetch its pre-compiled cache files. This is done by running the `cache` executable provided by the `mathlib` package itself.
    ```bash
    lake exe mathlib/cache get
    ```
    This will download and unpack the pre-compiled files for `mathlib`, making them available to the Lean server.

## Quick Start: Verifying Your Setup

Before proceeding, run the automated test script to ensure your environment is configured correctly. This is a critical first step.

The script verifies the entire toolchain: it sets up the example project, starts the Lean LSP server, and runs tests from both the host and a Docker container to confirm communication.

1.  **Make the script executable:**
    ```bash
    chmod +x bin/test.sh
    ```

2.  **Run the test:**
    Run the script from the root of the repository.
    ```bash
    ./bin/test.sh
    ```
    You should see "✅ Host Test PASSED" and "✅ Docker Test PASSED". If the test succeeds, you are ready to start working with the agent.

    **Troubleshooting:**
    - The script is pre-configured with a default host path (`/Users/jin/lean-lsp`). If the Docker test fails, you may need to provide the absolute path to this repository on your machine: `./bin/test.sh /path/to/your/lean-lsp`.
    - The Docker test requires a Docker image named `lean-aider` which has this repository's code available at `/app`.

## Agent Workflow

Once your setup is verified, the workflow involves two main steps running in separate terminals:

### Step 1: Run the Lean LSP Server (on your host machine)

The `lean-lsp` server must be running in the background for the agent to connect to. It needs to be run from within a Lean project directory.

For the included example, navigate to the `example-project` directory and start the server:
```bash
cd example-project
../bin/lean-lsp start --host 0.0.0.0
```
The server will start and listen for connections. You can leave this terminal window open.

### Step 2: Run the Agent (in a Docker container)

With the server running, you can now start an interactive session with the agent. In a new terminal, run the following command from the root of this repository.

Make sure to replace `AIza...` with your actual Gemini API key.

```bash
docker_args=(
    run -it                                   # Start in interactive mode with a TTY
    --rm                                      # Automatically remove the container when it exits
    --user "$(id -u):$(id -g)"                # Run as the current user to avoid file permission issues
    --volume "$(pwd):/app"                    # Mount the current directory into the container
    --env GIT_AUTHOR_NAME="$(git config user.name)"
    --env GIT_AUTHOR_EMAIL="$(git config user.email)"
    --env GIT_COMMITTER_NAME="$(git config user.name)"
    --env GIT_COMMITTER_EMAIL="$(git config user.email)"
    --env GEMINI_API_KEY="AIza..."

    lean-aider
    --model gemini/gemini-2.5-pro             # Specify the main model
    --no-stream                               # Disable streaming output for cleaner responses
    --weak-model gemini/gemini-2.0-flash-lite # Specify a weaker model for simpler tasks
)
docker "${docker_args[@]}"
```
The agent will now be able to use the `bin/lean-lsp` script to communicate with the Lean server running on your host.

## Manual Usage

If you want to run the server and client commands manually, follow these instructions.

### On the host machine (macOS)

1.  **Navigate to the example project and set up dependencies:**
    From the root of this repository, run the following commands. This will download `mathlib` and its pre-compiled cache, then build the project.
    ```bash
    cd example-project
    rm -f lake-manifest.json
    lake update
    lake exe mathlib/cache get
    lake build
    ```

2.  **Start the server:**
    From the `example-project` directory, start the server.
    ```bash
    ../bin/lean-lsp start --host 0.0.0.0
    ```
    The server will start in the background and listen for connections.

### In the Docker container (as the agent)

To communicate with the server running on the host, you will need the host's IP address as seen from the container. Inside a Docker container, you can often use `host.docker.internal` to refer to the host machine.

**IMPORTANT:** All client commands must be run from the root of the `lean-lsp` repository directory. This is because the script needs to find and read local files before sending requests to the server, and its working directory inside the container (`/app`) corresponds to your project root on the host.

Run client commands by specifying the host and providing file paths relative to the project root. Because the client (in Docker) and server (on macOS) have different views of the filesystem, you must also provide path mappings.

**Test the connection:**
In a new terminal, from the root of the `lean-lsp` repository, run the `hover` command to query the example project. You must replace `/path/to/your/lean-lsp` with the absolute path to this repository on your machine.

```bash
# From the lean-lsp project root:
./bin/lean-lsp hover --host host.docker.internal \
  --map-root-from /app \
  --map-root-to /path/to/your/lean-lsp \
  example-project/ExampleProject.lean 4 34
```
This should return the type signature and docstring for `Nat.Prime`, confirming the entire setup is working.
