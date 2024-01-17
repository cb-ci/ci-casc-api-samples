#! /bin/bash
AGENT_NAME="inbound4"
TOKEN="user:token"
HOST="https://CONTROLLER"

#copy agent and create
#java -jar jenkins-cli.jar -auth $TOKEN  -s $HOST get-node inbound1| java -jar jenkins-cli.jar -auth $TOKEN  -s $HOST create-node $AGENT_NAME


cat << EOF | java -jar jenkins-cli.jar -auth $TOKEN  -s $HOST create-node ${AGENT_NAME}
<?xml version="1.1" encoding="UTF-8"?>
<slave>
  <name>${AGENT_NAME}</name>
  <description></description>
  <remoteFS>/home/ec2-user/${AGENT_NAME}</remoteFS>
  <numExecutors>1</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="com.cloudbees.jenkins.plugins.replication.builds.ReplicatedRetentionStrategy" plugin="cloudbees-replication@1292"/>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>false</disabled>
      <workDirPath>/home/ec2-user/${AGENT_NAME}</workDirPath>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>true</failIfWorkDirIsMissing>
    </workDirSettings>
    <webSocket>true</webSocket>
  </launcher>
  <label>inbound</label>
  <nodeProperties/>
</slave>
EOF

#curl -O https://ci.acaternberg.pscbdemos.com/ha/jnlpJars/jenkins-cli.jar
chmod a+x jenkins-cli.jar
java -jar jenkins-cli.jar -auth $TOKEN  -s $HOST get-node ${AGENT_NAME}


#https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/client-and-managed-controllers/how-to-find-agent-secret-key
#https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/client-and-managed-controllers/execute-groovy-with-a-rest-call
echo 'jenkins.model.Jenkins.getInstance().getComputer("inbound1").getJnlpMac()' > agent_secret.groovy
echo -n "AGENT SECRET FOR $AGENT_NAME"
curl -XPOST --data-urlencode  "script=$(cat ./agent_secret.groovy)" -L --user $TOKEN $HOST/scriptText


