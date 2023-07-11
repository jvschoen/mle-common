#!/bin/bash
# Allow write to ssh mounted volume
sudo chown -R ${USERNAME} /home/${USERNAME}/.ssh

# Make library available from home dir for active development
ln -s ${BASE_LIBRARY_ROOT}/${COMMON_LIB_NAME} \
    /home/${USERNAME}/${COMMON_LIB_NAME}

# Setup git
git config --global user.name "${GIT_USERNAME}"
git config --global user.email "${GIT_EMAIL}"

exec "$@"