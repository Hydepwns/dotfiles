.PHONY: help install update diff status backup clean

# Default target
help:
	@echo "Available commands:"
	@echo "  install  - Install dotfiles using chezmoi"
	@echo "  update   - Update dotfiles from remote repository"
	@echo "  diff     - Show differences between current and target state"
	@echo "  status   - Show status of dotfiles"
	@echo "  backup   - Create backup of current dotfiles"
	@echo "  clean    - Clean up temporary files and backups"
	@echo "  doctor   - Run health check on dotfiles setup"

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
	mkdir -p backups
	chezmoi data > backups/chezmoi-data-$(shell date +%Y%m%d-%H%M%S).json

# Clean up
clean:
	@echo "Cleaning up..."
	find . -name "*.bak" -delete
	find . -name "*.tmp" -delete
	find . -name "*.swp" -delete
	find . -name "*.swo" -delete

# Health check
doctor:
	@echo "Running health check..."
	@echo "Checking chezmoi installation..."
	@which chezmoi || echo "chezmoi not found in PATH"
	@echo "Checking git configuration..."
	@git config --global --get user.name || echo "Git user.name not set"
	@git config --global --get user.email || echo "Git user.email not set"
	@echo "Checking shell configuration..."
	@echo "Current shell: $$SHELL"
	@echo "Zsh version: $$(zsh --version 2>/dev/null || echo 'Zsh not found')" 