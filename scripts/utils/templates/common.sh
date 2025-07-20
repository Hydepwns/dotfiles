#!/bin/bash
# Common template utilities for DROO's dotfiles

# Source helpers for consistent logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../helpers.sh" ]]; then
    source "$SCRIPT_DIR/../helpers.sh"
fi

# Function to validate project name
validate_project_name() {
    local name="$1"

    # Check if name is empty
    if [[ -z "$name" ]]; then
        log_error "Project name cannot be empty"
        return 1
    fi

    # Check if name contains invalid characters
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Project name can only contain letters, numbers, hyphens, and underscores"
        return 1
    fi

    # Check if name starts with a number
    if [[ "$name" =~ ^[0-9] ]]; then
        log_error "Project name cannot start with a number"
        return 1
    fi

    return 0
}

# Function to check if project directory exists
check_project_exists() {
    local name="$1"

    if [[ -d "$name" ]]; then
        log_error "Project directory '$name' already exists"
        return 1
    fi

    return 0
}

# Function to create basic project structure
create_basic_structure() {
    local name="$1"

    # Create project directory
    mkdir -p "$name"
    cd "$name" || return 1

    # Initialize git
    git init

    # Create basic directories
    mkdir -p src tests docs

    log_info "Created basic project structure for $name"
}

# Function to generate common .gitignore
generate_common_gitignore() {
    cat > .gitignore << EOF
# Dependencies
node_modules/
target/
dist/
build/

# Environment
.env
.env.local
.env.production

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory
coverage/
.nyc_output

# Temporary files
*.tmp
*.temp
*.cache

# Backup files
*.bak
*.backup
*.old
*.orig
EOF
}

# Function to generate basic README
generate_basic_readme() {
    local name="$1"
    local description="$2"

    cat > README.md << EOF
# $name

$description

## Features

- Modern development setup
- Testing framework
- Code quality tools
- Documentation

## Setup

\`\`\`bash
# Install dependencies
# (Add specific installation commands)

# Build the project
# (Add specific build commands)

# Run tests
# (Add specific test commands)
\`\`\`

## Development

\`\`\`bash
# Start development server
# (Add specific dev commands)

# Run tests
# (Add specific test commands)

# Format code
# (Add specific format commands)

# Lint code
# (Add specific lint commands)
\`\`\`

## License

MIT
EOF
}

# Function to generate package.json for Node.js projects
generate_package_json() {
    local name="$1"
    local description="$2"
    local keywords="$3"

    cat > package.json << EOF
{
  "name": "$name",
  "version": "0.1.0",
  "description": "$description",
  "main": "index.js",
  "scripts": {
    "dev": "echo 'Start development server'",
    "build": "echo 'Build project'",
    "test": "echo 'Run tests'",
    "lint": "echo 'Run linter'",
    "format": "echo 'Format code'"
  },
  "keywords": [$keywords],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "prettier": "^3.0.0",
    "eslint": "^8.0.0"
  }
}
EOF
}

# Function to generate TypeScript configuration
generate_tsconfig() {
    cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF
}

# Function to generate ESLint configuration
generate_eslint_config() {
    cat > .eslintrc.js << EOF
module.exports = {
  env: {
    es2020: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint'],
  rules: {
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn',
  },
};
EOF
}

# Function to generate Prettier configuration
generate_prettier_config() {
    cat > .prettierrc << EOF
{
  "semi": false,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
EOF

    cat > .prettierignore << EOF
node_modules
dist
build
*.log
EOF
}

# Function to install common Node.js dependencies
install_common_node_deps() {
    local features="$1"

    # Install base dependencies
    npm install @types/node typescript

    # Install development dependencies
    npm install --save-dev eslint prettier

    # Install TypeScript ESLint if TypeScript is enabled
    if [[ "$features" == *"typescript"* ]]; then
        npm install --save-dev @typescript-eslint/parser @typescript-eslint/eslint-plugin
    fi

    # Install testing dependencies if testing is enabled
    if [[ "$features" == *"jest"* ]]; then
        npm install --save-dev jest @types/jest
    fi

    # Install Vite if Vite is enabled
    if [[ "$features" == *"vite"* ]]; then
        npm install --save-dev vite @vitejs/plugin-react
    fi
}

# Function to print success message
print_success() {
    local name="$1"

    echo ""
    echo "✅ Project '$name' created successfully!"
    echo ""
    echo "Next steps:"
    echo "  cd $name"
    echo "  git add ."
    echo "  git commit -m 'Initial commit'"
    echo ""
    echo "Happy coding! 🚀"
}

# Function to print error message
print_error() {
    local message="$1"
    log_error "$message"
    exit 1
}

# Function to print info message
print_info() {
    local message="$1"
    log_info "$message"
}

# Function to print warning message
print_warning() {
    local message="$1"
    log_warning "$message"
}
