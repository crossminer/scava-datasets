pipeline {
  agent any
  options {
    buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '5'))
  }
  stages {
    stage('SCM') {
      steps {
        git url: 'https://github.com/eclipse-scava/scava-datasets.git'
      }
    }
    stage('Build') {
      steps {
        sh 'pwd'
        sh 'ls'
        sh 'cd scripts/ && sh ./process_all_projects.sh' 
        archiveArtifacts artifacts: 'datasets/**/*.gz', fingerprint: true 
        archiveArtifacts artifacts: 'datasets/**/*.html', fingerprint: true 
        archiveArtifacts artifacts: 'datasets/**/*.pdf', fingerprint: true 
        archiveArtifacts artifacts: 'docs/*', fingerprint: true 
        cleanWs()
      }
    }
  }
}

