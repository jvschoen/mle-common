# Objective
I'm testing out how to automate versioning following this chat:
https://chat.openai.com/share/9e4c646d-ee2f-4cc7-bd96-aab9723597eb

* I want to use bump2version to update version files and

# General Flow

1. develop new branch `feature-branch`
2. add files
3. create `release-branch` off `main`
4. merge `feature-branch` into `release-branch`
5. run bump2version with `major` `minor` or `patch`