#!/bin/bash
set -euo pipefail

# This script provides a "one-click" test to verify the entire client-server setup.
# It automates the process of setting up the test project, starting the server,
# running both a host and a Docker client query, and checking the results.

# --- Configuration ---
# The absolute path to this repository on your HOST machine (e.g., /Users/jin/lean-lsp).
# This is required for the Docker test to correctly map file paths from the
# container to the server on the host.
#
# You can provide this as the first argument to the script, or set it here directly.
# This script assumes it is run from the project root.
HOST_PROJECT_PATH=${1:-"$(pwd)"}

# Name of the Docker image to use for the test. This should be an image
# that has this repository's code available at /app.
DOCKER_IMAGE_NAME="lean-aider"

# --- Script ---

# --- Setup ---
echo "--- 1. Setting up test project ---"
(
    cd bin/test-project
    # Only run the full, slow setup if mathlib is not already downloaded.
    if [ ! -d ".lake/packages/mathlib" ]; then
        echo "Mathlib not found, running full setup (this may take a few minutes)..."
        rm -f lake-manifest.json
        lake update
        lake exe mathlib/cache get
        lake build
    else
        echo "Mathlib found, running a quick build..."
        lake build
    fi
)
echo "Setup complete."
echo



# --- Test Suite ---
# Define a cleanup function to stop the server when the script exits.
cleanup() {
    echo
    echo "--- Stopping any running server ---"
    # Use || true to prevent the script from exiting with an error if the server is already stopped.
    ./bin/lean-lsp stop --host 0.0.0.0 || true
}
trap cleanup EXIT

# --- Run test-project tests ---
echo "--- Running tests for test-project ---"
(cd bin/test-project && ../../bin/lean-lsp start --host 0.0.0.0)
echo "Server started for test-project."

# Host test
echo "--- Running host test query for test-project ---"
OUTPUT=$(./bin/lean-lsp hover --host 127.0.0.1 bin/test-project/ExampleProject.lean 4 34)
if [[ "$OUTPUT" == *"Nat.Prime"* ]]; then
  echo "✅ Host Test PASSED for test-project"
else
  echo "❌ Host Test FAILED for test-project: Output did not contain 'Nat.Prime'"
  exit 1
fi

# Docker test
echo "--- Running Docker test query for test-project ---"
if ! docker info > /dev/null 2>&1; then
    echo "⚠️  Docker is not running. Skipping Docker test."
else
    DOCKER_OUTPUT=$(docker run --rm \
      --user "$(id -u):$(id -g)" \
      --entrypoint /app/bin/lean-lsp \
      -v "$HOST_PROJECT_PATH":/app \
      "$DOCKER_IMAGE_NAME" \
      hover --host host.docker.internal \
      --map-root-from /app \
      --map-root-to "$HOST_PROJECT_PATH" \
      bin/test-project/ExampleProject.lean 4 34)

    if [[ "$DOCKER_OUTPUT" == *"Nat.Prime"* ]]; then
      echo "✅ Docker Test PASSED for test-project"
    else
      echo "❌ Docker Test FAILED for test-project: Output did not contain 'Nat.Prime'"
      exit 1
    fi
fi
./bin/lean-lsp stop --host 0.0.0.0
echo "Server stopped for test-project."
echo
echo "--- All test-project tests passed! ---"
