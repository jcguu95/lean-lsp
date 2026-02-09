# Dockerfile for a Lean development environment based on aider-full
FROM paulgauthier/aider-full

# Switch to root to install system-level dependencies
USER root

# Install dependencies needed for elan (the Lean toolchain manager) and for building Lean projects.
# git is needed by lake to fetch dependencies and is present in the base image.
# curl is needed to download elan.
# libgmp-dev is needed for Lean's arbitrary-precision integers.
# Install dependencies, fixing GPG errors by reinstalling the keyring first.

RUN apt-get update && \
    apt-get install -y --no-install-recommends --allow-unauthenticated debian-archive-keyring && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    libgmp-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts and test project from bin/ into the image.
# The tools are placed in /opt/lean-tools and added to the PATH.
COPY bin /opt/lean-tools
RUN chmod +x /opt/lean-tools/lean-lsp /opt/lean-tools/test.sh
ENV PATH="/opt/lean-tools:${PATH}"

USER appuser
WORKDIR /home/appuser

# Tell elan exactly where to go using ELAN_HOME
ENV ELAN_HOME=/home/appuser/.elan
ENV PATH="${ELAN_HOME}/bin:${PATH}"

ENV MATHLIB_CACHE_DIR=/home/appuser/.cache/mathlib
RUN mkdir -p ${MATHLIB_CACHE_DIR}

RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y \
    --default-toolchain stable \
    --no-modify-path

# Initialize Mathlib in a temporary space to pre-fetch the cache
# This ensures that when the container starts, the heavy lifting is already done.
WORKDIR /tmp/mathlib_init
RUN echo 'name = "mathlib_project"' > lakefile.toml && \
    echo '[[require]]' >> lakefile.toml && \
    echo 'name = "mathlib"' >> lakefile.toml && \
    echo 'git = "https://github.com/leanprover-community/mathlib4.git"' >> lakefile.toml

RUN lake update
RUN lake exe cache get
RUN lake build # Pre-compile the 'global_lib' to ensure everything is indexed

# Clean up temp project, but the binaries stay in $MATHLIB_CACHE_DIR
WORKDIR /home/appuser
RUN rm -rf /tmp/mathlib_init

# Set final working directory
WORKDIR /app

# The environment variable stays active so any 'lake exe cache get' 
# inside /app will use the persistent cache in /home/appuser
ENV MATHLIB_CACHE_DIR=/home/appuser/.cache/mathlib

