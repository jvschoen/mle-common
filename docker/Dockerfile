FROM databricksruntime/standard:12.2-LTS

COPY docker/requirements-12.2-ML.txt /opt/mle-common/requirements.txt

WORKDIR /opt/mle-common/

RUN /databricks/python3/bin/pip install -r requirements.txt

COPY . /opt/mle-common

RUN /databricks/python3/bin/pip install -e ./

EXPOSE 8888

CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=