#!/bin/bash

# Set branches
DEV_BRANCH="dev"
PROD_BRANCH="prod"
EXCLUDE_DIR="scripts|.github"

# Ensure we're starting on PROD_BRANCH
git checkout $PROD_BRANCH

# Fetch the latest changes from DEV_BRANCH
git fetch origin $DEV_BRANCH

git config --global user.email "talhatahir586@gmail.com"
git config --global user.name "Muhammad Talha Tahir"

# Merge changes from DEV_BRANCH into PROD_BRANCH using 'ours' strategy
# This ensures the current branch state is preferred, effectively ignoring changes from DEV_BRANCH
git merge -s ours origin/$DEV_BRANCH --no-commit

# Manually reapply changes from PROD_BRANCH, excluding the EXCLUDE_DIR
git checkout origin/$DEV_BRANCH -- $(git diff --name-only $PROD_BRANCH origin/$DEV_BRANCH | grep -Ev "$EXCLUDE_DIR")

# If there are conflicts (excluding EXCLUDE_DIR), resolve them by taking the version from PROD_BRANCH
if git ls-files -u | cut -f 2 | uniq
then
    git ls-files -u | cut -f 2 | uniq | grep -Ev "$EXCLUDE_DIR" | xargs -I{} git checkout --theirs {}
    git add -u
fi

# Commit the merge
git commit -m "Merged $DEV_BRANCH into $PROD_BRANCH excluding $EXCLUDE_DIR"

# Push data to $PROD_BRANCH
git push origin $PROD_BRANCH

# Clearing out merge conflicts and updating prod branch
git pull origin $PROD_BRANCH

echo "Merge completed successfully."
