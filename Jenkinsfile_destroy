pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('tfcloudcreds')
        ACCESS_KEY = credentials('aws-access')
        SECRET_KEY = credentials('aws-sec')
    }
    stages {
        stage('TF INIT'){
            steps{
                sh 'terraform init -no-color'
            }
        }
        stage('TF DESTROY'){
            steps{
                sh "terraform destroy -no-color -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'"
            }
        }
    }
}