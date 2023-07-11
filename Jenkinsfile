pipeline {
  agent any

  stages {
    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Unit Test') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Integration Test') {
      steps {
        sh 'mvn verify'
      }
    }

    stage('Deploy to Staging') {
      steps {
        sh 'ssh user@staging-server "cd /path/to/deploy && ./deploy.sh"'
      }
    }
  }
}