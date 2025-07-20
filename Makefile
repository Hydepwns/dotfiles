.PHONY: help install update diff status backup clean doctor bootstrap sync sync-from-remote backup-full install-optional performance-test generate-template tool-versions

# Source helper functions
# Note: Helper functions are loaded dynamically in targets

# Default target
help:
	@if command -v print_make_help &> /dev/null; then \
		print_make_help; \
	else \
		echo "Available commands:"; \
		echo "  install           - Install dotfiles using chezmoi"; \
		echo "  update            - Update dotfiles from remote repository"; \
		echo "  diff              - Show differences between current and target state"; \
		echo "  status            - Show status of dotfiles"; \
		echo "  backup            - Create backup of current dotfiles"; \
		echo "  backup-full       - Create full backup with archive"; \
		echo "  clean             - Clean up temporary files and backups"; \
		echo "  doctor            - Run health check on dotfiles setup"; \
		echo "  bootstrap         - Run bootstrap script for fresh installation"; \
		echo "  sync              - Sync local changes to repository"; \
		echo "  sync-from-remote  - Sync from remote repository"; \
		echo "  install-optional  - Install optional tools interactively"; \
		echo "  performance-test  - Run performance tests"; \
		echo "  generate-template - Generate project template"; \
		echo "  tool-versions     - Manage tool versions"; \
	fi

# Install dotfiles
install:
	@echo "Installing dotfiles..."
	chezmoi init --apply https://github.com/hydepwns/dotfiles.git

# Update dotfiles
update:
	@echo "Updating dotfiles..."
	chezmoi update
	chezmoi apply

# Show differences
diff:
	@echo "Showing differences..."
	chezmoi diff

# Show status
status:
	@echo "Showing status..."
	chezmoi status

# Create backup
backup:
	@echo "Creating backup..."
	@if command -v create_backup &> /dev/null; then \
		create_backup data; \
	else \
		mkdir -p backups; \
		chezmoi data > backups/chezmoi-data-$$(date +%Y%m%d-%H%M%S).json; \
	fi

# Create full backup with archive
backup-full:
	@echo "Creating full backup..."
	@if command -v create_backup &> /dev/null; then \
		create_backup full; \
	else \
		mkdir -p backups; \
		chezmoi archive --output backups/dotfiles-$$(date +%Y%m%d-%H%M%S).tar.gz; \
		chezmoi data > backups/chezmoi-data-$$(date +%Y%m%d-%H%M%S).json; \
		echo "Backup created: backups/dotfiles-$$(date +%Y%m%d-%H%M%S).tar.gz"; \
	fi

# Clean up
clean:
	@echo "Cleaning up..."
	find . -name "*.bak" -delete
	find . -name "*.tmp" -delete
	find . -name "*.swp" -delete
	find . -name "*.swo" -delete
	@if command -v clean_old_backups &> /dev/null; then \
		clean_old_backups 30; \
	else \
		echo "Cleaning backups older than 30 days..."; \
		find backups -name "*.tar.gz" -mtime +30 -delete 2>/dev/null || true; \
		find backups -name "*.json" -mtime +30 -delete 2>/dev/null || true; \
	fi

# Health check
doctor:
	@echo "Running health check..."
	@if [ -f "scripts/utils/health-check.sh" ]; then \
		chmod +x scripts/utils/health-check.sh; \
		./scripts/utils/health-check.sh; \
	else \
		echo "Health check script not found"; \
	fi

# Bootstrap script
bootstrap:
	@echo "Running bootstrap script..."
	@if [ -f "scripts/setup/bootstrap.sh" ]; then \
		chmod +x scripts/setup/bootstrap.sh; \
		./scripts/setup/bootstrap.sh; \
	else \
		echo "Bootstrap script not found"; \
	fi

# Sync local changes to repository
sync:
	@echo "Syncing local changes to repository..."
	chezmoi diff
	@read -p "Apply changes? (y/n): " apply; \
	if [ "$$apply" = "y" ]; then \
		chezmoi add .; \
		chezmoi commit -m "Sync: $(shell date)"; \
		git push origin main; \
		echo "Changes synced successfully"; \
	else \
		echo "Sync cancelled"; \
	fi

# Sync from remote repository
sync-from-remote:
	@echo "Syncing from remote repository..."
	chezmoi update
	chezmoi apply
	@echo "Remote changes applied successfully"

