#!/bin/bash

if ! which aria2c >/dev/null \
|| ! which cabextract >/dev/null \
|| ! which wimlib-imagex >/dev/null \
|| ! which chntpw >/dev/null \
|| ! which genisoimage >/dev/null; then
  echo "One of required applications is not installed."
  echo "The following applications need to be installed to use this script:"
  echo " - aria2c"
  echo " - cabextract"
  echo " - wimlib-imagex"
  echo " - chntpw"
  echo " - genisoimage"
  echo ""
  echo "If you use Debian or Ubuntu you can install these using:"
  echo "sudo apt-get install aria2 cabextract wimtools chntpw genisoimage"
  exit 1
fi

destDir="UUPs"
tempDir=`mktemp -d`
tempScript="$tempDir/aria2.txt"

function cleanup() {
  rm -rf "$tempDir"
}

echo "Retrieving updated aria2 script..."
aria2c -o"aria2.txt" -d"$tempDir" --allow-overwrite=true --auto-file-renaming=false "https://uupdump.ml/get.php?id=ea4e1d15-0c09-45bb-aac0-5e366c04ed2d&pack=en-us&edition=0&aria2=1"
if [ $? != 0 ]; then
  echo "Failed to retrieve aria2 script"
  cleanup
  exit 1
fi

echo ""
echo "Starting download of files..."
aria2c -x16 -s16 -j5 -c -R -d"$destDir" -i"$tempScript"
if [ $? != 0 ]; then
  echo "We have encountered an error while downloading files."
  cleanup
  exit 1
fi

echo ""
if [ -e ./files/convert.sh ]; then
  chmod +x ./files/convert.sh
  ./files/convert.sh wim "$destDir"
fi
