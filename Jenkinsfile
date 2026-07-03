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
                sh 'docker --version'

                echo "Verifying kubectl..."
                sh 'kubectl version --client'
            }
        }

        stage('Lint / Basic Checks') {
            steps {
                echo "Checking that key HTML files exist..."
                sh '''
                    test -f app/index.html
                    test -f app/schedule.html
                    test -f app/register.html
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh 'docker build --build-arg BUILD_VERSION=${IMAGE_TAG} -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .'
            }
        }

        stage('List Docker Images') {
            steps {
                echo "Available Docker Images"
                sh 'docker images | grep ${IMAGE_NAME}'
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
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} $DOCKER_USER/${IMAGE_NAME}:${IMAGE_TAG}
                        docker push $DOCKER_USER/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }
        */

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying application to Kubernetes..."
                sh '''
                    sed -i "s#image: college-event-site:v1#image: ${IMAGE_NAME}:${IMAGE_TAG}#" k8s/deployment.yaml
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Checking Deployment..."
                sh '''
                    kubectl rollout status deployment/college-event-site
                    kubectl get deployments
                    kubectl get pods
                    kubectl get svc
                '''
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
