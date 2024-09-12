#! /bin/bash

curl -s -X POST -u $TOKEN ${CJOC_URL}/cjoc/casc-bundle/check-out
#curl -s -X POST -u $TOKEN ${CONTROLLER_URL}/casc-bundle-mgnt/reload-bundle
