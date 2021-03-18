variable "prefix" {
  type        = string
  default     = "lda"
  description = "for prefixing resources. lda = lecture devops app."
}

variable "project" {
  type        = string
  default     = "lecture-devOps-app"
  description = "the project name"
}

variable "contact" {
  type        = string
  default     = "s40929@beuth-hochschule.de"
  description = "maintainer contact e-address"
}

variable "bastion_key_name" {
  default = "lda-app-devops-bastion"
}

variable "ecr_image_server" {
  description = "ECR image for server image"
  default     = "742206682728.dkr.ecr.us-east-1.amazonaws.com/lecture-devops-app-server:latest"
}

variable "ecr_image_db" {
  description = "ECR image for app db image"
  default     = "742206682728.dkr.ecr.us-east-1.amazonaws.com/lecture-devops-app-db:latest"
}
