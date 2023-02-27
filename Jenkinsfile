#!/usr/bin/env groovy

void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/vital987/hello-world-jsp"],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}
pipeline {
    agent any
    environment {
        DEPL = "helloworld-app"
        DEPL_NAMESPACE = "helloworld-ns"
        DOCKERHUB_CREDS = credentials('vital987_dockerhub')
        MAVEN_OPTS= "-Dmaven.artifact.threads=10"
    }
    stages {
        stage("Git Checkout") {
            steps {
                script {
                    try {
                        setBuildStatus("Build started", "PENDING");
                        checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'vital987_github', name: 'hello-world-jsp', url: 'https://github.com/vital987/hello-world-jsp.git']])
                    } catch(Exception e) {
                        echo 'Git Checkout failed: ' + e.toString()
                        currentBuild.result = 'FAILURE'
                        setBuildStatus("Build started", "FAILURE");
                        error "Build terminated"
                    }
                }
            }
        }
        stage("Build WebApp") {
            steps {
                script {
                    try {
                        setBuildStatus("Building App", "PENDING");
                        sh "mvn --no-transfer-progress package"
                    } catch(Exception e) {
                        echo 'App building failed: ' + e.toString()
                        currentBuild.result = 'FAILURE'
                        setBuildStatus("Build started", "FAILURE");
                        error "Build terminated"
                    }
                }
            }
        }
        stage("Send build artifacts to Ansible server & Execute Ansible playbook") {
            steps {
                script {
                    try {
                        setBuildStatus("Artifact Push, Image build, Create/Update deployment", "PENDING");
                        sshPublisher(publishers: [sshPublisherDesc(configName: 'Ansible', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "ansible-playbook playbook.yml --extra-vars=\"{depl: ${env.DEPL}, depl_namespace: ${env.DEPL_NAMESPACE}, imageTag: ${env.BUILD_NUMBER}, dockerUsr: ${env.DOCKERHUB_CREDS_USR}, dockerPass: ${env.DOCKERHUB_CREDS_PSW}}\"", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'imageBuild/', remoteDirectorySDF: false, removePrefix: 'target/', sourceFiles: 'target/hello-world-war-1.0.0.war')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
                    } catch(Exception e) {
                        echo 'Artifact Upload or CD failed: ' + e.toString()
                        currentBuild.result = 'FAILURE'
                        setBuildStatus("Build started", "FAILURE");
                        error "Build terminated"
                    }
                    setBuildStatus("CI-CD successful", "SUCCESS");
                }
            }
        }
    }
    post {
        always {
            sh "mvn clean"
        }
    }
}
