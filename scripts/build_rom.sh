#!/bin/bash
VERSION="T8264"
API=19
ARCH="arm"
API="19"
DATE=$(date +"%Y%m%d")
#DATETIME=$(date +"%Y%m%d%H%M%S")

TOP="$(realpath .)"
BUILD="$TOP/build"
SOURCES="$TOP/sources"
SCRIPTS="$TOP/scripts"
OUTFOLDER="$TOP/out"
LOGFOLDER="$TOP/log"
CERTIFICATES="$SCRIPTS/certificates"
#CERTIFICATEFILE=""  # this can be set to a filepath to use as certificate file for signing
#KEYFILE=""  # this can be set to a filepath to use as key file for signing
#ZIPALIGNRECOMPRESS=""  # if set to a non-zero value, APKs will be recompressed with zopfli during zipalign
ZIPCOMPRESSIONLEVEL="0"  # Store only the files in the zip without compressing them (-0 switch): further compression will be useless and will slow down the building process
#OUTFILE='$OUTFOLDER/P4-$ARCH-$PLATFORM-$VERSION-$DATE.zip'  # this can be set to a filepath to use as alternative outputfile; use ' to allow variables to be evaluated later

# shellcheck source=scripts/inc.buildhelper.sh
. "$SCRIPTS/inc.buildhelper.sh"
# shellcheck source=scripts/inc.buildtarget.sh
. "$SCRIPTS/inc.buildtarget.sh"
# shellcheck source=scripts/inc.packagetarget.sh
. "$SCRIPTS/inc.packagetarget.sh"
# shellcheck source=scripts/inc.sourceshelper.sh
. "$SCRIPTS/inc.sourceshelper.sh"
# shellcheck source=scripts/inc.tools.sh
. "$SCRIPTS/inc.tools.sh"

# Check tools
checktools aapt coreutils unzip zip realpath zipalign

case "$API" in
  19) PLATFORM="4.4";;
  *)  echo "ERROR: Unknown API version! Aborting..."; exit 1;;
esac

echo -e "\e[104mBUILD STEP\e[0m"
buildtarget
echo -e "\e[46mZIPALIGN\e[0m"
alignbuild
echo -e "\e[45mREPACK\e[0m"
createzip

