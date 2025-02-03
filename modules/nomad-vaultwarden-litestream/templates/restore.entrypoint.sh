#!/bin/sh
set -e

if restic cat config; then
    echo "repository exists, restoring to latest snapshot..."
    restic restore latest --target /
else
    echo "repository does not exist, skipping restoration..."
fi