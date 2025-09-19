#!/bin/sh
# Change committer email from OLD_EMAIL to CORRECT_EMAIL with CORRECT_NAME

git filter-branch --env-filter '
OLD_EMAIL="allisoon@allisonthackston.com"
CORRECT_NAME="Allison Thackston"
CORRECT_EMAIL="allison@allisonthackston.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
