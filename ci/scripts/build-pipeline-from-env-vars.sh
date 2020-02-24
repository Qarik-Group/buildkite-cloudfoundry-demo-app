#!/bin/bash

set -eu

env | sort

cat <<YAML
steps:
- block: "Deploy"
  prompt: "Deploy to production?"
YAML
