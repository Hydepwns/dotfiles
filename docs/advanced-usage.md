# Advanced Usage

## Configuration

### Setup Options

- **Email & username** - Git configuration
- **Tool preferences** - Nix, Oh My Zsh, asdf, etc.
- **Machine type** - Personal (includes SSH keys) or work

### SSH Setup

```bash
export GITHUB_TOKEN="your_token_here"
chezmoi apply
```

## Commands

| Category | Commands |
|----------|---------|
| **Core** | `install`, `update`, `diff`, `status` |
| **Health** | `doctor`, `bootstrap` |
| **Sync** | `sync`, `sync-from-remote` |
| **Environment** | `da`, `dr`, `de`, `ds`, `dv`, `dvi`, `dvb`, `dvr`, `dvs`, `dvc` |
| **Optional** | `install-optional`, `performance-monitor`, `lazy-loading-benchmark` |

## Setup Scripts

| Script | Purpose |
|--------|---------|
| `quick-setup.sh` | One-command setup |
| `bootstrap.sh` | Complete setup with dependencies |
| `setup-cursor.sh` | Cursor IDE configuration |
| `setup-ci.sh` | CI/CD tools setup |

## Environment Management

```bash
# Environment setup
setup_dev_env node    # Setup direnv for Node.js
setup_dev_env rust    # Setup direnv for Rust
devenv_setup python   # Setup devenv for Python
check_env_status      # Check environment status
env-status            # Quick environment status check

# Optional tools
make install-optional
./scripts/setup/setup-cursor-simple.sh
```

## Development Workflow

```bash
# Performance testing
make performance-test
make performance-monitor ACTION=measure
make lazy-loading-benchmark ACTION=run

# Health monitoring
make doctor
./scripts/utils/test-modular-system.sh

# Backup and sync
make backup
make sync
```

## Customization

```bash
# Edit configuration
chezmoi edit ~/.zshrc
chezmoi verify

# Template generation
make generate-template web3 my-project --web3-type both --with-tests --with-ci
make tool-versions COMMAND=update
```

## Troubleshooting

### Common Issues

1. **Template errors** - Check chezmoi syntax: `{{-` and `-}}`
2. **Path issues** - Verify Homebrew prefix for your architecture
3. **Tool not found** - Install tool before applying configuration
4. **Performance issues** - Run `make performance-monitor ACTION=measure`
5. **Cursor setup** - Use `./scripts/setup/setup-cursor-simple.sh`

### Debug Commands

```bash
make doctor
make performance-monitor ACTION=measure
make lazy-loading-benchmark ACTION=run
./scripts/utils/check-conflicts.sh
chezmoi verify
```

## Performance Metrics

- **Shell Startup**: 0.01s (~98% improvement)
- **Tool Loading**: Lazy-loaded version managers
- **Memory Usage**: Optimized PATH management
- **Development Speed**: Pre-configured templates

## Customization Guide

### Adding Templates

1. Create template script in `scripts/templates/`
2. Add to registry in `scripts/utils/template-manager.sh`
3. Update documentation

### Extending Environment Support

1. Add environment setup to `home/dot_zsh/functions/_dev.zsh`
2. Update common utilities in `scripts/utils/templates/common.sh`
3. Test with `make doctor`

### Performance Optimization

1. Monitor startup times: `make performance-monitor`
2. Profile lazy loading: `make lazy-loading-benchmark`
3. Optimize PATH management in `home/dot_zsh/core/paths.zsh`

## Resources

- [chezmoi Documentation](https://www.chezmoi.io/)
- [direnv Documentation](https://direnv.net/)
- [devenv Documentation](https://devenv.sh/)
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Kitty Terminal](https://sw.kovidgoyal.net/kitty/)
