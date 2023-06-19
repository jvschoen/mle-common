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

build-debug:
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

cleanup-docker: stop
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
release: release-git push-image

release-git: current-branch
	git checkout main
	yes | git pull origin main
	git checkout -b release-branch
	git merge $(cat current-branch)

	bump2version ${bump_level}
	yes | git push --set-upstream origin release-branch
	yes | git push --tags

# Get the name of the current branch
current-branch:
	echo $(git rev-parse --abbrev-ref HEAD) > current-branch

# ######################
# PUSHING DOCKER IMAGE #
# ######################
# Push the specific version, latest Git commit, and latest tag to the registry
push-image: push-version push-git-commit push-latest

push-image-version:
	docker push $(IMAGE_NAME):$(VERSION)

push-image-git-commit:
	docker push $(IMAGE_NAME):$(GIT_COMMIT)

push-image-latest:
	docker push $(IMAGE_NAME):latest

# Tag the image with the 'latest' tag
tag-latest:
	docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest