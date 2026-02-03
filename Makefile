.PHONY: help install update diff status backup clean doctor bootstrap sync sync-from-remote backup-full install-optional performance-test generate-template tool-versions setup-age age-retrieve age-status

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
test: ## Run comprehensive dotfiles test suite
	@echo "🧪 Running Dotfiles Test Suite..."
	@$(SCRIPTS_DIR)/utils/test-suite.sh
	@echo ""
	@echo "📋 Test Categories:"
	@echo "  • Core Infrastructure (chezmoi, git, config)"
	@echo "  • Shell Configuration (zsh, modules)"
	@echo "  • Tool Installation (Homebrew, Oh My Zsh, dev tools)"
	@echo "  • Configuration Validation (chezmoi verify, git status)"
	@echo "  • Integration Tests (zsh syntax)"
	@echo "  • Security Tests (sensitive files, SSH config)"

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

# Tailscale setup
setup-tailscale: ## Install and configure Tailscale
	@$(SCRIPTS_DIR)/setup/setup-tailscale.sh install

tailscale-status: ## Show Tailscale network status
	@$(SCRIPTS_DIR)/setup/setup-tailscale.sh status

# Secrets management setup
setup-secrets: ## Install 1Password, AWS CLI, Infisical, Tailscale
	@$(SCRIPTS_DIR)/setup/setup-secrets.sh all

secrets-status: ## Show secrets tools installation status
	@$(SCRIPTS_DIR)/setup/setup-secrets.sh status

# SSH key rotation
rotate-keys: ## Generate new SSH key, store in 1Password, sync to Tailscale hosts
	@$(SCRIPTS_DIR)/utils/secrets-rotation.sh rotate

sync-keys: ## Sync SSH public key to all Tailscale hosts
	@$(SCRIPTS_DIR)/utils/secrets-rotation.sh sync

keys-status: ## Show SSH key rotation status
	@$(SCRIPTS_DIR)/utils/secrets-rotation.sh status

# Age encryption
setup-age: ## Generate age key and back up to 1Password
	@$(SCRIPTS_DIR)/setup/setup-age.sh generate
	@$(SCRIPTS_DIR)/setup/setup-age.sh backup

age-retrieve: ## Retrieve age key from 1Password (new machine)
	@$(SCRIPTS_DIR)/setup/setup-age.sh retrieve

age-status: ## Show age encryption status
	@$(SCRIPTS_DIR)/setup/setup-age.sh status

# Dashboard
dashboard: ## Show comprehensive service status dashboard
	@$(SCRIPTS_DIR)/utils/dashboard.sh --all

dashboard-watch: ## Show dashboard with auto-refresh
	@$(SCRIPTS_DIR)/utils/dashboard.sh --watch

dashboard-secrets: ## Show secrets providers status only
	@$(SCRIPTS_DIR)/utils/dashboard.sh --secrets

# Theming
theme-generate: ## Generate all tool configs from unified theme
	@$(SCRIPTS_DIR)/utils/theme-generator.sh all

theme-list: ## List available theme generators
	@$(SCRIPTS_DIR)/utils/theme-generator.sh list

# Starship prompt
setup-starship: ## Install and configure Starship prompt
	@$(SCRIPTS_DIR)/setup/setup-starship.sh install

# Brewfile management
brew-install: ## Install packages from Brewfile
	@$(SCRIPTS_DIR)/setup/setup-brew.sh install

brew-dump: ## Update Brewfile from current system
	@$(SCRIPTS_DIR)/setup/setup-brew.sh dump

brew-check: ## Check for packages not in Brewfile
	@$(SCRIPTS_DIR)/setup/setup-brew.sh check

brew-cleanup: ## Remove packages not in Brewfile
	@$(SCRIPTS_DIR)/setup/setup-brew.sh cleanup

brew-update: ## Update Homebrew and all packages
	@$(SCRIPTS_DIR)/setup/setup-brew.sh update

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
