import subprocess
import sys
import time
from pathlib import Path
import json

import pytest

SCRIPT_PATH = Path(__file__).parent.parent / "scripts" / "lean-lsp"
DEFAULT_SOCKET_PATH = Path(".lean-lsp.sock")


def run_lsp_cmd(*args, check=True, **kwargs):
    """Helper to run the lean-lsp script."""
    # By default, subprocess.run(check=True) will raise an exception for a non-zero exit code.
    # We can pass check=False to inspect the result of a failing command.
    return subprocess.run(
        [sys.executable, str(SCRIPT_PATH)] + [str(a) for a in args],
        check=check,
        capture_output=True,
        text=True,
        **kwargs,
    )


def test_start_stop_check(tmp_path):
    """Test the daemon's start, stop, and check lifecycle."""
    # Use the default socket path
    socket_path = DEFAULT_SOCKET_PATH

    # Start the daemon. --wait ensures it's ready.
    start_proc = run_lsp_cmd("--socket", socket_path, "start", "--wait", "10")
    assert "started" in start_proc.stdout.strip()

    # Check if it's running.
    check_proc_running = run_lsp_cmd("--socket", socket_path, "check")
    assert "ok" in check_proc_running.stdout.strip()

    # Stop the daemon.
    stop_proc = run_lsp_cmd("--socket", socket_path, "stop")
    assert "stopped" in stop_proc.stdout.strip()

    # Give the daemon a moment to shut down and clean up the socket.
    time.sleep(0.5)

    # Check that it's stopped. This should exit with 1.
    result = run_lsp_cmd("--socket", socket_path, "check", check=False)
    assert result.returncode == 1
    assert "not running" in result.stderr.strip()


def test_ping(tmp_path):
    """Test the daemon's ping functionality."""
    # Use the default socket path
    socket_path = DEFAULT_SOCKET_PATH
    # Start the daemon. --wait ensures it's ready.
    start_proc = run_lsp_cmd("--socket", socket_path, "start", "--wait", "10")
    assert "started" in start_proc.stdout.strip()

    # Send a ping request.
    ping_proc = run_lsp_cmd("--socket", socket_path, "request", "--method", "$/lean/ping", "--timeout", "5")
    assert ping_proc.returncode == 0
    response = json.loads(ping_proc.stdout)
    assert response["ok"]
    assert response["result"] == {"status": "ok"}

    # Stop the daemon.
    stop_proc = run_lsp_cmd("--socket", socket_path, "stop")
    assert "stopped" in stop_proc.stdout.strip()
