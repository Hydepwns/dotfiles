# Documentation

## Index

- **[Main README](../README.md)** - Quick start and overview
- **[Advanced Usage](advanced-usage.md)** - Configuration and customization
- **[Project Templates](templates.md)** - Template reference

## Quick Reference

```bash
# Install dotfiles
make install

# Generate project template
make generate-template web3 my-project --with-direnv

# Health check
make doctor

# Performance monitoring
make performance-monitor ACTION=measure
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
├── advanced-usage.md      # Advanced configuration
└── templates.md           # Project templates
```

## Resources

- [chezmoi Documentation](https://www.chezmoi.io/)
- [direnv Documentation](https://direnv.net/)
- [devenv Documentation](https://devenv.sh/)
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Kitty Terminal](https://sw.kovidgoyal.net/kitty/)
