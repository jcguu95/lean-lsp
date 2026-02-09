[WARNING: This document is still a draft. The proposed method does not work yet, as
a linux-based docker container cannot run macOS's binary directy.]

# Aider with Lean Integration

This guide explains how to set up and run a Dockerized Aider environment that can interact with the Lean theorem prover on your host machine.

This setup uses a secure proxy (`lean-exec`) to forward `lean` and `lake` commands from the Aider container to your host. This avoids CPU architecture mismatch errors and keeps the Docker image small, as Lean does not need to be installed inside it.

## 1. Start the Command Server (on Host)

In a terminal on your host machine, start the `lean-exec` server from the root of the `lean-lsp` repository. This server will listen for commands from the Aider container.

```bash
./bin/lean-exec server
```
Leave this terminal running.

## 2. Build the Docker Image (on Host)

In a second terminal, build the `lean-aider` Docker image. This image contains wrapper scripts that forward `lean` and `lake` commands to the server you just started.

From within this `aider/` directory, run:
```bash
docker build -t lean-aider .
```

## 3. Run the Aider Container (on Host)

Once the image is built, you can start the Aider container.

Make sure to replace `AIza_YOURSECRET_API_KEY` with your actual Gemini API key.

The command is defined as a Bash array (`docker_args`) for readability.

```bash
docker_args=(
    run -it                                     # Start in interactive mode with a terminal.
    --rm                                        # Automatically remove the container when it exits.

    # Run as the current host user, not root, to avoid creating files with root
    # permissions in your project directory.
    --user "$(id -u):$(id -g)"

    # The --volume flag mounts a host directory into the container.
    # The syntax is: --volume <host_path>:<container_path>
    --volume "$(pwd):/app"                      # Mount the project root to /app in the container.
    --volume ~/.cache:/opt/cache                # Mount the host's cache for faster package management.

    # Environment variables for git and the AI model.
    --env GIT_AUTHOR_NAME="$(git config user.name)"
    --env GIT_AUTHOR_EMAIL="$(git config user.email)"
    --env GIT_COMMITTER_NAME="$(git config user.name)"
    --env GIT_COMMITTER_EMAIL="$(git config user.email)"
    --env GEMINI_API_KEY="AIza_YOURSECRET_API_KEY" # Set your API key. Other models work too; see Aider's docs.

    lean-aider                                  # The Docker image we built in the previous step.

    # Aider-specific arguments.
    --model gemini/gemini-2.5-pro
    --no-stream
    --weak-model gemini/gemini-2.0-flash-lite
)
docker "${docker_args[@]}"
```

## 4. Verify the Setup

After running the command above, you will be inside the Aider chat interface. To verify that Lean is correctly configured, you can ask Aider to run a shell command.

Type the following at the Aider prompt:
```
/run lean --version
```

Aider should execute the command via the proxy and show you the version of Lean from your host machine, for example:
```
Lean (version 4.8.0-rc1, commit 1234567890ab, Release)
```

You can also check the Lake version:
```
/run lake --version
```

If these commands succeed, your Aider environment is fully equipped to work on Lean projects.
