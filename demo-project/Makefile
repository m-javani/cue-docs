.PHONY: start stop restart logs health clean topic job subscribe help

# ================== CONFIG ==================
CUE_IMAGE = mehdyjavany/cue
CUE_PROXY_IMAGE = mehdyjavany/cue-proxy
TAG ?= latest
DOCKER_COMPOSE = docker compose
PRODUCER_TOKEN ?= admin_2024
CONSUMER_TOKEN ?= admin_2024
# ===========================================

# ================== MAIN COMMANDS ==================

start:
	@echo "🚀 Starting Cue Demo..."
	@echo "📥 Pulling latest images..."
	@docker pull $(CUE_IMAGE):$(TAG) > /dev/null 2>&1
	@docker pull $(CUE_PROXY_IMAGE):$(TAG) > /dev/null 2>&1
	@docker tag $(CUE_IMAGE):$(TAG) cue-demo:latest 2>/dev/null || true
	@docker tag $(CUE_PROXY_IMAGE):$(TAG) cueproxy-demo:latest 2>/dev/null || true
	@echo "🔐 Generating fresh certificates..."
	@rm -rf ./certs
	@chmod +x scripts/generate-certs.sh
	@./scripts/generate-certs.sh > /dev/null 2>&1
	@echo "🐳 Starting containers..."
	@$(DOCKER_COMPOSE) up -d
	@echo ""
	@echo "✅ Cue Demo is ready!"
	@echo ""
	@echo "  API: http://localhost:8080"
	@echo "  Health: make health"
	@echo "  Logs: make logs"
	@echo "  Stop: make stop"

stop:
	@echo "🛑 Stopping containers..."
	@$(DOCKER_COMPOSE) down
	@echo "✅ Cleanup complete"

restart: stop start

logs:
	@$(DOCKER_COMPOSE) logs -f

health:
	@echo "🔍 Checking services..."
	@if curl -s http://localhost:8080/health > /dev/null 2>&1; then \
		echo "✅ Proxy healthy"; \
		echo ""; \
		echo "📊 Cluster Status:"; \
		curl -s http://localhost:8080/health | jq '.' 2>/dev/null || curl -s http://localhost:8080/health; \
	else \
		echo "❌ Proxy not responding"; \
		exit 1; \
	fi

# ================== API COMMANDS ==================

topic:
	@if [ -z "$(name)" ]; then \
		echo "Usage: make topic name=<topic>"; \
		exit 1; \
	fi
	@echo "📝 Creating topic: $(name)"
	@curl -s -X POST http://localhost:8080/producer/topic \
		-H "Authorization: Bearer $(PRODUCER_TOKEN)" \
		-H "Content-Type: application/json" \
		-d "{\"topic\": \"$(name)\"}" | jq '.' 2>/dev/null || echo "❌ Failed to create topic"

job:
	@if [ -z "$(topic)" ] || [ -z "$(payload)" ]; then \
		echo "Usage: make job topic=<topic> payload='your message'"; \
		exit 1; \
	fi
	@JOB_ID="job-$$(date +%s)-$$$$"; \
	echo "📤 Adding job to topic: $(topic) (ID: $$JOB_ID)"; \
	PAYLOAD_B64=$$(echo -n '$(payload)' | base64 | tr -d '\n'); \
	curl -s -X POST http://localhost:8080/producer/job \
		-H "Authorization: Bearer $(PRODUCER_TOKEN)" \
		-H "Content-Type: application/json" \
		-d '{"job":{"id":"'$$JOB_ID'","topic":"$(topic)","data":"'$$PAYLOAD_B64'"}}' | jq '.' 2>/dev/null || echo "❌ Failed to add job"

subscribe:
	@if [ -z "$(topic)" ]; then \
		echo "Usage: make subscribe topic=<topic> [uuid=<uuid>]"; \
		exit 1; \
	fi
	@UUID=$(or $(uuid),consumer-$(shell whoami)); \
	echo "🔌 Connecting to topic: $(topic) (UUID: $$UUID)"; \
	echo ""; \
	echo "Type your messages (Ctrl+C to exit):"; \
	(echo '{"action":"init","uuid":"'$$UUID'","topic":"$(topic)"}'; cat) | \
	websocat ws://localhost:8080/ws?token=$(CONSUMER_TOKEN)

# ================== CLEANUP ==================

clean: stop
	@echo "🧹 Removing everything..."
	@rm -rf certs 2>/dev/null || true
	@echo "✅ Complete cleanup done"

# ================== HELP ==================

help:
	@echo "Cue Demo - Simple Commands"
	@echo ""
	@echo "  make start     - Pull images, generate certs, start everything"
	@echo "  make stop      - Stop everything and cleanup"
	@echo "  make restart   - Restart with fresh data"
	@echo "  make logs      - View all logs"
	@echo "  make health    - Check service health"
	@echo "  make clean     - Remove everything (containers, data, certs)"
	@echo ""
	@echo "API Commands:"
	@echo "  make topic name=<topic>              - Create a topic"
	@echo "  make job topic=<topic> payload='msg' - Add a job"
	@echo "  make subscribe topic=<topic>         - Subscribe to a topic"
	@echo ""
	@echo "Examples:"
	@echo "  make start"
	@echo "  make topic name=orders"
	@echo "  make job topic=orders payload='{\"item\":\"book\"}'"
	@echo "  make subscribe topic=orders"
	@echo "  make health"
	@echo "  make stop"

.DEFAULT_GOAL := help