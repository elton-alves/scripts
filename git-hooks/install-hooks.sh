#!/bin/sh

# Install all hooks in this scripts/git-hooks directory

MY_PATH="$(dirname $BASH_SOURCE)"
MY_NAME="$(basename $BASH_SOURCE)"

HOOKS=`ls $MY_PATH | grep -v $MY_NAME`
echo "Found hooks: $HOOKS"
for i in $HOOKS
do
  echo "Installing ${MY_PATH}/${i} on .git/hooks/"
  cp -f ${MY_PATH}/${i} .git/hooks/
done
