# DevOps Concept

**DevOps - Software Development and Operations (WiSe2021) @Beuth Hochschule**



## Environments

There are three environments. Each one is targeting 
a different purpose within the project. 

Briefly:

- Local 0: local development environment on a developers machine
- - Infrastructure runs in containers

- Staging 1: cloud development environment for new features and (hot) fixes
- - Managed by Terraform

- Production 2: cloud development environment for new new production builds.
- - Managed by Terraform

Each Cloud Environment (No. 1 and No. 2) has a Bastion Server.
This Bastion Server is for connecting into the private network part of the
environment (inside AWS) for administration purposes. This is a small 
linux running machine of a small type (t2.micro). 

### Local 0

#### Description

This one aims to establish a reliable local development environment on a developers machine. 

- All infrastructure and resources gets allocated locally via Docker/Docker-compose.
#### Pipeline

**Trigger**: Manual CLI Command

1. Run Linting 
If successful: 
2. Build
3. Run Tests (if any)
4. Allocate infrastructure locally via containers

App is reachable via dev server running on localhost

- Supervision insights is reduced or not available. 

### Staging 1 
#### Description
- This environment is allocated in an AWS cloud environment. 
- New features and (hot) fixes can get tested here. 

**Trigger**: Merge or Commit into Branch "Master" 
- Master branch is protected on GitLab
- - Only Maintainer can commit directly


#### Pipeline

1. Run Linting / Testing <br />
**If successful**: 
2. Run Terraform format and validation
**If successful**: 
3. Build Artifact
4. Push Artifact to Amazon ECR with tag ```$ECR_REPO:$CI_COMMIT_SHORT_SHA```
5. Plan Staging (Terraform) <br />
If successful:
5. Apply Staging (Terraform)


- App accessible via FQDN (Terraform output)

### Production 2

**Trigger**: Merge or Commit into Branch "Production" 

- This environment is allocated in an AWS cloud environment.
- New Builds get deployed here.
- Every Artifact that goes into production goes also to staging.
- => staging will at least always have latest production artifact.

- Access is maybe restricted to developers and stakeholders.

#### Pipeline

1. Run Linting / Testing <br />
**If successful**: 
2. Run Terraform format and validation
**If successful**: 
3. Build Artifact
4. Push Artifact to Amazon ECR with tag ```$ECR_REPO:$CI_COMMIT_SHORT_SHA```
5. Plan Production (Terraform) <br />
If successful:
5. Apply Production (Terraform)


- App accessible via FQDN (Terraform output)

## Lifecyle (Automation Steps)
- TBA

## Architecture
- TBA 

## Technology
This sections briefly describes technology (software, etc.) 
that is used within the project and the targeting environments.
### Version Control System

- Git
- Following the Git Flow Pattern.

### App insights (metrics etc)
- https://prometheus.io/ for metrics (insights)
- or https://github.com/cloudquery/cloudquery ?

### Command automation 
- Make (makefile)
- System (ps1 script or sh script)

### Container Orchestration
- Docker
- Docker Swarm
- Amazon ECS (Elastic Container Service)
- Amazon EC2 (for Bastion Server)

### CI

- GitLab CI

### CD

- GitLab CD

### Cloud

- Amazon Web Services AWS
- Terraform to manage resources in the cloud
- - Amazon S3 Bucket to version terraform state
- - Amazon DynamoDB Table to lock terraform state
- Amazon EC2 for Bastion Server (each per Cloud Environment)
- Amazon ECS for Container Orchestration
- Amazon VPC for managing environments
- Amazon ELB for load-balancing inbound traffic across two availability zones (per Environment)

### NGINX
- As reverse Proxy between Internet inbound access and ELB
  
### Security

- AWS-Vault to keep credentials encrypted with forced MFA policy on AWS
- AWS-Vault generated temporarily access tokens get passed via environments variables if needed


### Automated tool installation
The idea here is to provide a script 
on a (new) developers machine that automatically 
installs all needed tools to manage the project.

To keep the needed installed tools on a developers machine at a minimum,
most of the tools get executed by disposable one-time containers. 

-  MS Windows: Powershell Script (ps1)
- Apple Mac: shell script (sh)
- - Brew
- - Brew Cask

A DevOp/Maintainer/Developer only needs

- Git
- Docker
- Docker-Compose
- (Make)
  
locally installed on the machine.
