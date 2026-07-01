.PHONY: start stop logs health topic job consumer help

# ================== CONFIG ==================
CUE_IMAGE = mehdyjavany/cue
CUE_PROXY_IMAGE = mehdyjavany/cue-proxy
TAG ?= latest
DOCKER_COMPOSE = docker compose
PRODUCER_TOKEN ?= admin_2024
CONSUMER_TOKEN ?= admin_2024

# ================== MAIN COMMANDS ==================
start:
	@echo "🧹 Cleaning previous run..."
	@$(DOCKER_COMPOSE) down -v --remove-orphans 2>/dev/null || true
	@rm -rf ./certs 2>/dev/null || true
	
	@echo "🔐 Generating fresh certificates..."
	@chmod +x scripts/generate-certs.sh
	@./scripts/generate-certs.sh > /dev/null 2>&1
	
	@echo "🐳 Starting containers..."
	@$(DOCKER_COMPOSE) up -d
	
	@echo ""
	@echo "✅ Cue Demo is ready!"
	@echo ""
	@echo "   API    : http://localhost:8080"
	@echo "   Health : make health"
	@echo "   Logs   : make logs"
	@echo "   Stop   : make stop"
	@echo ""
	@echo "Quick test:"
	@echo "   make topic name=orders"
	@echo "   make consumer topic=orders"
	@echo "   make job topic=orders payload='{\"hello\": \"world\"}'"

stop:
	@echo "🛑 Stopping containers..."
	@$(DOCKER_COMPOSE) down -v --remove-orphans
	@echo "✅ Stopped"

logs:
	@$(DOCKER_COMPOSE) logs -f

health:
	@echo "🔍 Checking services..."
	@if curl -s http://localhost:8080/health > /dev/null 2>&1; then \
		echo "✅ Proxy healthy"; \
		echo ""; \
		curl -s http://localhost:8080/health | jq '.' 2>/dev/null || true; \
	else \
		echo "❌ Proxy not responding"; \
		exit 1; \
	fi

# ================== API COMMANDS ==================
topic:
	@chmod +x scripts/cli.py
	@python3 scripts/cli.py topic $(name)

job:
	@chmod +x scripts/cli.py
	@python3 scripts/cli.py job $(topic) '$(payload)'

consumer:
	@if [ -z "$(topic)" ]; then \
		echo "Usage: make consumer topic=<topic>"; \
		exit 1; \
	fi
	@chmod +x scripts/consumer.py
	@python3 scripts/consumer.py $(topic)

# ================== HELP ==================
help:
	@echo "Cue Demo"
	@echo ""
	@echo " make start              - Clean + Start fresh demo"
	@echo " make stop               - Stop everything"
	@echo " make logs               - View live logs"
	@echo " make health             - Check health"
	@echo ""
	@echo " make topic name=xxx        - Create topic"
	@echo " make job topic=xxx payload='{}' - Send job"
	@echo " make consumer topic=xxx    - Run consumer"
	@echo ""
	@echo "Example:"
	@echo "   make start"
	@echo "   make topic name=orders"
	@echo "   make consumer topic=orders"
	@echo "   make job topic=orders payload='{\"test\": 123}'"
.DEFAULT_GOAL := help