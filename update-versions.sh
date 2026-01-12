#!/bin/bash
set -exuo pipefail

version=$(curl -fsSL "https://api.github.com/repos/sct/overseerr/commits/develop" | jq -re .sha)
json=$(cat meta.json)
jq --sort-keys \
    --arg version "${version//v/}" \
    '.version = $version' <<< "${json}" | tee meta.json
