#!/bin/sh
set -e

if !(restic cat config); then
    echo "repository does not exist, initializing..."
    restic init
    mkdir -p /alloc/git
    chown -R 1000:1000 /alloc/git
    # create at least one snapshot to avoid empty repository
    restic backup /alloc/git
fi

exec crond -f -d 8 -c /local/crontabs
