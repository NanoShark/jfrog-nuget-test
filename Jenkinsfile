pipeline{
    agent{
        label 'jenkins-slave'
    }

    environment {


        // .NET settings
        DOTNET_CLI_HOME = "${WORKSPACE}/.dotnet"
        DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 'true'
    }

    stages{
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                }
            }
        }
        
        stage('Build') {
            steps {
                
                script {
                    sh """
                    pwd
                    ls
                    dotnet build --configuration Release --no-restore
                    """
                }
            }
        }
        
        stage('Test') {
            steps {
                sh 'dotnet test --configuration Release --no-build'
            }
        }
        
        stage('Package') {
            steps {
                sh 'dotnet pack --configuration Release --no-build --output ./nupkgs'
            }
       
        }

    }
     post {
        always {
            // Clean workspace after build
            cleanWs()
        }
        success {
            echo 'Build succeeded! Artifacts have been published to JFrog Artifactory.'
        }
        failure {
            echo 'Build failed! Check the logs for details.'
        }
    }
}