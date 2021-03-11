# Setup GitLab (CI/CD)

This project is using GitLab CI/CD system. <br/>
See [GitLabCI Configuration](../.gitlab-ci.yml). <br/>
<hr>
Policy: <br/>
CI/CD gets only triggered by Merge Requests or Commits into Branch Master (Staging environment) or Production. <br/>
CI/CD doesn't get triggered by Merges or Commits into other Branches. <br>

## Pipeline Stages:

In general: <br/>
- Every merge request into the environment branches (master = staging env., production = production env.) will trigger the __Test and Lint__ stage. Here we test and lint the code of the server and client part. 
- We also validating/linting every changes to the Terraform configuration. 
- On success we can then merge our changes into master or production branch
- This creates a new commit there and therefore __Build and Push__ stage gets triggered.
- - We build the Artifact of the Server (including the Client part)
- - We Push the Artifact to AWS ECR

- When then Plan every changes (if any) to the staging and production environment managed by Terraform in __Staging Plan__ / __Production Plan__ stage
- If successful we apply every changes (if any) to the staging and production environment managed by Terraform in __Staging Apply__ / __Production Apply__ stage
- _Info_ Every terraform changes that get applied to the production environment will be applied to the staging environment as well. 
- BUT NOT vice versa! This is a project policy.

- __Destroy Stage__, this stage can get triggered manually via GitLab to destroy the whole production or staging environment on AWS via Terraform.


There are 5 stages in the pipeline in total:

Test and Lint -> Build and Push -> Staging _or_ Production Plan -> Staging _or_ Production Apply -> Destroy (Manual Trigger) (staging _or_ production environment)

### 1: Test and Lint

_Triggered by_ : Merge Request or Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment 

- Test and Lint Server and Client part
- Validate Terraform Configuration

### 2: Build and Push

_Triggered by_ : Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment <br/>
We only want to Build and Push artifacts that survived test and lint.
Therefore only Build and Push after a merge request gets merged in ( = commit) -> No build and push on merge request creation!

- Build Server Part (including Client as static served artifact)
- Build DB Image
- __if successful__ : Push both to AWS ECR Repositories

### 3: Staging Plan / Production Plan

_Triggered by_ : Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment.

- After successful _Test and Lint_ stage that is validating Terraform code (beside test/lint Server/Client part). 
- Plan changes to Staging environment with terraform.

### 4: Staging Apply / Production Apply

_Triggered by_ : Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment.

- After successful _Test and Lint_ stage that is validating Terraform code. 
- Plan changes to Staging environment with terraform.

### 5: Destroy (Manual)

_Triggered by_ : Commit -> __Production__ <br/>

- Destroying entire staging or production environment in AWS manually with terraform via GitLab CI/CD pipeline.
  