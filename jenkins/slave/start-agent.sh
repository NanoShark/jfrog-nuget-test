#!/bin/bash

# Default variables
JENKINS_URL=${JENKINS_URL:-"http://jenkins:8080"}
AGENT_NAME=${AGENT_NAME:-"jenkins-slave"}
AGENT_SECRET=${AGENT_SECRET:-""}
AGENT_WORKDIR=${AGENT_WORKDIR:-"/home/jenkins/workspace"}
MAX_RETRIES=30
RETRY_INTERVAL=10

echo "Starting Jenkins Agent..."
echo "Jenkins URL: $JENKINS_URL"
echo "Agent Name: $AGENT_NAME"
echo "Work Directory: $AGENT_WORKDIR"

# Create the workspace directory if it doesn't exist
mkdir -p ${AGENT_WORKDIR}

# Function to check if Jenkins is ready
function is_jenkins_ready() {
    # Check if Jenkins is fully started by looking for the login page
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" ${JENKINS_URL})
    if [ "$HTTP_CODE" = "200" ]; then
        # Further check that it's not the "Starting Jenkins" page
        if ! curl -s ${JENKINS_URL} | grep -q "Jenkins is getting ready to work"; then
            return 0  # Jenkins is ready
        fi
    fi
    return 1  # Jenkins is not ready
}

# Wait for Jenkins to be fully started
echo "Waiting for Jenkins master to be fully started..."
for i in $(seq 1 $MAX_RETRIES); do
    if is_jenkins_ready; then
        echo "Jenkins master is ready!"
        break
    fi
    
    if [ $i -eq $MAX_RETRIES ]; then
        echo "Timed out waiting for Jenkins to start after $((MAX_RETRIES * RETRY_INTERVAL)) seconds"
        exit 1
    fi
    
    echo "Jenkins not ready yet (attempt $i/$MAX_RETRIES), waiting $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
done

# Download the agent.jar file
echo "Downloading agent.jar from $JENKINS_URL/jnlpJars/agent.jar"
for i in $(seq 1 5); do
    curl -fsSL "$JENKINS_URL/jnlpJars/agent.jar" -o /home/jenkins/agent.jar && break
    echo "Failed to download agent.jar (attempt $i/5), retrying in 5 seconds..."
    sleep 5
done

# Check if download was successful
if [ ! -f /home/jenkins/agent.jar ] || [ ! -s /home/jenkins/agent.jar ]; then
    echo "Failed to download agent.jar after multiple attempts"
    echo "Checking connectivity to Jenkins master:"
    curl -v $JENKINS_URL
    exit 1
fi

# Make sure the jar file has the right permissions
chmod 644 /home/jenkins/agent.jar
echo "Successfully downloaded agent.jar"

# Add -webSocket option for better connectivity through firewalls
if [ -z "$AGENT_SECRET" ]; then
    echo "No agent secret provided. Cannot connect without a secret."
    echo "Please provide the secret from the Jenkins master."
    sleep 10
    exit 1
else
    echo "Connecting to Jenkins master with secret..."
    java -jar /home/jenkins/agent.jar \
        -url "$JENKINS_URL" \
        -secret "$AGENT_SECRET" \
        -name "$AGENT_NAME" \
        -webSocket \
        -workDir "$AGENT_WORKDIR"
fi