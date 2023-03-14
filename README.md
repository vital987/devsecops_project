# DevOps Project: CI-CD Pipeline

## Table of contents
* [Introduction](#introduction)
* [Tools Used](#tools-used)
* [Pipeline](#pipeline)
* [Azure Infrastructure](#azure-infrastructure)
* [Detailed Workflow](#detailed-workflow)
* [Demos & screenshots](#demos--screenshots)
* [Build Outputs](#build-outputs)

## Introduction
The project demonstrates a CI-CD pipeline built on Azure using Terraform.

## Tools Used
| <a href="https://azure.microsoft.com"><img src="https://github.com/vital987/vital987/blob/master/assets/azure.svg" width=32 height=32></a><br><b>Azure</b> | <a href="https://terraform.io"><img src="https://github.com/vital987/vital987/blob/master/assets/terraformio.svg" width=32 height=32><a><br></b>Terraform</b> | <a href="https://linux.org/"><img src="https://github.com/vital987/vital987/blob/master/assets/linux-icon.svg" width=32 height=32></a><br><b>Linux</b> | <a href="https://www.vaultproject.io/"><img src="https://github.com/vital987/vital987/blob/master/assets/vault.svg" width=32 height=32></a><br><b>Vault</b> | | |
|:-:|:-:|:-:|:-:|:-:|:-:|
| <a href="https://git-scm.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/git.svg" width=32 height=32></a><br><b>Git</b> | <a href="https://github.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/github.svg" width=32 height=32></a><br><b>GitHub</b> | <a href="https://jenkins.io/"><img src="https://github.com/vital987/vital987/blob/master/assets/jenkins.svg" width=32 height=32></a><br><b>Jenkins</b> | <a href="https://maven.apache.org/"><img src="https://github.com/vital987/vital987/blob/master/assets/maven.svg" width=32 height=32></a><br><b>Maven</b> | <a href="https://junit.org/"><img src="https://github.com/vital987/vital987/blob/master/assets/junit5.png" width=32 height=32><a><br><b>JUnit</b> | <a href="https://www.selenium.dev/"><img src="https://github.com/vital987/vital987/blob/master/assets/selenium.svg" width=32 height=32></a><br><b>Selenium</b> | 
| <a href="https://www.ansible.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/ansible.svg" width=32 height=32></a><br><b>Ansible</b> | <a href="https://docker.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/docker.svg" width=32 height=32></a><br><b>Docker</b> | <a href="https://kubernetes.io/"><img src="https://github.com/vital987/vital987/blob/master/assets/kubernetes.svg" width=32 height=32></a><br><b>Kubernetes</b> | | | |

## Pipeline
![process_diagram](https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/devops_project.png)

## Azure Infrastructure
![azure_diagram](https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/azure_infra.png)

## Detailed workflow
* Coder commits & pushes the source code to GitHub repository.
* GitHub webhook pushes to Jenkins.
* Vault integration with Jenkins enables Jenkins to fetch credentials from Vault.
* Jenkins triggers the build.
    * **Declarative Checkout:** Jenkins fetches the [source code](https://github.com/vital987/cicdTestApp) from GitHub repo and checks out to specified branch.
    * **Build web app:** Builds the [source code](https://github.com/vital987/cicdTestApp) with maven and outputs a jar file (war+tomcat server).
    * **Test web app:** Tests the built application with given JUnit test cases and stores the reports with the help of surefire plugin.
    * **Push artifact:** Pushes the built jar file to the Ansible server via SCP.
    * **Exec command:** Execute playbook execution command on Ansible server.
    * **Clean workspace:** Delete compiled/built/packaged components.
    * **Send status:** Sends build status to GitHub and build status + test summary to Slack (the failure in any stage will also send notification).
* Ansible executes the playbook on the Ansible server.
    * **Docker login:** Login to Docker with registry credentials (DockerHub in thi case) to push images.
    * **Build image:** Build the image (Java JRE) copying the JAR file (artifact sent by Jenkins) into the image.
    * **Tag & push tagged image:** Tag the built image with current Jenkins build number and push to registry (for update deployments).
    * **Tag & push latest image:** Re-tag the above image with __latest__ tag and push to DockerHub (for initial deployments).
    * **Docker logout:** Logout of the DockerHub registry.
    * **Deployment check:** Check for the existance of deployment on kubernetes cluster via kubernetes master node.
        * Create deployment with the latest image if the deployment dosen't exist.
        * Update deployment the existing deployment with the tagged image if exist.
    * **Notify the deployment status to Slack** (failure in any stage will also notify Slack).
* The deployment can be accessed publically via a static public IP attached to the Nginx ingress controller of the cluster.
* [optional] One can attach a domain name to the above IP.

## Demos & screenshots

<div>
    <details>
        <summary>Project Demo</summary>
        <a href="https://youtu.be/iZ-X2QC6WJ8">View demo</a><br><br>
    </details>
    <details>
        <summary>Stage View</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/jenkins_stage_view.png" align="center"><br><br>
    </details>
    <details>
        <summary>System Config</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/jenkins_config.png" align="center"><br><br>
    </details>
    <details>
        <summary>Pipeline Config</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/jenkins_pipeline_config.png" align="center"><br><br>
    </details>
    <details>
        <summary>Credentials</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/jenkins_credentials.png" align="center"><br><br>
    </details>
    <details>
        <summary>Slack status</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/slack_status.png" align="center"><br><br>
    </details>
    <details>
        <summary>DockerHub repository</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/dockerhub_repo.png" align="center"><br><br>
    </details>
    <details>
        <summary>Kubernetes deployment</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/k8s_depl.png" align="center"><br><br>
    </details>
</div>

## Build Outputs
* Terraform
    * [Init](https://raw.githubusercontent.com/vital987/devops_project/master/outputs/tf_init.txt)
    * [Plan](https://raw.githubusercontent.com/vital987/devops_project/master/outputs/tf_plan.txt)
    * [Apply](https://raw.githubusercontent.com/vital987/devops_project/master/outputs/tf_apply.txt)
    * [Destroy](https://raw.githubusercontent.com/vital987/devops_project/master/outputs/tf_destroy.txt)
* Jenkins
    * [Create deployment](https://raw.githubusercontent.com/vital987/devops_project/master/outputs/jenkins_create_build.txt)
    * [Update deployment](https://raw.githubusercontent.com/vital987/devops_project/master/outputs/jenkins_update_build.txt)

---
