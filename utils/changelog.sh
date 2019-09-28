#!/bin/bash

version=$( git describe --tags --always )
tag=$( git describe --tags --always --abbrev=0 )
topdir=

if [ "$version" = "$tag" ]; then # on a tag
  current="$tag"
  previous=$( git describe --tags --abbrev=0 HEAD~ )
else
  current=$( git log -1 --format="%H" )
  previous="$tag"
fi

# Set $topdir to top-level directory of the checkout.
if [ -z "$topdir" ]; then
	dir=$( pwd )
	if [ -d "$dir/.git" -o -d "$dir/.svn" -o -d "$dir/.hg" ]; then
		topdir=.
	else
		dir=${dir%/*}
		topdir=..
		while [ -n "$dir" ]; do
			if [ -d "$topdir/.git" -o -d "$topdir/.svn" -o -d "$topdir/.hg" ]; then
				break
			fi
			dir=${dir%/*}
			topdir="$topdir/.."
		done
		if [ ! -d "$topdir/.git" -a ! -d "$topdir/.svn" -a ! -d "$topdir/.hg" ]; then
			echo "No Git, SVN, or Hg checkout found." >&2
			exit 1
		fi
	fi
fi

date=$( git log -1 --date=short --format="%ad" )
url=$( git remote get-url origin | sed -e 's/^git@\(.*\):/https:\/\/\1\//' -e 's/\.git$//' )
#title='# '${url##*/}
title="# TourGuide - Classic"

echo -ne "# [${version}](${url}/tree/${current}) ($date)\n\n[Full Changelog](${url}/compare/${previous}...${current})\n\n" > "$topdir/CHANGELOG.md"
git shortlog --no-merges --reverse "$previous..$current" | sed -e  '/^\w/G' -e 's/^      /- /' >> "$topdir/CHANGELOG.md"
#git log --pretty=format:"###%s" "$previous..$current" | sed -e 's/^/    /g' -e 's/^ *$//g' -e 's/^    ###/- /g' -e 's/$/  /' >> "$topdir/CHANGELOG.md"
#echo >> "CHANGELOG.md"