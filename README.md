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

## Usage

The `lean-lsp` script acts as both a server and a client.

### On the host machine (macOS)

1.  **Create a new Lean project (if you don't have one):**
    Use `lake` to create a new library project. This is the simplest starting point.
    ```bash
    lake new my-lean-project lib
    cd my-lean-project
    ```

2.  **Add and build dependencies:**
    Edit your `lakefile.toml` to add dependencies like `mathlib`. Then, from the project directory, update your dependencies and get the pre-compiled cache.
    ```bash
    # After adding a dependency, run these commands.
    # If `lake update` seems to do nothing, try removing `lake-manifest.json` first.
    lake update
    lake exe mathlib/cache get
    ```

3.  **Build the project:**
    Before starting the server, build your project to compile local files and ensure dependencies are correctly linked.
    ```bash
    lake build
    ```

4.  **Start the server from within the project directory:**
    You will need to run the `lean-lsp` script from your project directory. You can use a relative or absolute path to the script. For example, if the `lean-lsp` repository is in the parent directory, you would run:
    ```bash
    ../lean-lsp/lean-lsp start --host 0.0.0.0
    ```
    This will start the Lean LSP server and listen for connections on all network interfaces on the default port.

### In the Docker container

To communicate with the server running on the host, you will need the host's IP address as seen from the container. Inside a Docker container, you can often use `host.docker.internal` to refer to the host machine.

**IMPORTANT:** All client commands must be run from the root of the `lean-lsp` repository directory. This is because the script needs to find and read local files before sending requests to the server, and its working directory inside the container (`/app`) corresponds to your project root on the host.

Run client commands by specifying the host and providing file paths relative to the project root. Because the client (in Docker) and server (on macOS) have different views of the filesystem, you must also provide path mappings.

```bash
# General example with path mapping, run from the lean-lsp project root:
./lean-lsp hover --host host.docker.internal \
  --map-root-from /app \
  --map-root-to $(pwd) \
  path/to/your/file.lean 10 5
```
This connects to the server on the host machine and executes the `hover` command, correctly translating the file path.
