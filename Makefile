.DEFAULT_GOAL := help

.PHONY: help
help: ## show this message
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-8s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## build docker image
	docker build . -t takumakei/docker-dropbox:$(shell cat VERSION)

.PHONY: update
update: ## update Dockerfile
	./update.sh
