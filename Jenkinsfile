pipeline {
    agent any

    environment {
        IMAGE_NAME = 'devops-mini-project:v1'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
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

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yml'
                sh 'kubectl apply -f k8s/service.yml'
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