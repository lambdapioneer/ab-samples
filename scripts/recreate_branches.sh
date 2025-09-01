#!/bin/bash

# List of projects to create branches for
PROJECTS=("clang" "kernel" "kernel_tiny" "kernel_llvm" "libsodium" "rust_small" "tinycc" "verifier_client" "xz_tar" "gprolog" "hello" "ipxe" "menu" "scheme48" "neovim")

# For the scalar projects, also add their variantes _j1 .. _j8 to PROJECTS
SCALAR_PROJECTS=("verifier_client" "xz_tar")
for project in "${SCALAR_PROJECTS[@]}"; do
    for job_count in {1..8}; do
        PROJECTS+=("${project}_j${job_count}")
    done
done

# Checkout main and pull latest changes
echo "Updating main branch..."
git checkout main
git pull origin main

# Remove local project branches
echo "Removing local project branches..."
git branch | grep 'project_' | xargs -r git branch -D

# Remove remote project branches
echo "Removing remote project branches..."
git branch -r | grep 'origin/project_' | sed 's/origin\///' | xargs -r git push origin --delete

# Create new branches for each project
for project in "${PROJECTS[@]}"; do
    branch_name="project_${project}"
    echo "Creating branch ${branch_name}..."
        
    # Create new branch from main
    git checkout -b "$branch_name" main
    
    # Remove all files except .github, scripts, and the project folder
    git rm -rf .
    git checkout main -- .github scripts "project_${project}" .gitmodules .gitignore

    # Commit changes
    git add .github scripts "project_${project}" .gitmodules .gitignore
    git commit -m "Initialize ${branch_name} with only .github, scripts, and project_${project}"
    
    # Push to origin
    git push -u origin "$branch_name"
done

# Return to main branch
git checkout main

echo "Branch recreation completed!"
