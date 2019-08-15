#!/bin/sh
.DEFAULT_GOAL := help

.PHONY: up \
		status \
		stop \
		verify \

export AUTH_USER		= pe
export AUTH_PASS		= pe
export CONTAINER_NAME	= pagoefectivo_balancer
export PROJECT_SERVICES	= authorize:backend, cips:backend, users:backend, services:backend
export DOCKER_NETWORK 	= pagoefectivo_network

up: ## up local balancer: make up
	$(MAKE) verify
	docker-compose up -d
	docker-compose ps

restart: ## restart the balancer: make restart
	docker-compose restart

down:  ## stop local balancer: make down
	docker-compose down

verify: ## verify local network: make verify
	@if [ -z $$(docker network ls | grep $(DOCKER_NETWORK) | awk '{print $$2}') ]; then\
		(docker network create $(DOCKER_NETWORK));\
	fi

local_domain: ## add local domain to hosts: make local_domain
	@if [ -z "${HOST_NAME}" ]; then (echo "Please set the ip in to 'HOST_NAME' variable. e.g. HOST_NAME=local.urbania.ec" && exit 1); fi
	$(eval ETC_HOSTS := /etc/hosts)
	$(eval IP := 127.0.0.1)
	$(eval HOSTS_LINE := '$(IP)\t$(HOST_NAME)')
	@if [ -n "$$(grep $(HOST_NAME) /etc/hosts)" ]; \
		then \
			echo "$(HOST_NAME) already exists : $$(grep $(HOST_NAME) $(ETC_HOSTS))"; \
		else \
			echo "Adding $(HOST_NAME) to your $(ETC_HOSTS)"; \
			sudo -- sh -c -e "echo $(HOSTS_LINE) >> /etc/hosts"; \
			if [ -n "$$(grep $(HOST_NAME) /etc/hosts)" ];\
				then \
					echo "$(HOST_NAME) was added succesfully \n $$(grep $(HOST_NAME) /etc/hosts)"; \
				else \
					echo "Failed to Add $(HOST_NAME), Try again!"; \
			fi \
	fi

help:
	@printf "\033[31m%-29s %-32s %s\033[0m\n" "Target" " Help" "Usage"; \
	printf "\033[31m%-29s %-32s %s\033[0m\n"  "------" " ----" "-----"; \
	grep -hE '^\S+:.*## .*$$' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' | sort | awk 'BEGIN {FS = ":"}; {printf "\033[32m%-30s\033[0m %-30s \033[34m%s\033[0m\n", $$1, $$2, $$3}'