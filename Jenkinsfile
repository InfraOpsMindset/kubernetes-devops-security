@Library('slack') _

pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "enes789/devsecops-numeric-app:${BUILD_NUMBER}"
    applicationURL = "http://34.8.142.168"
    applicationURI = "/increment/99"
  }

  stages {

      // stage('Testing Slack') {
      //   steps {
      //     sh 'exit 1'
      //   }
      // }

      stage('Build Artifact') {
          steps {
            sh 'java -version'
            sh "mvn clean package -DskipTests=true" // trigger jenkins
            archive 'target/*.jar' //so that they can be downloaded later
          }
      }  

      // stage('Unit Tests') {
      //     steps {
      //       sh "mvn test"
      //     }
      //     post {
      //       always {
      //         junit 'target/surefire-reports/*.xml'
      //         jacoco execPattern: 'target/jacoco.exec'
      //       }
      //     }
      // }

      // stage('Mutation Tests - PIT') {
      //   steps {
      //     sh "mvn org.pitest:pitest-maven:mutationCoverage"
      //   }
      //   post {
      //     always {
      //       pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      //     }
      //   }
      // }

      // stage('SonarQube - SAST') {
      //   steps {
      //     withSonarQubeEnv('SonarQube') {
      //       sh "mvn sonar:sonar -Dsonar.projectKey=numeric-app -Dsonar.host.url=http://34.133.34.164:9000"
      //     }
      //     timeout(time: 2, unit: 'MINUTES') {
      //       script {
      //         waitForQualityGate abortPipeline: true
      //       }
      //     }
      //   }
      // }

      // stage('Vulnerability Scan - Depencency Check') {
      //   steps {
      //     sh "mvn dependency-check:check"
      //   }
      //   post {
      //     always {
      //       dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
      //     }
      //   }
      // }

      stage('Vulnerability Scan - Docker') {
        steps {
          parallel(
            // "Dependency Scan": {
            //   sh "mvn dependency-check:check"
            // },
            "Trivy Scan": {
              sh "bash trivy-docker-image-scan.sh"
            },
            "OPA Conftest": {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
            }
          )
        }
      }

      stage('Docker Build and Push') {
        steps {
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh 'sudo docker build -t enes789/devsecops-numeric-app:${BUILD_NUMBER} .'
            sh 'docker push enes789/devsecops-numeric-app:${BUILD_NUMBER}'
          }
        }
      }

      stage('Vulnerability Scan - Kubernetes') {
        steps {
          parallel(
            "OPA Scan": {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            },
            "Kubesec Scan": {
              sh "bash kubesec-scan.sh"
            },
            // "Trivy Scan": {
            //   sh "bash trivy-k8s-scan.sh"
            // }
          )
        }
      }

      // stage('Kubernetes Deployment - DEV') {
      //   steps {
      //     withKubeConfig([credentialsId: 'kubeconfig']) {
      //       sh "sed -i 's#replace#enes789/devsecops-numeric-app:${BUILD_NUMBER}#g' k8s_deployment_service.yaml"
      //       sh "kubectl apply -f k8s_deployment_service.yaml"
      //     }
      //   }
      // }

      stage('K8S Deployment - DEV') {
        steps {
          parallel(
            "Deployment": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash k8s-deployment.sh"
              }
            },
            // "Rollout Status": {
            //   withKubeConfig([credentialsId: 'kubeconfig']) {
            //     sh "bash k8s-deployment-rollout-status.sh"
            //   }
            // }
          )
        }
      }

      // stage('Integration Tests - DEV') {
      //   steps {
      //     script {
      //       try {
      //         withKubeConfig([credentialsId: 'kubeconfig']) {
      //           sh "bash integration-test.sh"
      //         }
      //       } catch (e) {
      //         withKubeConfig([credentialsId: 'kubeconfig']) {
      //           sh "kubectl -n default rollout undo deploy ${deploymentName}"
      //         }
      //         throw e
      //       }
      //     }
      //   }
      // }

      // stage('OWASP ZAP - DAST') {
      //   steps {
      //     withKubeConfig([credentialsId: 'kubeconfig']) {
      //       sh 'bash zap.sh'
      //     }
      //   }
      // }

      stage('Prompte to PROD?') {
        steps {
          timeout(time: 2, unit: 'DAYS') {
            input 'Do you want to Approve the Deployment to Production Environment/Namespace?'
          }
        }
      }

      // stage('K8S CIS Benchmark') {
      //   steps {
      //     script {

      //       parallel(
      //         "Master": {
      //           sh "bash cis-master.sh"
      //         },
      //         "Etcd": {
      //           sh "bash cis-etcd.sh"
      //         },
      //         "Kubelet": {
      //           sh "bash cis-kubelet.sh"
      //         }
      //       )

      //     }
      //   }
      // }

      stage('K8S Deployment - PROD') {
        steps {
          parallel(
            "Deployment": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "sed -i 's#replace#${imageName}#g' k8s_PROD-deployment_service.yaml"
                sh "kubectl -n prod apply -f k8s_PROD-deployment_service.yaml"
              }
            },
            "Rollout Status": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash k8s-PROD-deployment-rollout-status.sh"
              }
            }
          )
        }
      }

    }

    post {
      always {
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report'])
        sendNotification currentBuild.result
      }

      // success {

      // }

      // failure {

      // }
    }
}
