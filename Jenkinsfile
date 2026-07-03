pipeline {

    agent any

    environment {
        IMAGE_NAME = "techfest-backend"
        IMAGE_TAG  = "v${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                echo "Checking out source code from GitHub..."

                git branch: 'main',
                    url: 'https://github.com/Vairavel-AP/College-Event-Site.git'
            }
        }

        stage('Verify Tools') {
            steps {
                echo "Verifying Java..."
                bat 'java -version'

                echo "Verifying Maven..."
                bat 'mvn -version'

                echo "Verifying Docker..."
                bat 'docker --version'

                echo "Verifying Kubernetes..."
                bat 'kubectl version --client'
            }
        }

        stage('Clean Project') {
            steps {
                echo "Cleaning project..."
                bat 'mvn clean'
            }
        }

        stage('Compile Project') {
            steps {
                echo "Compiling project..."
                bat 'mvn compile'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo "Running unit tests..."
                bat 'mvn test'
            }
        }

        stage('Package Application') {
            steps {
                echo "Packaging Spring Boot application..."
                bat 'mvn package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                bat 'docker build -t %IMAGE_NAME%:%IMAGE_TAG% -t %IMAGE_NAME%:latest .'
            }
        }

        stage('List Docker Images') {
            steps {
                echo "Available Docker Images"
                bat 'docker images | findstr %IMAGE_NAME%'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying application to Kubernetes..."
                // Tag this build's image as :v1 so it matches the fixed image
                // reference already in k8s/deployment.yaml
                bat 'docker tag %IMAGE_NAME%:%IMAGE_TAG% %IMAGE_NAME%:v1'
                bat 'kubectl apply -f k8s/deployment.yaml'
                bat 'kubectl apply -f k8s/service.yaml'
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Checking Deployment..."
                bat 'kubectl rollout status deployment/techfest-backend'
                bat 'kubectl get deployments'
                bat 'kubectl get pods'
                bat 'kubectl get svc'
            }
        }
    }

    post {
        always {
            echo "Pipeline Finished."
        }
        success {
            echo "======================================="
            echo "BUILD SUCCESSFUL"
            echo "Application Deployed Successfully"
            echo "======================================="
        }
        failure {
            echo "======================================="
            echo "BUILD FAILED - Check Jenkins Console Output"
            echo "======================================="
        }
    }
}
