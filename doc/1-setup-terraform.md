# Setup Terraform

**Complete the [AWS Setup](./setup-aws.md) before setting up terraform!** <br/>
- There is a make file provided in the project root folder for shortcuting commands

## 1 Configure terraform backend
Set the AWS S3 Bucket name and dynamodb table name in [main.tf](../deploy/main.tf)
```
terraform {
    backend "s3" {
        bucket = "${YOUR_S3_BUCKET_NAME}"
        key = "devops-app.tfstate"
        region = "us-east-1"
        encrypt = true
        dynamodb_table = "${YOUR_DYNAMO_DB_NAME}"
    }
}
```

## 2 Set AWS credentials

- a) Use terraform within a container (*Not possible with student account!*)
- - In order to use terraform in that way you need to set your credentials
- - You will pass down your AWS credentials via env vars
- - If you use aws-vault they get set temporally after successful login
- - `${AWS_ACCESS_KEY_ID}`
- - `${AWS_SECRET_ACCESS_KEY}`
- - `${AWS_SESSION_TOKEN}`
- - **Hint: Because creation of IAM Accounts is not possible with AWS Student account, use option b)**
- - **or set these env vars manually. Remember to update the envs in future sessions!**

- b) Use terraform directly on your machine
- - Make sure your credentials are set correctly in `$HOME/.aws`

</br>

**AWS Student account: You need to update the credentials every time you start a new session!**

- There are scripts for `mac/linux` and `windows` systems for handy use:
- Windows: [set-aws-credentials.ps1](../deploy/tools/set-aws-credentials.ps1)
- Mac/Linux: [set-aws-credentials.sh](../deploy/tools/set-aws-credentials.sh)
- Use them again with empty input to unset the vars
- **Remember to refresh all terminal windows in order to user the env vars!**
- *Personal note: On windows you need to restart VS Code if in use :)*

- type `make aws-win` ||  `make aws-mac` to update your aws env vars credentials easily 


## 3 init terraform

- type `make tf-init` to init the project 
- This will use a terraform in a docker container 
- type `terraform init` to use your local terraform version


## 4 Set up terraform workspaces (= environments)

- Set up Staging environment:
- - type `terraform workspace new staging` (local terraform version)
- - type `docker-compose -f deploy/docker-compose.yml run --rm terraform workspace new staging` (docker version)
- Set up Production environment:
- - type `terraform workspace new production` (local terraform version)
- - type `docker-compose -f deploy/docker-compose.yml run --rm terraform workspace new prod` (docker version)

## Optional
- You can update project meta data in [variables.tf](../deploy/variables.tf) if you want to.
- these variables and tags data get attached to all created resources in AWS for easy management.

## 5 Create a terraform.tfvars file 

There a some environment variables that are containing sensitive information and might 
be unique to the setup a developer is running. 

- You will find a [sample.tfvars](../deploy/sample.tfvars) file in project deploy folder
- This sample file contains all variables that need to get set before planing or apply changes via terraform from local or bastion server.
- Create a file called `terraform.tfvars` in deploy folder with all variables from the sample file
- Alter variables values to your needs
- *info*: this `terraform.tfvars` file gets automatically excluded from versioning system (git) for security reasons by terraform
- **Hint**: You will need to set this variables via environment variables in GitLab. This is part of the GitLab setup.
  - GitLab will use these variables values in CI/CD pipeline jobs
  - Setting values in `terraform.tfvars` is for running terraform from a developer machine or bastion server

Continue with [**GitLab Setup**](2-setup-gitlab.md) 
