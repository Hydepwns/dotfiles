# Project Templates

## Available Templates

| Template | Tech Stack | Special Options |
|----------|------------|-----------------|
| **web3** | Ethereum/Foundry, Solana/Anchor, TypeScript | `--web3-type ethereum\|solana\|both` |
| **nextjs** | Next.js, TypeScript, Tailwind CSS | `--with-auth` |
| **react** | React, TypeScript, Vite | `--with-router` |
| **rust** | Rust, Tokio, Serde, Axum | `--with-cli` |
| **elixir** | Elixir, Phoenix, LiveView, Ecto | `--with-api` |
| **node** | Node.js, TypeScript, Express | `--with-express` |
| **python** | Python, Poetry, Pytest | `--with-fastapi` |
| **go** | Go, Gin, Testify | `--with-gin` |

## Common Options

All templates support:

- `--with-tests` - Test framework setup
- `--with-docs` - Documentation tools
- `--with-ci` - GitHub Actions CI/CD
- `--with-direnv` - direnv environment
- `--with-devenv` - devenv environment

## Usage

```bash
# List templates
make generate-template

# Basic generation
make generate-template TEMPLATE=web3 NAME=my-project

# With options
make generate-template TEMPLATE=nextjs NAME=my-app OPTIONS="--with-tests --with-direnv"
```

## Examples

```bash
# Web3 with both chains
make generate-template web3 my-defi --web3-type both --with-tests --with-direnv

# Next.js with auth
make generate-template nextjs my-app --with-auth --with-tests --with-direnv

# Rust CLI tool
make generate-template rust my-cli --with-cli --with-devenv

# Python API
make generate-template python my-api --with-fastapi --with-tests
```

## Project Structure

```bash
my-project/
├── src/                    # Source code
├── tests/                  # Test files
├── docs/                   # Documentation
├── scripts/                # Build scripts
├── .envrc                  # direnv config (if enabled)
├── devenv.nix             # devenv config (if enabled)
├── README.md              # Project docs
├── .gitignore             # Git ignore
└── package.json/cargo.toml # Dependencies
```

## Validation

```bash
./scripts/utils/template-manager.sh validate web3
./scripts/utils/template-manager.sh help nextjs
```

## Resources

- [Template Manager](../scripts/utils/template-manager.sh)
- [Template Scripts](../scripts/templates/)
- [Environment Management](../docs/advanced-usage.md#environment-management)
