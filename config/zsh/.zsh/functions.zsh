# Video compression
cv() {
    local input_file="$1"
    local output_file="${input_file%.*}_compressed.${input_file##*.}"
    ffmpeg -i "$input_file" -vcodec libx264 -crf 23 "$output_file"
}

# Git functions
gcae() {
    if [ $# -eq 0 ]; then
        echo "Usage: gcae <commit-id>"
        return 1
    fi

    commit_id=$1
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Check if there are staged changes
    if git diff --cached --quiet; then
        echo "No staged changes. Please stage your changes before using this command."
        return 1
    fi

    # Stash any unstaged changes
    git stash push --keep-index

    # Remember the current HEAD
    original_head=$(git rev-parse HEAD)

    # Create a temporary branch at the commit we want to amend
    git branch temp_amend_branch $commit_id

    # Checkout the temporary branch
    git checkout temp_amend_branch

    # Amend the commit
    git commit --amend --no-edit

    # Get the SHA of the amended commit
    amended_commit=$(git rev-parse HEAD)

    # Go back to the original branch
    git checkout $current_branch

    # Replace the old commit with the amended one using rebase
    git rebase --onto $amended_commit $commit_id $current_branch

    # Delete the temporary branch
    git branch -D temp_amend_branch

    # Pop the stashed changes if any
    git stash pop 2>/dev/null || true

    echo "Amended commit $commit_id with staged changes"
}

function ggpf() {
    local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null)
    
    if [ -z "$branch_name" ]; then
        echo "Error: Not currently on a branch"
        return 1
    fi
    
    echo "Pushing branch '$branch_name' to origin with --force-with-lease"
    git push origin "$branch_name" --force-with-lease
}

function cb() {
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    echo -n "$branch" | pbcopy
    echo "Current branch '$branch' copied to clipboard."
  else
    echo "Not in a git repository or no branch found."
  fi
}

function ggm() {
    local default_branch

    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not in a git repository."
        return 1
    fi

    # Check if 'master' branch exists
    if git show-ref --verify --quiet refs/heads/master; then
        default_branch="master"
    # Check if 'main' branch exists
    elif git show-ref --verify --quiet refs/heads/main; then
        default_branch="main"
    else
        echo "Error: Neither 'master' nor 'main' branch found."
        return 1
    fi

    # Pull from the default branch
    echo "Pulling from $default_branch..."
    git pull origin $default_branch

    # Check if pull was successful
    if [ $? -eq 0 ]; then
        echo "Successfully pulled from $default_branch."
    else
        echo "Error: Failed to pull from $default_branch."
        return 1
    fi
}

mr() {
    ggp
    # First determine if we should use master or main
    local base_branch=""
    if git rev-parse --verify origin/master &>/dev/null; then
        base_branch="master"
    elif git rev-parse --verify origin/main &>/dev/null; then
        base_branch="main"
    else
        echo "Error: Could not find master or main branch"
        return 1
    fi

    local template_path=".github/pull_request_template.md"

    local pr_template=""
    if [ -f "$template_path" ]; then
        pr_template="$(cat "$template_path" | sed 's/"/\\"/g')"
    fi

    local skip_reviewers=false
    if [[ "$1" == "nr" ]]; then
        skip_reviewers=true
        shift # Remove nr and shift remaining arguments
    fi

    # If branch specified, use it as base branch
    if [ -n "$1" ]; then
        base_branch="$1"
    fi

    # Fetch the latest changes
    git fetch origin "$base_branch" &>/dev/null

    if [ "$skip_reviewers" = true ]; then
        if [ -n "$pr_template" ]; then
            gh pr create -a @me -f -B "$base_branch" --body "$pr_template"
        else
            gh pr create -a @me -f -B "$base_branch"
        fi
    else
        if [ -n "$pr_template" ]; then
            gh pr create -a @me -f -r "iramons,lfarah" -B "$base_branch" --body "$pr_template"
        else
            gh pr create -a @me -f -r "iramons,lfarah" -B "$base_branch"
        fi
    fi
}

function copy_diff() {
  git diff "$@" | pbcopy
}

function copy_changes() {
    if [ $# -eq 0 ]; then
        echo "Usage: copy_changes <commit_id1> [commit_id2 ...]"
        return 1
    fi
    output=""
    for commit in "$@"; do
        output+="$(git show "$commit")\n\n"
    done
    echo -e "$output" | pbcopy
}

function copy_tree() {
    tree "$@" | pbcopy
    echo "Tree output copied to clipboard."
}

# macOS functions
function ph() {
    # Get current setting (returns "1" for true, "0" for false)
    current_setting=$(defaults read -g ApplePressAndHoldEnabled 2>/dev/null)
    
    # Handle case where setting doesn't exist yet
    if [ -z "$current_setting" ]; then
        current_setting=1  # Assume it's enabled by default
    fi
    
    # Toggle the setting
    if [ "$current_setting" -eq 1 ]; then
        defaults write -g ApplePressAndHoldEnabled -bool false
        echo "Global press-and-hold disabled"
    else
        defaults write -g ApplePressAndHoldEnabled -bool true
        echo "Global press-and-hold enabled"
    fi
    
    echo "Restart applications for this to have an effect"
}

function oc() { 
  local workspace=$(find . -maxdepth 1 -name "*.xcworkspace" | head -n 1)
  local project=$(find . -maxdepth 1 -name "*.xcodeproj" | head -n 1)
  local package=$(find . -maxdepth 1 -name "Package.swift" | head -n 1)
  
  if [[ -n "$workspace" ]]; then
    echo "Opening workspace: $workspace"
    open "$workspace"
  elif [[ -n "$project" ]]; then
    echo "Opening project: $project"
    open "$project"
  elif [[ -n "$package" ]]; then
    echo "Opening package: $package"
    open "$package"
  else
    echo "No Xcode project or workspace found in current directory"
  fi
}

function addalias() {
    if [ $# -ne 2 ]; then
        echo "Usage: addalias <aliasName> <aliasCommand>"
        return 1
    fi

    local nome_do_alias=$1
    local comando_do_alias=$2

    echo "alias $nome_do_alias='$comando_do_alias'" >> ~/.zsh/aliases.zsh

    source ~/.zsh/aliases.zsh

    echo "Alias '$nome_do_alias' sucessfully added!"
} 