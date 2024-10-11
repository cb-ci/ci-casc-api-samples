#! /bin/bash

source ./envvars.sh

#Example URL: https://example.com/cjoc/job/controller-0/export/download

## Add your cjoc admin user and jenins admin  token
#TOKEN="cjocadminuser:cjocadminjenkinstoken"

## Adjust your controller name
#CONTROLLER_NAME="controller-0"

## Operations Center URL
#CJOC_URL="https://example.com/cjoc"


# Download the items.yaml from CJOC that contains the specific Controller provisioning
# see API https://docs.cloudbees.com/docs/cloudbees-ci-api/latest/bundle-management-api
curl  -X POST  -u $TOKEN -sL -o cjoc-${CONTROLLER_NAME}-items.yaml \
      -H 'accept: text/html,application/xhtml+xml' \
      -H 'content-type: application/x-www-form-urlencoded' \
      "${CJOC_URL}/job/${CONTROLLER_NAME}/export/download"

#the result yaml looks like this
#      kind: managedController
#      name: controller-0
#      configuration:
#        kubernetes:
#          allowExternalAgents: true
#          terminationGracePeriodSeconds: 1200
#          image: CloudBees CI - Managed Controller - latest
#          ......


# BUT, we need it like this to be a vaild yaml that we can re apply

#      removeStrategy:
#        rbac: SYNC
#        items: NONE
#      items:
#      - kind: managedController
#        name: controller-0
#        configuration:
#          kubernetes:
#            allowExternalAgents: true
#            terminationGracePeriodSeconds: 1200
#            image: CloudBees CI - Managed Controller - latest
#            .......


# So we use yq to to add the missing header

yq eval '. | {"removeStrategy": {"rbac": "SYNC", "items": "NONE"}, "items": [.]}' cjoc-${CONTROLLER_NAME}-items.yaml > result-items.yaml



# Re-apply  the the items.yaml to the cjoc

curl  -XPOST \
   -u $TOKEN \
   "${CJOC_URL}/casc-items/create-items" \
    -H "Content-Type:text/yaml" \
   --data-binary @result-items.yaml
