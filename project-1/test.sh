#!/bin/bash
set -euo pipefail

# This script provides a "one-click" test for project-1.
# It automates the process of setting up the project, starting the server,
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
DOCKER_IMAGE_NAME="lean-aider"

# --- Script ---

# Ensure we are running from the project-1 directory.
cd "$(dirname "$0")"

# --- Setup ---
echo "--- Setting up project-1 ---"
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
echo "Setup complete."
echo

# --- Verification ---
echo "--- Verifying proof is complete ---"
# `lake build` already ran in setup, which confirms the proof compiles.
# Now, we check for any remaining `sorry` placeholders.
# The `!` negates the exit code of grep. Grep returns 0 on match (bad), 1 on no match (good).
if ! grep -R --include='*.lean' 'sorry' Project1; then
  echo "✅ Verification PASSED: No 'sorry' placeholders found."
else
  echo "❌ Verification FAILED: Found 'sorry' placeholders in the proof."
  exit 1
fi
