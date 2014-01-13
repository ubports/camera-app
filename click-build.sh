#!/bin/sh

export LC_ALL=C

BZR_SOURCE=${1:-lp:camera-app}

CLICKARCH=armhf
rm -rf $CLICKARCH-build
mkdir $CLICKARCH-build
cd $CLICKARCH-build
cmake .. -DINSTALL_TESTS=off -DCLICK_MODE=on \
	-DBZR_REVNO=$(cd ..; bzr revno) \
	-DBZR_SOURCE="$BZR_SOURCE"
make DESTDIR=../package install
cd ..
click build package
