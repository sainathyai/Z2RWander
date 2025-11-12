#!/bin/sh
# Wait for API to be ready

set -e

url="$1"
shift
cmd="$@"

until curl -f "$url/health" > /dev/null 2>&1; do
  >&2 echo "API is unavailable - sleeping"
  sleep 1
done

>&2 echo "API is up - executing command"
exec $cmd

