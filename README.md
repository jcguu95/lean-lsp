# LEAN Interaction Setup

This document outlines the plan for setting up the environment to interact with the LEAN theorem prover.

## Architecture

The development environment consists of:
1.  A Docker container where this software developer agent runs.
2.  The host machine (macOS) where LEAN and mathlib are installed.

Communication between the agent in the Docker container and the LEAN process on the host machine will be handled via a TCP socket.

## Rationale

An initial attempt was made to install LEAN and mathlib directly within the Docker container. This approach was abandoned because the size of these dependencies exhausted the available disk space in the container.

The current approach of running LEAN on the host machine and communicating over a socket avoids this storage issue while still allowing the agent to interact with the LEAN runtime.

## Usage

The `lean-lsp` script acts as both a server and a client.

### On the host machine (macOS)

1.  Install LEAN and mathlib.
2.  In your Lean project directory, start the server:
    ```bash
    ./lean-lsp start --host 0.0.0.0
    ```
    This will start the Lean LSP server and listen for connections on all network interfaces on the default port.

### In the Docker container

To communicate with the server running on the host, you will need the host's IP address as seen from the container. Inside a Docker container, you can often use `host.docker.internal` to refer to the host machine.

Run client commands by specifying the host:
```bash
./lean-lsp --host host.docker.internal hover path/to/MyTheorem.lean 10 5
```

This will connect to the server on the host machine and execute the `hover` command.
