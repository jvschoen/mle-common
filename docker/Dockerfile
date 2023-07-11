# Best practices from: https://github.com/hexops/dockerfile; https://sysdig.com/blog/dockerfile-best-practices/
ARG runtime_version=12.2-LTS
FROM databricksruntime/standard:${runtime_version}

ARG requirements_file=docker/requirements.txt
ARG library_path=/opt/platml
ARG username

RUN apt-get update \
     && apt-get install -y\
     git

# Create User, install python reqs, make dir for jupyter app
RUN useradd -m -s /bin/bash ${username} \
     && usermod -aG sudo ${username} \
     && echo "${username} ALL=(ALL) NOPASSWD:ALL" \
     | sudo tee /etc/sudoers.d/username
COPY ${requirements_file} .
RUN /databricks/python3/bin/pip install --upgrade pip \
     && /databricks/python3/bin/pip install -r requirements.txt
RUN mkdir /jupyter && chown ${username} /jupyter
RUN chown -R ${username} /databricks

USER ${username}
RUN mkdir /home/${username}/dev

# For running jupyterlab as entry for dev
ARG python_version=3.9
RUN virtualenv \
     --python=python${python_version} \
     --system-site-packages \
     /jupyter \
     --no-download
RUN /jupyter/bin/pip install jupyterlab
COPY --chown=${username} docker/extras/databricks_kernel.json \
     /jupyter/share/jupyter/kernels/databricks_env/kernel.json
COPY --chown=${username} docker/extras/user_kernel.json \
     /jupyter/share/jupyter/kernels/user_env/kernel.json

ARG commonlib
WORKDIR ${library_path}
# Run last to avoid breaking cache
COPY --chown=${username} . ${commonlib}
RUN /databricks/python3/bin/pip install -e ${commonlib}

COPY --chown=${username} docker/extras/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

WORKDIR /home/${username}/dev
EXPOSE 8888

CMD ["/jupyter/bin/jupyter", "lab", "--ip=0.0.0.0", "--port=8888","--no-browser", "--allow-root"]