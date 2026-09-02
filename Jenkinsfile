pipeline {
    agent any

    environment {
        HARBOR_REGISTRY = '192.168.1.184:9443'
        IMAGE_NAME      = 'library/enterprise-web-app'
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
                        docker build -t $HARBOR_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER .
                        echo "$HARBOR_PASS" | docker login https://$HARBOR_REGISTRY -u "$HARBOR_USER" --password-stdin
                        docker push $HARBOR_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER
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
                    STATUS=${currentBuild.currentResult}
                    curl -X POST -H 'Content-Type: application/json' \
                    --data "{\\"text\\":\\"Pipeline ${JOB_NAME} #${BUILD_NUMBER} finished with status: ${STATUS}\\"}" \
                    "$SLACK_WEBHOOK"
                '''
            }
        }
    }
}
