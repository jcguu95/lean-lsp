#!/bin/bash
set -euo pipefail

# This script provides a "one-click" test to verify the entire client-server setup.
# It automates the process of setting up the example project, starting the server,
# running both a host and a Docker client query, and checking the results.

# --- Configuration ---
# The absolute path to this repository on your HOST machine (e.g., /Users/jin/lean-lsp).
# This is required for the Docker test to correctly map file paths from the
# container to the server on the host.
#
# You can provide this as the first argument to the script, or set it here directly.
# NOTE: The default path below is pre-configured for a specific environment.
# You may need to change it or pass the path as an argument.
HOST_PROJECT_PATH=${1:-"/Users/jin/lean-lsp"}

# Name of the Docker image to use for the test. This should be an image
# that has this repository's code available at /app.
DOCKER_IMAGE_NAME="aider-chat"

# --- Script ---

# Ensure we are running from the project root.
cd "$(dirname "$0")"

# 1. Set up the example project
echo "--- 1. Setting up example project ---"
(
    cd example-project
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

# 2. Start the server in the background
echo "--- 2. Starting server ---"
(cd example-project && ../lean-lsp start --host 0.0.0.0)

# 3. Define a cleanup function to stop the server when the script exits.
cleanup() {
    echo
    echo "--- 7. Stopping server ---"
    # Use || true to prevent the script from exiting with an error if the server is already stopped.
    ./lean-lsp stop --host 0.0.0.0 || true
}
trap cleanup EXIT

# The `start` command waits for the daemon to be ready, so we don't need an extra sleep.
echo "Server started."
echo

# 4. Run the host test query
echo "--- 3. Running host test query ---"
OUTPUT=$(./lean-lsp hover --host 127.0.0.1 example-project/ExampleProject.lean 4 34)

echo
echo "--- 4. Checking host test result ---"
echo "Received output from server:"
echo "---------------------------"
echo "$OUTPUT"
echo "---------------------------"

# Check if the output contains the expected string for `Nat.Prime`.
if [[ "$OUTPUT" == *"Nat.Prime"* ]]; then
  echo "✅ Host Test PASSED"
else
  echo "❌ Host Test FAILED: Output did not contain 'Nat.Prime'"
  exit 1
fi
echo

# 5. Run the Docker test query
echo "--- 5. Running Docker test query ---"
# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "⚠️  Docker is not running. Skipping Docker test."
    exit 0
fi

DOCKER_OUTPUT=$(docker run --rm -v "$HOST_PROJECT_PATH":/app "$DOCKER_IMAGE_NAME" \
  /app/lean-lsp hover --host host.docker.internal \
  --map-root-from /app \
  --map-root-to "$HOST_PROJECT_PATH" \
  example-project/ExampleProject.lean 4 34)

echo
echo "--- 6. Checking Docker test result ---"
echo "Received output from server via Docker:"
echo "---------------------------"
echo "$DOCKER_OUTPUT"
echo "---------------------------"

# Check if the output contains the expected string for `Nat.Prime`.
if [[ "$DOCKER_OUTPUT" == *"Nat.Prime"* ]]; then
  echo "✅ Docker Test PASSED"
else
  echo "❌ Docker Test FAILED: Output did not contain 'Nat.Prime'"
  exit 1
fi
