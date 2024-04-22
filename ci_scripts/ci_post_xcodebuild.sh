#!/bin/zsh

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
  git fetch --deepen 1

  CURRENT_TAG=$(git describe --tags --abbrev=0 --match 'v*')
  LAST_TAG=$(git describe --tags --abbrev=0 --match 'v*' $(git rev-list --tags --max-count=1 --skip=1 --no-walk) 2>/dev/null)

  git log --pretty=format:"%s" $LAST_TAG..$CURRENT_TAG >> WhatToTest.en-US.txt
fi
