#!/usr/bin/env bash
# Dependencies: bash>=3.2, coreutils, file, spotify, procps-ng, wmctrl, xdotool

# Utility functions for getting songs' infos
function spotify-dbus {
  dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'
}

function spotify-dbus-entry {
  spotify-dbus | grep -E -A 2 "$1" | grep -E -v "$1"
}

function spotify-artist {
  spotify-dbus-entry "artist" | grep -E -v "array" | cut -b 27- | cut -d '"' -f 1| grep -E -v ^$ | sed 's/&/&#38;/g'
}

function spotify-album {
  spotify-dbus-entry "album" | cut -b 44- | cut -d '"' -f 1| grep -E -v ^$ | sed 's/&/&#38;/g'
}

function spotify-title {
  spotify-dbus-entry "title" | cut -b 44- | cut -d '"' -f 1| grep -E -v ^$ | sed 's/&/&#38;/g'
}

function spotify-art {
  TMP_PIC_DIR="/tmp"
  wget -q --output-document="${TMP_PIC_DIR}"/spotify-art.png $(spotify-dbus | grep -E -A 1 "artUrl" | cut -b 44- | cut -d '"' -f 1| grep -E -v ^$) 2> /dev/null
}

# Makes the script more portable
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Optional icon to display before the text
# Insert the absolute path of the icon
# Recommended size is 24x24 px
readonly ICON="${DIR}/icons/music/spotify.png"

if pidof spotify &> /dev/null; then
  # Spotify song's info
  readonly ARTIST=$(spotify-artist)
  readonly TITLE=$(spotify-title)
  readonly ALBUM=$(spotify-album)
  readonly WINDOW_ID=$(wmctrl -l | grep -E "${ARTIST}|{$TITLE}" | awk '{print $1}')
  ARTIST_TITLE=$(echo "${ARTIST} - ${TITLE}")

  # Proper length handling
  readonly MAX_CHARS=52
  readonly STRING_LENGTH="${#ARTIST_TITLE}"
  readonly CHARS_TO_REMOVE=$(( STRING_LENGTH - MAX_CHARS ))
  [ "${#ARTIST_TITLE}" -gt "${MAX_CHARS}" ] \
    && ARTIST_TITLE="${ARTIST_TITLE:0:-CHARS_TO_REMOVE} …"

  # Panel
  if [[ $(file -b "${ICON}") =~ PNG|SVG ]]; then
    INFO="<img>${ICON}</img>"
    INFO+="<txt>"
    INFO+="${ARTIST_TITLE}"
    INFO+="</txt>"
  else
    INFO="<txt>"
    INFO+="${ARTIST_TITLE}"
    INFO+="</txt>"
  fi

  INFO+="<click>xdotool windowactivate ${WINDOW_ID}</click>"

  # Tooltip
  MORE_INFO="<tool>"
  MORE_INFO+="Artist ....: ${ARTIST}\n"
  MORE_INFO+="Album ..: ${ALBUM}\n"
  MORE_INFO+="Title ......: ${TITLE}"
  MORE_INFO+="</tool>"
else
  # Panel
  if [[ $(file -b "${ICON}") =~ PNG|SVG ]]; then
    INFO="<img>${ICON}</img>"
    INFO+="<txt>"
    INFO+="</txt>"
  else
    INFO="<txt>"
    INFO+="</txt>"
  fi

  # Tooltip
  MORE_INFO="<tool>"
  MORE_INFO+="Spotify is not running"
  MORE_INFO+="</tool>"
fi

# Panel Print
echo -e "${INFO}"

# Tooltip Print
echo -e "${MORE_INFO}"
