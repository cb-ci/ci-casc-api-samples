#! /bin/bash

source ./envvars.sh
export CONTROLLER_NAME=${1:-$CONTROLLER_NAME}
export CONTROLLER_URL=${BASE_URL}"/"${CONTROLLER_NAME}

GEN_DIR=gen
rm -rf $GEN_DIR
mkdir -p $GEN_DIR

# We render the CasC template instances for cjoc-controller-items.yaml
# All variables from the envvars.sh will be substituted
envsubst < ${CREATE_MM_TEMPLATE_YAML} > $GEN_DIR/${CONTROLLER_NAME}.yaml
cat $GEN_DIR/${CONTROLLER_NAME}.yaml

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
   "${BASE_URL}/cjoc/casc-items/create-items" \
    -H "Content-Type:text/yaml" \
   --data-binary @$GEN_DIR/${CONTROLLER_NAME}.yaml
