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

# Generate change log
github_changelog_generator --future-release $NEW_VERSION --exclude-labels 'Duplicate,Question,Can''t Reproduce,Won''t Fix,Hide from CHANGELOG,'

# Ask for the name of the next version
while [[ "$NEXT_VERSION" =~ ^$  ]]
do
	read -p 'Enter the next version: ' NEXT_VERSION
done

# Append -dev and update the VERSION file
echo -n $NEXT_VERSION > VERSION
echo '-dev' >> VERSION

# Replace the current version with the new version in the README
read -p "Update the version in the README? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
	sed -i "s/checkout $CURRENT_VERSION/checkout $NEW_VERSION/g" README.md
fi

# Commit the updated files
git add CHANGELOG.md VERSION README.md
git commit -m 'Updated CHANGELOG'
git push

# Switch to the release branch and merge master into it, overwriting any conflicts with the version in mast
git checkout release
git merge --no-edit -q -X theirs master

# Set the new version
echo $NEW_VERSION > VERSION

git add VERSION

# Remove the compiled assets
git rm --quiet -rf public/build/*
rm -rf public/build/

# Ensure all dependencies are installed
yarn install
composer install

# Build the CSS/JS
gulp --production

git add -f public/build/rev-manifest.json
git add -f public/build/css/*.css
git add -f public/build/js/*.js
git add -f public/build/fonts/*

# Commit the build and switch back to master
git commit -am 'Building new release'
git push

git checkout master
git branch -D release

# Build the assets as switching back would have removed them
gulp

#git stash pop "tmp-create-release"
