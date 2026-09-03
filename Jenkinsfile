pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'bus57790'
        IMAGE_NAME      = 'enterprise-web-app'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
                    sh '''
                        BUILD_TAG="${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
                        LATEST_TAG="${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"

                        docker build --provenance=false -t "${BUILD_TAG}" -t "${LATEST_TAG}" .
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker push "${BUILD_TAG}"
                        docker push "${LATEST_TAG}"
                    '''
                }
            }
        }

        stage('Update GitOps Repo for ArgoCD') {
            steps {
                echo "Updating deployment manifests for version ${BUILD_NUMBER}..."
            }
        }
    }

    post {
        always {
            withCredentials([string(credentialsId: 'slack-webhook-url', variable: 'SLACK_WEBHOOK')]) {
                sh '''
                    curl -X POST -H 'Content-Type: application/json' \
                    --data "{\"text\":\"Pipeline ${JOB_NAME} #${BUILD_NUMBER} finished with status: ${currentBuild.currentResult}\"}" \
                    "$SLACK_WEBHOOK" || true
                '''
            }
        }
    }
}
