#!/bin/bash

# Set branches
DEV_BRANCH="dev"
PROD_BRANCH="prod"
EXCLUDE_DIR="scripts/"

# Ensure we're starting on DEV_BRANCH
git checkout $DEV_BRANCH

# Fetch the latest changes from PROD_BRANCH
git fetch origin $PROD_BRANCH

# Merge changes from PROD_BRANCH into DEV_BRANCH, but do not commit yet
git merge --no-commit --no-ff origin/$PROD_BRANCH

# Check if there are changes in the EXCLUDE_DIR
if git diff --cached --name-only | grep -q "$EXCLUDE_DIR"
then
    # Reset the EXCLUDE_DIR to the current state of DEV_BRANCH
    git reset HEAD $EXCLUDE_DIR
    git checkout -- $EXCLUDE_DIR
fi

# If there are conflicts, resolve them by checking out the version from PROD_BRANCH
if git ls-files -u | cut -f 2 | uniq
then
    git ls-files -u | cut -f 2 | uniq | grep -v "$EXCLUDE_DIR" | xargs -I{} git checkout --theirs {}
    git add -u
fi

# Commit the merge
git commit -m "Merged $PROD_BRANCH into $DEV_BRANCH with automatic conflict resolution"

echo "Merge completed successfully."
