pipeline{
    agent any
    //agent { label 'dev_agent' }
    stages{
        stage('Code'){
            steps{
             git url: "https://github.com/rajMaurya0502/node-todo-cicd.git", branch: 'master'   
            }
        }
        stage('build and test'){
            steps{
                sh 'docker build -t node_todo_app .'
                sh 'docker tag node_todo_app:latest rajmaurya/node_todo_app:latest'
            }
        }
        stage('Login and push'){
            steps{
                echo 'login to dockerhub repo for pushing the image'
                withCredentials([usernamePassword(credentialsId:'dockerHub', passwordVariable:'dockerHubPassword', usernameVariable:'dockerHubUsername')]){
                    sh "docker login -u ${env.dockerHubUsername} -p ${env.dockerHubPassword}"
                    sh "docker push rajmaurya/node_todo_app:latest"
                }
            }
        }
        stage('deploy'){
            steps{
                sh 'docker run -d -p 8000:8000 rajmaurya/node_todo_app:latest'
            }
        }
    }
}
