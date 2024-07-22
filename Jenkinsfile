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
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIAL}"]]) {
                        def loginCommand = """
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}
                        """
                        def loginResult = sh(script: loginCommand, returnStatus: true)
                        if (loginResult == 0) {
                            echo 'Login to ECR succeeded'
                        } else {
                            error 'Login to ECR failed'
                        }
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
                    sh './gradlew clean build --no-daemon --info'
                }
            }
        }
        
        stage('Clean Workspace') {
            steps {
                deleteDir() // 작업 공간 정리
            }
        }
        
        
        stage('Building image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_REPO_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Pushing to ECR') {
            steps {
                script {
                    sh """docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}"""
                    sh """docker push ${REPOSITORY_URI}:${IMAGE_TAG}"""
                }
            }
        }
    }
        stage('Clean up Docker images') {
            steps {
                script {
                    // Docker 이미지 삭제
                    sh """docker rmi ${IMAGE_REPO_NAME}:${IMAGE_TAG}"""
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
