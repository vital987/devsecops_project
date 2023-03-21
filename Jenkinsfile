#!/usr/bin/env groovy

void setBuildStatus(String message, String state) {
    step([
        $class: "GitHubCommitStatusSetter",
        reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/vital987/cicdTestApp"],
        contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
        errorHandlers: [
            [$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]
        ],
        statusResultSource: [$class: "ConditionalStatusResultSource", results: [
            [$class: "AnyBuildResult", message: message, state: state]
        ]]
    ]);
}

def test_summary;

pipeline {
    agent any
    environment {
        DEPL = "testapp-app"
        DEPL_NAMESPACE = "testapp-ns"
        IMAGE = "vital987/testapp"
        DOCKERHUB_CREDS = credentials('vital987_dockerhub')
        ANSIBLE_SLACK_TOKEN = credentials('vital987_ansible_slack_token')
        AZURE_STORAGE_ACCOUNT_NAME = "sa1nlptjrbeqcblkwjgqsme"
        AZURE_STORAGE_CONTAINER_NAME = "trivy-reports"
    }
    stages {
        stage("Scan WebApp") {
            steps {
                script {
                    try {
                        setBuildStatus("Scanning app", "PENDING");
                        withSonarQubeEnv() {
                            sh "mvn --no-transfer-progress clean verify sonar:sonar -Dsonar.projectKey=cicdTestApp -Dmaven.test.skip=true"
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        setBuildStatus("Scanning app failed.", "FAILURE");
                        slackSend color: "danger", message: "Failed to scan app."
                        throw e
                    }
                }
            }
        }
        stage("Build WebApp") {
            steps {
                script {
                    try {
                        setBuildStatus("Building app", "PENDING");
                        sh "mvn --no-transfer-progress package -Dmaven.test.skip=true"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        setBuildStatus("Building app failed.", "FAILURE");
                        slackSend color: "danger", message: "Failed to build app."
                        throw e
                    }
                }
            }
        }
        stage("Test WebApp") {
            steps {
                script {
                    try {
                        setBuildStatus("Testing web app.", "PENDING")
                        // Will always return 0 even if tests fail
                        sh "mvn --no-transfer-progress test || :"
                        sh "pkill chrome"
                    } catch (Exception e) {
                        setBuildStatus("Web app testing failed.", "FAILURE")
                        currentBuild.result = 'UNSTABLE'
                        slackSend color: "danger", message: "App testing failed."
                        throw e
                    }
                }
            }
            post {
                always {
                    script {
                        test_summary = junit healthScaleFactor: 25.0, keepLongStdio: true, testResults: '**/target/surefire-reports/TEST-*.xml', skipPublishingChecks: true
                    }
                }
            }
        }
        stage("Push artifact to Ansible server") {
            steps {
                script {
                    try {
                        setBuildStatus("Push artifact", "PENDING")
                        sshPublisher(publishers: [sshPublisherDesc(configName: 'Ansible', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'imageBuild/', remoteDirectorySDF: false, removePrefix: 'target/', sourceFiles: 'target/testapp.jar')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                    } catch (Exception e) {
                        setBuildStatus("Artifact push failed.", "FAILURE")
                        currentBuild.result = 'FAILURE'
                        slackSend color: "danger", message: "Artifact push failed."
                        throw e
                    }
                }
            }
        }
        stage("Execute playbook on Ansible server") {
            steps {
                script {
                    try {
                        setBuildStatus("Push artifact", "PENDING")
                        sshPublisher(publishers: [sshPublisherDesc(configName: 'Ansible', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "ansible-playbook playbooks/main.yml --extra-vars=\"{depl: ${env.DEPL}, depl_namespace: ${env.DEPL_NAMESPACE}, image: ${env.IMAGE}, imageTag: ${env.BUILD_NUMBER}, dockerUsr: ${env.DOCKERHUB_CREDS_USR}, dockerPass: ${env.DOCKERHUB_CREDS_PSW}, storageAccountName: ${env.AZURE_STORAGE_ACCOUNT_NAME}, storageContainerName: ${env.AZURE_STORAGE_CONTAINER_NAME}, slackToken: ${env.ANSIBLE_SLACK_TOKEN}}\"", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
                    } catch (Exception e) {
                        setBuildStatus("Ansible playbook failed.", "FAILURE")
                        currentBuild.result = 'FAILURE'
                        slackSend color: "danger", message: "Playbook execution failed."
                        throw e
                    }
                }
            }
        }
    }
    post {
        always {
            sh "mvn clean"
        }
        success {
            script {
                setBuildStatus("CI successful", "SUCCESS");
                slackSend color: "good", message: "BUILD ${currentBuild.currentResult}\nTest results:\nTotal: ${test_summary.totalCount}\nPassed: ${test_summary.passCount}\nFailed: ${test_summary.failCount}\nSkipped: ${test_summary.skipCount}"
            }
        }
        unstable {
            script {
                setBuildStatus("CI unstable, maybe tests failed", "SUCCESS");
                slackSend color: "warning", message: "BUILD ${currentBuild.currentResult}\nTest results:\nTotal: ${test_summary.totalCount}\nPassed: ${test_summary.passCount}\nFailed: ${test_summary.failCount}\nSkipped: ${test_summary.skipCount}"
            }
        }
        failure {
            script {
                setBuildStatus("CI failed", "FAILURE");
                slackSend color: "danger", message: "BUILD ${currentBuild.currentResult}\nTest results:\nTotal: ${test_summary.totalCount}\nPassed: ${test_summary.passCount}\nFailed: ${test_summary.failCount}\nSkipped: ${test_summary.skipCount}"
            }
        }
    }
}
