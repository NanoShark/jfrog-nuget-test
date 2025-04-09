#!/bin/bash

# Default variables
JENKINS_URL=${JENKINS_URL:-"http://jenkins:8080"}
AGENT_NAME=${AGENT_NAME:-"slave-agent"}
AGENT_SECRET=${AGENT_SECRET:-""}
AGENT_WORKDIR=${AGENT_WORKDIR:-"/home/jenkins"}

echo "Starting Jenkins Agent..."
echo "Jenkins URL: $JENKINS_URL"
echo "Agent Name: $AGENT_NAME"

# If agent secret is not provided, start in JNLP mode with auto-discovery
if [ -z "$AGENT_SECRET" ]; then
    echo "No agent secret provided. Waiting for Jenkins master to connect."
    echo "Jenkins will auto-discover this agent if properly configured."
    
    # Keep the container running for manual setup if needed
    tail -f /dev/null
else
    # Connect to Jenkins master with provided secret
    echo "Connecting to Jenkins master using provided secret..."
    java -jar agent.jar \
        -jnlpUrl ${JENKINS_URL}/computer/${AGENT_NAME}/slave-agent.jnlp \
        -secret ${AGENT_SECRET} \
        -workDir ${AGENT_WORKDIR}
fi