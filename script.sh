#!/bin/bash

# Set branches
DEV_BRANCH="dev"
PROD_BRANCH="prod"
EXCLUDE_DIR="script/"

# Ensure we're starting on DEV_BRANCH
git checkout $DEV_BRANCH

# Fetch the latest changes from PROD_BRANCH
git fetch origin $PROD_BRANCH

# Merge changes from PROD_BRANCH into DEV_BRANCH, without committing
git merge --no-commit --no-ff origin/$PROD_BRANCH

# Check if there are changes in the EXCLUDE_DIR
if git diff --cached --name-only | grep -q "$EXCLUDE_DIR"
then
    # Reset the EXCLUDE_DIR to the current state of DEV_BRANCH
    git reset HEAD $EXCLUDE_DIR
    git checkout -- $EXCLUDE_DIR

    # Add a message indicating the directory has been excluded
    echo "Excluded changes to $EXCLUDE_DIR"
fi

# Commit the merge
git commit -m "Merged $PROD_BRANCH into $DEV_BRANCH excluding $EXCLUDE_DIR"

echo "Merge completed successfully."
