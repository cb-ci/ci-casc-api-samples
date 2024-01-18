#! /bin/bash

##Example: Create agents in a loop
# for i in {1..3};do ./createStaticInboundAgent.sh $(hostname)-$i;done

#Example: Kill all create created agent processes
## for i in $(find . -name "*.pid");do cat  $i| xargs kill -15 ;done

echo "Usage: $0 <AGENT_NAME> <AGENT_LABEL>"

AGENT_NAME=${1:-"$(hostname)-1"}
AGENT_LABEL=${2:-"inbound"}
REMOTE_FS_DIR=$(pwd)/$AGENT_NAME
TOKEN="user:jenkinstoken"
HOST="https://CONTROLLER_URL"


##Download jenkins-cli
#curl -O $HOST/jnlpJars/jenkins-cli.jar
chmod a+x jenkins-cli.jar

#copy agent node and create config on Controller
#java -jar jenkins-cli.jar -auth $TOKEN  -s $HOST get-node inbound1| java -jar jenkins-cli.jar -auth $TOKEN  -s $HOST create-node inbound3

#Create Agent node on Controller
cat << EOF | java -jar jenkins-cli.jar -auth $TOKEN  -s $HOST create-node ${AGENT_NAME}
<?xml version="1.1" encoding="UTF-8"?>
<slave>
  <name>${AGENT_NAME}</name>
  <description></description>
  <remoteFS>$REMOTE_FS_DIR</remoteFS>
  <numExecutors>1</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="com.cloudbees.jenkins.plugins.replication.builds.ReplicatedRetentionStrategy" plugin="cloudbees-replication@1292"/>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>false</disabled>
      <workDirPath>$REMOTE_FS_DIR</workDirPath>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
    <webSocket>true</webSocket>
  </launcher>
  <label>$AGENT_LABEL</label>
  <nodeProperties/>
</slave>
EOF

#Get created node config and display
java -jar jenkins-cli.jar -auth $TOKEN -s $HOST get-node ${AGENT_NAME}
echo "\n"

#Get node secret
#https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/client-and-managed-controllers/how-to-find-agent-secret-key
#https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/client-and-managed-controllers/execute-groovy-with-a-rest-call
echo "jenkins.model.Jenkins.getInstance().getComputer('$AGENT_NAME').getJnlpMac()" > agent_secret.groovy
AGENT_SECRET=$(curl -XPOST --data-urlencode  "script=$(cat ./agent_secret.groovy)" -L -s --user $TOKEN $HOST/scriptText)
AGENT_SECRET=$(echo $AGENT_SECRET | sed "s#Result: ##g")
echo  "AGENT SECRET FOR $AGENT_NAME : $AGENT_SECRET"

#Create agent workspace
mkdir -p $AGENT_NAME/remoting
curl -sO $HOST/jnlpJars/agent.jar
chmod a+x agent.jar
#Launch agent
nohup java -jar agent.jar -jnlpUrl $HOST/computer/$AGENT_NAME/jenkins-agent.jnlp -secret $AGENT_SECRET -workDir "$REMOTE_FS_DIR" -failIfWorkDirIsMissing  2>&1 & > /dev/null
echo $! > $AGENT_NAME.pid
tail -f nohup.out
#Send in background,better create service later-on TODO
#nohub java -jar agent.jar  ......   2>&1 & > /dev/null