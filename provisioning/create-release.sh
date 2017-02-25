#!/usr/bin/env bash

set -e

# Use the composer github token if it exists
if [ -z "$CHANGELOG_GITHUB_TOKEN" ]; then
	export CHANGELOG_GITHUB_TOKEN=`composer config --global github-oauth.github.com`
fi

# Check that a github token exists in CHANGELOG_GITHUB_TOKEN
while [[ "$CHANGELOG_GITHUB_TOKEN" =~ ^$  ]]
do
	read -p 'Github token not set: ' GITHUB_TOKEN
	export CHANGELOG_GITHUB_TOKEN=$GITHUB_TOKEN
done

#git stash save --include-untracked --all "tmp-create-release"

git checkout master

git pull

# Get the current latest release tag from github - FIXME: Actually test this returns a valid response otherwise exit
CURRENT_VERSION=`curl --silent https://api.github.com/repos/REBELinBLUE/deployer/releases/latest | php -r 'echo json_decode(file_get_contents("php://stdin"))->tag_name;'`

# Remove -dev from the version in the VERSION file
NEW_VERSION=`sed 's/-dev//' VERSION`

echo -n $NEW_VERSION > VERSION

# Generate change log
github_changelog_generator --future-release $NEW_VERSION --exclude-labels "Duplicate,Question,Can't Reproduce,Won't Fix,Hide from CHANGELOG,"

# Commit the updated files
git add CHANGELOG.md VERSION

# Remove the compiled assets
git rm --quiet -rf public/build/*
rm -rf public/build/

# Ensure all dependencies are installed
yarn install
composer install

# Build the CSS/JS
gulp --production

git add public/build/rev-manifest.json
git add public/build/css/*.css
git add public/build/js/*.js
git add public/build/fonts/*

# Commit the build and switch back to master
git commit -am 'Building new release'
git push

# Ask for the name of the next version
while [[ "$NEXT_VERSION" =~ ^$  ]]
do
	read -p 'Enter the next version: ' NEXT_VERSION
done

# Append -dev and update the VERSION file
echo -n $NEXT_VERSION > VERSION
echo '-dev' >> VERSION

git add VERSION
