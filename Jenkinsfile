pipeline{
    agent any
    //agent { label 'dev_agent' }
    environment{
        SONARQUBE_SCANNER_HOME = tool name: 'SonarQube Scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
    //     AWS_DEFAULT_REGION="ap-south-1"
    //     AWS_ACCOUNT_ID="590183764012"
        REPO_NAME="demo_repo"
        IMG_TAG="node_todo_app"
        REPO_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${REPO_NAME}"
    //     LAMBDA_FUNCTION_NAME="sample_lambda_function-dev"
     }
    stages{
        // stage('aws ecr loggin'){
        //     steps{
        //         script{
        //             sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        //         }
        //     }
        // }
        stage('Code'){
            steps{
             git url: "https://github.com/rajMaurya0502/node-todo-cicd.git", branch: 'dev'   
            }
        }
        stage('Static code analysis'){
            steps{
                   
                   withSonarQubeEnv('SonarQube'){
                       // sh "mvn -ntp sonar:sonar -Dsonar.projectKey=java_app -Dsonar.host.url=${SONARQUBE_URL} -Dsonar.login=sqa_0908e617ed2e9f32f7269acafe3e997e41456f16"
                       sh "${SONARQUBE_SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=nodejs_todo_app -Dsonar.host.url=http://13.233.195.163:9000 -Dsonar.login=sqa_0908e617ed2e9f32f7269acafe3e997e41456f16"

               }
            }
       }
        stage('build and test'){
            steps{
                script{
                    docker.build("${IMG_TAG}")
                    
                    // sh "docker build -t $IMAGE_TAG -f Dockerfile ."
                    sh "docker tag $IMAGE_TAG:latest $REPO_URI:$IMG_TAG"
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
                //sh 'docker pull ${IMG_TAG}'
                sh 'docker run -d -p 8000:8000 385240549448.dkr.ecr.us-east-1.amazonaws.com/demo_repo:node_todo_app'
            }
        }
        stage('deployment'){
            steps{
                script{
                    sh "aws lambda update-function-code --function-name ${LAMBDA_FUNCTION_NAME} --image-uri 385240549448.dkr.ecr.us-east-1.amazonaws.com/demo_repo:node_todo_app --region ${AWS_DEFAULT_REGION}"
                }
            }
        }
    }
}
