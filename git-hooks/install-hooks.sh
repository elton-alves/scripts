#!/bin/sh

# Install all hooks in this scripts/git-hooks directory

MY_PATH="$(dirname $0)"
MY_NAME="$(basename $0)"

HOOKS=`ls $MY_PATH | grep -v $MY_NAME`
echo "Found hooks: $HOOKS"
for i in $HOOKS
do
  echo "Installing ${MY_PATH}/${i} on .git/hooks/"
  cp -f ${MY_PATH}/${i} .git/hooks/
done