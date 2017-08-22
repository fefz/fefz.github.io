#!/bin/bash
cd ./public
git init
git config --global push.default matching
git config --global user.email "${GITHUB_MAIL}"
git config --global user.name "${GITHUB_USER}"
git add --all .
git commit -m "Auto Builder of ${GITHUB_USER}'s Blog"
git push --quiet --force https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO}.git master