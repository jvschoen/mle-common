# Objective
I'm testing out how to automate versioning following this chat:
https://chat.openai.com/share/9e4c646d-ee2f-4cc7-bd96-aab9723597eb

* I want to use bump2version to update version files and
* I want to implement for Docker and Git code repos
* I want to automate the tagging of git commits on releases
    - Done via Makefile
* I want to kick off CICD pipelines that run on tagged commits on release-branch
* I want the CICD pipeline to push a built wheel to proget and docker image to docker hub, and submit a merge request to main branch.
    - Currently focussing on the wheel bit


# General Flow

1. develop new branch `feature-branch`
2. add files
3. create `release-branch` off `main`
4. merge `feature-branch` into `release-branch`
5. run bump2version with `major` `minor` or `patch`

Steps **3-5** above have been wrapped up in a `make release` command.
The `make release` command goes a step further to kick off tagging and pushing
docker images. That way we know we have a docker environment that runs the current commit
of the code version.

# Thoughts
* I'd like to think of quarterly (minor) releases of our ML models
    - Allowing for quick patches at the patch level.
* Should have sprint-level releases of the common library