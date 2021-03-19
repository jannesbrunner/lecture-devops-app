Lecture: DevOps - application
=============================


This repository contains the [application](./app/README.md) that should is used as *deployable workload* for the
[exercise](https://github.com/lucendio/lecture-devops-material/blob/master/assignments/exercise.md) implementation.  


### Getting started 

For more information regarding the app, please take a look into its [README](./app/README.md).

The `Makefile` in this directory can be seen as the main entry point for this repository. It's meant to locally run the
application in a container environment and also dispatch commands to terraform that is in control of orchestrating the 
AWS cloud. 
</br>

You can use make to use the following upcoming make commands in following sections. If you haven't make installed,
please take a look at the [makefile](Makefile) and copy paste needed commands. </br>

### Prerequisites

The following software must be installed and available in your `${PATH}`:

* `docker` ([Docker](https://www.docker.com/get-started))
* `docker-compose` ([Docker Compose](https://docs.docker.com/compose/install/))

Optional:

* `make` ([Make](https://www.gnu.org/software/make/))
  * For command shortcuts mainly
* `npm` ([npm](https://www.npmjs.com/get-npm))
  * To run or test the app (server/client) without containers
* `mongod` ([MongoDB](https://docs.mongodb.com/manual/installation/))
  * To run or test database (MongoDB) without containers
* `terraform` ([Terraform](https://www.terraform.io/))
  * To user terraform directly on your machine

*NOTE: [required versions](https://github.com/lucendio/lecture-devops-app/blob/master/Makefile#L14-L126)*


### Concept
To get a better understatement of the devOps setup and flow of this project, please take a look at the
[concept here](./doc/concept.md).

### Setup
In order to use the implemented devOps workflow with terraform, AWS, GitLab (CI/CD) you need to set them 
up. Pleaser refer to the setup documentations:

* [Amazon Web Services Setup](./doc/0-setup-aws.md)
  * Amazon Web Services Account needed (project compatible with AWS Educate Account) 
* [Terraform Setup](./doc/1-setup-terraform.md)
* [GitLab Repository with CI/CD Setup](./doc/2-setup-gitlab.md)
  * GitLab should offer CI/CD Runners. If not you can register your own:
  * [Registering Runners](https://docs.gitlab.com/runner/register/) 


### Make changes

The normal workflow is pushing committed made changes (VCS=Git) to the app (best case scenario: reflecting [Git-Flow-Workflow](https://www.atlassian.com/de/git/tutorials/comparing-workflows/gitflow-workflow)) and push them to GitLab.
- Every change that is made to master and production branch will trigger the CI/CD system. 
#### Run Project locally 

cd in project root. With make, docker and docker-compose installed use: 

- `$ make dev-start`
- Spin up project locally
- access running app via [http://localhost:3000]

#### Test Project locally

cd in project root. With make, docker and docker-compose installed use: 

##### Server

- `$ make dev-test-server`
- See console output

##### Client 

- `$ make dev-test-client`
- See console output

#### Terraform commands

Terraform is first-class citizen in this project and in charge of the whole cloud infrastructure. 
You can use the following shortcut commands on a local developer machine: 

- `$ make tf-init` : init project 
- `$ make tf-fmt` : format terraform code
- `$ make tf-validate` : validate terraform code
- `$ make tf-workspace-ls` : list available workspaces
- `$ make tf-plan` : plan made infra changes
- `$ make tf-apply` : apply made infra changes
- `$ make tf-destroy` : destroy infrastructure in workspace
- `$ make tf-workspace-dev` : switch to development workspace (not meant for cloud)
- `$ make tf-workspace-staging` : switch to staging workspace (cloud)
- `$ make tf-workspace-prod` : switch to production workspace (cloud)
### Provisioning

#### locally

- If app is running
- visit [http://localhost:3000/status] //TODO
  - [Express Status Monitor](https://github.com/RafalWilinski/express-status-monitor)
  - Secured with http-auth: **USER**: admin, **PW**: testtest
- check console output
  
#### Cloud (AWS)

- All console output gets combined into one log-group
- This is made by AWS CloudWatch Logs
- You can access these logs via AWS Console oder by connecting into Bastion server
  - For Bastion Server connect check console output after terraform apply process
    - e.g.: "bastion_host = ec2-18-207-193-234.compute-1.amazonaws.com"
    - ssh into it with `$ ec2-user@ec2-18-207-193-234.compute-1.amazonaws.com`
    - check [AWS Setup](./doc/0-setup-aws.md) for adding secure SSH Key
  - Check [AWS CLI logs](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/logs/index.html)

### Helpers 

- Easily refresh your AWS Educate credentials
  -  `$ make aws-win` : On Windows Systems
  -  `$ make aws-win` : On Mac / Linux Systems

- Easily refresh your AWS Educate credentials in GitLab
  - **WORK IN PROGRESS**
### Serving over HTTPS 

**Serving over HTTPS not possible with AWS Educate account in combination with AWS Elastic Load Balancer**

~~The server runs via https (port 3000) and is using a self-signed certificate.~~
~~You need to specify that you are using "https" in your address bar.~~
This can cause alarming prompts when opening up the server frontend with a webbrowser.
You can safely bypass this warning. However, to remove the warning you have to add 
the server [certificate file](./app/server/src/server.cert) to trusted ones on your machine.
<br/>
Here is how:

- [Windows 10](https://support.kaspersky.com/CyberTrace/1.0/en-US/174127.htm)
- [Linux](https://unix.stackexchange.com/questions/90450/adding-a-self-signed-certificate-to-the-trusted-list)
- [MacOS](https://tosbourn.com/getting-os-x-to-trust-self-signed-ssl-certificates/)

### Purge

- `$ make purge`
  - shut down all containers
  - delete all containers and networks etc.
