
# Setup GitLab

GitLab is in use for the CI/CD workflow. This project is adapted for GitLab CI/CD. <br/>
The [.gitlab-ci.yml](../.gitlab-ci.yml) will only work in a GitLab environment.
## 1 Create necessary branches

This project is using two branches that represent the staging and production environment:

- master 
  - Branch for staging environment
- production
  - Branch for production environment 

You can create these branches with git and push these branches to the repository.
You can also create these branches via GitLab repository webpage. <br/>

*Hint*: If you just forked or copied the entire project, you can skip creating branches for sure :)

## 2 Protect environment branches

It's best practice to protect the environment branches (master & production) against (force) pushes etc by non-maintainers!
In GitLab you can achieve this under `Settings/Repository/Protected branches`.

## 3 Setup GitLab (CI/CD)

**INFO**: Normally you would use an IAM AWS User with only programmatic access to your environment. 
This users access is limited by an AWS policy (template [here](../doc/aws-policies/app-terraform-ci-user.json)). <br/>
This is not possible with an AWS Educate account so in that case you have to use your main account also on the CI/CD pipeline. <br/>
With that being said: Every time you log-in again on AWS Educate you have to repeat this step here :/

- Log in to your GitLab repository
- Go to Settings -> CI/CD -> Expand Variables
- Put in the following variables (get it from your AWS Educate or IAM CI user):
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY_ID

- Only set the following var once (regardless AWS Educate or Normal)
  - ECR_REPO
    - ECR Repository URI (get it from https://console.aws.amazon.com/ecr/repositories)
    - e.g 742206682728.dkr.ecr.us-east-1.amazonaws.com/lecture-devops-app-server
  - TF_VAR_db_user
    - Username for accessing AWS DocumentDB
    - **Hint**: Mask and protect the var!
  - TF_VAR_db_password
    - Password for accessing AWS DocumentDB
    - **Hint**: Mask and protect the var!
  
  Set this variable after first deployment and update the cloud again with Terraform
  - TV_VAR_mongodb_url
    - Connection string for connecting to AWS DocumentDB Cluster
    - Get it from AWS Console -> DocumentDB -> Clusters -> lda-staging-docdb-cluster -> Connectivity & security

  