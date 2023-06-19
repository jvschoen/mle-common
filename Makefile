#export BUILDKIT_PROGRESS=plain
image_tag=bumpversion

build:
	docker build -f docker/Dockerfile . -t ${image_tag}

build_debug:
	docker build -f docker/Dockerfile . -t ${image_tag} --progress plain --no-cache

run: build
	docker run -v ~/.ssh:/home/developer/.ssh -d --name ${image_tag} ${image_tag}

attach:
	docker exec -it ${image_tag} /bin/bash

stop:
	docker stop ${image_tag}

cleanup: stop
	docker rm ${image_tag}