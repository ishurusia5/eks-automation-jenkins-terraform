pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/ishurusia5/eks-automation-jenkins-terraform.git'
                }
            }
        }

        stage('Initializing Terraform') {
            steps {
                script {
                    dir('terraform/eks-setup') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Validating Terraform') {
            steps {
                script {
                    dir('terraform/eks-setup') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Previewing the Terraform Infrastructure') {
            steps {
                script {
                    dir('terraform/eks-setup') {
                        sh 'terraform plan'
                    }
                }
                input(message: "Approve?", ok: "Proceed")
            }
        }

        stage('Create/Destroy an EKS Cluster') {
            steps {
                script {
                    dir('terraform/eks-setup') {
                        sh "terraform ${params.ACTION} --auto-approve"
                    }
                }
            }
        }
    }
}
