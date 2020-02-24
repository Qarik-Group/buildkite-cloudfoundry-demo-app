#!/bin/bash

set -eu

if [[ -n "${CF_SPACE_PRODUCTION:-}" && -n "${CF_ROUTE_PRODUCTION:-}" ]]; then
  echo "Adding production to pipeline" >&2
  cat <<YAML
steps:
  - block: "Deploy"
    prompt: "Deploy to production?"

  - label: ":cloudfoundry: production"
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
      CF_SPACE_SELECTOR: CF_SPACE_PRODUCTION
      CF_ROUTE_SELECTOR: CF_ROUTE_PRODUCTION
YAML
else
  echo "steps: []"
fi