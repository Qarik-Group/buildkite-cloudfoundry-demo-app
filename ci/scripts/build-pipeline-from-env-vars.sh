#!/bin/bash

set -eu

if [[ -n "${CF_ROUTE:-}" && -n "${CF_SPACE:-}" ]]; then
  echo "Configuring for single deployment" >&2
  cat <<YAML
steps:
  - label: ":cloudfoundry:"
    command: "ci/scripts/cf-push-or-action.sh"
    artifact_paths: "."
    concurrency: 1
    concurrency_group: "cf-push"
    plugins:
      - docker#v3.5.0:
          image: "starkandwayne/update-all-cf-buildpacks:latest"
          propagate-environment: true
    timeout_in_minutes: 5
    env:
      CF_API: ""
      CF_SKIP_SSL_VALIDATION: ""
      CF_USERNAME: ""
      CF_PASSWORD: ""
YAML
else
  cat <<YAML
steps:
- block: "Deploy"
  prompt: "Deploy to production?"
YAML
fi