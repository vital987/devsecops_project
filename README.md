# DevOps Project: CI-CD Pipeline
## Table of contents

* [Introduction](#introduction)
* [Tools Used](#tools-used)
* [Azure Infrastructure](#azure-infrastructure)
* [Pipeline Process](#pipeline-process)
* [Demos & Screenshots](#demos--screenshots)
* [Build Outputs](#build-outputs)

## Introduction
The project demonstrates a complete CI-CD pipeline built using native devops tools.<br>
The complete project infrastructure is provisioned on Azure cloud via Terraform.

## Tools Used
| <a href="https://azure.microsoft.com"><img src="https://github.com/vital987/vital987/blob/master/assets/azure.svg" width=32 height=32></a><br>Azure | <a href="https://terraform.io"><img src="https://github.com/vital987/vital987/blob/master/assets/terraformio.svg" width=32 height=32></a><br>Terraform | <a href="https://linux.org/"><img src="https://github.com/vital987/vital987/blob/master/assets/linux-icon.svg" width=32 height=32></a><br>Linux | <a href="https://git-scm.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/git.svg" width=32 height=32></a><br>Git | <a href="https://github.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/github.svg" width=32 height=32></a><br>GitHub | <a href="https://jenkins.io/"><img src="https://github.com/vital987/vital987/blob/master/assets/jenkins.svg" width=32 height=32></a><br>Jenkins | <a href="https://maven.apache.org/"><img src="https://github.com/vital987/vital987/blob/master/assets/maven.svg" width=32 height=32></a><br>Maven | <a href="https://www.ansible.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/ansible.svg" width=32 height=32></a><br>Ansible | <a href="https://docker.com/"><img src="https://github.com/vital987/vital987/blob/master/assets/docker.svg" width=32 height=32></a><br>Docker | <a href="https://kubernetes.io/"><img src="https://github.com/vital987/vital987/blob/master/assets/kubernetes.svg" width=32 height=32></a><br>Kubernetes |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|

## Pipeline Process
[![process_diagram](https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/devops_project.png)]()

## Azure Infrastructure
[![azure_diagram](https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/diagram.azure.png)]()

## Demos & Screenshots
<div>
    <details>
        <summary>Project File Structure</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/file_structure.png" align="center"><br><br>
    </details>
</div>

### Jenkins
<div>
    <details>
        <summary>Initial Deployment</summary>
        <a href="https://www.youtube.com/watch?v=1vnD8qli9oI" target="_blank"> View Demo </a>
    </details>
    <details>
        <summary>Update Deployment</summary>
        <a href="https://www.youtube.com/watch?v=Pu6y5A9MAwE" target="_blank"> View Demo </a>
    </details>
    <details>
        <summary>Stage View</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/jenkins_staged_view.png" align="center"><br><br>
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
</div>

## Build Outputs

### Jenkins
<div>
    <details>
        <summary>Initial Deployment</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/jenkins_initial_deployment_output.png" align="center"><br><br>
    </details>
</div>
<div>
    <details>
        <summary>Update Deployment</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/jenkins_update_deployment_output.png" align="center"><br><br>
    </details>
</div>

### Ansible Server
<div>
    <details>
        <summary>Initial Deployment</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/ansible_initial_deployment.png" align="center"><br><br>
    </details>
    </details>
    <details>
        <summary>Update Deployment</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/ansible_update_deployment.png" align="center"><br><br>
    </details>
    </details>
</div>

### AKS Cluster
<div>
    <details>
        <summary>Deployment</summary>
        <img src="https://raw.githubusercontent.com/vital987/devops_project/master/docsAssets/k8s_depl.png" align="center"><br><br>
    </details>
</div>

---
