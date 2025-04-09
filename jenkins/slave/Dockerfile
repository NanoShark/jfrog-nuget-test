FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk \
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
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create jenkins user
RUN useradd -m -s /bin/bash jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    mkdir -p /home/jenkins/.jenkins && \
    mkdir -p /home/jenkins/agent && \
    chown -R jenkins:jenkins /home/jenkins

# Add jenkins to docker group
RUN groupadd -f docker && \
    usermod -aG docker jenkins

# Set up SSH server
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Download the Jenkins agent
RUN curl -s -o /home/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/latest/remoting-latest.jar && \
    chmod 755 /home/jenkins && \
    chmod 644 /home/jenkins/agent.jar

# Create start-agent script
COPY start-agent.sh /home/jenkins/start-agent.sh
RUN chmod +x /home/jenkins/start-agent.sh && \
    chown jenkins:jenkins /home/jenkins/start-agent.sh

# Switch to jenkins user
USER jenkins
WORKDIR /home/jenkins

# Entry point
ENTRYPOINT ["/home/jenkins/start-agent.sh"]