#!/bin/bash -xe

export NAME=gauntlet

SCRIPT=srpm.sh
RPM_REPO=https://github.com/wiiznokes/gauntlet-packaging.git

git clone $RPM_REPO packaging
cp packaging/rpms/$NAME/* .
cp packaging/scripts/$SCRIPT .

./$SCRIPT
