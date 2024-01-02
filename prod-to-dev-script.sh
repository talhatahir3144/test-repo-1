#!/bin/bash

# Set branches
DEV_BRANCH="dev"
PROD_BRANCH="prod"
EXCLUDE_DIR="scripts"

# Ensure we're starting on DEV_BRANCH
git checkout $DEV_BRANCH

# Fetch the latest changes from PROD_BRANCH
git fetch origin $PROD_BRANCH

# Merge changes from PROD_BRANCH into DEV_BRANCH using 'ours' strategy
# This ensures the current branch state is preferred, effectively ignoring changes from PROD_BRANCH
git merge -s ours origin/$PROD_BRANCH --no-commit

# Manually reapply changes from PROD_BRANCH, excluding the EXCLUDE_DIR
git checkout origin/$PROD_BRANCH -- $(git diff --name-only $DEV_BRANCH origin/$PROD_BRANCH | grep -v "$EXCLUDE_DIR")

# If there are conflicts (excluding EXCLUDE_DIR), resolve them by taking the version from PROD_BRANCH
if git ls-files -u | cut -f 2 | uniq
then
    git ls-files -u | cut -f 2 | uniq | grep -v "$EXCLUDE_DIR" | xargs -I{} git checkout --theirs {}
    git add -u
fi

# Commit the merge
git commit -m "Merged $PROD_BRANCH into $DEV_BRANCH excluding $EXCLUDE_DIR"

# Clearing out merge conflicts and updating dev branch
git pull origin $DEV_BRANCH

echo "Merge completed successfully."
