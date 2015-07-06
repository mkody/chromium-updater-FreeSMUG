#!/bin/bash
# This script will try to upgrade to latest FreeSMUG OSX Chromium build on your system via the
# command line (right, that means you'll have to open a term and run it from there)
#
# See README for further informations

die() {
  printf "\n❌  $@ => exiting\n" >&2
  exit 1
}

W="$(whoami)"
TMP="${TMPDIR-/tmp}"
PROC="$(ps aux | grep -i 'Chromium' | grep -iv 'grep' | grep -iv "$0" | wc -l | awk '{print $1}')" || die 'Unable to count running Chromium processes'
DOWNLOAD_URL="$(curl 'http://sourceforge.net/projects/osxportableapps/rss?path=/Chromium' 2> /dev/null | grep 'guid' | head -1 | sed -e 's/      <guid>\(.*\)<\/guid>/\1/')" || die 'Unable to fetch download URL'
INSTALL_DIR='/Applications'
MOUNTPOINT='/Volumes/Chromium'

# The script should never be run by root
if [ "$W" = 'root' ]; then
  die 'This script cannot be run as root'
fi

# Testing if Chromium is currently running
if [ "$PROC" -ne 0 ]; then
  die 'You must quit Chromium in order to install a new version'
fi

# Fetching latest archive if not already existing in tmp dir
if [ ! -f "${TMP}/chromium.dmg" ]; then
  printf "\n🔎  Fetching chromium build from FreeSMUG, please wait...\n"
  curl -L -o "${TMP}/chromium.dmg" "$DOWNLOAD_URL" || die "Unable to fetch archive"
fi

# Deleting previously installed version
if [ -d "${INSTALL_DIR}/Chromium.app" ]; then
  printf "\n♻️  Delting previous installed version of Chromium, please wait...\n"
  rm -rf "${INSTALL_DIR}/Chromium.app" || die 'Unable to delete previous installed version of Chromium'
fi

# Mount and copy Chromium.app
# http://stackoverflow.com/a/7301584
printf "\n🚸  Mounting, checking and installing from Chromium archive, please wait...\n"
IFS="
"
hdiutil attach -quiet -mountpoint $MOUNTPOINT "${TMP}/chromium.dmg"
for app in `find $MOUNTPOINT -type d -maxdepth 1 -name \*.app `; do
  cp -a "$app" /Applications/
done
hdiutil detach -quiet $MOUNTPOINT

printf "\n👍  Lastest Chromium Stable Build from FreeSMUG installed\n"

# Cleaning
rm "${TMP}/chromium.dmg"

# Open Chromium
open "${INSTALL_DIR}/Chromium.app"
