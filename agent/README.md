# Aider-Lean Docker Environment

This directory contains a `Dockerfile` to build a Docker image named `aider-lean`. This image provides a complete development environment for the [Lean 4](https://lean-lang.org/) programming language, integrated with [Aider](https://github.com/paul-gauthier/aider), an AI-powered coding assistant.

The image is based on `paulgauthier/aider-full` and includes:
- The `elan` toolchain manager with a stable version of Lean.
- A pre-compiled `mathlib`, the Lean mathematical library, to speed up project setup.

## Building the Image

To build the `aider-lean` Docker image, run the following command from this directory:

```bash
docker build -t aider-lean -f Dockerfile .
```

**Note:** The first build will take a significant amount of time (20-30 minutes) as it downloads and compiles `mathlib`. Subsequent builds will be much faster due to Docker's caching.

## Running the Container

To start an interactive session in a container, use the `docker run` command. This command mounts your current project directory into the container, sets up your git identity, and passes your AI model API key.

```bash
docker run -it --rm \
  --user "$(id -u):$(id -g)" \
  --volume "$(pwd):/app" \
  --volume "$HOME/.cache/mathlib:/home/appuser/.cache/mathlib" \
  --env GIT_AUTHOR_NAME="$(git config user.name)" \
  --env GIT_AUTHOR_EMAIL="$(git config user.email)" \
  --env GIT_COMMITTER_NAME="$(git config user.name)" \
  --env GIT_COMMITTER_EMAIL="$(git config user.email)" \
  --env GEMINI_API_KEY="YOUR_API_KEY" \
  aider-lean \
  --model gemini/gemini-2.5-pro \
  --no-stream \
  --weak-model gemini/gemini-2.0-flash-lite
```

### Explanation of `docker run` options:

- `-it`: Runs the container in interactive mode with a terminal.
- `--rm`: Automatically removes the container when it exits.
- `--user "$(id -u):$(id -g)"`: Runs the container with your current user and group ID, so that files created in the mounted volume have the correct ownership.
- `--volume "$(pwd):/app"`: Mounts the current directory on your host into the `/app` directory inside the container.
- `--volume "$HOME/.cache/mathlib:/home/appuser/.cache/mathlib"`: Mounts a directory from your host to the `mathlib` cache location in the container. This preserves the cache between container runs.
- `--env ...`: Sets environment variables for `git` and your `GEMINI_API_KEY`. **Remember to replace `"YOUR_API_KEY"` with your actual key.**
- `aider-lean`: The name of the image to run.
- `...`: Arguments passed to `aider` at the end of the command.

## Usage

Once inside the container, `aider` will start and your current directory on the host is available at `/app`.

### Creating a new Lean project

If you are starting a new project from scratch, you can initialize it with `lake` and add `mathlib` as a dependency. The following commands can be run from within the `aider` prompt.

1.  Initialize a new Lean project. This creates a new directory for your project.
    ```bash
    /run lake init my_new_project
    ```

2.  Add `mathlib` as a dependency to your new project's `lakefile.toml`.
    ```bash
    /run echo -e "\n[[require]]\nname = \"mathlib\"\ngit = \"https://github.com/leanprover-community/mathlib4.git\"" >> my_new_project/lakefile.toml
    ```

3.  Navigate into your project directory to update dependencies and get the cache. Since `/run` executes each command in a new shell, you should combine commands with `&&`.
    ```bash
    /run cd my_new_project && lake update && lake exe cache get
    ```

Because `mathlib` is pre-compiled in the Docker image, the `lake exe cache get` step should be very fast (under a minute). Your Lean project is now set up and ready to go!
