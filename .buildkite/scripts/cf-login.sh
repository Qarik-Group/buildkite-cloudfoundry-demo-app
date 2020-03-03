#!/bin/bash

# USAGE: ./cf-push-or-action.sh
# To delete the app: CF_ACTION=delete ./cf-push-or-action.sh
set -eu

: "${CF_API:?required}"
: "${CF_USERNAME:?required}"
: "${CF_PASSWORD:?required}"

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

CF_SKIP_SSL_VALIDATION=${CF_SKIP_SSL_VALIDATION+--skip-ssl-validation}
echo "+ cf api ${CF_API} ${CF_SKIP_SSL_VALIDATION}"
cf api "${CF_API}" ${CF_SKIP_SSL_VALIDATION}
echo

echo "+ cf auth ${CF_USERNAME} [redacted]"
cf auth "${CF_USERNAME}" "${CF_PASSWORD}"
echo

