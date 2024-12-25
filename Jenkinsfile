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
        stage('Docker Build and Push') {
          steps {
            withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
              sh 'printenv'
              sh 'sudo docker build -t enes789/devsecops-numeric-app:""$GIT_COMMIT"" .'
              sh 'sudo docker push enes789/devsecops-numeric-app:""$GIT_COMMIT""'
            }
          }
        }
    }
}
