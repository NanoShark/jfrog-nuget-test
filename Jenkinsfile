pipeline {
    agent {
        label 'jenkins-slave'
    }
    
    environment {
        // JFrog settings
        JFROG_CLI_HOME_DIR = "${WORKSPACE}/.jfrog"
        ARTIFACTORY_URL = 'https:///artifactory/api/nuget/my-app-nuget'
        ARTIFACTORY_CREDS = credentials('artifactory-credentials')
        NUGET_REPO = 'nuget-local'
        
        // .NET settings
        DOTNET_CLI_HOME = "${WORKSPACE}/.dotnet"
        DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 'true'
        DOTNET_NOLOGO = 'true'
        
        // Version settings
        VERSION = getVersion()
    }
    
    stages {
        stage('Setup Tools') {
            steps {
                // Install and configure JFrog CLI
                bash '''
                    sudo su
                    curl -fL https://install-cli.jfrog.io | sh
                    export PATH=$PATH:$HOME/.jfrog/bin
                    jfrog config add artifactory --url=${ARTIFACTORY_URL} --user=${ARTIFACTORY_CREDS_USR} --password=${ARTIFACTORY_CREDS_PSW} --interactive=false
                    jfrog rt c show
                '''
            }
        }
        
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Restore') {
            steps {
                sh '''
                    jfrog rt dotnet-restore --server-id-resolve=artifactory --repo-resolve=${NUGET_REPO}
                '''
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                    cd ${WORKSPACE}
                    dotnet build --configuration Release /p:Version=${VERSION} --no-restore
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    cd ${WORKSPACE}
                    dotnet test --configuration Release --no-build --logger:trx --results-directory ./TestResults/
                '''
            }
            post {
                always {
                    mstest testResultsFile:"**/*.trx", keepLongStdio: true
                }
            }
        }
        
        stage('Package') {
            steps {
                sh '''
                    cd ${WORKSPACE}
                    dotnet pack --configuration Release /p:Version=${VERSION} --no-build --output ./artifacts
                '''
                
                // Archive artifacts in Jenkins
                archiveArtifacts artifacts: 'artifacts/*.nupkg', fingerprint: true
            }
        }
        
        stage('Scan with JFrog Xray') {
            steps {
                sh '''
                    jfrog rt bp artifacts/ scan --fail=false
                '''
            }
        }
        
        stage('Publish to Artifactory') {
            steps {
                sh '''
                    jfrog rt dotnet-push artifacts/*.nupkg ${NUGET_REPO} --server-id=artifactory --detailed-summary
                '''
            }
        }
        
        stage('Create Build Info') {
            steps {
                sh '''
                    jfrog rt build-publish
                '''
            }
        }
    }
    
    post {
        always {
            // Clean workspace after build
            cleanWs()
        }
        success {
            echo "Build succeeded! .NET packages have been published to JFrog Artifactory."
        }
        failure {
            echo "Build failed! Check the logs for details."
        }
    }
}

// Helper function to determine version
def getVersion() {
    def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    def gitTag = sh(script: 'git tag --points-at HEAD | head -n 1', returnStdout: true).trim()
    
    if (gitTag) {
        return gitTag
    } else {
        def branchName = env.BRANCH_NAME ?: 'unknown'
        def sanitizedBranch = branchName.replaceAll('/', '-')
        def timestamp = new Date().format('yyyyMMddHHmmss')
        return "0.1.0-${sanitizedBranch}.${timestamp}.${gitCommit}"
    }
}