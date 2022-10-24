#!/usr/bin/env bash
# Script to download asset file from tag release using GitHub API v3.
# See: http://stackoverflow.com/a/35688093/55075    
CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

# Check dependencies.
set -e
type curl grep sed tr >&2
xargs=$(which gxargs || which xargs)

# Validate settings.
[ -f ~/.secrets ] && source ~/.secrets
[ $# -lt 1 ] && { echo "Usage: $0 owner/repo [(tag)] [(name)]"; exit 1; }
[ "$TRACE" ] && set -x

if [[ -z ${GITHUB_API_TOKEN} ]]; then
    read -sp 'Github Token: ' GITHUB_API_TOKEN
fi
[ "$GITHUB_API_TOKEN" ] || { echo "Error: please provide your token." >&2; exit 1; }

read repo tag name <<<$@

release_tag=latest

if [[ ! -z ${tag} ]]; then
    release_tag=tags/$tag
fi

GH_API="https://api.github.com"
GH_REPO="$GH_API/repos/$repo"

GH_TAGS="$GH_REPO/releases/$release_tag"

AUTH="Authorization: token $GITHUB_API_TOKEN"
WGET_ARGS="--content-disposition --auth-no-challenge --no-cookie"
CURL_ARGS="-LJO#"

# Validate token.
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

# Read asset tags.
response=$(curl -sH "$AUTH" $GH_TAGS)
# Get ID of the asset based on given name.
eval $(echo "$response" | grep -C3 "name.:.\+$name" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
#id=$(echo "$response" | jq --arg name "$name" '.assets[] | select(.name == $name).id') # If jq is installed, this can be used instead. 
[ "$id" ] || { echo "Error: Failed to get asset id, response: $response" | awk 'length($0)<100' >&2; exit 1; }
GH_ASSET="$GH_REPO/releases/assets/$id"

# Download asset file.
echo "Downloading asset..." >&2
curl $CURL_ARGS -H "Authorization: token $GITHUB_API_TOKEN" -H 'Accept: application/octet-stream' "$GH_ASSET"
echo "$0 done." >&2