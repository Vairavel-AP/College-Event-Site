pipeline {

    agent any

    environment {
        IMAGE_NAME = "college-event-site"
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
                echo "Verifying Docker..."
                bat 'docker --version'

                echo "Verifying kubectl..."
                bat 'kubectl version --client'
            }
        }

        stage('Lint / Basic Checks') {
            steps {
                echo "Checking that key HTML files exist..."
                bat '''
                    if not exist app\\index.html exit /b 1
                    if not exist app\\schedule.html exit /b 1
                    if not exist app\\register.html exit /b 1
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                bat 'docker build --build-arg BUILD_VERSION=%IMAGE_TAG% -t %IMAGE_NAME%:%IMAGE_TAG% -t %IMAGE_NAME%:latest .'
            }
        }

        stage('List Docker Images') {
            steps {
                echo "Available Docker Images"
                bat 'docker images | findstr %IMAGE_NAME%'
            }
        }

        // Optional: push to Docker Hub. Configure credentials in Jenkins first
        // (Manage Jenkins > Credentials) and uncomment this stage.
        /*
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                    usernameVariable: 'DOCKER_USER',
                                                    passwordVariable: 'DOCKER_PASS')]) {
                    bat '''
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        docker tag %IMAGE_NAME%:%IMAGE_TAG% %DOCKER_USER%/%IMAGE_NAME%:%IMAGE_TAG%
                        docker push %DOCKER_USER%/%IMAGE_NAME%:%IMAGE_TAG%
                    '''
                }
            }
        }
        */

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying application to Kubernetes..."
                // Tag this build's image as :v1 so it matches the fixed image
                // reference already in k8s/deployment.yaml (no file editing needed,
                // since Windows doesn't have sed)
                bat 'docker tag %IMAGE_NAME%:%IMAGE_TAG% %IMAGE_NAME%:v1'
                bat 'kubectl apply -f k8s/deployment.yaml'
                bat 'kubectl apply -f k8s/service.yaml'
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Checking Deployment..."
                bat 'kubectl rollout status deployment/college-event-site'
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
            echo "Website Deployed Successfully"
            echo "======================================="
        }
        failure {
            echo "======================================="
            echo "BUILD FAILED - Check Jenkins Console Output"
            echo "======================================="
        }
    }
}