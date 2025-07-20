# Git-related functions

# Quick git status
gitst() {
    git status --short
}

# Quick git add all and commit
gitac() {
    local message="$1"
    if [[ -z "$message" ]]; then
        echo "Usage: gitac <commit_message>"
        return 1
    fi
    git add -A && git commit -m "$message"
}

# Quick git add all, commit and push
gitacp() {
    local message="$1"
    if [[ -z "$message" ]]; then
        echo "Usage: gitacp <commit_message>"
        return 1
    fi
    git add -A && git commit -m "$message" && git push
}

# Git log with graph
gitlog() {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

# Git log oneline
gitlo() {
    git log --oneline --graph --decorate
}

# Git diff staged
gitds() {
    git diff --staged
}

# Git diff cached (alias for staged)
gitdc() {
    git diff --cached
}

# Git checkout branch
gitcb() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        echo "Usage: gitcb <branch_name>"
        return 1
    fi
    git checkout -b "$branch"
}

# Git checkout existing branch
gitco() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        echo "Usage: gitco <branch_name>"
        return 1
    fi
    git checkout "$branch"
}

# Git pull with rebase
gitpr() {
    git pull --rebase
}

# Git push with upstream
gitpu() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        branch=$(git branch --show-current)
    fi
    git push --set-upstream origin "$branch"
}

# Git reset to HEAD
gitrh() {
    git reset --hard HEAD
}

# Git reset soft to HEAD~1
gitrs() {
    git reset --soft HEAD~1
}

# Git stash with message
gitsm() {
    local message="$1"
    if [[ -z "$message" ]]; then
        git stash
    else
        git stash push -m "$message"
    fi
}

# Git stash pop
gitsp() {
    git stash pop
}

# Git stash list
gitsl() {
    git stash list
}

# Git remote URL
gitru() {
    git remote get-url origin
}

# Git branch with remote info
gitbr() {
    git branch -vv
}

# Git clean untracked files
gitclean() {
    git clean -fd
}

# Git fetch all
gitfa() {
    git fetch --all
}

# Git merge base
gmb() {
    local branch1="$1"
    local branch2="$2"
    if [[ -z "$branch1" ]] || [[ -z "$branch2" ]]; then
        echo "Usage: gmb <branch1> <branch2>"
        return 1
    fi
    git merge-base "$branch1" "$branch2"
}

# Git show files changed in last commit
gslf() {
    git show --name-only --pretty=format:""
}

# Git show files changed between commits
gdiff() {
    local commit1="$1"
    local commit2="$2"
    if [[ -z "$commit1" ]] || [[ -z "$commit2" ]]; then
        echo "Usage: gdiff <commit1> <commit2>"
        return 1
    fi
    git diff --name-only "$commit1" "$commit2"
} 