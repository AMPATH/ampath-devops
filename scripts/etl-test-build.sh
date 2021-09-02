#!/usr/bin/env bash
set -euo pipefail
set +x

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

# Arguements order:
# 1. BRANCH - Branch name, output file namee
# 2. FILE_PATH - File path to location configuration template
# 3. TARGET_DIR - Where to place the output conf file

isEmpty() {
  if [ -z "$1" ]
  then
    true
  else
    false
  fi
}

#Generate nginx configurations file
#Branch-name as the file name
createNginxConf() {
  sed "s/PORT/$1/;s/BRANCH/$1/" ${ETL_TEMPLATE_PATH} > $2/$1.conf
}

#Reload nginx service
reloadNginxService()  {
  # Reload service @nginx-test-build
  docker ps | grep 'test-build-task-'| awk '{print $1}'| xargs docker restart
}
# Wait for ETL job to come live
# Get the assigned port
# Grep docker service port
while true ; do
  PORT="$(docker ps | grep $1 | awk 'NR == 1' | awk '{print $1}' | xargs docker port |  awk 'NR == 1' | cut -d ":" -f2)"
  echo "${PORT}"
  if [ $PORT -gt 0 ]; then
    createNginxConf $PORT
    break
  fi
  sleep 5
done

reloadNginxService

#sed "s/PORT/${PORT}/;s/BRANCH/${BRANCH}/" ${FILE_PATH} > ${TARGET_DIR}/${BRANCH}.conf

# create the conf file
# sed "'s/PORT/$PORT/;s/BRANCH/$BRANCH/' $FILE_PATH > $BRANCH.conf"
# # move to the Target Dir
# mv $BRANCH.conf
#createNginxConf

#script call
#sh scripts/test-build-conf.sh HIV-400 files/etl-test-build.conf files/
echo "ETL test build $1 created successfully!"
