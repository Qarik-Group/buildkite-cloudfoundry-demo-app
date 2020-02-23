#!/bin/bash

[[ -x "$(command -v cf)" ]] || {
  echo "Must run on agent environment with 'cf' installed" >&2
  exit 1
}

cf version
