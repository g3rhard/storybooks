PROJECT_ID=disco-beanbag-298417

run-local:
	docker-compose up

###

create-tf-backend-bucket:
	gsutil mb -p $(PROJECT_ID) gs://$(PROJECT_ID)-terraform-g3

###

ENV=staging

terraform-create-workspace:
	cd terraform && \
		terraform workspace new $(ENV)

terraform-init:
	cd terraform && \
		terraform workspace select $(ENV) && \
		terraform init

TF_ACTION?=plan
terraform-action:
	cd terraform && \
		terraform workspace select $(ENV) && \
		terraform $(TF_ACTION) \
			--var-file="./environments/common.tfvars" \
			--var-file="./environments/$(ENV)/config.tfvars"
