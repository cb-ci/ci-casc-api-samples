#! /bin/bash

source ./envvars.sh

echo "USage: $0: testcontroller mytestfolder"

export CONTROLLER_NAME=${1:-$CONTROLLER_NAME}
export CONTROLLER_URL=${BASE_URL}"/"${CONTROLLER_NAME}
export FOLDER_NAME=${2:-$CONTROLLER_NAME}
GEN_DIR=gen
rm -rf $GEN_DIR
mkdir -p $GEN_DIR

# We render the CasC template instances for the casc-folder (target folder)
# All variables from the envvars.sh will be substituted
envsubst < ${CREATE_MM_FOLDER_TEMPLATE_YAML} > $GEN_DIR/${CONTROLLER_NAME}-folder.yaml

echo "------------------  CREATING MANAGED CONTROLLER ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CONTROLLER_URL}/casc-items/create-items" \
    -H "Content-Type:text/yaml" \
   --data-binary @$GEN_DIR/${CONTROLLER_NAME}-folder.yaml
