#!/bin/bash

# USAGE: ./cf-push-or-action.sh
# To delete the app: CF_ACTION=delete ./cf-push-or-action.sh

set -eu

[[ "${CF_ROUTE_SELECTOR:-X}" == "X" ]] || {
  CF_ROUTE="${!CF_ROUTE_SELECTOR}"
}
: "${CF_ROUTE:?required}"

if [[ "${CF_ACTION:-push}" == "delete" ]]; then
  ( set -x; cf delete buildkite-cloudfoundry-demo-app -f )
else
  ( set -x; cf push --var route="${CF_ROUTE}" )
fi
