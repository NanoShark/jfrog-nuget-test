FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and Java 17 instead of Java 11
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk \
                       git \
                       curl \
                       apt-transport-https \
                       ca-certificates \
                       gnupg2 \
                       software-properties-common \
                       lsb-release \
                       openssh-server \
                       python3 \
                       python3-pip && \
    # Install Docker CLI
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create jenkins user
RUN useradd -m -s /bin/bash jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    mkdir -p /home/jenkins/.jenkins && \
    mkdir -p /home/jenkins/workspace && \
    chown -R jenkins:jenkins /home/jenkins

# Add jenkins to docker group
RUN groupadd -f docker && \
    usermod -aG docker jenkins

# Set up SSH server
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Set working directory
WORKDIR /home/jenkins

# Switch to jenkins user
USER jenkins

# Create a simple startup script
RUN echo '#!/bin/bash\n\
echo "Starting Jenkins agent connection..."\n\
curl -sO "http://jenkins:8080/jnlpJars/agent.jar"\n\
java -jar agent.jar -url http://jenkins:8080 -secret "$AGENT_SECRET" -name "jenkins-slave" -webSocket -workDir "/home/jenkins/workspace"\n\
' > /home/jenkins/start-agent.sh && \
    chmod +x /home/jenkins/start-agent.sh

# Entry point
ENTRYPOINT ["/home/jenkins/start-agent.sh"]