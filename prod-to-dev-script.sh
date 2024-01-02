#!/bin/bash

# Set branches
DEV_BRANCH="dev"
PROD_BRANCH="prod"
EXCLUDE_DIR="scripts|.github"

# Ensure we're starting on DEV_BRANCH
git checkout $DEV_BRANCH

# Fetch the latest changes from PROD_BRANCH
git fetch origin $PROD_BRANCH

# Set global Git configuration
git config --global user.email "talhatahir586@gmail.com"
git config --global user.name "Muhammad Talha Tahir"

# Merge changes from PROD_BRANCH into DEV_BRANCH using 'ours' strategy. This ensures the current branch state is preferred, effectively ignoring changes from PROD_BRANCH
# Added --allow-unrelated-histories to handle branches with unrelated histories
git merge -s ours origin/$DEV_BRANCH --allow-unrelated-histories --no-commit

# Manually reapply changes from PROD_BRANCH, excluding the EXCLUDE_DIR
git checkout origin/$PROD_BRANCH -- $(git diff --name-only $DEV_BRANCH origin/$PROD_BRANCH | grep -Ev "$EXCLUDE_DIR")

# If there are conflicts (excluding EXCLUDE_DIR), resolve them by taking the version from PROD_BRANCH
if git ls-files -u | cut -f 2 | uniq
then
    git ls-files -u | cut -f 2 | uniq | grep -Ev "$EXCLUDE_DIR" | xargs -I{} git checkout --theirs {}
    git add -u
fi

# Commit the merge
git commit -m "Merged $PROD_BRANCH into $DEV_BRANCH excluding $EXCLUDE_DIR"

# Clearing out merge conflicts and updating dev branch
git pull origin $DEV_BRANCH --allow-unrelated-histories

echo "Merge completed successfully."
