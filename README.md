# LEAN Interaction Setup

This document outlines the plan for setting up the environment to interact with the LEAN theorem prover.

## Architecture

The development environment consists of:
1.  A Docker container where this software developer agent runs.
2.  The host machine (macOS) where LEAN and mathlib are installed.

Communication between the agent in the Docker container and the LEAN process on the host machine will be handled via a socket.

## Rationale

An initial attempt was made to install LEAN and mathlib directly within the Docker container. This approach was abandoned because the size of these dependencies exhausted the available disk space in the container.

The current approach of running LEAN on the host machine and communicating over a socket avoids this storage issue while still allowing the agent to interact with the LEAN runtime.

## Next Steps

1.  **Host Machine (macOS):** Install LEAN and mathlib, and set up a LEAN server that listens on a socket.
2.  **Docker Container:** Implement client-side logic to connect to the host machine's socket and communicate with the LEAN server.
