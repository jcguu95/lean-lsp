FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for elan and building Lean projects.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    gcc \
    g++ \
    make \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install elan, the Lean toolchain manager.
# The --no-modify-path flag prevents the script from modifying shell startup files,
# as we are setting the PATH using the ENV instruction.
RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --default-toolchain leanprover/lean4:stable --no-modify-path

# Add elan to PATH. The default installation path for the root user is /root/.elan.
ENV PATH="/root/.elan/bin:$PATH"

# Set the working directory in the container.
WORKDIR /app
