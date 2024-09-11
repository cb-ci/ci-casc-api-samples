#! /bin/bash

source ./envvars.sh

###NOTE:
#to create a PTC Job instance by casc it requires to setup a PCT first in jenkins.yaml of the CONTROLLER
#example for jenkins.yaml
#globalCloudBeesPipelineTemplateCatalog:
#  catalogs:
#  - branchOrTag: "main"
#    scm:
#      git:
#        credentialsId: "ci-template-gh-app"
#        id: "0bcc6b4a-bf1f-4549-af9a-27f5eff23e1d"
#        remote: "https://github.com/cb-ci-templates/ci-templates.git"
#    updateInterval: "1d"


echo "USage: $0: testcontroller mytestjob"

export CONTROLLER_NAME=${1:-$CONTROLLER_NAME}
export CONTROLLER_URL=${BASE_URL}"/"${CONTROLLER_NAME}
export JOB_NAME=${2:-$JOB_NAME}
GEN_DIR=gen
rm -rf $GEN_DIR
mkdir -p $GEN_DIR

# We render the CasC template instances for the casc-folder (target folder)
# All variables from the envvars.sh will be substituted
envsubst < templates/create-PTC-job-instance.yaml > $GEN_DIR/${JOB_NAME}.yaml

echo "------------------  CREATING MANAGED CONTROLLER ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CONTROLLER_URL}/casc-items/create-items" \
    -H "Content-Type:text/yaml" \
   --data-binary @$GEN_DIR/${JOB_NAME}.yaml
