# Dockerfile for a Lean development environment based on aider-full
FROM paulgauthier/aider-full

# Switch to root to install system-level dependencies
USER root

# Install dependencies needed for elan (the Lean toolchain manager) and for building Lean projects.
# git is needed by lake to fetch dependencies and is present in the base image.
# curl is needed to download elan.
# libgmp-dev is needed for Lean's arbitrary-precision integers.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libgmp-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch back to the non-root user provided by the base image
USER coder
WORKDIR /home/coder

# Install elan, which manages installations of Lean and Lake.
# This installs lean and lake into /home/coder/.elan
# The -y flag runs it non-interactively.
# We set the default toolchain to stable.
RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --default-toolchain stable

# Add elan's bin directory to the PATH
ENV PATH="/home/coder/.elan/bin:${PATH}"

# Create a new lean project to use as a context for downloading mathlib.
RUN lake new mathlib_project

# Enter the project directory
WORKDIR /home/coder/mathlib_project

# Add mathlib as a dependency to the dummy project.
RUN echo "require mathlib from git \"https://github.com/leanprover-community/mathlib4.git\"" >> lakefile.toml

# Download pre-compiled mathlib files. This is much faster than building from source.
RUN lake exe cache get

# Clean up the dummy project
WORKDIR /home/coder
RUN rm -rf /home/coder/mathlib_project

# Set the working directory back to the default for the base image.
WORKDIR /home/coder/project
