#!/bin/bash

# USAGE: ./cf-push-or-action.sh
# To delete the app: CF_ACTION=delete ./cf-push-or-action.sh

set -eu

if [[ "${CF_ACTION:-push}" == "delete" ]]; then
  ( set -x; cf delete buildkite-cloudfoundry-demo-app -f )
else
  ( set -x; cf push --var route="${CF_ROUTE}" )
fi
