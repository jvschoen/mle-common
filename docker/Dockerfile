# Best practices from: https://github.com/hexops/dockerfile; https://sysdig.com/blog/dockerfile-best-practices/
ARG runtime_version=12.2-LTS

FROM databricksruntime/standard:${runtime_version}

ARG requirements_file=docker/requirements.txt
ARG library_path=/opt/mle-common/
ARG username

# Create User
RUN useradd -m -s /bin/bash ${username} \
     && usermod -aG sudo ${username} \
     && echo "${username} ALL=(ALL) NOPASSWD:ALL" \
     | sudo tee /etc/sudoers.d/username

COPY ${requirements_file} ${library_path}/requirements.txt

WORKDIR ${library_path}
# TODO: Remove this in favor of
RUN chown -R ${username} . /databricks

RUN /databricks/python3/bin/pip install --upgrade pip \
     && /databricks/python3/bin/pip install -r requirements.txt

ARG python_version=3.9

RUN mkdir /jupyter && chown ${username} /jupyter

RUN chown -R ${username} . /databricks

USER ${username}

RUN mkdir /home/${username}/.ssh \
    && mkdir /home/${username}/dev

# For running jupyterlab as entry for dev
RUN virtualenv \
     --python=python${python_version} \
     --system-site-packages \
     /jupyter \
     --no-download

RUN /jupyter/bin/pip install jupyter
RUN /jupyter/bin/python -m ipykernel install --name "user_env" --user
RUN /databricks/python3/bin/python -m ipykernel install --name "databricks_env" --user

# Run last to avoid breaking cache
COPY . .
RUN /databricks/python3/bin/pip install -e ./

WORKDIR /home/${username}/dev

EXPOSE 8888

CMD ["/jupyter/bin/jupyter", "--ip=0.0.0.0", "--port=8888","--no-browser", "--allow-root"]