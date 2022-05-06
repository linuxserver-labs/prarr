#!/bin/bash

APP="$1"
PULL_REQUEST_BRANCH="$2"

declare -A portmap=(["radarr"]="7878" ["readarr"]="8787" ["prowlarr"]="9696" ["lidarr"]="8686" ["whisparr"]="6969")

if [ -z "${PULL_REQUEST_BRANCH}" ]; then
    PULL_REQUEST_BRANCH=$(curl -fsSL "https://api.github.com/repos/${APP^}/${APP^}/pulls?state=open&base=develop&sort=updated&direction=desc" | jq -r --arg REPO "${APP^}/${APP^}" '[.[] | select((.head.repo.full_name == $REPO) and(.head.ref | contains("dependabot") | not)) | .head.ref] | first')
fi

PULL_REQUEST_RELEASE=$(curl -fsSL "https://${APP}.servarr.com/v1/update/${PULL_REQUEST_BRANCH}/changes?os=linuxmusl&runtime=netcore&arch=x64" | jq -r '.[0].version')

echo "${PULL_REQUEST_BRANCH}"
echo "${PULL_REQUEST_RELEASE}"
echo "${portmap[$APP]}"
