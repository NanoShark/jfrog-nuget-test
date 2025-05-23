pipeline {
    agent {
        label 'jenkins-slave'
    }
    
    environment {
        // JFrog settings
        JFROG_CLI_HOME_DIR = "${WORKSPACE}/.jfrog"
        ARTIFACTORY_URL = 'https://trialo8nx47.jfrog.io/artifactory'
        ARTIFACTORY_CREDS = credentials('artifactory-credentials')
        NUGET_REPO = 'my-app-nuget'
        
        // .NET settings
        DOTNET_CLI_HOME = "${WORKSPACE}/.dotnet"
        DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 'true'
        DOTNET_NOLOGO = 'true'
        
        // Version settings
        VERSION = getVersion()
    }
    
    stages {
        
        
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Setup Tools') {
            steps {
                // Install and configure JFrog CLI
                sh '''
                    #curl -fL https://install-cli.jfrog.io | sh
                    export PATH=$PATH:$HOME/.jfrog/bin
                    jf config add artifactory --url=${ARTIFACTORY_URL} --user=${ARTIFACTORY_CREDS_USR} --password=${ARTIFACTORY_CREDS_PSW} --interactive=false
                    jf rt c show
                '''
            }
        }
        
        stage('Restore') {
            steps {
                sh '''
                    jf rt dotnet-restore --server-id-resolve=artifactory --repo-resolve=${NUGET_REPO}
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
                    jf rt bp artifacts/ scan --fail=false
                '''
            }
        }
        
        stage('Publish to Artifactory') {
            steps {
                sh '''
                    jf rt dotnet-push artifacts/*.nupkg ${NUGET_REPO} --server-id=artifactory --detailed-summary
                '''
            }
        }
        
        stage('Create Build Info') {
            steps {
                sh '''
                    jf rt build-publish
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


