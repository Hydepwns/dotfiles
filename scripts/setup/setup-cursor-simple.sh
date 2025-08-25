#!/usr/bin/env bash

# Standard script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_INIT_PATH="$(cd "$SCRIPT_DIR" && find . .. ../.. -name "script-init.sh" -type f | head -1)"
source "$SCRIPT_DIR/${SCRIPT_INIT_PATH#./}"

# Source constants

# Simplified setup script for Cursor configuration
# This script installs Cursor settings, keybindings, snippets, and extensions


# Source shared utilities
if file_exists "$SCRIPT_DIR/../utils/colors.sh"; then
    # shellcheck disable=SC1091
else
    echo "Warning: colors.sh not found, using fallback colors"
    # Fallback color definitions

    print_status() {
        local status=$1
        local message=$2
        case $status in
            "OK") echo -e "${GREEN}[OK]${NC} $message" ;;
            "WARN") echo -e "${YELLOW}${NC} $message" ;;
            "ERROR") echo -e "${RED}[FAIL]${NC} $message" ;;
            "INFO") echo -e "${BLUE}${NC} $message" ;;
        esac
    }
fi

# Cursor configuration directories
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
CURSOR_SNIPPETS_DIR="$CURSOR_USER_DIR/snippets"

# Dotfiles configuration directory
DOTFILES_CONFIG_DIR="$(chezmoi source-path)/config/cursor"

echo " Setting up Cursor configuration (Simplified)"
echo "==============================================="

# Check if Cursor is installed
check_cursor_installation() {
    if [[ ! -d "$CURSOR_USER_DIR" ]]; then
        print_status "ERROR" "Cursor is not installed or not found at expected location"
        print_status "INFO" "Please install Cursor from https://cursor.sh"
        return 1
    fi

    print_status "OK" "Cursor installation found"
    return 0
}

# Create Cursor directories
create_cursor_directories() {
    print_status "INFO" "Creating Cursor directories..."

    mkdir -p "$CURSOR_USER_DIR"
    mkdir -p "$CURSOR_SNIPPETS_DIR"

    print_status "OK" "Cursor directories created"
}

