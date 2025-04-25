pipeline {
    agent any

    environment {
        AZURE_SUBSCRIPTION_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        STORAGE_ACCOUNT_NAME  = 'demostatesa1234'
        CONTAINER_NAME        = 'terraform-state-cont'
        TFSTATE_KEY           = 'terraform.tfstate'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'gitcredsterra', url: 'https://github.com/Chandudixitt/terraform-modules-jenkins.git'
            }
        }

        stage('Azure CLI Login') {
            steps {
                script {
                    sh 'az login --identity --username xxxxxxxxxxxxxxxxxxxxxxxxxxx'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                terraform init -reconfigure \
                  -backend-config="resource_group_name=demosatatergnew" \
                  -backend-config="storage_account_name=${STORAGE_ACCOUNT_NAME}" \
                  -backend-config="container_name=${CONTAINER_NAME}" \
                  -backend-config="key=${TFSTATE_KEY}" \
                  -backend-config="use_msi=true"
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    sh 'terraform plan -var-file=terraform.tfvars'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    sh 'terraform apply -var-file=terraform.tfvars -auto-approve'
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/*.tfstate', allowEmptyArchive: true
            cleanWs()
        }
    }
}
