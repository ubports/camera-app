#!/bin/sh

export LC_ALL=C

SOURCE=${1:-lp:camera-app}

CLICKARCH=armhf
rm -rf $CLICKARCH-build
mkdir $CLICKARCH-build
cd $CLICKARCH-build
cmake .. -DINSTALL_TESTS=off -DCLICK_MODE=on \
	-DREVNO=$(cd ..; bzr revno) \
	-DSOURCE="$SOURCE"
make DESTDIR=../package install
cd ..
click build package
