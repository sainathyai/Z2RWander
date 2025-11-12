#!/bin/sh
# Wait for Redis to be ready

set -e

host="$1"
port="$2"
shift 2
cmd="$@"

until redis-cli -h "$host" -p "$port" ping > /dev/null 2>&1; do
  >&2 echo "Redis is unavailable - sleeping"
  sleep 1
done

>&2 echo "Redis is up - executing command"
exec $cmd

