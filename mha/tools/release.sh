#!/usr/bin/env bash
# This file is part of the HörTech Open Master Hearing Aid (openMHA)
# Copyright © 2018 2019 HörTech gGmbH
#
# openMHA is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# openMHA is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License, version 3 for more details.
#
# You should have received a copy of the GNU Affero General Public License, 
# version 3 along with openMHA.  If not, see <http://www.gnu.org/licenses/>.

#Prompt the user to answer yes or no, repeat question on any other answer, exit when answer is no.


function ask_yes_no ()
{
    local ANSWER=""
    read ANSWER
    while [[ "x$ANSWER" != "xyes" ]] && [[ "x$ANSWER" != "xno" ]]; do
        echo "Please answer yes or no"
        read ANSWER
    done
    if [[ $ANSWER = "no" ]]; then
       echo "Exiting..."
       exit 1;
    fi
}

#Prevent user from accidentally calling script as it should only be called by make
if [[ "x$1" != "xopenMHA" ]]; then
        echo "Error: This script should only be called by make"
        exit 1;
fi

#Ask for user input when branch name is suggests neither a release branch
#nor the development branch. Our workflow currently prescribes a squash merge
#from development or a release branch in preparation for a release. If the branch
#does not match either, we ask for a user override.
BRANCH=$(git branch | grep '*' | cut -d" " -f2);
if  [[ "$BRANCH" =~ "*release*" ]] && [[ "$BRANCH" =~ "development" ]]; then
    echo "Suspicious branch: $BRANCH is neither a development or release branch. Continue? [yes/no];"
    ask_yes_no;
fi

#$BRANCH will be squash merged into master
echo "Releasing from branch $BRANCH..."

echo "Have you tested the live pre-release tests as described in"
echo "https://dev.openmha.org/w/releaseprotocol/, 'Release procedure' step 3, and"
echo "sections 'test_mhaioalsa.m and other automated live tests' and 'Run gain_live"
echo "example, dynamic compressor live example, localizer live example'? [yes|no]"
ask_yes_no;

echo "Was everything as expected? (refer to"
echo "https://dev.openmha.org/w/releaseprotocol/ for expected behaviour) [yes/no]"
ask_yes_no;

#Prompt for new version number and change version number in manual and code to new version.
#Our normal version nomenclature is MAJOR.MINOR.PATCH, anything else requires a user override
printf "Enter new version number (e.g. 1.2.3): "
read VER
if ! [[ $VER =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Warning: Version does not follow usual convention: $VER. Continue? [yes/no]"
    ask_yes_no
fi

MAJOR_OLD=`grep "define MHA_VERSION_MAJOR" mha/libmha/src/mha.hh | sed -E 's/.*[^0-9]([0-9]+).*$/\1/g'`
MINOR_OLD=`grep "define MHA_VERSION_MINOR" mha/libmha/src/mha.hh | sed -E 's/.*[^0-9]([0-9]+).*$/\1/g'`
POINT_OLD=`grep "define MHA_VERSION_RELEASE" mha/libmha/src/mha.hh | sed -E 's/.*[^0-9]([0-9]+).*$/\1/g'`

MAJOR_NEW=`echo $VER | cut -d"." -f1`
MINOR_NEW=`echo $VER | cut -d"." -f2`
POINT_NEW=`echo $VER | cut -d"." -f3`

VERSIONS="$MAJOR_OLD.$MINOR_OLD.$POINT_OLD $MAJOR_NEW.$MINOR_NEW.$POINT_NEW"
SORTED_VERSIONS=$(echo $VERSIONS | xargs -n1 | sort -V | xargs)
if [[ "$VERSIONS" != "$SORTED_VERSIONS" ]]; then
    echo "Warning: New version number $MAJOR_NEW.$MINOR_NEW.$POINT_NEW is not an increase. Continue? [yes/no]"
    ask_yes_no
fi

if [[ $MAJOR_OLD = $MAJOR_NEW && $MINOR_OLD = $MINOR_NEW && $POINT_OLD = $POINT_NEW ]]; then
    echo "Warning: Old version number and new version number are equal! $VER. Continue? [yes/no]"
    ask_yes_no
fi

sed -i "s/$MAJOR_OLD\\.$MINOR_OLD\\.$POINT_OLD/$VER/g" README.md
sed -i "s/^#define MHA_VERSION_MAJOR $MAJOR_OLD$/#define MHA_VERSION_MAJOR $MAJOR_NEW/g" mha/libmha/src/mha.hh
sed -i "s/MHA_VERSION_MINOR $MINOR_OLD/MHA_VERSION_MINOR $MINOR_NEW/g" mha/libmha/src/mha.hh
sed -i "s/MHA_VERSION_RELEASE $POINT_OLD/MHA_VERSION_RELEASE $POINT_NEW/g" mha/libmha/src/mha.hh
sed -i "s/$MAJOR_OLD\\.$MINOR_OLD\\.$POINT_OLD/$VER/g" mha/doc/openMHAdoxygen.sty
sed -i -re "s/2[0-9]{3}-[0-9]{2}-[0-9]{2}/$(date +%Y-%m-%d)/g" README.md
sed -i "s/$MAJOR_OLD\\.$MINOR_OLD\\.$POINT_OLD/$VER/g" mha/tools/packaging/exe/mha.nsi
sed -i "s/$MAJOR_OLD\\.$MINOR_OLD\\.$POINT_OLD/$VER/g" mha/tools/packaging/pkg/Makefile
sed -i "s/$MAJOR_OLD\\.$MINOR_OLD\\.$POINT_OLD/$VER/g" mha/tools/packaging/ports/Portfile
#deb package version is extracted from mha.hh

git commit -a -m"Increase version number to $VER"
git clean -fdx . 2>/dev/null 1>/dev/null;
echo "Regenerating documentation..."
./configure 1>/dev/null && yes | make -j5 doc 1>/dev/null 2>/dev/null
printf "Documentation generated correctly? [yes/no]"
ask_yes_no;
git commit *.pdf -m "Regenerate Documentation for release $VER"
git checkout master && git pull && git merge --squash $BRANCH && git commit -m"Prepare Release $VER"
echo "All tests complete. Push new release to internal server [yes/no]?"
ask_yes_no
git push
git tag -a v$VER -m"Release $VER"
git checkout development
git merge master
echo "Push new release to Github? [yes/no]"
ask_yes_no;
git push git@github.com:HoerTech-gGmbH/openMHA.git master
git push git@github.com:HoerTech-gGmbH/openMHA.git v$VER
