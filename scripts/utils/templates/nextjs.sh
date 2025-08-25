#!/usr/bin/env bash

# Use simple script initialization (no segfaults!)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../simple-init.sh"

# Next.js template generator for DROO's dotfiles

# Simple utilities (no dependencies)
log_info() { echo -e "${BLUE:-}[INFO]${NC:-} $1"; }
log_success() { echo -e "${GREEN:-}[SUCCESS]${NC:-} $1"; }
log_error() { echo -e "${RED:-}[ERROR]${NC:-} $1" >&2; }
log_warning() { echo -e "${YELLOW:-}[WARNING]${NC:-} $1"; }

# Exit codes
EXIT_SUCCESS=0
EXIT_INVALID_ARGS=1
EXIT_FAILURE=1

# Simple utility functions
file_exists() { test -f "$1"; }
dir_exists() { test -d "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Function to generate Next.js project
generate_nextjs_project() {
    local name="$1"
    local features="$2"

    echo "Creating Next.js project: $name"

    # Use create-next-app
    npx create-next-app@latest "$name" --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --yes

    cd "$name" || return 1

    # Add additional dependencies
    npm install @types/node @types/react @types/react-dom

    # Add testing if requested
    if [[ "$features" == *"jest"* ]]; then
        echo "Adding Jest testing setup..."
        generate_jest_setup
    fi

    # Add Storybook if requested
    if [[ "$features" == *"storybook"* ]]; then
        echo "Adding Storybook..."
        npx storybook@latest init --yes
    fi

    # Add Prettier if requested
    if [[ "$features" == *"prettier"* ]]; then
        echo "Adding Prettier configuration..."
        generate_prettier_setup
    fi
}

# Function to generate Jest setup
generate_jest_setup() {
    npm install --save-dev jest @testing-library/react @testing-library/jest-dom jest-environment-jsdom
    npm install --save-dev @types/jest

    # Create jest.config.js
    cat > jest.config.js << EOF
const nextJest = require('next/jest')

const createJestConfig = nextJest({
  // Provide the path to your Next.js app to load next.config.js and .env files
  dir: './',
})

// Add any custom config to be passed to Jest
const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
}

// createJestConfig is exported this way to ensure that next/jest can load the Next.js config which is async
module.exports = createJestConfig(customJestConfig)
EOF

    # Create jest.setup.js
    cat > jest.setup.js << EOF
import '@testing-library/jest-dom'
EOF

    # Update package.json scripts
    if [[ -f "package.json" ]]; then
        # Add test script if it doesn't exist
        if ! grep -q '"test":' package.json; then
            sed -i.bak 's/"scripts": {/"scripts": {\n    "test": "jest",/' package.json
            rm package.json.bak
        fi
    fi
}

# Function to generate Prettier setup
generate_prettier_setup() {
    npm install --save-dev prettier

    # Create .prettierrc
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

    # Create .prettierignore
    cat > .prettierignore << EOF
node_modules
.next
out
build
dist
*.log
EOF

    # Update package.json scripts
    if [[ -f "package.json" ]]; then
        # Add format script if it doesn't exist
        if ! grep -q '"format":' package.json; then
            sed -i.bak 's/"scripts": {/"scripts": {\n    "format": "prettier --write .",/' package.json
            rm package.json.bak
        fi
    fi
}
