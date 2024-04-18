#!/bin/sh

CURRENT_TAG=$(git describe --tags --abbrev=0 --match 'v*')
LAST_TAG=$(git describe --tags --abbrev=0 --match 'v*' --contains $CURRENT_TAG | grep -v $CURRENT_TAG | tail -n 1)

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
    git fetch --deepen 1
    git log $LAST_TAG..$CURRENT_TAG --pretty=format:"%s" >> ../TestFlight/WhatToTest.en-US.txt
fi
