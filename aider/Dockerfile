FROM paulgauthier/aider-full

USER root

# Copy the wrapper scripts into the container's PATH.
# These wrappers will forward calls to the host via the `lean-exec` proxy.
COPY bin/lean /usr/local/bin/lean
COPY bin/lake /usr/local/bin/lake
RUN chmod +x /usr/local/bin/lean /usr/local/bin/lake
