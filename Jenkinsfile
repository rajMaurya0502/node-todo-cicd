pipeline{
    agent any
    //agent { label 'dev_agent' }
    environment{
        SONARQUBE_SCANNER_HOME = tool name: 'SonarQube Scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
        AWS_DEFAULT_REGION="ap-south-1"
        AWS_ACCOUNT_ID="590183764012"
        REPO_NAME="demo_repo"
        IMG_TAG="node_todo_app"
        REPO_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${REPO_NAME}"
        LAMBDA_FUNCTION_NAME="sample_lambda_function-dev"
        IAM_ROLE_ARN="arn:aws:iam::590183764012:role/EC2_lambda_ecr_role"
        CFN_TEMPLATE_PATH="cftemplate.yaml"
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
        stage("Quality Gate") {
            steps {
                // Wait for SonarQube to compute the results and check the quality gate
                timeout(time: 1, unit: 'HOURS') {
                 //This function waits for the quality gate results from SonarQube.If the quality gate fails (i.e., the code does not meet the predefined quality criteria), the pipeline will be aborted.    
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('build'){
            steps{
                script{
                    sh "docker build -t $IMG_TAG -f Dockerfile ."
                }
            }
        }
        stage('tag and push'){
            steps{
                sh 'docker tag ${IMG_TAG}:latest ${REPO_URI}:${IMG_TAG}'
                sh 'docker push ${REPO_URI}:${IMG_TAG}'
                
            }
        }
       stage('Deploy to AWS Lambda') {
            steps {
                script {
                    def lambdaFunctionExists = sh(script: """
                        aws lambda get-function --function-name ${LAMBDA_FUNCTION_NAME} --region ${AWS_DEFAULT_REGION} > /dev/null 2>&1
                    """, returnStatus: true) == 0

                    if (lambdaFunctionExists) {
                        echo "Updating existing Lambda function..."
                        sh """
                        aws lambda update-function-code \
                            --function-name ${LAMBDA_FUNCTION_NAME} \
                            --image-uri ${REPO_URI}:${IMG_TAG} \
                            --region ${AWS_DEFAULT_REGION}
                        """
                    } else {
                        echo "Creating new Lambda function..."
                        sh """
                         aws cloudformation deploy \
                            --template-file ${CFN_TEMPLATE_PATH} \
                            --stack-name lambda-demo-stack \
                            --capabilities CAPABILITY_NAMED_IAM \
                            --region ${AWS_DEFAULT_REGION} \
                            --parameter-overrides \
                                LambdaFunctionName=${LAMBDA_FUNCTION_NAME} \
                                LambdaRoleArn=${IAM_ROLE_ARN} \
                                ImageUri=${REPO_URI}:${IMG_TAG}   
                        """
                    }
                }
            }
        }
    

    }
}
