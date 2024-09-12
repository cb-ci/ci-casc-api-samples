#! /bin/bash

curl -s -X POST -u $TOKEN ${CJOC_URL}/cjoc/casc-bundle/check-out |jq
sleep 20
curl -s -X GET -u $TOKEN ${CONTROLLER_URL}/casc-bundle-mgnt/check-bundle-update |jq
curl -s -X POST -u $TOKEN ${CONTROLLER_URL}/casc-bundle-mgnt/reload-bundle |jq
#curl -s -X POST -u $TOKEN ${CONTROLLER_URL}/safeRestart
#curl -X POST -u  $TOKEN ${CONTROLLER_URL}/restart
#curl -X POST ${CONTROLLER_URL}/reload -u $TOKEN
