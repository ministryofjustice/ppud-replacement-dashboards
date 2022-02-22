#!/bin/bash
set -euo pipefail

function check_dep {
  if ! command -v "${1}" &>/dev/null; then
    echo "You need '${1}' - '${2}'"
    exit 1
  fi
}

function wait_for_db {
  printf "Waiting for postgres to be ready."
  until pg_isready -q -h "127.0.0.1" -p 5432; do
    printf "."
    sleep 1
  done
  printf "\n"
}

# Check dependencies
check_dep "kubectl" "asdf install kubectl 1.19.15"
check_dep "pg_isready" "brew install postgresql"

# Start the database
docker compose up -d db
wait_for_db

set +e
pkill kubectl
set -e

# Port-forward manage-recalls-api
export MANAGE_RECALLS_API_DEV=http://localhost:9090
export MANAGE_RECALLS_API_PREPROD=http://localhost:9091
export MANAGE_RECALLS_API_PROD=http://localhost:9092

kubectl -n manage-recalls-dev port-forward svc/manage-recalls-api 9090:81 &
kubectl -n manage-recalls-preprod port-forward svc/manage-recalls-api 9091:81 &
kubectl -n manage-recalls-prod port-forward svc/manage-recalls-api 9092:81 &

# Start the app
bundle exec rake db:migrate
bundle exec smashing start

# Clean up
set +e
pkill kubectl
set -e
docker compose down
