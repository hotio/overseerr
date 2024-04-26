#!/bin/bash
version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/sct/overseerr/commits/develop" | jq -re .sha) || exit 1
[[ -z ${version} ]] && exit 0
[[ ${version} == null ]] && exit 0
message=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/sct/overseerr/commits/${version}" | jq -re .commit.message) || exit 1
[[ ${message} == *"[skip ci]"* ]] && exit 0
json=$(cat VERSION.json)
jq --sort-keys \
    --arg version "${version//v/}" \
    '.version = $version' <<< "${json}" | tee VERSION.json