# Install optional tools interactively
install-optional:
	@echo "Installing optional tools..."
	@if command -v install_optional_tool &> /dev/null; then \
		install_optional_tool "Neovim" "neovim"; \
		install_optional_tool "Elixir" "elixir"; \
		install_optional_tool "Lua" "lua"; \
		install_optional_tool "direnv" "direnv"; \
		install_optional_tool "asdf" "asdf"; \
	else \
		@read -p "Install Neovim? (y/n): " nvim; \
		if [ "$$nvim" = "y" ]; then \
			if command -v brew &> /dev/null; then \
				brew install neovim; \
			else \
				echo "Homebrew not found. Please install Neovim manually."; \
			fi; \
		fi; \
		@read -p "Install Elixir? (y/n): " elixir; \
		if [ "$$elixir" = "y" ]; then \
			if command -v brew &> /dev/null; then \
				brew install elixir; \
			else \
				echo "Homebrew not found. Please install Elixir manually."; \
			fi; \
		fi; \
		@read -p "Install Lua? (y/n): " lua; \
		if [ "$$lua" = "y" ]; then \
			if command -v brew &> /dev/null; then \
				brew install lua; \
			else \
				echo "Homebrew not found. Please install Lua manually."; \
			fi; \
		fi; \
		@read -p "Install direnv? (y/n): " direnv; \
		if [ "$$direnv" = "y" ]; then \
			if command -v brew &> /dev/null; then \
				brew install direnv; \
			else \
				echo "Homebrew not found. Please install direnv manually."; \
			fi; \
		fi; \
		@read -p "Install asdf? (y/n): " asdf; \
		if [ "$$asdf" = "y" ]; then \
			if command -v brew &> /dev/null; then \
				brew install asdf; \
			else \
				echo "Homebrew not found. Please install asdf manually."; \
			fi; \
		fi; \
	fi
	@echo "Optional tools installation complete!"

# Performance test
performance-test:
	@echo "Running performance tests..."
	@if [ -f "scripts/utils/performance-test.sh" ]; then \
		chmod +x scripts/utils/performance-test.sh; \
		./scripts/utils/performance-test.sh; \
	else \
		echo "Performance test script not found"; \
	fi

# Generate project template
generate-template:
	@if command -v show_template_help &> /dev/null; then \
		show_template_help; \
	else \
		echo "Template generator for DROO's dotfiles"; \
		echo "Usage: make generate-template TEMPLATE=<type> NAME=<project-name>"; \
		echo ""; \
		echo "Available templates:"; \
		echo "  web3    - Ethereum/Solana smart contract project"; \
		echo "  nextjs  - Next.js with TypeScript and Tailwind"; \
		echo "  rust    - Rust project with common dependencies"; \
		echo "  elixir  - Elixir Phoenix project"; \
		echo ""; \
		echo "Example: make generate-template TEMPLATE=web3 NAME=my-defi-project"; \
	fi
	@if [ -n "$(TEMPLATE)" ] && [ -n "$(NAME)" ]; then \
		if [ -f "scripts/templates/generate.sh" ]; then \
			chmod +x scripts/templates/generate.sh; \
			./scripts/templates/generate.sh "$(TEMPLATE)" "$(NAME)"; \
		else \
			echo "Template generator script not found"; \
		fi; \
	fi

# Tool version management
tool-versions:
	@if command -v show_tool_versions_help &> /dev/null; then \
		show_tool_versions_help; \
	else \
		echo "Tool version management for DROO's dotfiles"; \
		echo "Usage: make tool-versions COMMAND=<command>"; \
		echo ""; \
		echo "Available commands:"; \
		echo "  update   - Update .tool-versions with current installed versions"; \
		echo "  check    - Check for outdated tools"; \
		echo "  install  - Install missing tools using asdf"; \
		echo "  list     - List all tools and their versions"; \
		echo ""; \
		echo "Example: make tool-versions COMMAND=update"; \
	fi
	@if [ -n "$(COMMAND)" ]; then \
		if [ -f "scripts/utils/update-tool-versions.sh" ]; then \
			chmod +x scripts/utils/update-tool-versions.sh; \
			./scripts/utils/update-tool-versions.sh "$(COMMAND)"; \
		else \
			echo "Tool version management script not found"; \
		fi; \
	fi 