# Jenkins Master-Slave Docker Setup

This repository contains a Docker setup for Jenkins with master and slave nodes.

## Project Structure

```
.
├── docker-compose.yml
├── jenkins
│   ├── master
│   │   ├── Dockerfile
│   │   ├── init.groovy.d
│   │   │   └── security.groovy
│   │   └── plugins.txt
│   └── slave
│       ├── Dockerfile
│       └── start-agent.sh
└── volume
    └── (mounted as Jenkins agent workspace)
```

## Quick Start

1. Clone this repository
2. Create the directory structure shown above
3. Run the following command to start both Jenkins master and slave:

```bash
docker-compose up -d
```

4. Access Jenkins at http://localhost:8080
5. Log in with the default credentials:
   - Username: `admin`
   - Password: `admin`
   - **Note:** Please change this password immediately after first login!

## Setting Up the Slave Node

After Jenkins is up and running:

1. Go to "Manage Jenkins" > "Manage Nodes and Clouds" > "New Node"
2. Enter a node name (match it with the `AGENT_NAME` in the start-agent.sh script)
3. Select "Permanent Agent" and click "OK"
4. Configure the node:
   - Remote root directory: `/home/jenkins`
   - Labels: `docker slave linux` (or as needed)
   - Usage: "Use this node as much as possible"
   - Launch method: "Launch agent via Java Web Start"
5. Click "Save"

6. Go to the newly created agent page and copy the agent secret
7. Update the docker-compose.yml file to include the agent secret:

```yaml
jenkins-slave:
  environment:
    - 'JENKINS_URL=http://jenkins:8080'
    - 'AGENT_NAME=your-node-name'
    - 'AGENT_SECRET=your-secret-copied-from-jenkins'
```

8. Restart the slave container:

```bash
docker-compose restart jenkins-slave
```

## Customization

### Adding Plugins

Edit the `jenkins/master/plugins.txt` file to add or remove plugins as needed.

### Build Tools

The slave Dockerfile includes basic build tools. Add additional tools as needed for your specific projects.

### Security Configuration

The initial security setup is in `jenkins/master/init.groovy.d/security.groovy`. Customize this file for your security requirements.

## Security Considerations

- Change the default admin password immediately
- For production use, configure proper authentication and authorization
- Consider implementing HTTPS for Jenkins access