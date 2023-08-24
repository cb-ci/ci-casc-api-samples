#! /bin/bash


source ./envvars.sh
#env | sort
#
#curl -s  -u $TOKEN "$CJOC_URL/view/all/job/Teams/api/json?depth=2&pretty=true?tree=jobs" | jq

ALL_CONTROLLERS_JSON=allcontrollers.json
echo "Get all controllers to a local file $ALL_CONTROLLERS_JSON"
curl -o $ALL_CONTROLLERS_JSON -s  -u $TOKEN "$CJOC_URL/view/Controllers/api/json?depth=2&pretty=true" | jq
#cat $ALL_CONTROLLERS_JSON

echo "Get all Team Controllers"
cat $ALL_CONTROLLERS_JSON | jq -c '.jobs[] | select( .url | contains("job/Teams/job/"))' | jq

echo "Get just names and urls for all Team Controllers "
cat $ALL_CONTROLLERS_JSON | jq -c '.jobs[] | select( .url | contains("job/Teams/job/"))' | jq '.name,.url'


echo "Get all Managed Controllers"
cat $ALL_CONTROLLERS_JSON | jq -c '.jobs[] | select( .url | contains("job/Teams/job/") | not)' | jq

echo "Get just names and urls for all Managed Controllers"
cat $ALL_CONTROLLERS_JSON | jq -c '.jobs[] | select( .url | contains("job/Teams/job/") | not)' | jq '.name,.url'



