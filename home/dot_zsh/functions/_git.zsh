#!/bin/zsh
# Git-related functions



# Quick git status
git_status_short() {
    git status --short
}

# Quick git add all and commit
git_add_commit() {
    local message="$1"
    if [[ -z "$message" ]]; then
        echo "Usage: git_add_commit <commit_message>"
        return 1
    fi
    git add -A && git commit -m "$message"
}

# Quick git add all, commit and push
gacp() {
    local message="$1"
    if [[ -z "$message" ]]; then
        echo "Usage: gacp <commit_message>"
        return 1
    fi
    git add -A && git commit -m "$message" && git push
}

# Git log with graph
glg() {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

# Git log oneline
glo() {
    git log --oneline --graph --decorate
}

# Git diff staged
gds() {
    git diff --staged
}

# Git diff cached (alias for staged)
gdc() {
    git diff --cached
}

# Git checkout branch
gcb() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        echo "Usage: gcb <branch_name>"
        return 1
    fi
    git checkout -b "$branch"
}

# Git checkout existing branch
gco() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        echo "Usage: gco <branch_name>"
        return 1
    fi
    git checkout "$branch"
}

# Git pull with rebase
gpr() {
    git pull --rebase
}

# Git push with upstream
gpu() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        branch=$(git branch --show-current)
    fi
    git push --set-upstream origin "$branch"
}

# Git reset to HEAD
grh() {
    git reset --hard HEAD
}

# Git reset soft to HEAD~1
grs() {
    git reset --soft HEAD~1
}

# Git stash with message
gsm() {
    local message="$1"
    if [[ -z "$message" ]]; then
        git stash
    else
        git stash push -m "$message"
    fi
}

# Git stash pop
gsp() {
    git stash pop
}

# Git stash list
gsl() {
    git stash list
}

# Git remote URL
gru() {
    git remote get-url origin
}

# Git branch with remote info
gbr() {
    git branch -vv
}

# Git clean untracked files
gclean() {
    git clean -fd
}

# Git fetch all
gfa() {
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
