# Makefile for Cue Docs (MkDocs)

.PHONY: help serve build deploy clean install new-page

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

serve: ## Start local development server (hot reload)
	mkdocs serve

build: ## Build the static site
	mkdocs build

deploy: ## Deploy to GitHub Pages
	mkdocs gh-deploy --force

clean: ## Clean built files
	rm -rf site/

install: ## Install required dependencies
	pip install mkdocs mkdocs-material

new-page: ## Create a new documentation page (usage: make new-page path= cue/new-feature.md)
	@if [ -z "$(path)" ]; then \
		echo "Usage: make new-page path=cue/new-feature.md"; \
		exit 1; \
	fi
	@mkdir -p docs/$(dir $(path))
	@touch docs/$(path)
	@echo "Created new page: docs/$(path)"

update: ## Update MkDocs and Material theme
	pip install --upgrade mkdocs mkdocs-material

# Aliases
dev: serve
up: serve
preview: serve
publish: deploy

.DEFAULT_GOAL := help