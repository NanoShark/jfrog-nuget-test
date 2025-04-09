FROM jenkins/jenkins:lts

USER root

# Install Docker CLI and other dependencies
RUN apt-get update && \
    apt-get install -y apt-transport-https \
                       ca-certificates \
                       curl \
                       gnupg2 \
                       software-properties-common \
                       git \
                       lsb-release && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add Jenkins user to docker group to allow Docker command execution
RUN groupadd -f docker && \
    usermod -aG docker jenkins

# Copy custom Jenkins initialization scripts if needed
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Set Jenkins environment variables
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Switch back to jenkins user for running Jenkins
USER jenkins