#!/usr/bin/env bash
set -e # halt script on error

#!/bin/bash
DATE=`date +%Y-%m-%d:%H:%M:%S`

# config git for commits
git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

rm -rf ./_site

git_url="https://${CI_USER_TOKEN}@github.com/Starbound-Fr/Starbound-Fr.github.io"
git clone -b master ${git_url} ./_site

rm -rf ./_site/*

bundle exec jekyll build -t

git add .
git commit -m "Travis-CI - Site Updated - ${DATE}"

git_push_res=$(git push origin master 2>&1)
git_return_code=$?

echo "${git_push_res}" | sed -r "s/${CI_USER_TOKEN}/\[masked\]/g"

exit ${git_return_code}