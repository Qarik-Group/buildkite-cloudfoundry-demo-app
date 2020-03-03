#!/bin/bash

set -eu

WAIT_TO_REAP_APP=${WAIT_TO_REAP_APP:-10}
echo "Waiting ${WAIT_TO_REAP_APP}s to reap routes and possibly app"

for((i=0;i<WAIT_TO_REAP_APP;i++));
do
  sleep 1
  buildkite-agent meta-data exists user-wants-to-keep-app 2>/dev/null && {
    echo "User has requested we keep the application."
    exit 0
  }
  echo "."
done
echo

echo "Deleting route..."
cf_route=$(buildkite-agent meta-data get cf-route-for-build)
sleep 1
echo "No routes remain; deleting app..."
