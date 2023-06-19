FROM python:3.9.17-buster

COPY requirements.txt /tmp/

COPY VERSION .

RUN pip install -r /tmp/requirements.txt

# dummy cmd to keep container running
CMD ["tail", "-f", "/dev/null"]