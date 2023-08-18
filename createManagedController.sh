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

if [ -n "$(kubectl get pvc jenkins-home-$CONTROLLER_NAME-0)" ]
then
  #see https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/operations-center/how-to-delete-a-managed-controller-in-cloudbees-jenkins-enterprise-and-cloudbees-core
   echo "PVC jenkins-home-$CONTROLLER_NAME-0 exist, JENKINS_HOME will be recreated by CASC"
   #TODO: delete/deprovisioning controller from cjoc
   #java -jar jenkins-cli.jar -auth admin:admin -s https://sda.acaternberg.flow-training.beescloud.com/cjoc/ managed-master-stop-and-deprovision $CONTROLLER_NAME
   #java -jar jenkins-cli.jar -auth admin:admin -s https://sda.acaternberg.flow-training.beescloud.com/cjoc/ delete-job $CONTROLLER_NAME
   kubectl delete pvc jenkins-home-$CONTROLLER_NAME-0
   #kubectl exec -ti ${CONTROLLER_NAME}-0 -- sh -c "rm -Rfv /var/jenkins_home/jobs/*"
fi

echo "------------------  CREATING MANAGED CONTROLLER ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CJOC_URL}/casc-items/create-items" \
    -H "Content-Type:text/yaml" \
   --data-binary @$GEN_DIR/${CONTROLLER_NAME}.yaml