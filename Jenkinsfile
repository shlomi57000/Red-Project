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
        // Build images from docker files
        stage('build images on local'){
            steps{
                sh 'cd server && docker build -t shlomi57000/biu12_red_backend_local .'
                sh 'sleep 5'
                sh "cd frontend && docker build --build-arg server_ip=localhost -t shlomi57000/biu12_red_frontend_local ."
                sh 'sleep 5'
            }
        }
        // Run containers
        stage('Run images on local') {
            steps {
                sh 'docker run -d -p3001:3001 shlomi57000/biu12_red_backend_local:latest'
                sh 'sleep 5'
                sh 'docker run -d -p3000:3000 shlomi57000/biu12_red_frontend_local:latest'
                sh 'sleep 5'
            }
        }
        // Run tests -> Test connection
        stage('Test') {
            steps {
                sh 'python3 -m pytest --junitxml=test-results.xml test/test.py'
            }   
        }
        // Update success
        stage('Test alert'){
            steps{
                echo "Test completed successfully, images will be removed"
            }
        }
        // Remove images from local
        stage('Remove images') {
            steps {
                sh 'docker kill $(docker ps -q)'
                sh 'echo docker rmi -f galdevops/biu12_red_backend_local'
                sh 'echo docker rmi -f galdevops/biu12_red_frontend_local'
            }        
        }
        // Initiate TF - initializes a working directory containing TF configuration files
        stage('TF INIT'){
            steps{
                sh 'terraform init -no-color'
            }
        }
        // Terminates TF resources managed by TF project
        stage('TF DESTROY_1'){
            steps{
                sh "terraform destroy -no-color -auto-approve -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'"
            }
        }
        // Creates an execution plan, to preview the infrastructure changes that TF plans to make to apply.
        stage('TF PLAN'){
            steps{
                sh "terraform plan -no-color -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'"
            }
        }
        // Executes infrastructure changes to each TF resource
        stage('TF APPLY'){
            steps{
                sh "terraform apply -no-color -auto-approve -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'"
            }
        }
        // Wait for AWS instance creation is done before continue to the following steps
        stage('EC2 Wait'){
            steps{
                sh "AWS_ACCESS_KEY_ID=${env.ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${env.SECRET_KEY} aws ec2 wait instance-status-ok --region us-east-1"
            }
        }
        // Copy IP - line 2 in file aws_hosts (public_ip was added by TF when backend instance was created)
        // Assign IP to Jenkins VAR.SERVER_IP
        stage("Assign IP") {
            steps {
                script {
                    SERVER_IP = sh (
                            script: "sed -n '2p' aws_hosts",
                            returnStdout: true
                        ).trim()
                        echo "updated ip: ${SERVER_IP}"
                }
            }
        }
        // Build backend image from docker file
        stage('build aws backend'){
            steps{
                sh 'cd server && docker build -t galdevops/biu12_red_backend_01 .'
            }
        }
        // Build frontend image from docker file, pass backend_instance_ip as argument
        stage('build aws frontend'){
            steps{
                sh "echo ip: ${SERVER_IP}"
                sh "cd frontend && docker build --build-arg server_ip=${SERVER_IP} -t galdevops/biu12_red_frontend_01 ."
            }
        }
        // Login to dockerhub with jenkins creds
        stage('Login dockerhub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        // Push backend image to dockerhub
        stage('Push backend to dockerhub') {
            steps {
                sh 'docker push galdevops/biu12_red_backend_01'
            }
        }
        // Push frontend image to dockerhub
        stage('Push frontend to dockerhub') {
            steps {
                sh 'docker push galdevops/biu12_red_frontend_01'
            }
        }
        // Add Ansible settings to aws_hosts file - to be applied on aws instance group
        stage('Ansible User'){
            steps{
                sh "cat user.txt >> aws_hosts"
            }
        }
        // Print aws_hosts file to view Ansible inventory
        stage('Inventory'){
            steps{
                sh "cat aws_hosts"
            }
        }
        // Execute Ansible script
        stage('Ansible Execution'){
            steps{
                ansiblePlaybook(credentialsId: 'ec2-ssh', inventory: 'aws_hosts', playbook: 'playbooks/dockerans.yml')
            }
        }
        // Update success
        stage('Completed alert'){
            steps{
                echo "You can now test aws instances"
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