# Install Cursor settings
install_cursor_settings() {
    print_status "INFO" "Installing Cursor settings..."

    local settings_source="$DOTFILES_CONFIG_DIR/settings.json.tmpl"
    local settings_target="$CURSOR_USER_DIR/settings.json"

    if file_exists "$settings_source"; then
        # For now, just copy the template content directly
        cat > "$settings_target" << 'EOF'
{
  // Language-specific formatters
  "[ansible]": {
    "editor.autoIndent": "advanced",
    "editor.detectIndentation": true,
    "editor.insertSpaces": true,
    "editor.quickSuggestions": {
      "comments": true,
      "other": true,
      "strings": true
    },
    "editor.tabSize": 2
  },
  "[css]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "SimonSiefke.prettier-vscode"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[mdx]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter"
  },
  "[solidity]": {
    "editor.defaultFormatter": "JuanBlanco.solidity"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[astro]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[erlang]": {
    "editor.defaultFormatter": "pgourlain.erlang"
  },

  // Application settings
  "application.shellEnvironmentResolutionTimeout": 30,
  "cursor.composer.shouldAllowCustomModes": true,
  "cursor.composer.collapsePaneInputBoxPills": true,
  "cursor.terminal.usePreviewBox": true,
  "cursor.cpp.disabledLanguages": [],
  "cursor.cpp.enablePartialAccepts": true,

  // Editor settings
  "editor.accessibilitySupport": "off",
  "editor.fontFamily": "'Monaspace Argon', monospace",
  "editor.fontLigatures": "'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08'",
  "editor.inlineSuggest.enabled": true,
  "editor.inlineSuggest.showToolbar": "onHover",
  "editor.largeFileOptimizations": false,
  "editor.renderWhitespace": "all",
  "editor.suggestSelection": "first",
  "editor.tabSize": 2,

  // File associations
  "files.associations": {
    "*.md": "markdown",
    "*.yml": "yaml"
  },
  "files.autoSave": "onFocusChange",

  // Git settings
  "git.confirmSync": false,
  "git.enableCommitSigning": true,
  "git.openRepositoryInParentFolders": "always",
  "git.path": "/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core",
  "git.replaceTagsWhenPull": true,

  // Language-specific settings
  "go.toolsManagement.autoUpdate": true,
  "makefile.configureOnOpen": true,
  "javascript.updateImportsOnFileMove.enabled": "always",

  // Solidity settings
  "solidity.compileUsingRemoteVersion": "v0.8.17",
  "solidity.formatter": "forge",
  "solidity.packageDefaultDependenciesContractsDirectory": "src",
  "solidity.packageDefaultDependenciesDirectory": "lib",

  // Security settings
  "security.promptForLocalFileProtocolHandling": false,
  "security.workspace.trust.banner": "never",
  "security.workspace.trust.untrustedFiles": "open",

  // Terminal settings
  "terminal.external.osxExec": "iTerm.app",
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.profiles.osx": {
    "zsh": {
      "args": [],
      "path": "/bin/zsh"
    }
  },
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.enableImages": true,
  "terminal.integrated.env.osx": {
    "Q_NEW_SESSION": "1"
  },
  "terminal.integrated.fontLigatures": true,
  "terminal.integrated.hideOnStartup": "whenEmpty",
  "terminal.integrated.localEchoStyle": "dim",
  "terminal.integrated.shellIntegration.enabled": true,

  // Workbench settings
  "workbench.colorTheme": "SynthWave '84",
  "workbench.editor.autoLockGroups": {
    "default": true,
    "terminalEditor": false
  },
  "workbench.iconTheme": "material-icon-theme",
  "workbench.sideBar.location": "right",
  "workbench.tips.enabled": false,

  // Window settings
  "window.confirmSaveUntitledWorkspace": false,
  "window.zoomLevel": 1,

  // Theme settings
  "synthwave84.brightness": 0.75,

  // Explorer settings
  "explorer.confirmDelete": false,
  "explorer.confirmDragAndDrop": false,

  // Update settings
  "update.releaseTrack": "prerelease",

  // Pre-commit settings
  "pre-commit-helper.runOnSave": "all hooks",

  // Telemetry
  "redhat.telemetry.enabled": true,

  // Kubernetes settings
  "vs-kubernetes": {
    "vscode-kubernetes.minikube-path-mac": "$HOME/.vs-kubernetes/tools/minikube/darwin-arm64/minikube"
  },

  // Kilo Code settings
  "kilo-code.allowedCommands": [
    "npm test",
    "npm install",
    "tsc",
    "git log",
    "git diff",
    "git show"
  ],

  // Diff editor settings
  "diffEditor.maxComputationTime": 0,

  // Todo highlight settings
  "todohighlight.defaultStyle": {
    "backgroundColor": "#ffeb3b",
    "color": "#000000",
    "fontWeight": "bold"
  },
  "todohighlight.keywords": [
    "BUG",
    "HACK",
    "FIXME",
    "TODO",
    "XXX",
    "TEMP",
    "placeholder"
  ],
  "todohighlight.isEnable": true,

  // Elixir settings
  "elixir.projectPath": "/axol_events"
}
EOF
        print_status "OK" "Cursor settings installed"
    else
        print_status "WARN" "Cursor settings template not found"
    fi
}

# Install Cursor keybindings
install_cursor_keybindings() {
    print_status "INFO" "Installing Cursor keybindings..."

    local keybindings_target="$CURSOR_USER_DIR/keybindings.json"

    cat > "$keybindings_target" << 'EOF'
// Place your key bindings in this file to override the defaults
[
  {
    "key": "cmd+i",
    "command": "composerMode.agent"
  },
  {
    "key": "shift+enter",
    "command": "workbench.action.terminal.sendSequence",
    "args": {
      "text": "\\\r\n"
    },
    "when": "terminalFocus"
  }
]
EOF
    print_status "OK" "Cursor keybindings installed"
}

