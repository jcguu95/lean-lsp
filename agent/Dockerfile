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

USER appuser
WORKDIR /home/appuser

# 2. Tell elan exactly where to go using ELAN_HOME
ENV ELAN_HOME=/home/appuser/.elan
ENV PATH="${ELAN_HOME}/bin:${PATH}"

ENV MATHLIB_CACHE_DIR=/home/appuser/.cache/mathlib
RUN mkdir -p ${MATHLIB_CACHE_DIR}

RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y \
    --default-toolchain stable \
    --no-modify-path

# 3. Initialize Mathlib in a temporary space to pre-fetch the cache
# This ensures that when the container starts, the heavy lifting is already done.
WORKDIR /tmp/mathlib_init
# RUN lake init mathlib_project toml && \
#     echo '[[require]]\nname = "mathlib"\ngit = "https://github.com/leanprover-community/mathlib4.git"' >> lakefile.toml && \
#     lake update && \
#     lake exe cache get && \
#     lake build
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

# 4. Set final working directory
WORKDIR /app

# The environment variable stays active so any 'lake exe cache get' 
# inside /app will use the persistent cache in /home/appuser
ENV MATHLIB_CACHE_DIR=/home/appuser/.cache/mathlib

# ### TODO

# # 3. Run the installer. 
# # We use --no-modify-path because we are setting the PATH manually via ENV.
# RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y \
#     --default-toolchain stable \
#     --no-modify-path

# # 4. Verify it exists in the NEW location
# RUN ls -la ${ELAN_HOME}/bin/lake && lake --version

# # 5. Now go to /app to do your project work
# WORKDIR /app
# RUN lake new mathlib_project

# WORKDIR /home/appuser/mathlib_project

# RUN echo 'name = "mathlib_project"' > lakefile.toml && \
#     echo '[[require]]' >> lakefile.toml && \
#     echo 'name = "mathlib"' >> lakefile.toml && \
#     echo 'git = "https://github.com/leanprover-community/mathlib4.git"' >> lakefile.toml

# RUN rm -f lakefile.lean

# RUN lake update

# # NOTE -- the above seems to wrok. The below are no good.
# # Enter the project directory

# # # Force the cache tool to use this internal directory TODO
# # ENV LEAN_DEP_CACHE_PATH=/home/appuser/.cache/lean

# RUN lake exe cache get
# RUN lake build # Pre-compile the 'global_lib' to ensure everything is indexed


# # 1. Create the central cache directory
# RUN mkdir -p /home/appuser/.cache/lean
# # 2. Move the downloaded binaries from the dummy project to the central cache
# # This effectively "installs" mathlib into the container's global storage
# RUN cp -r /home/appuser/mathlib_project/.lake/packages/* /home/appuser/.cache/lean/
# # 3. Set the magic environment variable so Lean always finds them
# ENV LEAN_DEP_CACHE_PATH=/home/appuser/.cache/lean
# # 4. (Optional) Cleanup the dummy project to save space
# RUN rm -rf /home/appuser/mathlib_project




# WORKDIR /app

# # ###
# # 
# # # Add mathlib as a dependency to the dummy project.
# # RUN echo 'require mathlib from git "https://github.com/leanprover-community/mathlib4.git"' > lakefile.toml
# # RUN cat lakefile.toml
# # 
# # # Download pre-compiled mathlib files. This is much faster than building from source.
# # RUN lake exe cache get
# # 
# # # Clean up the dummy project
# # WORKDIR /home/appuser
# # RUN rm -rf /home/appuser/mathlib_project
# # 
# # # Set the working directory back to the default for the base image.
# # WORKDIR /home/appuser/project
