#!/usr/bin/env bash

# Standard script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_INIT_PATH="$(cd "$SCRIPT_DIR" && find . .. ../.. -name "script-init.sh" -type f | head -1)"
source "$SCRIPT_DIR/${SCRIPT_INIT_PATH#./}"

# Next.js template generator for DROO's dotfiles

# Source helpers for consistent logging
if [[ -f "$SCRIPT_DIR/../helpers.sh" ]]; then
    source "$SCRIPT_DIR/../helpers.sh"
fi

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
