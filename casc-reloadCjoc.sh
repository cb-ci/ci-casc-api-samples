C#! /bin/bash

#https://docs.cloudbees.com/docs/cloudbees-ci-api/latest/bundle-management-api

curl -s -X GET -u $TOKEN ${CJOC_URL}/cjoc/casc-bundle-mgnt/check-bundle-update > check-bundle-update.json
cat check-bundle-update.json | jq
#updateAvailable=$(jq '."update-available"' check-bundle-update.json)
#validBundle=$(jq '.versions."new-version".validations[]' check-bundle-update.json)


curl -s -X POST -u $TOKEN ${CJOC_URL}/cjoc/casc-bundle-mgnt/reload-bundle
