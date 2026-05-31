IMAGE_NAME ?= fit4110/iot-ingestion:lab04
CONTAINER_NAME ?= fit4110-iot-lab04
PORT ?= 8000

.PHONY: help install lint mock build run run-detached health test-mock test-local test-docker stop clean-reports

help:
	@echo "FIT4110 Lab 04 - Docker Packaging & Newman Testing"
	@echo "====================================================="
	@echo ""
	@echo "Setup:"
	@echo "  make install          - Install npm and pip dependencies"
	@echo "  make lint             - Lint OpenAPI specification"
	@echo ""
	@echo "Mock Testing:"
	@echo "  make mock             - Start Prism mock server (port 4010)"
	@echo "  make test-mock        - Run Newman against mock server"
	@echo ""
	@echo "Docker & Local Testing:"
	@echo "  make build            - Build Docker image"
	@echo "  make run              - Run container in foreground"
	@echo "  make run-detached     - Run container in background"
	@echo "  make health           - Check service health"
	@echo "  make test-docker      - Run Newman against real container"
	@echo "  make test-local       - Run Newman against real container (alias)"
	@echo "  make stop             - Stop running container"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean-reports    - Delete test reports"
	@echo ""

install:
	npm install
	pip install -q -r requirements.txt

lint:
	npm run lint:openapi

mock:
	npm run mock:iot

test-mock:
	npm run test:mock

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run --rm --name $(CONTAINER_NAME) -p $(PORT):8000 --env-file .env.example $(IMAGE_NAME)

run-detached:
	docker run -d --rm --name $(CONTAINER_NAME) -p $(PORT):8000 --env-file .env.example $(IMAGE_NAME)
	@echo "✅ Container started in background ($(CONTAINER_NAME))"
	@echo "   Health check: make health"
	@echo "   View logs: docker logs $(CONTAINER_NAME)"
	@echo "   Stop: make stop"

health:
	curl http://localhost:$(PORT)/health

test-docker:
	npm run test:local

test-local:
	npm run test:local

stop:
	docker stop $(CONTAINER_NAME) || true
	@echo "✅ Container stopped"

clean-reports:
	rm -f reports/*.xml reports/*.html reports/*.json
	@echo "✅ Reports cleaned"

