#! /bin/bash

source ./envvars.sh
export CONTROLLER_NAME=${1:-$CONTROLLER_NAME}
export CONTROLLER_URL=${BASE_URL}"/"${CONTROLLER_NAME}

GEN_DIR=gen
rm -rf $GEN_DIR
mkdir -p $GEN_DIR

ALL_CONTROLLERS_JSON=allcontrollers.json

echo "Get all controllers to a local file $ALL_CONTROLLERS_JSON"
curl -o $ALL_CONTROLLERS_JSON -s  -u $TOKEN "$CJOC_URL/view/Controllers/api/json?depth=2&pretty=true" | jq

echo "Verify if $CONTROLLER_NAME controller exist and is attached to CJOC"
if [ -n $(cat $ALL_CONTROLLERS_JSON | jq -c ".jobs[] | select( .name | contains($CONTROLELR))") ]
then

  echo "$CONTROLLER_NAME controller exist, will be deleted now from CJOC"
  PATH_MANAGED_CONTROLLER="job/$CONTROLLER_NAME"
  PATH_TEAM_CONTROLLER="job/Teams/job/$CONTROLLER_NAME"

  #For Managed Controllers use this path
  PATH_CONTROLLER=$PATH_MANAGED_CONTROLLER

  #For Team Controllers use this path
  #PATH_CONTROLLER=$PATH_TEAM_CONTROLLER

  #We assume here that the controller is online
  # As the $ALL_CONTROLLERS_JSON file with jq to check the connection state
  # in case you want to delete offline controllers you need to skip this step
  echo "force stop Controller $CONTROLLER_NAME"
  curl  -v -XPOST  -u $TOKEN "$CJOC_URL/$PATH_CONTROLLER/stopAction"
  sleep 10
  echo "delete Controller $CONTROLLER_NAME"
  curl  -v -XPOST -u $TOKEN "$CJOC_URL/$PATH_CONTROLLER/doDelete"
else
  echo "$CONTROLLER_NAME is not connected to CJOC, nothing to do"
fi

