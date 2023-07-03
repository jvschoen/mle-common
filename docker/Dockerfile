FROM databricksruntime/standard:12.2-LTS
ARG requirements_file=docker/requirements.txt

# Avoids this layer from
COPY ${requirements_file} /opt/mle-common/requirements.txt

WORKDIR /opt/mle-common/

RUN /databricks/python3/bin/pip install --upgrade pip
RUN /databricks/python3/bin/pip install -r requirements.txt

COPY . /opt/mle-common

RUN /databricks/python3/bin/pip install -e ./

EXPOSE 8888

CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=