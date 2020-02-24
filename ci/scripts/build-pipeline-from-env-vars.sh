#!/bin/bash

set -eu

cat <<YAML
steps:
- block: "Deploy"
  prompt: "Deploy to production?"
YAML
