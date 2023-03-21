
# DevSecOps Project

## Table of contents

- [Introduction](#introduction)
- [Tools Used](#tools-used)
- [Pipeline](#pipeline)
- [Azure Infrastructure](#azure-infrastructure)
- [Detailed Workflow](#detailed-workflow)
- [Security approaches](#security-approaches)
- [Project Demo](#demo)
- [Screenshots](#screenshots)
- [Build Outputs](#build-outputs)

## Introduction

An end-to-end DevSecOps pipeline built on Azure using Terraform.

## Tools Used

| <a href="https://azure.microsoft.com"><img src="https://github.com/vital987/vital987/blob/master/assets/azure.svg" width=32 height=32></a><br><b>Azure</b>  | <a href="https://terraform.io"><img src="https://github.com/vital987/vital987/blob/master/assets/terraformio.svg" width=32 height=32><a><br></b>Terraform</b> |                 <a href="https://linux.org/"><img src="https://github.com/vital987/vital987/blob/master/assets/linux-icon.svg" width=32 height=32></a><br><b>Linux</b>                 |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|       <a href="https://git-scm.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/git.svg" width=32 height=32></a><br><b>Git</b>       |     <a href="https://github.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/github.svg" width=32 height=32></a><br><b>GitHub</b>      |                 <a href="https://jenkins.io/"><img src="https://github.com/vital987/vital987/blob/master/assets/jenkins.svg" width=32 height=32></a><br><b>Jenkins</b>                 |
| <a href="https://www.vaultproject.io/"><img src="https://github.com/vital987/vital987/blob/master/assets/vault.svg" width=32 height=32></a><br><b>Vault</b> |       <a href="https://trivy.dev/"><img src="https://github.com/vital987/vital987/blob/master/assets/trivy.svg" width=32 height=32></a><br><b>Trivy</b>       | <a href="https://www.sonarsource.com/products/sonarqube/"><img src="https://github.com/vital987/vital987/blob/master/assets/sonarqube.svg" width=32 height=32></a><br><b>SonarQube</b> |
|  <a href="https://maven.apache.org/"><img src="https://github.com/vital987/vital987/blob/master/assets/maven.svg" width=32 height=32></a><br><b>Maven</b>   |       <a href="https://junit.org/"><img src="https://github.com/vital987/vital987/blob/master/assets/junit5.png" width=32 height=32><a><br><b>JUnit</b>       |             <a href="https://www.selenium.dev/"><img src="https://github.com/vital987/vital987/blob/master/assets/selenium.svg" width=32 height=32></a><br><b>Selenium</b>             |
| <a href="https://www.ansible.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/ansible.svg" width=32 height=32></a><br><b>Ansible</b> |     <a href="https://docker.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/docker.svg" width=32 height=32></a><br><b>Docker</b>      |            <a href="https://kubernetes.io/"><img src="https://github.com/vital987/vital987/blob/master/assets/kubernetes.svg" width=32 height=32></a><br><b>Kubernetes</b>             |

## Pipeline

![process_diagram](https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/devops_project.png)

## Azure Infrastructure

![azure_diagram](https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/azure_infra.png)

## Detailed workflow

- The coder commits and pushes the source code to the GitHub repository.
- GitHub webhook pushes to Jenkins.
- Vault integration with Jenkins enables Jenkins to fetch credentials from Vault.
- Jenkins triggers the build.
    - **Declarative Checkout:** Jenkins fetches the [source code](https://github.com/vital987/cicdTestApp) from the GitHub repo and checks it out to the specified branch.
    - **Scan web app:** Scans the fetched source code with SonarQube scanner and reports the analysis to the SonarQube host.
    - **Build web app:** Builds the [source code](https://github.com/vital987/cicdTestApp) with Maven and outputs a jar file (war+tomcat server).
    - **Test web app:** Tests the built application with given JUnit test cases and stores the reports with the help of the SureFire plugin.
    - **Push artifact:** Pushes the built jar file to the Ansible server via SCP.
    - **Run the playbook**: Run the Ansible playbook on the Ansible server.
    - **Clean workspace:** Delete compiled/built/packaged components.
    - **Send status:** Sends build status to GitHub and build status + test summary to Slack (the failure in any stage will also send notification).
- Ansible executes the playbook on the Ansible server.
    - **Docker login:** Login to Docker with registry credentials (DockerHub in this case) to push images.
    - **Build image:** Build the image by copying the JAR file (the artifact sent by Jenkins) into the image.
    - **Tag & push tagged image:** Tag the built image with the current Jenkins build number and push to the registry (for update deployments).
    - **Tag & push latest image:** Re-tag the above image with the "latest" tag and push it to DockerHub (for initial deployments).
    - **Docker logout:** Log out of the DockerHub registry.
    - **Trivy vulnerability scan:** Scan Docker images for vulnerabilities and secrets and upload reports to blob storage.
    - **Deployment check:** check for the existence of deployment on a Kubernetes cluster via the master node.
        - Create the deployment with the latest image if it doesn't exist.
        - Update the existing deployment with the tagged image if it exists.
- **Notify the deployment status to Slack** (failure at any stage will also notify Slack).
- The deployment can be accessed publicly via a static public IP attached to the Nginx ingress controller of the cluster.
- One can further attach a domain name to the above IP.

## Security approaches

- All the virtual machines are separated into their own subnets. The interconnection between subnets is blocked by NSG security rules.
- Other than the NSG rules mentioned above, each VM has its own NSG inbound rules, allowing only the ports used by the respective softwares.
- All the virtual machines are secured with SSH public key authentication, which will help prevent brute-force attacks. The ssh connections between required virtual machines are made using Terraform during infrastructure provisioning. The keys are optionally stored locally to access the virtual machines manually.
- The credentials of all the tools are stored securely in the Hashicorp Vault. The credentials are accessed only by Jenkins and distributed to the rest of the tools via pipeline interpolation, reason was to secure the Vault AppRole credentials. Cause, according to my perspective, Jenkins provides the most secure credential storage among all the other tools (except vault) used in the pipeline to store Vault access (AppRole) credentials.

<p align=center>
    <img src="https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/secret_mgmt.png" height=300px>
</p>
 
## [Demo](https://youtu.be/F2fakudbC8o)
Demonstration of the pipeline workflow. Click the above hyperlink to view the demo.

## Screenshots

<div>

### Jenkins
 <details>
 <summary>Stage View</summary>
 <img src="https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/jenkins_stage_view.png" align="center"><br><br>
 </details>
 <details>
 <summary>System Config</summary>
 <img src="https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/jenkins_config.png" align="center"><br><br>
 </details>
 <details>
 <summary>Pipeline Config</summary>
 <img src="https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/jenkins_pipeline_config.png" align="center"><br><br>
 </details>
 <details>
 <summary>Credentials</summary>
 <img src="https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/jenkins_credentials.png" align="center"><br><br>
 </details>

### SonarQube
 <details>
 <summary>Dashboard</summary>
 <img src="https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/sonarqube_analysis.png" align="center"><br><br>
 </details>

### Slack
 <details>
 <summary>Channel messages</summary>
 <img src="https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/slack_status.png" align="center"><br><br>
 </details>

### DockerHub
 <details>
 <summary>Repository dashboard</summary>
 <img src="https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/dockerhub_repo.png" align="center"><br><br>
 </details>
 
### Kubernetes
 <details>
 <summary>Deployment</summary>
 <img src="https://raw.githubusercontent.com/vital987/devsecops_project/master/docsAssets/k8s_depl.png" align="center"><br><br>
 </details>
</div>

## Build Outputs

- Terraform
    - [Plan](https://raw.githubusercontent.com/vital987/devsecops_project/master/outputs/tf_plan.txt)
- Jenkins
    - [Create deployment](https://raw.githubusercontent.com/vital987/devsecops_project/master/outputs/jenkins_create_build.txt)
    - [Update deployment](https://raw.githubusercontent.com/vital987/devsecops_project/master/outputs/jenkins_update_build.txt)
- Vault
    - [Credentials](https://raw.githubusercontent.com/vital987/devsecops_project/master/outputs/vault_credentials.txt)

---
