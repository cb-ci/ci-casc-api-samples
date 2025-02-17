#! /bin/bash

export TOKEN="<ADMIN_ID>:<TOKENXXXXXX>"
export CJOC_URL="https://<CJOC_URL>"
export SHARED_AGENT_NAME="mySharedAgent"
export SHARED_AGENT_REMOTE_FS="/tmp"


echo "------------------  RENDER SHARED_AGENT ITEM YAML ------------------"
#see https://docs.cloudbees.com/docs/cloudbees-ci/latest/casc-oc/items#_example_items_yaml_file
# We render the CasC template instances for the item (sharedAgent)
# All variables  will be substituted
cat << EOF > sharedAgent.yaml
removeStrategy:
  rbac: SYNC
  items: NONE
items:
- kind: sharedAgent
  name: ${SHARED_AGENT_NAME}
  description: ''
  displayName: ${SHARED_AGENT_NAME}
  labels: ''
  launcher:
    inboundAgent:
      webSocket: false
      workDirSettings:
        remotingWorkDirSettings:
          internalDir: remoting
          disabled: false
          failIfWorkDirIsMissing: false
  mode: NORMAL
  numExecutors: 1
  remoteFS: ${SHARED_AGENT_REMOTE_FS}
  retentionStrategy:
    sharedNodeRetentionStrategy: {}
EOF

echo "------------------  CREATE/UPDATE SHARED AGENT ------------------"
# see https://docs.cloudbees.com/docs/cloudbees-ci-api/latest/bundle-management-api
curl -v -XPOST \
   --user $TOKEN \
   "${CJOC_URL}/casc-items/create-items" \
    -H "Content-Type:text/yaml" \
   --data-binary @sharedAgent.yaml

echo "------------------  GET AGENT SECRET ------------------"
#see https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/client-and-managed-controllers/how-to-find-agent-secret-key#_operations_center_shared_agents
echo "def sharedAgent = Jenkins.getInstance().getItems(com.cloudbees.opscenter.server.model.SharedSlave.class).find { it.launcher != null && it.launcher.class.name == 'com.cloudbees.opscenter.server.jnlp.slave.JocJnlpSlaveLauncher' && it.name == '$SHARED_AGENT_NAME'}; return sharedAgent?.launcher.getJnlpMac(sharedAgent)" > agent_secret.groovy
AGENT_SECRET=$(curl -XPOST --data-urlencode  "script=$(cat ./agent_secret.groovy)" -L -s --user $TOKEN $CJOC_URL/scriptText)
AGENT_SECRET=$(echo $AGENT_SECRET | sed "s#Result: ##g")
echo  "AGENT SECRET FOR $AGENT_NAME : $AGENT_SECRET"


echo "------------------  START AGENT CONNECTION ------------------"
#Download agent.jar and start agent connection to CJOC sharedAgent
curl -sO $CJOC_URL/jnlpJars/agent.jar
chmod a+x agent.jar
#Launch agent
java -jar agent.jar -url $CJOC_URL -name $SHARED_AGENT_NAME -secret $AGENT_SECRET -workDir $SHARED_AGENT_REMOTE_FS -webSocket

#RUN in background
#nohup java -jar agent.jar -url $CJOC_URL -name $SHARED_AGENT_NAME -secret $AGENT_SECRET -workDir $SHARED_AGENT_REMOTE_FS -webSocket  2>&1 & > /dev/null
#echo $! > $AGENT_NAME.pid
#tail -f nohup.out
