#####################################################
# Makefile containing shortcut commands for project #
#####################################################

# MACOS USERS:
#  Make should be installed with XCode dev tools.
#  If not, run `xcode-select --install` in Terminal to install.

# WINDOWS USERS:
#  1. Install Chocolately package manager: https://chocolatey.org/
#  2. Open Command Prompt in administrator mode
#  3. Run `choco install make`
#  4. Restart all Git Bash/Terminal windows.

.PHONY: aws-win
aws-win:
	powershell.exe ./deploy/tools/set-aws-credentials.ps1

.PHONY: aws-mac
aws-mac:
	./deploy/tools/set-aws-credentials.sh

.PHONY: dev-start
dev-start:
	docker-compose up

.PHONY: dev-test
dev-test:
	docker-compose exec -e MONGODB_URL=mongodb://todo-app-db:27017/todo-app todo-app-server npm run test

.PHONY: dev-purge
dev-purge:
	docker-compose down && docker-compose rm

.PHONY: tf-init
tf-init:
	docker-compose -f deploy/docker-compose.yml run --rm terraform init

.PHONY: tf-fmt
tf-fmt:
	docker-compose -f deploy/docker-compose.yml run --rm terraform fmt

.PHONY: tf-workspace-ls
tf-workspace-ls:
	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace list

.PHONY: tf-validate
tf-validate:
	docker-compose -f deploy/docker-compose.yml run --rm terraform validate

.PHONY: tf-plan
tf-plan:
	docker-compose -f deploy/docker-compose.yml run --rm terraform plan

.PHONY: tf-apply
tf-apply:
	docker-compose -f deploy/docker-compose.yml run --rm terraform apply

.PHONY: tf-destroy
tf-destroy:
	docker-compose -f deploy/docker-compose.yml run --rm terraform destroy

.PHONY: tf-workspace-dev
tf-workspace-dev:
	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace select dev

.PHONY: tf-workspace-staging
tf-workspace-staging:
	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace select staging

.PHONY: tf-workspace-prod
tf-workspace-prod:
	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace select prod