# Install Cursor snippets
install_cursor_snippets() {
    print_status "INFO" "Installing Cursor snippets..."

    # JavaScript snippets
    cat > "$CURSOR_SNIPPETS_DIR/javascript.json" << 'EOF'
{
  "React Functional Component": {
    "prefix": "rfc",
    "body": [
      "import React from 'react';",
      "",
      "interface ${1:ComponentName}Props {",
      "  $2",
      "}",
      "",
      "export const ${1:ComponentName}: React.FC<${1:ComponentName}Props> = ({ $3 }) => {",
      "  return (",
      "    <div>",
      "      $0",
      "    </div>",
      "  );",
      "};",
      "",
      "export default ${1:ComponentName};"
    ],
    "description": "Create a React functional component with TypeScript"
  },
  "Async Function": {
    "prefix": "async",
    "body": [
      "const ${1:functionName} = async (${2:params}) => {",
      "  try {",
      "    $0",
      "  } catch (error) {",
      "    console.error('Error:', error);",
      "    throw error;",
      "  }",
      "};"
    ],
    "description": "Create an async function with error handling"
  },
  "Console Log": {
    "prefix": "clg",
    "body": [
      "console.log('${1:label}:', ${2:value});"
    ],
    "description": "Console log with label"
  }
}
EOF

    # Python snippets
    cat > "$CURSOR_SNIPPETS_DIR/python.json" << 'EOF'
{
  "Class": {
    "prefix": "class",
    "body": [
      "class ${1:ClassName}:",
      "    \"\"\"${2:Class description}\"\"\"",
      "    ",
      "    def __init__(self, ${3:params}):",
      "        \"\"\"Initialize ${1:ClassName}.\"\"\"",
      "        $0",
      "    ",
      "    def __str__(self):",
      "        return f\"${1:ClassName}(${4:})\"",
      "    ",
      "    def __repr__(self):",
      "        return self.__str__()"
    ],
    "description": "Create a Python class with __init__, __str__, and __repr__"
  },
  "Function": {
    "prefix": "def",
    "body": [
      "def ${1:function_name}(${2:params}):",
      "    \"\"\"${3:Function description}\"\"\"",
      "    $0",
      "    return ${4:None}"
    ],
    "description": "Create a Python function with docstring"
  }
}
EOF

    # Rust snippets
    cat > "$CURSOR_SNIPPETS_DIR/rust.json" << 'EOF'
{
  "Struct": {
    "prefix": "struct",
    "body": [
      "#[derive(Debug, Clone)]",
      "pub struct ${1:StructName} {",
      "    ${2:field}: ${3:String},",
      "    $0",
      "}",
      "",
      "impl ${1:StructName} {",
      "    pub fn new(${2:field}: ${3:String}) -> Self {",
      "        Self {",
      "            ${2:field},",
      "        }",
      "    }",
      "}"
    ],
    "description": "Create a Rust struct with implementation"
  },
  "Function": {
    "prefix": "fn",
    "body": [
      "pub fn ${1:function_name}(${2:params}) -> ${3:Result<(), Box<dyn std::error::Error>>} {",
      "    $0",
      "    Ok(())",
      "}"
    ],
    "description": "Create a Rust function with Result return type"
  }
}
EOF

    # Shell snippets
    cat > "$CURSOR_SNIPPETS_DIR/shell.json" << 'EOF'
{
  "Function": {
    "prefix": "func",
    "body": [
      "${1:function_name}() {",
      "    local ${2:var}=\"${3:value}\"",
      "    $0",
      "}"
    ],
    "description": "Create a shell function"
  },
  "If Statement": {
    "prefix": "if",
    "body": [
      "if [[ ${1:condition} ]]; then",
      "    $0",
      "fi"
    ],
    "description": "Create an if statement"
  }
}
EOF

    print_status "OK" "Cursor snippets installed"
}

