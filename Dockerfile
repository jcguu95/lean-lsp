FROM paulgauthier/aider-full

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for elan and building Lean projects.
# The base image should have most of these, but we ensure they are present.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gcc \
    g++ \
    make \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install elan to a shared location /opt/elan
ENV ELAN_HOME=/opt/elan
RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --default-toolchain leanprover/lean4:stable --no-modify-path
RUN chmod -R a+rx /opt/elan

# Add elan to PATH for all users.
ENV PATH="/opt/elan/bin:$PATH"

# Set the working directory in the container.
WORKDIR /app

# Switch back to the default user from the base image.
USER aider
