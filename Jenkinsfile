pipeline {
    agent any
    environment {
        // Updated to use local Harbor registry endpoint and repository path
        HARBOR_REGISTRY = "192.168.1.184:9443"
        IMAGE_NAME      = "192.168.1.184:9443/library/enterprise-web-app"
        BUILD_TAG       = "${BUILD_NUMBER}"
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/bus57790/my-devops-project.git'
            }
        }
        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('Docker Build & Push') {
            steps {
                // Ensure credentials ID matches your Harbor credentials in Jenkins
                withCredentials([usernamePassword(credentialsId: 'harbor-credentials', usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
                    sh "docker build -t ${IMAGE_NAME}:${BUILD_TAG} ."
                    sh "echo \$HARBOR_PASS | docker login ${HARBOR_REGISTRY} -u \$HARBOR_USER --password-stdin"
                    sh "docker push ${IMAGE_NAME}:${BUILD_TAG}"
                }
            }
        }
        stage('Update GitOps Repo for ArgoCD') {
            steps {
                sh """
                    git config user.email "jenkins@192.168.1.184"
                    git config user.name "Jenkins CI"
                    sed -i 's|image: .*|image: ${IMAGE_NAME}:${BUILD_TAG}|g' k8s/deployment.yaml
                    git commit -am "Automated deployment update build #${BUILD_TAG}"
                    git push origin main
                """
            }
        }
    }
    post {
        always {
            // Using withCredentials prevents the Groovy String interpolation security warning
            withCredentials([string(credentialsId: 'slack-webhook-url', variable: 'SLACK_WEBHOOK')]) {
                sh '''
                    curl -X POST -H 'Content-type: application/json' \
                    --data "{\"text\":\"Pipeline ${JOB_NAME} #${BUILD_NUMBER} finished with status: ${currentBuild.currentResult}\"}" \
                    "$SLACK_WEBHOOK"
                '''
            }
        }
    }
}
