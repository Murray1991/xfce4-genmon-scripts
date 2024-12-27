#!/usr/bin/env bash

case "$1" in
  artist)
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|grep -E -A 2 "artist"|grep -E -v "artist"|grep -E -v "array"|cut -b 27-|cut -d '"' -f 1|grep -E -v ^$
  ;;
  title)
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|grep -E -A 1 "title"|grep -E -v "title"|cut -b 44-|cut -d '"' -f 1|grep -E -v ^$
  ;;
  album)
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|grep -E -A 1 "album"|grep -E -v "album"|cut -b 44-|cut -d '"' -f 1|grep -E -v ^$
  ;;
  art)
    TMP_PIC_DIR="/tmp"
    wget -q --output-document="${TMP_PIC_DIR}"/spotify-art.png $(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|grep -E -A 1 "artUrl"|cut -b 44-|cut -d '"' -f 1|grep -E -v ^$) 2> /dev/null
  ;;
esac