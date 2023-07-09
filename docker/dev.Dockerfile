# WIP, to make dev image include jupyter for dev work.
FROM base-image
ARG python_version="3.9"

RUN mkdir /etc/ssh/keys/

# Modify the SSH client config to always use this key
RUN echo "IdentityFile /etc/ssh/keys/id_rsa" >> /etc/ssh/ssh_config

# RUN virtualenv \
#      --python=python${python_version} \
#      --system-site-packages \
#      /jupyter/ \
#      --no-download

# RUN /jupyter/bin/pip install jupyter

# ENTRYPOINT ["/sbin/tini", "--", "myapp"]

# CMD ["--foo", "1", "--bar=2"]