.PHONY: all clone build certs start stop logs health clean restart topic job subscribe

# ================== CONFIG ==================
REPO_CUE = git@github.com:m-javani/cue.git
REPO_PROXY = git@github.com:m-javani/cue-proxy.git
CUE_IMAGE = cue-demo
CUE_PROXY_IMAGE = cueproxy-demo
DOCKER_COMPOSE = docker compose
BUILD_DIR = ./build
PRODUCER_TOKEN ?= admin_2024
CONSUMER_TOKEN ?= admin_2024
# ===========================================

all: clone build certs start

clone:
	@echo "Cloning repositories..."
	@mkdir -p $(BUILD_DIR)
	@if [ ! -d "$(BUILD_DIR)/cue" ]; then \
		git clone $(REPO_CUE) $(BUILD_DIR)/cue; \
	else \
		echo "  cue already exists"; \
	fi
	@if [ ! -d "$(BUILD_DIR)/cueproxy" ]; then \
		git clone $(REPO_PROXY) $(BUILD_DIR)/cueproxy; \
	else \
		echo "  cueproxy already exists"; \
	fi
	@echo "✅ Repositories cloned"

build: clone
	@echo "Building binaries..."
	@cd $(BUILD_DIR)/cue && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -tags 'demo' -ldflags="-s -w" -o cue .
	@cd $(BUILD_DIR)/cueproxy && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -tags 'demo' -ldflags="-s -w" -o cueproxy ./cmd/proxy
	@cp $(BUILD_DIR)/cue/cue ./cue
	@cp $(BUILD_DIR)/cueproxy/cueproxy ./cueproxy
	@echo "✅ Binaries built"
	@echo "Building Docker images..."
	@docker build -f Dockerfile.cue.dev -t $(CUE_IMAGE):latest .
	@docker build -f Dockerfile.cueproxy.dev -t $(CUE_PROXY_IMAGE):latest .
	@echo "✅ Docker images built"

certs:
	@chmod +x scripts/generate-certs.sh
	@./scripts/generate-certs.sh

start: certs
	@$(DOCKER_COMPOSE) up -d
	@echo ""
	@echo "✅ All services started!"
	@echo ""
	@echo "API: http://localhost:8080"
	@echo "Health: curl http://localhost:8080/health"

stop:
	@$(DOCKER_COMPOSE) down

logs:
	@$(DOCKER_COMPOSE) logs -f

health:
	@echo "Checking services..."
	@curl -s http://localhost:8080/health || echo "⚠️  Proxy not responding"
	@docker exec node1 curl -s http://node1:8321/health > /dev/null && echo "✅ node1 healthy" || echo "❌ node1 not healthy"
	@docker exec node1 curl -s http://node2:8321/health > /dev/null && echo "✅ node2 healthy" || echo "❌ node2 not healthy"
	@docker exec node1 curl -s http://node3:8321/health > /dev/null && echo "✅ node3 healthy" || echo "❌ node3 not healthy"

# ================== API COMMANDS ==================

topic:
	@if [ -z "$(name)" ]; then \
		echo "Usage: make topic name=<topic>"; \
		exit 1; \
	fi
	@echo "Creating topic: $(name)"
	@RESPONSE=$$(curl -s -X POST http://localhost:8080/producer/topic \
		-H "Authorization: Bearer $(PRODUCER_TOKEN)" \
		-H "Content-Type: application/json" \
		-d "{\"topic\": \"$(name)\"}"); \
	echo $$RESPONSE | jq '.' 2>/dev/null || echo $$RESPONSE

job:
	@if [ -z "$(topic)" ] || [ -z "$(payload)" ]; then \
		echo "Usage: make job topic=<topic> payload='your message'"; \
		exit 1; \
	fi
	@JOB_ID="job-$$(date +%s)-$$$$"; \
	echo "Adding job to topic: $(topic) (ID: $$JOB_ID)"; \
	PAYLOAD_B64=$$(echo -n '$(payload)' | base64 | tr -d '\n'); \
	curl -s -X POST http://localhost:8080/producer/job \
		-H "Authorization: Bearer $(PRODUCER_TOKEN)" \
		-H "Content-Type: application/json" \
		-d '{"job":{"id":"'$$JOB_ID'","topic":"$(topic)","data":"'$$PAYLOAD_B64'"}}'

subscribe:
	@if [ -z "$(topic)" ]; then \
		echo "Usage: make subscribe topic=<topic> [uuid=<uuid>]"; \
		exit 1; \
	fi
	@UUID=$(or $(uuid),consumer-$(shell whoami)); \
	echo "Connecting to topic: $(topic) (UUID: $$UUID)"; \
	echo ""; \
	(echo '{"action":"init","uuid":"'$$UUID'","topic":"$(topic)"}'; cat) | \
	websocat "ws://localhost:8080/ws?token=$(CONSUMER_TOKEN)"

# ================== CLEANUP ==================

clean: stop
	@rm -rf $(BUILD_DIR) certs data cue cueproxy 2>/dev/null || true
	@docker rmi $(CUE_IMAGE):latest $(CUE_PROXY_IMAGE):latest 2>/dev/null || true
	@echo "✅ Cleanup complete"

restart: stop start

help:
	@echo "Cue Demo - Makefile Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make all      - Clone, build, generate certs, and start"
	@echo "  make clone    - Clone repositories"
	@echo "  make build    - Build binaries and Docker images"
	@echo "  make certs    - Generate TLS certificates"
	@echo ""
	@echo "Control:"
	@echo "  make start    - Start all services"
	@echo "  make stop     - Stop all services"
	@echo "  make restart  - Restart all services"
	@echo "  make logs     - View logs"
	@echo "  make health   - Check health of all services"
	@echo ""
	@echo "API:"
	@echo "  make topic name=<topic>              - Create a topic"
	@echo "  make job topic=<topic> payload='<json>' - Add a job"
	@echo "  make subscribe topic=<topic>         - Subscribe as consumer (WebSocket)"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean    - Remove everything"
	@echo ""
	@echo "Tokens (override with env vars):"
	@echo "  PRODUCER_TOKEN=$(PRODUCER_TOKEN)"
	@echo "  CONSUMER_TOKEN=$(CONSUMER_TOKEN)"

.DEFAULT_GOAL := help