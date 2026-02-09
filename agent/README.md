Build the docker image `aider-lean`.
The first build will take a while (20~30 minutes), as mathlib is pulled and compiled.
```
docker build -t aider-lean -f Dockerfile .
```


Run the docker image:
```
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
    --env GEMINI_API_KEY="AIza_YOUR_SECRET_KEY"

    lean-aider                                  # The Docker image we built in the previous step.

    # Aider-specific arguments.
    --model gemini/gemini-2.5-pro
    --no-stream
    --weak-model gemini/gemini-2.0-flash-lite
)
docker "${docker_args[@]}"

```

This command will make the home dir `/app` being the current working directory
on the host machine. If there's no lean project yet, the user can create one by

``` 
/run lake init my_new_project
/run echo '[[require]]' >> lakefile.toml
/run echo 'name = "mathlib"' >> lakefile.toml
/run echo 'git = "https://github.com/leanprover-community/mathlib4.git"' >> lakefile.toml
/run lake update # the first time will take a while
/run lake exe cache get # as aider-lean has mathlib compiled already, this should take less than 1 minute!
```
