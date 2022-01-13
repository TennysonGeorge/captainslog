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
            sh '''#!/bin/bash

build() 
{
  local tag="$1"
  local file="${2:-Dockerfile}"
  echo -n "building $tag ... "
  start=`date +%s`
  docker build -t "$tag" -f "$file" . &> /dev/null
  end=`date +%s`
  runtime=$((end-start))
  echo "done in ${runtime}s"
}'''
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