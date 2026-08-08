# Documentation

## Index

- **[Main README](../README.md)** - Quick start and overview
- **[Project Templates](templates.md)** - Template reference
- **[Performance](performance.md)** - Shell startup profiling
- **[Neovim Plugins](nvim-plugins.md)** - Plugin reference
- **[NixOS Installation](nixos-installation.md)** - NixOS setup

## Quick Reference

```bash
# Install dotfiles
make install

# Generate project template
make generate-template web3 my-project --with-direnv

# Health check
make doctor

# Performance monitoring
make perf
```

## Environment Shortcuts

```bash
# direnv
da                    # direnv allow
dr                    # direnv reload

# devenv
dv                    # devenv
dvs                   # devenv shell
```

## Structure

```bash
docs/
├── README.md              # This file
├── nixos-installation.md  # NixOS setup
├── nvim-plugins.md        # Neovim plugin reference
├── performance.md         # Shell startup profiling
└── templates.md           # Project templates
```

## Resources

- [chezmoi Documentation](https://www.chezmoi.io/)
- [direnv Documentation](https://direnv.net/)
- [devenv Documentation](https://devenv.sh/)
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Ghostty Terminal](https://ghostty.org/docs)
