FROM alpine

RUN set -xe \
    && apk update \
    && apk add bash openssh git

SHELL ["/bin/bash", "-c"]
CMD trap 'rm -rf ~/.ssh' HUP INT QUIT ABRT KILL ALRM TERM \
    && mkdir ~/.ssh -p \
    && eval `ssh-agent -s` \
    && cat > ~/.ssh/known_hosts <<< "$PLUGIN_KNOWN_HOST" \
    && if [ -n "$PLUGIN_DEPLOYMENT_KEY" ]; then \
        cat > ~/.ssh/id_rsa <<<  "$PLUGIN_DEPLOYMENT_KEY" \
        && chmod 600 ~/.ssh/id_rsa \
        && ssh-add ~/.ssh/id_rsa; \
    fi \
    && set -xe \
    && git init \
    && git remote add origin "$DRONE_GIT_SSH_URL" \
    && git fetch origin "$DRONE_COMMIT_REF" \
    && git checkout "$DRONE_COMMIT_SHA" -b "$DRONE_COMMIT_BRANCH"
