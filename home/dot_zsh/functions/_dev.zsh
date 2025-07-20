# Development-related functions

# Create a new directory and cd into it
mkcd() {
    local dir="$1"
    if [[ -z "$dir" ]]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    mkdir -p "$dir" && cd "$dir"
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
fgrep() {
    local text="$1"
    if [[ -z "$text" ]]; then
        echo "Usage: fgrep <text>"
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

# Quick directory navigation (renamed to avoid conflict with alias)
cd_up() {
    local levels="${1:-1}"
    local path=""
    for ((i=1; i<=levels; i++)); do
        path="../$path"
    done
    cd "$path"
}

# Go to git root
gr() {
    cd "$(git rev-parse --show-toplevel)"
}

# Quick edit
e() {
    local file="$1"
    if [[ -z "$file" ]]; then
        ${EDITOR:-vim}
    else
        ${EDITOR:-vim} "$file"
    fi
}

# Quick view
v() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "Usage: v <file>"
        return 1
    fi
    ${PAGER:-less} "$file"
}

# Create a temporary directory and cd into it
tmp() {
    local name="$1"
    if [[ -n "$name" ]]; then
        cd "$(mktemp -d "/tmp/$name.XXXXXX")"
    else
        cd "$(mktemp -d)"
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
ports() {
    if command -v lsof &> /dev/null; then
        lsof -i -P -n | grep LISTEN
    elif command -v netstat &> /dev/null; then
        netstat -tulpn | grep LISTEN
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
ll() {
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
ls() {
    ls -laS "$@"
} 