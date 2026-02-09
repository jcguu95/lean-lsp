FROM paulgauthier/aider-full

USER root

ENV ELAN_HOME=/opt/elan
ENV PATH="${ELAN_HOME}/bin:${PATH}"

RUN mkdir -p ${ELAN_HOME} && chmod 777 ${ELAN_HOME}

RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --no-modify-path
