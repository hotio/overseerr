#!/bin/bash
set -e
version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/sct/overseerr/commits/develop" | jq -re .sha)
message=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/sct/overseerr/commits/${version}" | jq -re .commit.message)
[[ ${message} == *"[skip ci]"* ]] && exit 0
json=$(cat VERSION.json)
jq --sort-keys \
    --arg version "${version//v/}" \
    '.version = $version' <<< "${json}" | tee VERSION.json
