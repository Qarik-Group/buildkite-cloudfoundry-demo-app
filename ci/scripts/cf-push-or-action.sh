#!/bin/bash

# USAGE: ./cf-push-or-action.sh
# To delete the app: CF_ACTION=delete ./cf-push-or-action.sh

set -eu

CF_ORGANIZATION=${CF_ORGANIZATION:-$(buildkite-agent meta-data get cf-organization)}

[[ "${CF_SPACE_SELECTOR:-X}" == "X" ]] || {
  CF_SPACE="${!CF_SPACE_SELECTOR}"
}
[[ "${CF_ROUTE_SELECTOR:-X}" == "X" ]] || {
  CF_ROUTE="${!CF_ROUTE_SELECTOR}"
}

CF_SPACE=${CF_SPACE:-$(buildkite-agent meta-data get cf-space)}
CF_ROUTE=${CF_ROUTE:-$(buildkite-agent meta-data get cf-route)}

: ${CF_API:?required}
: ${CF_USERNAME:?required}
: ${CF_PASSWORD:?required}
: ${CF_ORGANIZATION:?required}
: ${CF_SPACE:?required}
: ${CF_ROUTE:?required}

CF_CLI_VERSION=${CF_CLI_VERSION:-6.49.0}

mkdir -p bin
export PATH=$PWD/bin:$PATH

[[ -x "$(command -v cf)" ]] || {
( set -x
  # FIXME - hard-coded $os
  os=linux64
  url="https://packages.cloudfoundry.org/stable?release=${os}-binary&version=${CF_CLI_VERSION}&source=github-rel"
  curl -L "$url" | tar -C bin -xvz cf
  chmod +x bin/cf
)
}

( set -x; cf version )

[[ "${CF_SKIP_SSL_VALIDATION:-X}" == "X" ]] || { export CF_SKIP_SSL_VALIDATION="--skip-ssl-validation"; }
echo "+ cf api \"${CF_API}\" ${CF_SKIP_SSL_VALIDATION}"
cf api "${CF_API}" ${CF_SKIP_SSL_VALIDATION}
echo

echo "+ cf auth \"${CF_USERNAME}\" [redacted]"
cf auth "${CF_USERNAME}" "${CF_PASSWORD}"
echo

echo "+ cf target -o \"${CF_ORGANIZATION}\" -s \"${CF_SPACE}\""
cf target -o "${CF_ORGANIZATION}" -s "${CF_SPACE}"
echo

if [[ "${CF_ACTION:-push}" == "delete" ]]; then
  echo "+ cf delete buildkite-cloudfoundry-demo-app"
  cf delete buildkite-cloudfoundry-demo-app -f
else
  echo "+ cf push --var route=${CF_ROUTE}"
  cf push --var route="${CF_ROUTE}"
fi
