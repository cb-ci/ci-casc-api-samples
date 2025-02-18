#! /bin/bash

source ./envvars.sh

#export CONTROLLER_NAME=${1:-$CONTROLLER_NAME}


export MB_JOB_NAME=${1:-"MY_NEW_MB_JOB"}
export MB_JOB_REPO_OWNER=${2:-"REPOOWNER"}
export MB_JOB_REPO_NAME=${3:-"REPONAME"}
export MB_JOB_REPO_URL=${4:-"REPOURL"}
export CONTROLLER_URL=${5-:"REPO_GIT_URL"}
export TOKEN="USER:TOKEN"
export FOLDER_PATH="/Pipeline-Demo"

GEN_DIR=gen
rm -rf $GEN_DIR
mkdir -p $GEN_DIR

# We render the CasC template instances for the casc-folder (target folder)
# All variables from the envvars.sh will be substituted
envsubst < templates/create-mb-job-template.yaml > $GEN_DIR/${MB_JOB_NAME}.yaml

echo "------------------  CREATING MANAGED CONTROLLER ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CONTROLLER_URL}/casc-items/create-items?path=${FOLDER_PATH}" \
    -H "Content-Type:text/yaml" \
   --data-binary @$GEN_DIR/${MB_JOB_NAME}.yaml
