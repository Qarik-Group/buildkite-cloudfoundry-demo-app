#!/bin/bash

set -eu

CF_CLI_VERSION=${CF_CLI_VERSION:-6.49.0}

mkdir bin
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

cf version
