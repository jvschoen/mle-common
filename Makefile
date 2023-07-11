#export BUILDKIT_PROGRESS=plain
include .env

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
	docker compose build

# build:
# 	docker build -f docker/Dockerfile . -t ${IMAGE_NAME}

build-debug:
	docker build -f docker/Dockerfile \
	--progress plain \
	--no-cache

run:
	docker compose up

attach:
#	docker run -it ${IMAGE_NAME}:$(VERSION) /bin/bash
	docker compose up
	docker compose exec ml-platform bash

stop:
	docker compose stop

cleanup-docker: stop
	docker compose rm

volumes:
	docker volume create ${DEV_VOLUME_NAME}
	docker volume create ${SSH_KEY_VOLUME_NAME}

# Create a ssh key in /tmp, then move to persistent volume for docker containers, then delete from host machine
ssh-key:
	ssh-keygen -t ed25519 -f /tmp/id_ed25519 -C "${USERNAME} Shared Docker Key"
	docker run --rm -v ssh_keys:/keys -v /tmp:/host_keys alpine sh -c "cp /host_keys/id_ed25519* /keys"
	rm /tmp/id_ed25519*

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
# -- If Conflicts, then could break automation after above cmd --

	bump2version ${bump_level}
# This triggers the CICD pipeline
	yes | git push --set-upstream origin release-v$(new_version)
# TODO: This should actually occur after the CI completes without failure
	yes | git push --tags

# ######################
# PUSHING DOCKER IMAGE #
# ######################
# Push the specific version, latest Git commit, and latest tag to the registry
push-image: push-image-version #push-git-commit push-latest

push-image-version: tag-version
	docker push $(DOCKER_REGISTRY_HOST)/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${VERSION}

# push-image-git-commit:
# 	docker push $(IMAGE_NAME):$(GIT_COMMIT)

# push-image-latest:
# 	docker push $(IMAGE_NAME):latest

# Tag the image with the 'repo url base' and version
tag-version:
	docker tag ${DOCKER_REPOSITORY}/$(IMAGE_NAME):$(VERSION) \
	$(DOCKER_REGISTRY_HOST)/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${VERSION}