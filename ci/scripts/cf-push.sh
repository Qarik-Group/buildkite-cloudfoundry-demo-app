#!/bin/bash

set -eu

CF_CLI_VERSION=${CF_CLI_VERSION:-6.49.0}
: ${CF_API:?required}
: ${CF_USERNAME:?required}
: ${CF_PASSWORD:?required}

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

echo cf api "${CF_API}" ${CF_SKIP_SSL_VALIDATION:=--skip-ssl-validation}
cf api "${CF_API}" ${CF_SKIP_SSL_VALIDATION:=--skip-ssl-validation}

echo cf login "${CF_USERNAME}" [redacted]
echo cf login "${CF_USERNAME}" "${CF_PASSWORD}"