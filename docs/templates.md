# Project Templates

## Available Templates

| Template | Description | Features |
|----------|-------------|----------|
| [web3](https://github.com/Hydepwns/dotfiles/tree/main/scripts/templates) | Full-stack blockchain | Foundry, Hardhat, Web3.js, Ethers.js |
| [nextjs](https://nextjs.org/) | Modern React apps | TypeScript, Tailwind, ESLint, Prettier |
| [rust](https://www.rust-lang.org/) | CLI tools & services | Cargo, Clippy, Testing, Documentation |
| [elixir](https://elixir-lang.org/) | Phoenix web apps | Mix, ExUnit, Dialyzer, Documentation |
| [node](https://nodejs.org/) | Node.js APIs | Express, Jest, ESLint, TypeScript |
| [python](https://www.python.org/) | Python applications | Poetry, Pytest, Black, MyPy |
| [go](https://golang.org/) | Go services | Modules, Testing, Linting, Documentation |

## Usage

```bash
# Quick examples
make generate-template web3 my-project --web3-type both --with-tests --with-ci
make generate-template nextjs my-app --with-tests --with-ci --with-docs
make generate-template rust my-cli --with-docs --with-ci

# List all templates
make generate-template
```

## Template Options

Each template supports various flags:

- `--with-tests`: Include testing setup
- `--with-ci`: Include CI/CD configuration
- `--with-docs`: Include documentation setup
- Template-specific options (e.g., `--web3-type` for web3 template)
