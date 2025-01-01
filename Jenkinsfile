pipeline {
  agent any

  stages {

      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true" // trigger jenkins
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }  

        stage('Unit Tests') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }

        stage('Mutation Tests - PIT') {
          steps {
            sh "mvn org.pitest:pitest-maven:mutationCoverage"
          }
          post {
            always {
              pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            }
          }
        }

        stage('SonarQube - SAST') {
          steps {
            withSonarQubeEnv('SonarQube') {
              sh "mvn sonar:sonar -Dsonar.projectKey=numeric-app -Dsonar.host.url=http://34.133.34.164:9000"
            }
            timeout(time: 2, unit: 'MINUTES') {
              script {
                waitForQualityGate abortPipeline: true
              }
            }
          }
        }

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

        stage('Vulnerability Scan - Trivy') {
          steps {
            parallel(
              // "Dependency Scan": {
              //   sh "mvn dependency-check:check"
              // },
              "Trivy Scan": {
                sh "bash trivy-docker-image-scan.sh"
              }
            )
          }
        }

        stage('Docker Build and Push') {
          steps {
            withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
              sh 'printenv'
              sh 'docker build -t enes789/devsecops-numeric-app:${BUILD_NUMBER} .'
              sh 'docker push enes789/devsecops-numeric-app:${BUILD_NUMBER}'
            }
          }
        }

        stage('Kubernetes Deployment - DEV') {
          steps {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "sed -i 's#replace#enes789/devsecops-numeric-app:${BUILD_NUMBER}#g' k8s_deployment_service.yaml"
              sh "kubectl apply -f k8s_deployment_service.yaml"
            }
          }
        }
    }
}
