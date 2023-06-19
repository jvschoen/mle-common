#export BUILDKIT_PROGRESS=plain
include docker/.env

bump_level=minor

# Extract the latest Git commit hash
GIT_COMMIT := $(shell git rev-parse --short HEAD)

# Default 'make' action would be 'build'
.DEFAULT_GOAL := build

#########################
# BUILDING DOCKER IMAGE #
#########################
# Build Docker image with a specific version and latest Git commit hash
build:
	docker build -f docker/Dockerfile \
	-t $(IMAGE_NAME):$(VERSION) \
	-t $(IMAGE_NAME):$(GIT_COMMIT) .

# build:
# 	docker build -f docker/Dockerfile . -t ${IMAGE_NAME}

build_debug:
	docker build -f docker/Dockerfile \
	-t ${IMAGE_NAME} --progress plain --no-cache \
	-t $(IMAGE_NAME):$(VERSION) \
	-t $(IMAGE_NAME):$(GIT_COMMIT) .

run: build
	docker run -v ~/.ssh:/home/developer/.ssh \
	-d \
	--name ${IMAGE_NAME} \
	${IMAGE_NAME}:$(VERSION)

attach:
	docker exec -it ${IMAGE_NAME} /bin/bash

stop:
	docker stop ${IMAGE_NAME}

cleanup_docker: stop
	docker rm ${IMAGE_NAME}


# ##################
# PYTHON PACKAGING #
# ##################
# Install requirements
init:
	pip install --no-cache-dir -r /tmp/requirements.txt

# Run test suite
test: clean-pyc
	py.test

# Clean build artifacts
clean: clean-build clean-pyc

# From running bdist_
clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

lint:
	flake8 your_project_name tests

whl: clean
	python setup.py bdist_wheel
	ls -l dist


# #################
# RELEASE VERSION #
# #################
# Release both git and image versions
release: release_git push_image

release_git:
	bump2version ${bump_level}
	git push
	git push --tags

# ######################
# PUSHING DOCKER IMAGE #
# ######################
# Push the specific version, latest Git commit, and latest tag to the registry
push_image: push_version push_git_commit push_latest

push_image_version:
	docker push $(IMAGE_NAME):$(VERSION)

push_image_git_commit:
	docker push $(IMAGE_NAME):$(GIT_COMMIT)

push_image_latest:
	docker push $(IMAGE_NAME):latest

# Tag the image with the 'latest' tag
tag_latest:
	docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest