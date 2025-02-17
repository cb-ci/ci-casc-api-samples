#! /bin/bash

export TOKEN="<ADMIN_ID>:<TOKENXXXXXX>"
export CJOC_URL="https://<CJOC_URL>"
export SHARED_AGENT_NAME="mySharedAgent"
export SHARED_AGENT_REMOTE_FS="/tmp"

# Create a gen dir where to render the template to
GEN_DIR=gen
rm -rf $GEN_DIR
mkdir -p $GEN_DIR

# We render the CasC template instances for the item (sharedAgent)
# All variables from the envvars.sh will be substituted
envsubst < templates/sharedAgent.yaml > $GEN_DIR/sharedAgent.yaml

# see https://docs.cloudbees.com/docs/cloudbees-ci-api/latest/bundle-management-api
echo "------------------  CREATE/UPDATE SHARED AGENT ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CJOC_URL}/casc-items/create-items" \
    -H "Content-Type:text/yaml" \
   --data-binary @${GEN_DIR}/sharedAgent.yaml

#see https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/client-and-managed-controllers/how-to-find-agent-secret-key#_operations_center_shared_agents
echo "def sharedAgent = Jenkins.getInstance().getItems(com.cloudbees.opscenter.server.model.SharedSlave.class).find { it.launcher != null && it.launcher.class.name == 'com.cloudbees.opscenter.server.jnlp.slave.JocJnlpSlaveLauncher' && it.name == '$SHARED_AGENT_NAME'}; return sharedAgent?.launcher.getJnlpMac(sharedAgent)" > agent_secret.groovy
AGENT_SECRET=$(curl -XPOST --data-urlencode  "script=$(cat ./agent_secret.groovy)" -L -s --user $TOKEN $CJOC_URL/scriptText)
AGENT_SECRET=$(echo $AGENT_SECRET | sed "s#Result: ##g")
echo  "AGENT SECRET FOR $AGENT_NAME : $AGENT_SECRET"

#Create agent workspace
mkdir -p $SHARED_AGENT_NAME/remoting
curl -sO $CJOC_URL/jnlpJars/agent.jar
chmod a+x agent.jar
#Launch agent
java -jar agent.jar -url $CJOC_URL -name $SHARED_AGENT_NAME -secret $AGENT_SECRET -workDir $SHARED_AGENT_REMOTE_FS -webSocket
#nohup java -jar agent.jar -url $CJOC_URL -name $SHARED_AGENT_NAME -secret $AGENT_SECRET -workDir $SHARED_AGENT_REMOTE_FS -webSocket  2>&1 & > /dev/null
#echo $! > $AGENT_NAME.pid
#tail -f nohup.out
