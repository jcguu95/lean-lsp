# Lean LSP Aider Environment

This repository contains a skill for `aider` to interact with a Lean LSP server.
It includes a `Dockerfile` to set up a development environment with `aider`, `lean`, and `lake`.

## Getting Started

### Prerequisites
- Docker must be installed on your system.
- You need a Gemini API key.

### 1. Build the Docker Image
First, build the Docker image from the `Dockerfile`. This image will contain `aider`, `lean`, and `lake`.

```bash
docker build -t lean-aider .
```

Note: The Docker image is managed by the Docker daemon and stored in Docker's internal storage, not in your project directory. You can see the built image by running `docker images | grep lean-aider`.

### 2. Start an Aider Session
To start an `aider` session within the Docker container, run the following command.

You will need to replace `your-gemini-api-key` with your actual Gemini API key.

```bash
docker run -it --rm \
  --user "$(id -u):$(id -g)" \
  --volume "$(pwd):/app" \
  --env GIT_AUTHOR_NAME="$(git config user.name)" \
  --env GIT_AUTHOR_EMAIL="$(git config user.email)" \
  --env GIT_COMMITTER_NAME="$(git config user.name)" \
  --env GIT_COMMITTER_EMAIL="$(git config user.email)" \
  --env GEMINI_API_KEY="your-gemini-api-key" \
  lean-aider \
  --model gemini/gemini-2.5-pro \
  --no-stream \
  --weak-model gemini/gemini-2.0-flash-lite
```
