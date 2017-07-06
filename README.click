Building for click
==================

To build for a click package configure cmake as:

mkdir build
cd build

# Under bazzar VCS :
cmake [path_to_this_location] -DINSTALL_TESTS=off -DCLICK_MODE=on \
    -DREVNO=$(cd [path_to_this_location]; bzr revno)

# Under git VCS :
cmake [path_to_this_location] -DINSTALL_TESTS=off -DCLICK_MODE=on \
    -DREVNO=$(cd [path_to_this_location]; git rev-list --count --first-parent HEAD)

make DESTDIR=package install
click build package

This package can be installed by running:

pkcon install-local com.ubuntu.camera_*.click
