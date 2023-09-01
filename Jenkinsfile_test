pipeline {
    agent any
    environment {
        SERVER_IP = "1"
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('tfcloudcreds')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        ACCESS_KEY = credentials('aws-access')
        SECRET_KEY = credentials('aws-sec')
    }
    stages {
        stage('TF INIT'){
            steps{
                sh 'terraform init -no-color'
            }
        }
        stage('TF DESTROY_1'){
            steps{
                sh "terraform destroy -no-color -auto-approve -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'"
            }
        }
        stage('TF PLAN'){
            steps{
                sh "terraform plan -no-color -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'"
            }
        }
        stage('TF APPLY'){
            steps{
                sh "terraform apply -no-color -auto-approve -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'"
            }
        }
        stage('EC2 Wait'){
            steps{
                sh "AWS_ACCESS_KEY_ID=${env.ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${env.SECRET_KEY} aws ec2 wait instance-status-ok --region us-east-1"
            }
        }
        stage('Update Server IP'){
            steps{
                echo "sed -n '2p' aws_hosts"
            }
        }
        stage("Test IP") {
            steps {
                echo "ip is '${SERVER_IP}'"
                
                script {
                    SERVER_IP = sh (
                            script: "sed -n '2p' aws_hosts",
                            returnStdout: true
                        ).trim()
                        echo "updated ip: ${SERVER_IP}"
                }
            }
        }
        stage('build backend'){
            steps{
                sh 'cd server && docker build -t galdevops/biu12_red_backend_09 .'
            }
        }
        stage('build frontend'){
            steps{
                // sh 'cd frontend && docker build -t galdevops/biu12_red_frontend_01 .'
                sh "echo ip: ${SERVER_IP}"
                sh "cd frontend && docker build --build-arg server_ip=${SERVER_IP} -t galdevops/biu12_red_frontend_09 ."
            }
        }
        stage('Login dockerhub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        stage('Push backend to dockerhub') {
            steps {
                sh 'docker push galdevops/biu12_red_backend_09'
            }
        }
        stage('Push frontend to dockerhub') {
            steps {
                sh 'docker push galdevops/biu12_red_frontend_09'
            }
        }
        stage('test'){
            steps{
                sh 'cd frontend/src'
            }
        }
        stage('build image'){
            steps{
                sh 'ls'
            }
        }
        stage('post'){
            steps{
                sh 'echo post'
            }
        }
        stage('Ansible User'){
            steps{
                sh "cat user.txt >> aws_hosts"
            }
        }
        stage('Inventory'){
            steps{
                sh "cat aws_hosts"
            }
        }
        stage('Ansible Test'){
            steps{
                ansiblePlaybook(credentialsId: 'ec2-ssh', inventory: 'aws_hosts', playbook: 'playbooks/dockerans.yml')
            }
        }
        // stage('TF DESTROY'){
        //     steps{
        //         sh "terraform destroy -no-color -auto-approve -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'"
        //     }
        // }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
    
}