# Install Cursor extensions
install_cursor_extensions() {
    print_status "INFO" "Installing Cursor extensions..."

    local extensions_target="$CURSOR_USER_DIR/extensions.json"

    cat > "$extensions_target" << 'EOF'
{
  "recommendations": [
    "robbowen.synthwave-vscode",
    "PKief.material-icon-theme",
    "ms-python.python",
    "rust-lang.rust-analyzer",
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "astro-build.astro-vscode",
    "JuanBlanco.solidity",
    "pgourlain.erlang",
    "esbenp.prettier-vscode",
    "ms-python.black-formatter",
    "ms-python.flake8",
    "ms-python.isort",
    "eamodio.gitlens",
    "mhutchie.git-graph",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-vscode.makefile-tools",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "wayou.vscode-todo-highlight",
    "streetsidesoftware.code-spell-checker",
    "ms-vscode.vscode-js-debug",
    "GitHub.copilot",
    "GitHub.copilot-chat",
    "ms-vscode.vscode-js-debug-companion",
    "cweijan.vscode-mysql-client2",
    "ms-mssql.mssql",
    "ms-azuretools.vscode-docker",
    "ms-vscode.test-adapter-converter",
    "hbenl.vscode-test-explorer",
    "yzhang.markdown-all-in-one",
    "DavidAnson.vscode-markdownlint",
    "ms-vscode.vscode-npm-script",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-json",
    "redhat.vscode-xml",
    "ms-vscode.vscode-js-profile-flame",
    "ms-vscode.vscode-js-profile-table",
    "ms-vscode.vscode-json",
    "kilo-code.kilo-code",
    "pre-commit-helper.pre-commit-helper"
  ],
  "unwantedRecommendations": [
    "ms-vscode.vscode-typescript",
    "ms-vscode.vscode-javascript"
  ]
}
EOF
    print_status "OK" "Cursor extensions configuration installed"
    print_status "INFO" "Please install recommended extensions from Cursor's extension marketplace"
}

# Backup existing Cursor configuration
backup_existing_config() {
    print_status "INFO" "Backing up existing Cursor configuration..."

    local backup_dir="$HOME/.local/share/chezmoi/backups/cursor"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    mkdir -p "$backup_dir"

    # Backup settings
    if file_exists "$CURSOR_USER_DIR/settings.json"; then
        cp "$CURSOR_USER_DIR/settings.json" "$backup_dir/settings_${timestamp}.json"
        print_status "OK" "Backed up settings.json"
    fi

    # Backup keybindings
    if file_exists "$CURSOR_USER_DIR/keybindings.json"; then
        cp "$CURSOR_USER_DIR/keybindings.json" "$backup_dir/keybindings_${timestamp}.json"
        print_status "OK" "Backed up keybindings.json"
    fi

    # Backup snippets
    if dir_exists "$CURSOR_SNIPPETS_DIR" && [[ "$(ls -A "$CURSOR_SNIPPETS_DIR")" ]]; then
        cp -r "$CURSOR_SNIPPETS_DIR" "$backup_dir/snippets_${timestamp}"
        print_status "OK" "Backed up snippets directory"
    fi
}

# Verify Cursor configuration
verify_cursor_config() {
    print_status "INFO" "Verifying Cursor configuration..."

    local issues=()

    # Check settings
    if [[ ! -f "$CURSOR_USER_DIR/settings.json" ]]; then
        issues+=("settings.json not found")
    fi

    # Check keybindings
    if [[ ! -f "$CURSOR_USER_DIR/keybindings.json" ]]; then
        issues+=("keybindings.json not found")
    fi

    # Check snippets directory
    if [[ ! -d "$CURSOR_SNIPPETS_DIR" ]]; then
        issues+=("snippets directory not found")
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        print_status "WARN" "Configuration issues found:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        return 1
    else
        print_status "OK" "Cursor configuration verified successfully"
        return 0
    fi
}

# Main execution
main() {
    if ! check_cursor_installation; then
        exit $EXIT_FAILURE
    fi

    backup_existing_config
    create_cursor_directories
    install_cursor_settings
    install_cursor_keybindings
    install_cursor_snippets
    install_cursor_extensions
    verify_cursor_config

    echo ""
    echo " Cursor configuration setup complete!"
    echo "========================================"
    echo "Next steps:"
    echo "1. Restart Cursor to apply the new configuration"
    echo "2. Install recommended extensions from the extensions marketplace"
    echo "3. Customize settings as needed"
    echo ""
    echo "Configuration files:"
    echo "  - Settings: $CURSOR_USER_DIR/settings.json"
    echo "  - Keybindings: $CURSOR_USER_DIR/keybindings.json"
    echo "  - Snippets: $CURSOR_SNIPPETS_DIR/"
    echo "  - Extensions: $CURSOR_USER_DIR/extensions.json"
}

# Run main function
main "$@"
