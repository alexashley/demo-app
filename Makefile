MAKEFLAGS += --silent
.PHONY: image run push-image
.PHONY: tf-init tf-plan tf-apply

REPO = alexashley/demo-app
VERSION := $(shell git rev-parse --short HEAD)
TF_VERSION = "0.12.29"

default:
	echo No default target.

image:
	docker build \
		-t $(REPO):$(VERSION) \
		-t $(REPO):latest \
		 .

run: image
	docker run \
		-it \
		--rm \
		-p 1234:1234 \
		$(REPO)

push-image: image
	docker push $(REPO):$(VERSION) && \
	docker push $(REPO):latest

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
		hashicorp/terraform:$(TF_VERSION) \
		plan -var-file=gcp.tfvars

tf-apply: tf-init
	docker run \
		-it \
		--rm \
		-w /usr/src/tf \
		-v ~/.config/gcloud:/root/.config/gcloud \
		-v $$(pwd)/tf:/usr/src/tf \
		hashicorp/terraform:$(TF_VERSION) \
		apply -var-file=gcp.tfvars