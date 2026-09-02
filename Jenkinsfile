pipeline {
    agent any
    environment {
        IMAGE_NAME = "your-dockerhub-user/enterprise-web-app"
        BUILD_TAG  = "${BUILD_NUMBER}"
        SLACK_URL  = credentials('slack-webhook-url')
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "docker build -t ${IMAGE_NAME}:${BUILD_TAG} ."
                    sh "echo \$PASS | docker login -u \$USER --password-stdin"
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
            sh """
                curl -X POST -H 'Content-type: application/json' \
                --data '{"text":"Pipeline ${JOB_NAME} #${BUILD_NUMBER} finished with status: ${currentBuild.currentResult}"}' \
                ${SLACK_URL}
            """
        }
    }
}
