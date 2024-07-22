pipeline {
    agent any

    tools {
        gradle 'Gradle'  
    }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = '058087963754.dkr.ecr.us-east-1.amazonaws.com'
        IMAGE_REPO_NAME = "devopstest"
        IMAGE_TAG = "latest"
        REPOSITORY_URI = "058087963754.dkr.ecr.us-east-1.amazonaws.com/devopstest"
        AWS_ACCOUNT_ID = "058087963754"
        AWS_CREDENTIAL = "AWS_Credential"
        GIT_URL = 'https://github.com/ChoiSeungBeom/weasel-backend.git'
        SLACK_CHANNEL = '#test'
        SLACK_CREDENTIALS_ID = 'Slack_test'
    }

    stages {
       stage('Login to ECR') {
            steps {
                script {
                    // AWS 자격 증명을 사용하여 ECR에 로그인
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIAL}"]]) {
                       sh '''
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}
                          '''

                    }
                }
            }
        }
        
        stage('Cloning Git') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: "${GIT_URL}"]]])
            }
        }

        stage('Build') {
            steps {
                script {
                sh '''
                    chmod +x ./gradlew
                    ./gradlew clean build --no-daemon
                '''
                }
            }
        }
        
        stage('Building image') {
          steps{
            script {
              sh """ docker.build -t ${IMAGE_REPO_NAME} . """
            }
          }
        }

        stage('Pushing to ECR') {
            steps {
                script {
                    sh """docker tag ${IMAGE_REPO_NAME}:${currentBuild.number} ${REPOSITORY_URI}:${currentBuild.number}"""
                    sh """docker push ${REPOSITORY_URI}:${currentBuild.number}"""
                }
            }
        }
        
        stage('Delete Docker images') {
            steps {
                script {
                    sh """docker rmi ${IMAGE_REPO_NAME}:${currentBuild.number}"""
                }
            }
        }
    }
    
    post {
        success {
            slackSend(channel: SLACK_CHANNEL, message: "Build succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${env.BUILD_URL}")
        }
        failure {
            slackSend(channel: SLACK_CHANNEL, message: "Build failed: ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${env.BUILD_URL}")
        }
        unstable {
            slackSend(channel: SLACK_CHANNEL, message: "Build unstable: ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${env.BUILD_URL}")
        }
    }
}
