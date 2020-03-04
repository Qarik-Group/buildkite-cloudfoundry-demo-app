#!/bin/bash

# USAGE: ./cf-push-or-action.sh

set -eu

: "${CF_APPNAME:?required}"
: "${CF_MANIFEST:=manifest.yml}"
: "${CF_ORGANIZATION:?required}"

[[ "${CF_SPACE_SELECTOR:-X}" == "X" ]] || {
  CF_SPACE="${!CF_SPACE_SELECTOR}"
}
: "${CF_SPACE:?required}"

[[ "${CF_ROUTE_SELECTOR:-X}" == "X" ]] || {
  CF_ROUTE="${!CF_ROUTE_SELECTOR}"
}
: "${CF_ROUTE:?required}"

echo "+ cf target -o ${CF_ORGANIZATION} -s ${CF_SPACE}"
cf target -o "${CF_ORGANIZATION}" -s "${CF_SPACE}"
echo

( set -x; cf push "$CF_APPNAME" -f "${CF_MANIFEST}" --var route="${CF_ROUTE}" )

echo
APP_GUID="$(cf app "$CF_APPNAME" --guid)"
APP_URI="/v3/apps/${APP_GUID}"

reap_timestamp="2020-03-04"
commit_sha="$(git rev-parse --short HEAD)"

annotation_json=$(jq -rc --arg annotation "cf.starkandwayne.com/reap-me-after" --arg value "$reap_timestamp" '.[$annotation] = $value' <<< '{}')
annotation_json=$(jq -rc --arg annotation "git-commit" --arg value "$commit_sha" '.[$annotation] = $value' <<< "$annotation_json")

patch_json=$(jq -rc '{"metadata": {"annotations": .}}' <<< "$annotation_json")
( set -x; cf curl "$APP_URI" -X PATCH -d "$patch_json")
