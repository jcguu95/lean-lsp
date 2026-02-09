[WARNING: This document is still a draft. The proposed method does not work yet, as
a linux-based docker container cannot run macOS's binary directy.]

# Aider with Lean Integration

This guide explains how to set up and run a Dockerized Aider environment that can interact with the Lean theorem prover.

The key to this setup is that the Docker container mounts and uses your **host machine's** Lean toolchain (`~/.elan`). This ensures that the agent has access to the exact same versions of Lean, Lake, and Mathlib that you use locally, avoiding any version conflicts or the need to install large dependencies inside the container.

## 1. Build the Docker Image

First, you need to build the `lean-aider` Docker image. This image is based on `paulgauthier/aider-full` and adds the necessary setup for `elan`, the Lean toolchain manager.

From within this `aider/` directory, run the following command:
```bash
cd ./aider
docker build -t lean-aider .
```

## 2. Run the Aider Container

Once the image is built, you can start the Aider container. The command below is configured to share your host's Lean installation and project files with the container.

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
    --volume "$(pwd):/app"                      # Mount the current project directory to /app in the container.
    --volume ~/.elan:/opt/elan                  # Mount the host's elan toolchain.
    --volume ~/.cache:/opt/cache                # Mount the host's cache for faster package management.

    # Environment variables needed for elan, git, and the AI model.
    --env ELAN_HOME=/opt/elan
    --env PATH="/opt/elan/bin:/usr/local/bin:/usr/bin:/bin"
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

## 3. Verify the Setup

After running the command above, you will be inside the Aider chat interface. To verify that Lean is correctly configured, you can ask Aider to run a shell command.

Type the following at the Aider prompt:
```
/run lean --version
```

Aider should execute the command and show you the version of Lean from your host machine, for example:
```
Lean (version 4.8.0-rc1, commit 1234567890ab, Release)
```

You can also check the Lake version:
```
/run lake --version
```

If these commands succeed, your Aider environment is fully equipped to work on Lean projects.
