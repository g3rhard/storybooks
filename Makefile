PROJECT_ID=disco-beanbag-298417
ZONE=us-central1-a

run-local:
	docker-compose up

###

create-tf-backend-bucket:
	gsutil mb -p $(PROJECT_ID) gs://$(PROJECT_ID)-terraform-g3

###

define get-secret
$(shell gcloud secrets versions access latest --secret=$(1) --project=$(PROJECT_ID))
endef

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
			--var-file="./environments/$(ENV)/config.tfvars" \
			-var="mongodbatlas_private_key=$(call get-secret,mongodbatlas_private_key)" \
			-var="atlas_user_password=$(call get-secret,atlas_user_password_$(ENV))" \
			-var="cloudflare_api_token=$(call get-secret,cloudflare_api_token)"

###

SSH_STRING=storybooks-vm-$(ENV)
VERSION?=latest
LOCAL_TAG=storybooks-app:$(VERSION)
REMOTE_TAG=gcr.io/$(PROJECT_ID)/$(LOCAL_TAG)

CONTAINER_NAME=storybooks-api

ssh:
	gcloud compute ssh --zone=$(ZONE) \
		--project=$(PROJECT_ID) \
		$(SSH_STRING)

ssh-cmd:
	gcloud compute ssh $(SSH_STRING) \
		--project=$(PROJECT_ID) \
		--zone=$(ZONE) \
		--command="$(CMD)"

build:
	docker build -t $(LOCAL_TAG) .

push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

deploy:
	$(MAKE) ssh-cmd CMD='docker-credential-gcr configure-docker'
	$(MAKE) ssh-cmd CMD='docker pull $(REMOTE_TAG)'
	-$(MAKE) ssh-cmd CMD='docker container stop $(CONTAINER_NAME)'
	-$(MAKE) ssh-cmd CMD='docker container rm $(CONTAINER_NAME)'
	$(MAKE) ssh-cmd CMD='\
		docker run -d --name=$(CONTAINER_NAME) \
			--restart=unless-stopped \
			-p 80:3000 \
			-e PORT=3000 \
			-e \"MONGO_URI=mongodb+srv://storybooks-user-$(ENV):$(call get-secret,atlas_user_password_$(ENV))@storybooks-$(ENV).3y88a.mongodb.net/$(DB_NAME)?retryWrites=true&w=majority\" \
			-e GOOGLE_CLIENT_ID=583683178691-kg0jkvie0j1bdkoj3bhbvkqg7nbrqlgr.apps.googleusercontent.com \
			-e GOOGLE_CLIENT_SECRET=$(call get-secret,google_oauth_client_secret) \
			$(REMOTE_TAG) \
			'
