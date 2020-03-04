#!/bin/bash

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
