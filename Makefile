MAKEFLAGS += --silent
.PHONY: tf-init tf-plan tf-apply
.PHONY: k8s-apply

TF_VERSION = "0.12.29"

default:
	echo No default target.

tf-init:
	docker run \
		-it \
		--rm \
		-w /usr/src/tf \
		-v ~/.config/gcloud:/root/.config/gcloud \
		-v $$(pwd)/tf:/usr/src/tf \
		hashicorp/terraform:$(TF_VERSION) \
		init

tf-plan: tf-init
	docker run \
		-it \
		--rm \
		-w /usr/src/tf \
		-v ~/.config/gcloud:/root/.config/gcloud \
		-v $$(pwd)/tf:/usr/src/tf \
		-e TF_VAR_project_id=$(PROJECT_ID) \
		hashicorp/terraform:$(TF_VERSION) \
		plan -var-file=gcp.tfvars

tf-apply: tf-init
	docker run \
		-it \
		--rm \
		-w /usr/src/tf \
		-v ~/.config/gcloud:/root/.config/gcloud \
		-v $$(pwd)/tf:/usr/src/tf \
		-e TF_VAR_project_id=$(PROJECT_ID) \
		hashicorp/terraform:$(TF_VERSION) \
		apply -var-file=gcp.tfvars

k8s-template:
	docker run \
	-it \
	--rm \
	-w /usr/src/manifests \
	-v $$(pwd)/manifests:/usr/src/manifests \
	alpine/helm:3.2.4 template --release-name demo-app demo-app
