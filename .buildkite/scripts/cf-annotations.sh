#!/bin/bash

set -eu

: "${CF_APPNAME:?required}"

echo
echo "Setting annotations on app $CF_APPNAME..."

APP_GUID="$(cf app "$CF_APPNAME" --guid)"
APP_URI="/v3/apps/${APP_GUID}"

commit_sha="$(git rev-parse --short HEAD)"
origin_url="$(git config remote.origin.url)"

annotation_json='{}'
annotation_json=$(jq -rc --arg annotation "git-commit" --arg value "$commit_sha" '.[$annotation] = $value' <<< "$annotation_json")
annotation_json=$(jq -rc --arg annotation "git-origin-url" --arg value "$origin_url" '.[$annotation] = $value' <<< "$annotation_json")

patch_json=$(jq -rc '{"metadata": {"annotations": .}}' <<< "$annotation_json")
( set -x; cf curl "$APP_URI" -X PATCH -d "$patch_json")
