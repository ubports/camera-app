#!/bin/sh

ARCH="x86_64-linux-gnu"
# FIXME: (ubuntu-app-platform) missing pulse path on LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SNAP/ubuntu-app-platform/usr/lib/$ARCH/pulseaudio

# FIXME: Tell GStreamer where to find its system plugins
export GST_PLUGIN_SYSTEM_PATH=$SNAP/ubuntu-app-platform/usr/lib/$ARCH/gstreamer-1.0

# FIXME: this is a workaround for XDG variables
# not being set adequately
# Ref.: https://bugs.launchpad.net/snappy/+bug/1577471
XDG_PICTURES_DIR=$(HOME=/home/$USER xdg-user-dir PICTURES)
XDG_VIDEOS_DIR=$(HOME=/home/$USER xdg-user-dir VIDEOS)
SNAP_PICTURES_DIR=$HOME/`basename $XDG_PICTURES_DIR`
SNAP_VIDEOS_DIR=$HOME/`basename $XDG_VIDEOS_DIR`

if [ ! -h $SNAP_PICTURES_DIR ]; then
    if [ -e $SNAP_PICTURES_DIR ]; then
        mv $SNAP_PICTURES_DIR $SNAP_PICTURES_DIR.old
    fi

    ln -s "$XDG_PICTURES_DIR" "$SNAP_PICTURES_DIR"
fi

if [ ! -h $SNAP_VIDEOS_DIR ]; then
    if [ -e $SNAP_VIDEOS_DIR ]; then
        mv $SNAP_VIDEOS_DIR $SNAP_VIDEOS_DIR.old
    fi

    ln -s "$XDG_VIDEOS_DIR" "$SNAP_VIDEOS_DIR"
fi

mkdir -p $HOME/.config/
ln -s /home/$USER/.config/user-dirs.dirs $HOME/.config/user-dirs.dirs

exec "$SNAP/usr/bin/camera-app" --desktop_file_hint=unity8 "$@"
