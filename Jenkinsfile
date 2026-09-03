pipeline {
    agent any

    environment {
        HARBOR_HOST = '192.168.1.184:9443'
        IMAGE_NAME  = 'library/enterprise-web-app'
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
                withCredentials([usernamePassword(credentialsId: 'harbor-credentials', usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
                    sh '''
                        BUILD_TAG="${HARBOR_HOST}/${IMAGE_NAME}:${BUILD_NUMBER}"
                        docker build --provenance=false -t "${BUILD_TAG}" .
                        echo "$HARBOR_PASS" | docker login "https://${HARBOR_HOST}" -u "$HARBOR_USER" --password-stdin
                        docker push "${BUILD_TAG}"
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
                    PAYLOAD=$(jq -n --arg text "Pipeline ${JOB_NAME} #${BUILD_NUMBER} finished with status: ${currentBuild.currentResult}" '{text: $text}')
                    curl -X POST -H 'Content-Type: application/json' --data "$PAYLOAD" "$SLACK_WEBHOOK"
                '''
            }
        }
    }
}
