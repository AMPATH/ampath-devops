#!/usr/bin/env bash
set -euo pipefail
set +x

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

cd $ROOT_DIR
ci/levant deploy -address=$NOMAD_ADDRESS -var "job_name=$1" ci/dev-workflows/templates/etl.nomad

echo $BRANCH " etl job deployed successful"

