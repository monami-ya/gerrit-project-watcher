#!/bin/bash

if [[ $@ != "" ]]; then
    # For debug.
    exec $@
fi

: ${GERRIT_MASTER_URL_SCHEME:=http}
: ${GERRIT_MASTER_HOST:=gerrit.wikimedia.org}
: ${GERRIT_MASTER_PORT:=8080}
: ${GERRIT_MASTER_ADMIN_USER:=root}
: ${GERRIT_MASTER_ADMIN_PASS:=pass}
: ${GIT_BACKEND_URL_SCHEME:=http}
: ${GIT_BACKEND_HOST:=git-backend.gerrit-replica.svc.local}
: ${GIT_BACKEND_PORT:=8080}
: ${GIT_BACKEND_ADMIN_USER:=backroot}
: ${GIT_BACKEND_ADMIN_PASS:=backpass}


if [[ $GERRIT_MASTER_ADMIN_USER != "" ]]; then
    GERRIT_MASTER_CRED="${GERRIT_MASTER_ADMIN_USER}:${GERRIT_MASTER_ADMIN_PASS}@"
    GERRIT_MASTER_API_PATH="/a/projects/?all"
else
    GERRIT_MASTER_CRED=""
    GERRIT_MASTER_API_PATH="/r/projects/?all"
fi
GERRIT_MASTER_URL="${GERRIT_MASTER_URL_SCHEME}://${GERRIT_MASTER_CRED}${GERRIT_MASTER_HOST}:${GERRIT_MASTER_PORT}${GERRIT_MASTER_API_PATH}"


GIT_BACKEND_URL="${GIT_BACKEND_URL_SCHEME}://${GIT_BACKEND_ADMIN_USER}:${GIT_BACKEND_ADMIN_PASS}@${GIT_BACKEND_HOST}:${GIT_BACKEND_PORT}/new"


while read repo; do
    curl "${GIT_BACKEND_URL}/${repo}" 2> /dev/null
done < <(curl -sL ${GERRIT_MASTER_URL} | \
    tail -c +6 | \
    jq -r '.|to_entries|map(select(.value.state == "ACTIVE"))|.[].key')
