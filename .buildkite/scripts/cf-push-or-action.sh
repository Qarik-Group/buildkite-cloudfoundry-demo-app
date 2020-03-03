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
app_guid=$(cf app "$CF_APPNAME" --guid)
# TODO: set reap-me-after annotation
annotation=cf.starkandwayne.com/reap-me-after
reap_timestamp="2020-03-04"
echo "Setting annotation $annotation=$reap_timestamp"
annotation_json=$(jq -rc --arg annotation "$annotation" --arg timestamp "$reap_timestamp" '.[$annotation] = $timestamp' <<< '{}')
patch_json=$(jq -rc '{"metadata": {"annotations": .}}' <<< "$annotation_json")
( set -x; cf curl "/v3/apps/$app_guid" -X PATCH -d "$patch_json")
