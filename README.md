Lecture: DevOps - application
=============================


This repository contains the [application](./app/README.md) that should is used as *deployable workload* for the
[exercise](https://github.com/lucendio/lecture-devops-material/blob/master/assignments/exercise.md) implementation.  


### Getting started 

For more information regarding the app, please take a look into its [README](./app/README.md).

The `Makefile` in this directory can be seen as the main entry point for this repository. It's meant to locally run the
application in a container environment and also dispatch commands to terraform that is in control of orchestrating the 
AWS cloud. 

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
* [Terraform Setup](./doc/1-setup-terraform.md)
* [GitLab Repository with CI/CD Setup](./doc/2-setup-gitlab.md) 

### Serving over HTTPS 

The server runs via https (port 3000) and is using a self-signed certificate.
You need to specify that you are using "https" in your address bar.
This can cause alarming prompts when opening up the server frontend with a webbrowser.
You can safely bypass this warning. However, to remove the warning you have to add 
the server [certificate file](./app/server/src/server.cert) to trusted ones on your machine.
<br/>
Here is how:

- [Windows 10](https://support.kaspersky.com/CyberTrace/1.0/en-US/174127.htm)
- [Linux](https://unix.stackexchange.com/questions/90450/adding-a-self-signed-certificate-to-the-trusted-list)
- [MacOS](https://tosbourn.com/getting-os-x-to-trust-self-signed-ssl-certificates/)
### Commands

You can use make to use the following commands. If you haven't make installed,
please take a look at the [makefile](Makefile) and copy paste needed commands. </br>

The following commands are available from the root directory (if make is installed):



#### TBA

### Building 

#### `make build`

* builds the client code
* copies it over into the server

### Spin up locally 

### Testing

### Make changes


### Provisioning
