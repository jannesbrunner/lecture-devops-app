# Setup GitLab (CI/CD)

This project is using GitLab CI/CD system. <br/>
See [GitLabCI Configuration](../.gitlab-ci.yml). <br/>
<hr>
Policy: <br/>
CI/CD gets only triggered by Merge Requests or Commits into Branch Master (Staging environment) or Production. <br/>
CI/CD doesn't get triggered by Merges or Commits into other Branches.


## Pipeline Stages:

There are 7 stages in the pipeline:

### Test and Lint

_Triggered by_ : Merge Request or Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment 

- Test and Lint Server and Client part
- Validate Terraform Configuration

### Build and Push

_Triggered by_ : Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment <br/>
We only want to Build and Push artifacts that survived test and lint.
Therefore only Build and Push after a merge request gets merged in ( = commit) -> No build and push on merge request creation!

- Build Server Part (including Client as static served artifact)
- Build DB Image
- __if successful__ : Push both to AWS ECR Repositories

### Staging Plan

_Triggered by_ : Commit -> __Master__ or __Production__ <br/>
Hint: Master branch = Staging environment.
master | production -> this makes sure that staging environment (master branch) <br/>
will at least have the latest production artifact as well. So everything that goes into production will also go into staging.
Normally everything should get tested in staging before publish on production.


- After successful _Test and Lint_ stage that is validating Terraform code. 
- Plan changes to Staging environment with terraform.
  