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

## Testing the Setup

The repository includes a "one-click" test script to verify that the entire client-server setup is working correctly. This test runs on your host machine and does not require Docker.

1.  **Make the script executable:**
    ```bash
    chmod +x test.sh
    ```

2.  **Run the test:**
    Run the script from the root of the repository.
    ```bash
    ./test.sh
    ```
    The script will automatically set up the `example-project`, start the server, run a `hover` query, check the result, and shut down the server. If everything is configured correctly, you should see a "✅ Test PASSED" message.

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
    ../lean-lsp start --host 0.0.0.0
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
./lean-lsp hover --host host.docker.internal \
  --map-root-from /app \
  --map-root-to /path/to/your/lean-lsp \
  example-project/ExampleProject.lean 4 34
```
This should return the type signature and docstring for `Nat.Prime`, confirming the entire setup is working.
