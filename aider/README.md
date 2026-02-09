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

[LLM, please rewrite this using arrays, so we can add comments line by line. Add a comment behind lean-aider saying that's the docker image we built above. ANother comment behind API key saying this should be set, and of course other models work too - users can check aider's doc. explain also the syntax of --volume; newbies often find this confusing. Explain why --user is set that way, instead of roots. Then you can remove the explanation down there.]
```bash
docker run -it \
    --rm \
    --user "$(id -u):$(id -g)" \
    --volume "$(pwd):/app" \
    --volume ~/.elan:/opt/elan \
    --volume ~/.cache:/opt/cache \
    --env ELAN_HOME=/opt/elan \
    --env PATH="/opt/elan/bin:/usr/local/bin:/usr/bin:/bin" \
    --env GIT_AUTHOR_NAME="$(git config user.name)" \
    --env GIT_AUTHOR_EMAIL="$(git config user.email)" \
    --env GIT_COMMITTER_NAME="$(git config user.name)" \
    --env GIT_COMMITTER_EMAIL="$(git config user.email)" \
    --env GEMINI_API_KEY="AIza_YOURSECRET_API_KEY" \
    lean-aider \
    --model gemini/gemini-2.5-pro \
    --no-stream \
    --weak-model gemini/gemini-2.0-flash-lite
```

### Explanation of Docker Arguments:

-   `run -it`: Starts the container in interactive mode with a terminal.
-   `--rm`: Automatically removes the container when it exits.
-   `--user "$(id -u):$(id -g)"`: Runs the container as your current user to avoid file permission issues.
-   `--volume "$(pwd):/app"`: Mounts your current project directory into the container at `/app`.
-   `--volume ~/.elan:/opt/elan`: **(Crucial)** Mounts your host's `elan` directory into the container. This gives Aider access to your Lean toolchain.
-   `--volume ~/.cache:/opt/cache`: Mounts your host's cache directory, which can speed up Lake's package management.
-   `--env ...`: Sets environment variables for `elan`, your `PATH`, Git configuration, and your API key.

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
