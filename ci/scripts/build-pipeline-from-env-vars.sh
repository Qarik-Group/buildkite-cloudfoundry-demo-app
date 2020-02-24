#!/bin/bash

set -eu

env | sort >&2

cat <<YAML
steps:
- block: "Deploy"
  prompt: "Deploy to production?"
YAML
