#! /bin/bash

source ./envvars.sh
export CONTROLLER_NAME=${1:-$CONTROLLER_NAME}
export CONTROLLER_URL=${BASE_URL}"/"${CONTROLLER_NAME}

GEN_DIR=gen
rm -rf $GEN_DIR
mkdir -p $GEN_DIR

# We render the CasC template instances for cjoc-controller-items.yaml  and the casc-folder (target folder)
# All variables from the envvars.sh will be substituted
envsubst < ${CREATE_MM_TEMPLATE_YAML} > $GEN_DIR/${CONTROLLER_NAME}.yaml
#envsubst < ${CREATE_MM_FOLDER_TEMPLATE_YAML} > $GEN_DIR/${CONTROLLER_NAME}-folder.yaml

ALL_CONTROLLERS_JSON=allcontrollers.json

echo "Get all controllers to a local file $ALL_CONTROLLERS_JSON"
curl -o $ALL_CONTROLLERS_JSON -s  -u $TOKEN "$CJOC_URL/view/Controllers/api/json?depth=2&pretty=true" | jq

echo "Verify if $CONTROLLER_NAME controller exist"
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
fi


echo "Verify if PVC ${CONTROLLER_NAME}-0  exist"
if [ -n "$(kubectl get pvc jenkins-home-$CONTROLLER_NAME-0)" ]
then
  #see https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/operations-center/how-to-delete-a-managed-controller-in-cloudbees-jenkins-enterprise-and-cloudbees-core
   echo "PVC jenkins-home-$CONTROLLER_NAME-0 exist, will be deleted now"
   kubectl delete pvc jenkins-home-$CONTROLLER_NAME-0
fi

echo "------------------  CREATING MANAGED CONTROLLER ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CJOC_URL}/casc-items/create-items" \
    -H "Content-Type:text/yaml" \
   --data-binary @$GEN_DIR/${CONTROLLER_NAME}.yaml