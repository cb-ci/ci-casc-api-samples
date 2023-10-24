#! /bin/bash
source ./envvars.sh
export CONTROLLER_NAME=${1:-$CONTROLLER_NAME}
export CONTROLLER_URL=${BASE_URL}"/"${CONTROLLER_NAME}
PATH_MANAGED_CONTROLLER="job/$CONTROLLER_NAME"
PATH_TEAM_CONTROLLER="job/Teams/job/$CONTROLLER_NAME"
#For Managed Controllers use this path
PATH_CONTROLLER=$PATH_MANAGED_CONTROLLER
#For Team Controllers use this path
#PATH_CONTROLLER=$PATH_TEAM_CONTROLLER

echo "force stop Controller $CONTROLLER_NAME"
curl  -Ls -XPOST  -u $TOKEN "$CJOC_URL/$PATH_CONTROLLER/stopAction"

sleep 10

echo "delete Controller $CONTROLLER_NAME"
curl  -Ls -XPOST -u $TOKEN "$CJOC_URL/$PATH_CONTROLLER/doDelete"

echo "PVC jenkins-home-$CONTROLLER_NAME-0 exist, will be deleted now"
kubectl delete pvc jenkins-home-${CONTROLLER_NAME}-0