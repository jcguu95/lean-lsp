#!/bin/bash
set -euo pipefail

# This script provides a "one-click" test to verify the client-server setup.
# It automates the process of setting up the test project, starting the server,
# running a client query, and checking the results.

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
(cd bin/test-project && ../../bin/lean-lsp start --host 0.0.0.0 --verbose)
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

./bin/lean-lsp stop --host 0.0.0.0
echo "Server stopped for test-project."
echo
echo "--- All test-project tests passed! ---"
