jenkins:
  systemMessage: "Jenkins Configuration as Code"

  plugins:
    - github
    - gitlab
    - docker-workflow
    - kubernetes

  securityRealm:
    local:
      allowsSignup: false
       users:
          id: "admin"
          password: "admin"
    
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Job/Build:anonymous"
    
  globalNodeProperties:
     environmentVariables:
         env:
            key: "GIT_HASH"
            value: "${GIT_COMMIT}"

  pipelines:
     script: 
        pipeline {
          agent any
          environment {
            DOCKER_IMAGE_NAME = 'myimage'
            K8S_DEPLOYMENT_NAME = 'myapp-deployment'
            K8S_CONTAINER_NAME = 'myapp-container'
          }
          stages {
            stage('Checkout') {
              steps {
                git branch: 'master', url: 'https://github.com/vijkes/newjenkinshook.git'
              }
            }
            stage('Build and Test') {
              steps {
                sh 'npm install'
                sh 'npm test'
                sh 'docker build -t $DOCKER_IMAGE_NAME:$GIT_HASH .'
              }
            }
            stage('Deploy') {
              steps {
                script {
                  def deployStatus = input(
                    message: "Deploy to Kubernetes?",
                    ok: "Deploy",
                    parameters: [
                      string(
                        defaultValue: "prod",
                        description: "Environment",
                        name: "ENVIRONMENT"
                      )
                    ]
                  )
                  if (deployStatus == "Deploy") {
                    withKubeConfig([credentialsId: 'kubeconfig', serverUrl: 'https://my-kubernetes-cluster']) {
                      sh "kubectl set image deployment/$K8S_DEPLOYMENT_NAME $K8S_CONTAINER_NAME=$DOCKER_IMAGE_NAME:$GIT_HASH --namespace=$deployEnvironment"
                      sh "kubectl rollout status deployment/$K8S_DEPLOYMENT_NAME --namespace=$deployEnvironment"
                      sh "kubectl annotate deployment/$K8S_DEPLOYMENT_NAME kubernetes.io/change-cause=$JOB_NAME"
                    }
                  }
                }
              }
            }
          }
          post {
            always {
              // Update the GitHub commit status
              withCredentials([string(credentialsId: 'github-token', variable: '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')]) {
                sh '''
                  curl -X POST \
                  -H "Authorization: token $GITHUB_TOKEN" \
                  -H "Accept: application/vnd.github+json" \
                  https://api.github.com/repos/myorg/myrepo/statuses/$GIT_HASH \
                  -d '{"state": "success", "description": "Deployed to Kubernetes"}'
                '''
              }
            }
          }
        }
