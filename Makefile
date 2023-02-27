.SUFFIXES:
Makefile:;

ACCEPTANCE_TEST_BUILD_CONSTRAINT := acceptance.test
ACCEPTANCE_TEST_DOCKER_COMPOSE_FILE := lucirpc/docker-compose.acceptance-test.yaml

.DEFAULT_GOAL := test

.PHONY: build
build:
	go build ./...

.PHONY: clean
clean: clean-acceptance-test-server

.PHONY: clean-acceptance-test-server
clean-acceptance-test-server:
	docker compose --file $(ACCEPTANCE_TEST_DOCKER_COMPOSE_FILE) down --remove-orphans --rmi all --volumes

.PHONY: docs
docs: install
	go generate ./...

.PHONY: install
install:
	go install ./...

.PHONY: release
release:
	goreleaser release --clean

.PHONY: start-acceptance-test-server
start-acceptance-test-server:
	docker compose --file $(ACCEPTANCE_TEST_DOCKER_COMPOSE_FILE) up --build --remove-orphans --wait

.PHONY: test
test: build test-docs test-go

.PHONY: test-docs
test-docs: test-docs-up-to-date

.PHONY: test-docs-up-to-date
test-docs-up-to-date:
	./scripts/test-docs-up-to-date.sh

.PHONY: test-go
test-go: test-go-unit-test test-go-acceptance-test

.PHONY: test-go-acceptance-test
test-go-acceptance-test: start-acceptance-test-server
	TF_ACC=1 go test -tags=$(ACCEPTANCE_TEST_BUILD_CONSTRAINT) ./...

.PHONY: test-go-unit-test
test-go-unit-test:
	go test ./...
