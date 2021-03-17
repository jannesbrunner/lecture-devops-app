# DevOps Concept

**DevOps - Software Development and Operations (WiSe2021) @Beuth Hochschule**



## Environments

There are three environments. Each one is targeting 
a different purpose within the project. 

Briefly:

- Local 0: local development environment on a developers machine
- - Infrastructure runs in containers

- Staging 1: cloud development environment for new features and (hot) fixes
- - Managed by Terraform (via Terraform Workspace)
- - Git Branch Master -> AWS Staging Environment

- Production 2: cloud development environment for new new production builds.
- - Managed by Terraform (via Terraform Workspace)
- - Git Branch Production -> AWS Production Environment

Each Cloud Environment (No. 1 and No. 2) has a Bastion Server.
This Bastion Server is for connecting into the private network part of the
environment (inside AWS) for administration purposes. This is a small 
linux running machine of a small type (t2.micro). 

### Local 0

#### Description

This one aims to establish a reliable local development environment on a developers machine. 

- All infrastructure and resources gets allocated locally via Docker/Docker-compose.

- There are 3 `.env` - files:
  - app-container-dev.env => This gets forwarded into the running development container of the server (including client).
  - app-db-container-dev.env => This gets forwarded into the running mongodb database container.
  - .env => variables set here get used by docker-compose to create dev (server/db) with set configuration
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

This project is using GitLab CI/CD system. <br/>
See [GitLabCI Configuration](../.gitlab-ci.yml). <br/>
<hr>
Policy: <br/>
CI/CD gets only triggered by Merge Requests or Commits into Branch Master (Staging environment) or Production. <br/>
CI/CD doesn't get triggered by Merges or Commits into other Branches. <br>

### Pipeline Stages:

In general: <br/>
- Every merge request into the environment branches (master = staging env., production = production env.) will trigger the __Test and Lint__ stage. Here we test and lint the code of the server and client part with a job. 
- We also validating/linting every changes to the Terraform configuration with a job. 
- On success we can then merge our changes into master or production branch
- This creates a new commit there and therefore __Build and Push__ stage gets triggered.
  - Job: We build the Artifact of the Server (including the Client part)
  - Job: We Push the Artifact to AWS ECR

- When then plan every changes (if any) to the staging and/or production environment managed by Terraform in __Staging Plan__ / __Production Plan__ stage with a job.
- If successful we apply every changes (if any) to the staging and production environment managed by Terraform in __Staging Apply__ / __Production Apply__ stage with a job.
- _Info_ Every terraform changes that get applied to the production environment will be applied to the staging environment as well. 
- **This gets done before the production apply gets done**
- BUT NEVER vice versa! This is a project policy.
- The *Production Apply* Terraform job can also get set to manual to increase security (but loosing some automation).
  - If set manual: Every merge into production branch gets applied on staging environment automatically. Then if tested we can trigger the production apply.

- __Destroy Stage__, this Job can get triggered manually via GitLab to destroy the whole production or staging environment on AWS via Terraform.


There are 5 stages in the pipeline in total:

Test and Lint -> Build and Push -> Staging _or_ Production Plan -> Staging _or_ Production Apply -> Destroy (Manual Trigger) (staging _or_ production environment)

#### 1: Test and Lint

_Triggered by_ : Merge Request or Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment 

- Test and Lint Server and Client part
- Validate Terraform Configuration

#### 2: Build and Push

_Triggered by_ : Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment <br/>
We only want to Build and Push artifacts that survived test and lint.
Therefore only Build and Push after a merge request gets merged in ( = commit) -> No build and push on merge request creation!

- Build Server Part (including Client as static served artifact)
- Build DB Image
- __if successful__ : Push both to AWS ECR Repositories

#### 3: Staging Plan / Production Plan

_Triggered by_ : Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment.

- After successful _Test and Lint_ stage that is validating Terraform code (beside test/lint Server/Client part). 
- Plan changes to Staging environment with terraform.

#### 4: Staging Apply / Production Apply

_Triggered by_ : Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment.

- After successful _Test and Lint_ stage that is validating Terraform code. 
- Plan changes to Staging environment with terraform.

#### 5: Destroy (Manual)

_Triggered by_ : Commit -> __Production__ <br/>

- Destroying entire staging or production environment in AWS manually with terraform via GitLab CI/CD pipeline.

## Architecture

*INSERT Architecture PICTURE HERE* <br/>

### Load Balancer 

- A load balancer is handling incoming requests on staging and production environment (not on local dev environment)
- The load balancer is listening on http port and forwards the traffic to the ECS services that is running the app via containers
- Health checks getting performed on the entry path of the app-server `"/"`.
  - If the status is unhealthy (detected by non satisfying http status code response)
    - Load balancer informs ECS services about the outage (ECS will try to reload the service)
    - Fallback to another availability zone (1 or 2 in us-east-1)
### Database 

- The project needs a documented orientated ('noSQL') database like MongoDB.
- On local development (Environment 0) a MongoDB version 4.2.6 is running in a Docker Container. 
  - automatically provided by Docker-Compose (see [docker-compose.yml](../docker-compose.yml)).

- In staging and production environment (managed by terraform) an AWS documented-db cluster gets allocated
  - Per environment one doc-db-cluster having one doc-db-instance per availability zone (A,B)
  - Hence, one cluster with 2 instances

### Container Engine

- The project is fully containerized
  - In other words: the server runs in a single container
  - The client side gets build and pushed to the server container as artifact
  - At runtime the client gets dispatched to the visiting users web-browser as static files
  - client does requests to the server then

- On a local dev setup:
  - With docker compose build:
    - Build Client artifact
    - Transfer Client artifact to server build
    - Build server including client artifact
  - With docker compose up
    - Run server container (serve client on request)
    - Run MongoDB container as local dev backend

  - You can run tests on client and server automatically with docker compose
    - All will run within containers

- On Cloud Setup (Environments staging and production)
  - We use AWS ECS with AWS Fargate to:
    - Spin up built containers pulled from AWS ECR
    - ECR contains a build from every commit (normally made by a merge request) 
      - that was made into master (representing staging environment) and production branch
    - The running app container(s) within an ECS Task are using the AWS documented-db cluster described before as db backend.

### Network 

- Each environment (staging and production) is divided up into one public and one private reachable part 
represented by subnets.
  - Public Subnet A (running in availability zone A):   10.1.1.0/24
  - Private Subnet A (running in availability zone A):  10.1.10.0/24
  - Public Subnet B (running availability zone B):      10.1.2.0/24
  - Private Subnet B (running in availability zone B):  10.1.11.0/24
- Terraform will create a whole VPC on AWS with described network for each environment
    
- The running app itself (server part that also serves the client to a visitors browser) is set up in the public subnet of each environment.
- Alongside with a public reachable (but ssh-key secured) bastion server for performing administration task within the environment.
  - e.g. checking out metrics and logs etc. 
- the database is located in the private part of each environment because there is no need for direct public access to the db.
- an AWS Internet Gateway is controlling inbound and outbound access to the app and the bastion server.
- (there is also an AWS NAT Gateway acting as emergency exit for outbound traffic only for the private subnets).
- The traffic between Public and Private subnets is managed by a route table.
  
- The network is set up to make use of AWS availability zones in the running AWS region
  - This is done by creating the subnets (public/private) twice, hence in availability zone A and B of the AWS region.
  - This means if availability zone A goes down, zone B can take over and prevent an outage.
  - This also necessary for AWS load balancer to do its job. 

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
- Docker Compose
- Amazon ECS (for running app in container)


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
- Amazon DocumentDB (for running MongoDB like Database)

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
