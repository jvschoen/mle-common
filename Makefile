#export BUILDKIT_PROGRESS=plain
include docker/.env

bump_level=minor
new_version=0.0.0

# Extract the latest Git commit hash
GIT_COMMIT := $(shell git rev-parse --short HEAD)
current_branch := $(shell git rev-parse --abbrev-ref HEAD)

# Default 'make' action would be 'build'
.DEFAULT_GOAL := build

# ###########
# Releasing #
# ###########

# TODO: Update proget server, and get UN PW
release-code: release-git

release-whl: whl
	twine upload \
	--repository-url https://your-proget-server \
	--username $(USERNAME) \
	--password $(PASSWORD) \
	dist/*

release-image: tag-latest push-image


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
	pytest

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
	pylint my_package tests

whl: clean
	python setup.py bdist_wheel
	ls -l dist

# ######################
# VERSION AND TAG CODE #
# ######################
release-git:
	git checkout main
	yes | git pull origin main
	git checkout -b release-v$(new_version)
	git merge $(current_branch)

	bump2version ${bump_level}
	yes | git push --set-upstream origin release-branch
# This triggers the CICD
	yes | git push --tags

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