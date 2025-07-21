#!/bin/zsh
# Development workflow functions



# Start a development session
dev_session() {
    local project="$1"
    cd "$project" || exit 1

    # Auto-load environment
    if [[ -f .envrc ]]; then
        direnv allow
    fi

    # Start development server based on project type
    if [[ -f package.json ]]; then
        npm run dev
    elif [[ -f Cargo.toml ]]; then
        cargo run
    elif [[ -f mix.exs ]]; then
        mix phx.server
    fi
}

# direnv helpers
direnv_setup() {
    local project_type="${1:-default}"

    case "$project_type" in
        "node"|"js"|"ts")
            cat > .envrc << EOF
export NODE_ENV=development
export PATH="\$PWD/node_modules/.bin:\$PATH"
export NPM_CONFIG_LOGLEVEL=warn
EOF
            ;;
        "python"|"py")
            cat > .envrc << EOF
export PYTHONPATH="\$PWD:\$PYTHONPATH"
export PIPENV_VENV_IN_PROJECT=1
export PYTHONUNBUFFERED=1
EOF
            ;;
        "rust")
            cat > .envrc << EOF
export RUST_BACKTRACE=1
export CARGO_INCREMENTAL=1
export RUST_LOG=info
EOF
            ;;
        "go")
            cat > .envrc << EOF
export GOPATH="\$PWD"
export PATH="\$PWD/bin:\$PATH"
export GO111MODULE=on
EOF
            ;;
        "web3")
            cat > .envrc << EOF
export FOUNDRY_PROFILE=default
export ANCHOR_PROVIDER_URL=http://127.0.0.1:8899
export ANCHOR_WALLET=~/.config/solana/id.json
EOF
            ;;
        *)
            cat > .envrc << EOF
# Auto-generated .envrc for $project_type
export PROJECT_ROOT="\$PWD"
export PATH="\$PWD/bin:\$PATH"
EOF
            ;;
    esac

    direnv allow
    echo "✅ Created .envrc for $project_type project"
}

# devenv helpers
devenv_setup() {
    local project_type="${1:-default}"

    case "$project_type" in
        "node"|"js"|"ts")
            cat > devenv.nix << EOF
{ pkgs, ... }:

{
  packages = [ pkgs.git ];

  enterShell = ''
    echo "Node.js development environment loaded"
    echo "Available commands: node, npm, yarn, pnpm"
  '';

  scripts.hello = "echo 'Hello from devenv!'";
}
EOF
            ;;
        "python"|"py")
            cat > devenv.nix << EOF
{ pkgs, ... }:

{
  packages = [ pkgs.git pkgs.python311 ];

  enterShell = ''
    echo "Python development environment loaded"
    echo "Available commands: python, pip, poetry"
  '';

  scripts.hello = "echo 'Hello from devenv!'";
}
EOF
            ;;
        "rust")
            cat > devenv.nix << EOF
{ pkgs, ... }:

{
  packages = [ pkgs.git pkgs.rustc pkgs.cargo ];

  enterShell = ''
    echo "Rust development environment loaded"
    echo "Available commands: rustc, cargo"
  '';

  scripts.hello = "echo 'Hello from devenv!'";
}
EOF
            ;;
        "go")
            cat > devenv.nix << EOF
{ pkgs, ... }:

{
  packages = [ pkgs.git pkgs.go ];

  enterShell = ''
    echo "Go development environment loaded"
    echo "Available commands: go"
  '';

  scripts.hello = "echo 'Hello from devenv!'";
}
EOF
            ;;
        *)
            cat > devenv.nix << EOF
{ pkgs, ... }:

{
  packages = [ pkgs.git ];

  enterShell = ''
    echo "Development environment loaded"
  '';

  scripts.hello = "echo 'Hello from devenv!'";
}
EOF
            ;;
    esac

    echo "✅ Created devenv.nix for $project_type project"
    echo "Run 'devenv up' to start the environment"
}

# Combined environment setup
setup_dev_env() {
    local project_type="$1"
    local use_direnv="${2:-true}"
    local use_devenv="${3:-false}"

    echo "Setting up development environment for $project_type..."

    if [[ "$use_direnv" == "true" ]]; then
        direnv_setup "$project_type"
    fi

    if [[ "$use_devenv" == "true" ]]; then
        devenv_setup "$project_type"
    fi

    echo "✅ Development environment setup complete!"
}

# Environment status checker
check_env_status() {
    echo "🔍 Checking environment status..."

    # Check direnv
    if command -v direnv &> /dev/null; then
        echo "✅ direnv: $(direnv --version)"
        if [[ -f .envrc ]]; then
            echo "📁 .envrc found: $(direnv status)"
        else
            echo "📁 No .envrc found"
        fi
    else
        echo "❌ direnv not installed"
    fi

    # Check devenv
    if command -v devenv &> /dev/null; then
        echo "✅ devenv: $(devenv --version)"
        if [[ -f devenv.nix ]]; then
            echo "📁 devenv.nix found"
            devenv status 2>/dev/null || echo "⚠️  devenv status unavailable"
        else
            echo "📁 No devenv.nix found"
        fi
    else
        echo "❌ devenv not installed"
    fi

    # Check Nix
    if command -v nix &> /dev/null; then
        echo "✅ Nix: $(nix --version)"
    else
        echo "❌ Nix not installed"
    fi
}

# Create a new directory and cd into it
mkcd() {
    local dir="$1"
    if [[ -z "$dir" ]]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    mkdir -p "$dir" && cd "$dir" || exit
}

