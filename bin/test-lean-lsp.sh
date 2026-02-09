#!/bin/bash
set -euo pipefail

# This script provides a "one-click" test to verify the client-server setup.
# It creates a minimal Lean project, starts the server, runs a client query,
# and checks the results.

# --- Setup ---
# Create a temporary directory for the test project.
TEST_DIR=$(mktemp -d)
echo "--- 1. Setting up test project in $TEST_DIR ---"
(
    cd "$TEST_DIR"
    echo "Creating new Lean project..."
    lake new test-project > /dev/null
    cd test-project

    # Create a test file.
    cat > Test.lean <<EOL
def my_number : Nat := 42

#check my_number
EOL

    echo "Building project..."
    lake build > /dev/null
)
echo "Setup complete."
echo



# --- Test Suite ---
# Define a cleanup function to stop the server and remove the temp directory.
cleanup() {
    echo
    echo "--- Cleaning up ---"
    # Use || true to prevent the script from exiting with an error if the server is already stopped.
    ./bin/lean-lsp stop --host 0.0.0.0 || true
    echo "Removing temporary directory $TEST_DIR..."
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# --- Run test-project tests ---
echo "--- Running tests for test-project ---"
./bin/lean-lsp start --host 0.0.0.0 --root "$TEST_DIR/test-project" --verbose
echo "Server started for test-project."

# Host test
echo "--- Running host test query for test-project ---"
LEAN_FILE="$TEST_DIR/test-project/Test.lean"
OUTPUT=$(./bin/lean-lsp hover --host 127.0.0.1 "$LEAN_FILE" 1 5)
if [[ "$OUTPUT" == *"my_number : Nat"* ]]; then
  echo "✅ Host Test PASSED for test-project"
else
  echo "❌ Host Test FAILED for test-project: Output did not contain 'my_number : Nat'"
  echo "--- OUTPUT ---"
  echo "$OUTPUT"
  echo "--------------"
  exit 1
fi

./bin/lean-lsp stop --host 0.0.0.0
echo "Server stopped for test-project."
echo
echo "--- All test-project tests passed! ---"
