FROM python:3.9.17-buster

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
    && apt-get -y install sudo

COPY requirements.txt /tmp/

COPY VERSION .

# Create developer user
RUN useradd -m developer \
    && echo "developer:developer" | \
    chpasswd && adduser developer sudo

# Give sudo no password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Move the source folder into the container and
# Give container user ownership
WORKDIR /home/developer
ADD . src/
RUN chown -R developer:developer src/

# Change to non-root privilege
USER developer

RUN git config --global --add safe.directory /home/developer/src

# Add user bin to PATH
RUN pip install --no-cache-dir -r /tmp/requirements.txt
ENV PATH="/home/developer/.local/bin:${PATH}"

# dummy cmd to keep container running
CMD ["tail", "-f", "/dev/null"]