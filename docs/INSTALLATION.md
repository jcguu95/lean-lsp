# Installation and Setup (macOS)

This guide covers how to set up your environment (macOS) to use `lean-lsp`.

## Architecture

`lean-lsp` operates on a client-server model:
1.  **The Server:** Runs on a machine with a full Lean installation. It is started from within a Lean project and acts as a bridge to the real Lean LSP server (`lake serve`).
2.  **The Client:** Can be any application that needs to interact with the Lean LSP. It communicates with the `lean-lsp` server over a simple TCP socket, which makes it ideal for remote or containerized environments.

This setup decouples the client from the Lean environment, allowing lightweight clients to query a full Lean installation from anywhere on the network.

## Host Installation 

These instructions are for macOS. On your host machine, you need to install the Lean toolchain, which includes `lake`, the Lean build manager and language server. The recommended way to do this is using `elan`, the Lean toolchain manager.

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
    You should see "✅ Host Test PASSED". If you have Docker installed, it will also run a container-based test and you should see "✅ Docker Test PASSED". A successful test means your environment is configured correctly.
