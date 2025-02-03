#!/bin/sh
set -e

if !(restic cat config); then
    echo "repository does not exist, initializing..."
    restic init
    mkdir -p /alloc/data/vaultwarden
    # create at least one snapshot to avoid empty repository
    restic backup /alloc/data/vaultwarden
fi

exec crond -f -d 8 -c /local/crontabs