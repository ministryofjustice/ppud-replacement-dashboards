#!/bin/bash
set -euo pipefail

function check_dep {
  if ! command -v "${1}" &>/dev/null; then
    echo "You need '${1}' - '${2}'"
    exit 1
  fi
}

# Check dependencies
check_dep "psql" "brew install postgresql"
check_dep "jq" "brew install jq"
check_dep "kubectl" "asdf install kubectl 1.19.15"

K8S_NAMESPACE="ppud-replacement-dev"
PFP_NAME="ppud-replacement-dashboards-db-proxy-$(whoami | tr ._ -)"
SECRET=dashboards-database

DB_HOST=$(kubectl -n "${K8S_NAMESPACE}" get secret "${SECRET}" -o json | jq -r '.data.host | @base64d')
DB_PORT=$(kubectl -n "${K8S_NAMESPACE}" get secret "${SECRET}" -o json | jq -r '.data.port | @base64d')
DB_USER=$(kubectl -n "${K8S_NAMESPACE}" get secret "${SECRET}" -o json | jq -r '.data.username | @base64d')
DB_PASS=$(kubectl -n "${K8S_NAMESPACE}" get secret "${SECRET}" -o json | jq -r '.data.password | @base64d')
DB_NAME=$(kubectl -n "${K8S_NAMESPACE}" get secret "${SECRET}" -o json | jq -r '.data.dbname | @base64d')
LOCAL_PORT=54321

echo "Connecting to ${K8S_NAMESPACE}"

set +e
PFP_COUNT=$(kubectl -n "${K8S_NAMESPACE}" get pods | grep -c "${PFP_NAME}")
set -e

if [ "${PFP_COUNT}" -eq "0" ]; then
  echo "Starting up port forward pod..."

  kubectl -n "${K8S_NAMESPACE}" run \
    "${PFP_NAME}" \
    --image=ministryofjustice/port-forward \
    --port="${DB_PORT}" \
    --env="REMOTE_HOST=${DB_HOST}" \
    --env="LOCAL_PORT=${DB_PORT}" \
    --env="REMOTE_PORT=${DB_PORT}"

  sleep 5
fi

set +e
cmd="kubectl -n ${K8S_NAMESPACE} port-forward ${PFP_NAME} ${LOCAL_PORT}:${DB_PORT}"
pid=$(pgrep -f "${cmd}")
set -e

echo "You can now connect to the database on 127.0.0.1:${LOCAL_PORT} - username: ${DB_USER} - password: ${DB_PASS}"
echo "or..."
echo "export DATABASE_URL=postgres://${DB_USER}:${DB_PASS}@127.0.0.1:${LOCAL_PORT}/${DB_NAME}"

# if the port-forward isn't already running, start it...
if [[ -z "${pid}" ]]; then
  ${cmd}
fi