# Create a new file and open it in editor
mkfile() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "Usage: mkfile <filename>"
        return 1
    fi
    touch "$file" && ${EDITOR:-vim} "$file"
}

# Extract various archive formats
extract() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "Usage: extract <archive>"
        return 1
    fi

    if [[ -f "$file" ]]; then
        case "$file" in
            *.tar.bz2)   tar xjf "$file"     ;;
            *.tar.gz)    tar xzf "$file"     ;;
            *.bz2)       bunzip2 "$file"     ;;
            *.rar)       unrar e "$file"     ;;
            *.gz)        gunzip "$file"      ;;
            *.tar)       tar xf "$file"      ;;
            *.tbz2)      tar xjf "$file"     ;;
            *.tgz)       tar xzf "$file"     ;;
            *.zip)       unzip "$file"       ;;
            *.Z)         uncompress "$file"  ;;
            *.7z)        7z x "$file"        ;;
            *)           echo "'$file' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$file' is not a valid file"
    fi
}

# Create a backup of a file
backup() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "Usage: backup <file>"
        return 1
    fi
    cp "$file" "$file.backup.$(date +%Y%m%d_%H%M%S)"
}

# Find files by name
ff() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Usage: ff <filename>"
        return 1
    fi
    find . -name "*$name*" -type f
}

# Find directories by name
fd() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Usage: fd <dirname>"
        return 1
    fi
    find . -name "*$name*" -type d
}

# Find files containing text
find_grep() {
    local text="$1"
    if [[ -z "$text" ]]; then
        echo "Usage: find_grep <text>"
        return 1
    fi
    find . -type f -exec grep -l "$text" {} \;
}

# Count lines of code in a directory
cloc() {
    local dir="${1:-.}"
    if command -v cloc &> /dev/null; then
        cloc "$dir"
    else
        echo "cloc not found. Install with: brew install cloc"
        return 1
    fi
}

# Create a new git repository
newrepo() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Usage: newrepo <name>"
        return 1
    fi
    mkcd "$name" && git init
}

# Create a new project with git
newproject() {
    local name="$1"
    local type="${2:-basic}"
    if [[ -z "$name" ]]; then
        echo "Usage: newproject <name> [type]"
        return 1
    fi

    mkcd "$name"
    git init

    case "$type" in
        "node"|"npm")
            npm init -y
            echo "node_modules/" > .gitignore
            echo ".env" >> .gitignore
            ;;
        "python")
            python3 -m venv venv
            echo "venv/" > .gitignore
            echo "__pycache__/" >> .gitignore
            echo "*.pyc" >> .gitignore
            ;;
        "rust")
            cargo init
            ;;
        "go")
            go mod init "$name"
            ;;
        *)
            echo "# $name" > README.md
            ;;
    esac

    git add .
    git commit -m "Initial commit"
}

# Quick directory navigation
go_up() {
    local levels="${1:-1}"
    local path=""
    for ((i=1; i<=levels; i++)); do
        path="../$path"
    done
    cd "$path" || exit
}

# Go to git root
git_root() {
    cd "$(git rev-parse --show-toplevel)" || exit
}

# Quick edit
quick_edit() {
    local file="$1"
    if [[ -z "$file" ]]; then
        ${EDITOR:-vim}
    else
        ${EDITOR:-vim} "$file"
    fi
}

# Quick view
quick_view() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "Usage: quick_view <file>"
        return 1
    fi
    ${PAGER:-less} "$file"
}

# Create a temporary directory and cd into it
tmp() {
    local name="$1"
    if [[ -n "$name" ]]; then
        cd "$(mktemp -d "/tmp/$name.XXXXXX")" || exit
    else
        cd "$(mktemp -d)" || exit
    fi
}

# Show disk usage for current directory
duh() {
    du -h -d 1 . | sort -hr
}

# Show largest files in current directory
largest() {
    local count="${1:-10}"
    find . -type f -exec ls -la {} \; | sort -k5 -nr | head -n "$count"
}

# Create a symlink
symlink() {
    local source="$1"
    local target="$2"
    if [[ -z "$source" ]] || [[ -z "$target" ]]; then
        echo "Usage: symlink <source> <target>"
        return 1
    fi
    ln -s "$source" "$target"
}

# Remove broken symlinks
rmbroken() {
    find . -type l -exec test ! -e {} \; -delete
}

# Show process tree
ptree() {
    local pid="${1:-$$}"
    pstree -p "$pid"
}

# Kill process by name
killname() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Usage: killname <process_name>"
        return 1
    fi
    pkill -f "$name"
}

# Show listening ports
ports_listen() {
    if command -v lsof &> /dev/null; then
        lsof -i -P -n | command grep LISTEN
    elif command -v netstat &> /dev/null; then
        netstat -tulpn | command grep LISTEN
    else
        echo "Neither lsof nor netstat found"
        return 1
    fi
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    if command -v python3 &> /dev/null; then
        python3 -m http.server "$port"
    elif command -v python &> /dev/null; then
        python -m SimpleHTTPServer "$port"
    else
        echo "Python not found"
        return 1
    fi
}

# Quick directory listing with details
list_long() {
    ls -la "$@"
}

# Quick directory listing with human readable sizes
lh() {
    ls -lah "$@"
}

# Quick directory listing sorted by time
lt() {
    ls -lat "$@"
}

# Quick directory listing sorted by size
list_size() {
    command ls -laS "$@"
}
