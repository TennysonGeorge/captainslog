pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo 'Build Demo Application'
      }
    }

    stage('Testing/Linux ') {
      parallel {
        stage('Testing/Linux ') {
          steps {
            sh 'sh run_build_script.sh'
          }
        }

        stage('Windows') {
          steps {
            echo 'Run Windows tests '
          }
        }

      }
    }

    stage('Deploy Staging') {
      steps {
        echo 'Deploy to staging environment'
        input 'Is it ok to deploy this app in production?'
      }
    }

    stage('Deploy Production') {
      steps {
        echo 'Deploy to Prod'
      }
    }

  }
  post {
    always {
      archiveArtifacts(artifacts: 'target/demoapp.jar', fingerprint: true)
    }

    failure {
      mail(to: 'tennyson.m.george@gmail.com', subject: "Failed Pipeline ${currentBuild.fullDisplayName}", body: " For details about the failure, see ${env.BUILD_URL}")
    }

  }
}