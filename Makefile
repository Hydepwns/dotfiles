.PHONY: help install update diff status backup clean doctor bootstrap sync sync-from-remote backup-full install-optional performance-test generate-template tool-versions

# Configuration
DOTFILES_ROOT := $(shell pwd)
SCRIPTS_DIR := $(DOTFILES_ROOT)/scripts
BACKUP_DIR := $(DOTFILES_ROOT)/backups

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Core operations
install: ## Install dotfiles using chezmoi
	@echo "Installing dotfiles..."
	chezmoi init --apply https://github.com/hydepwns/dotfiles.git

update: ## Update dotfiles from remote repository
	@echo "Updating dotfiles..."
	chezmoi update
	chezmoi apply

diff: ## Show differences between current and target state
	@echo "Showing differences..."
	chezmoi diff

status: ## Show status of dotfiles
	@echo "Showing status..."
	chezmoi status

# Backup operations
backup: ## Create backup of current dotfiles
	@$(SCRIPTS_DIR)/utils/backup.sh data

backup-full: ## Create full backup with archive
	@$(SCRIPTS_DIR)/utils/backup.sh full

clean: ## Clean up temporary files and backups
	@$(SCRIPTS_DIR)/utils/clean.sh

# Health and maintenance
doctor: ## Run health check on dotfiles setup
	@$(SCRIPTS_DIR)/utils/health-check.sh

bootstrap: ## Run bootstrap script for fresh installation
	@$(SCRIPTS_DIR)/setup/bootstrap.sh

# Sync operations
sync: ## Sync local changes to repository
	@$(SCRIPTS_DIR)/utils/sync.sh local

sync-from-remote: ## Sync from remote repository
	@$(SCRIPTS_DIR)/utils/sync.sh remote

# Optional tools
install-optional: ## Install optional tools interactively
	@$(SCRIPTS_DIR)/utils/install-optional.sh

# Testing and development
test: ## Run dotfiles tests
	@$(SCRIPTS_DIR)/utils/simple-test.sh

test-full: ## Run comprehensive dotfiles tests
	@$(SCRIPTS_DIR)/utils/test-dotfiles.sh

debug-zsh: ## Debug zsh configuration issues
	@$(SCRIPTS_DIR)/utils/debug-zsh.sh

fix-zsh: ## Fix zsh configuration issues
	@$(SCRIPTS_DIR)/utils/fix-zsh-issue.sh

performance-test: ## Run performance tests
	@$(SCRIPTS_DIR)/utils/performance-test.sh

perf: ## Run performance test
	@$(SCRIPTS_DIR)/utils/performance-monitor.sh measure

perf-report: ## Generate performance report
	@$(SCRIPTS_DIR)/utils/performance-monitor.sh report

perf-history: ## Show performance history
	@$(SCRIPTS_DIR)/utils/performance-monitor.sh history

perf-realtime: ## Start real-time performance monitoring
	@$(SCRIPTS_DIR)/utils/performance-monitor.sh start-monitoring

perf-stop: ## Stop real-time performance monitoring
	@$(SCRIPTS_DIR)/utils/performance-monitor.sh stop-monitoring

lazy-load-config: ## Generate lazy loading config
	@$(SCRIPTS_DIR)/utils/lazy-load-tools.sh generate

lazy-load-stats: ## Show lazy loading stats
	@$(SCRIPTS_DIR)/utils/lazy-load-tools.sh stats

lazy-load-clean: ## Clean lazy loading data
	@$(SCRIPTS_DIR)/utils/lazy-load-tools.sh clean

# CI/CD setup
setup-ci: ## Setup CI/CD tools and pre-commit hooks
	@$(SCRIPTS_DIR)/setup/setup-ci.sh

# Template generation
generate-template: ## Generate project template
	@if [ -n "$(TEMPLATE)" ] && [ -n "$(NAME)" ]; then \
		$(SCRIPTS_DIR)/utils/template-manager.sh generate "$(TEMPLATE)" "$(NAME)" "$(OPTIONS)"; \
	else \
		$(SCRIPTS_DIR)/utils/template-manager.sh list; \
	fi

# Tool version management
tool-versions: ## Manage tool versions
	@if [ -n "$(COMMAND)" ]; then \
		$(SCRIPTS_DIR)/utils/update-tool-versions.sh "$(COMMAND)"; \
	else \
		$(SCRIPTS_DIR)/utils/update-tool-versions.sh --help; \
	fi
