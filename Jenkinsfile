pipeline{
    agent any
    //agent { label 'dev_agent' }
    environment{
        AWS_DEFAULT_REGION="us-east-1"
        AWS_ACCOUNT_ID="385240549448"
        REPO_NAME="demo_repo"
        IMG_TAG="node_todo_app"
        REPO_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${REPO_NAME}"
    }
    stages{
        stage('aws ecr loggin'){
            steps{
                script{
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                }
            }
        }
        stage('Code'){
            steps{
             git url: "https://github.com/rajMaurya0502/node-todo-cicd.git", branch: 'master'   
            }
        }
        stage('build and test'){
            steps{
                script{
                    dockerImage = docker.build("${IMG_TAG}")
                }
                //sh 'docker tag demo_repo:latest 385240549448.dkr.ecr.us-east-1.amazonaws.com/demo_repo:latest'
                //sh 'docker tag node_todo_app:latest rajmaurya/${IMG_TAG}:latest'
            }
        }
        stage('push'){
            steps{
                // echo 'login to dockerhub repo for pushing the image'
                // withCredentials([usernamePassword(credentialsId:'dockerHub', passwordVariable:'dockerHubPassword', usernameVariable:'dockerHubUsername')]){
                //     sh "docker login -u ${env.dockerHubUsername} -p ${env.dockerHubPassword}"
                //     sh "docker push rajmaurya/node_todo_app:latest"
                // }
                sh 'docker tag ${IMG_TAG}:latest ${REPO_URI}:${IMG_TAG}'
                sh 'docker push ${REPO_URI}:${IMG_TAG}'
                
            }
        }
        stage('deploy'){
            steps{
                sh 'docker pull ${IMG_TAG}'
                sh 'docker run -d -p 8000:8000 385240549448.dkr.ecr.us-east-1.amazonaws.com/demo_repo:node_todo_app'
            }
        }
    }
}
