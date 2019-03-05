.PHONY: build push run help
.DEFAULT_GOAL:= help

# bash scripts kicked off via make need the env too
.EXPORT_ALL_VARIABLES:

# kubernetes namespace = $IMAGE-$ENV_NAME
IMAGE ?= gatsby-docker
APPNAME = $(IMAGE)

# Grab the current git hash and use as the tag
GIT_HASH := $(shell git rev-parse HEAD)
# gitlab uses CI_COMMIT_REF_NAME, else you get HEAD
GIT_BRANCH := $(if $(CI_COMMIT_REF_NAME),$(CI_COMMIT_REF_NAME),$(shell git rev-parse --symbolic-full-name --abbrev-ref HEAD))
TAG = $(GIT_HASH)

REGION = us-east-1
PREFIX = 642011407717.dkr.ecr.us-east-1.amazonaws.com

# common functions
docker-push-aws = aws ecr get-login --region $(REGION) --no-include-email | sh && docker push $(PREFIX)/$1:$(TAG)


build:
	@echo "# building $(IMAGE)"
	docker build --no-cache=true -f Dockerfile -t $(PREFIX)/$(IMAGE):$(TAG) .
	@echo "# checking docker images"
	docker images | grep -i '$(PREFIX)'

push:
	$(call docker-push-aws,$(IMAGE))

run:
	docker run -e NPM_CONFIG_LOGLEVEL=$(LOGLEVEL) -e ENV_NAME=$(ENV_NAME) --env-file=.env_${ENV_NAME} -t --rm --name $(IMAGE) $(PREFIX)/$(IMAGE):$(TAG)
	#docker run -e ENV_NAME=$(ENV_NAME) -t --rm --name $(IMAGE) $(PREFIX)/$(IMAGE):$(TAG)

stop:
	docker stop $(IMAGE)

help:
	@echo ""
	@echo "========================= Config ========================= "
	@echo "GIT_HASH=$(GIT_HASH)"
	@echo "GIT_BRANCH=$(GIT_BRANCH)"
	@echo "PREFIX=$(PREFIX)"
	@echo ""
	@echo "========================== Help ========================== "
	@echo ""
	@echo " # build the ${IMAGE} docker image:"
	@echo "	make build"
	@echo ""
	@echo " # push the ${IMAGE} docker image:"
	@echo "	make push"
	@echo ""
	@echo ""
	@echo " # run the ${IMAGE} docker image:"
	@echo "	make run"
	@echo " # stop the ${IMAGE} docker image:"
	@echo "	make stop"
	@echo ""

