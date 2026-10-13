pipeline {
    agent any

    environment {
        IMAGE_NAME = 'devops-mini-project:v1'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'python3 -m venv .venv'
                sh '.venv/bin/python -m pip install --upgrade pip'
                sh '.venv/bin/python -m pip install -r requirements.txt'
            }
        }

        stage('Run Tests') {
            steps {
                sh '.venv/bin/python -m pytest -v'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build --pull=false -t "$IMAGE_NAME" .'
            }
        }

        stage('Load Image into kind') {
            steps {
                sh 'kind load docker-image "$IMAGE_NAME" --name kind'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -input=false -out=tfplan'
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl rollout status deployment/devops-app --timeout=120s'
                sh 'kubectl get pods'
                sh 'kubectl get services'
            }
        }
    }
}