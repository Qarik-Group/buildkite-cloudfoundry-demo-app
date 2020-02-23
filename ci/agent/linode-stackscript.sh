#!/bin/sh

# This script is the StackScript for Linode

exec >/var/log/stackscript.log 2>&1

set -eux

# <UDF name="buildkite_token" Label="Buildkite account token" />

apk add docker bash git

rc-update add docker boot
service docker start

TOKEN="$BUILDKITE_TOKEN" bash -c "`curl -sL https://raw.githubusercontent.com/buildkite/agent/master/install.sh`"

BUILDKITE_DIR=/root/.buildkite-agent

export BUILDKITE_AGENT_NAME="linode-$LINODE_ID-dc-$LINODE_DATACENTERID"
sed -i "s/name=.*$/name=\"$BUILDKITE_AGENT_NAME\"/g" $BUILDKITE_DIR/buildkite-agent.cfg

# Create buildkite user/group
addgroup -g 100000 buildkite
adduser -G docker -G buildkite -u 100000 -D buildkite

# TODO: create /etc/init.d/buildkite-agent
curl -L https://raw.githubusercontent.com/starkandwayne/buildkite-cloudfoundry-demo-app/master/ci/agent/buildkite-agent.openrc.sh > /etc/init.d/buildkite-agent
chmod +x /etc/init.d/buildkite-agent
rc-update add buildkite-agent
service buildkite-agent start