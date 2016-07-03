#!/bin/bash
command -v realpath >/dev/null 2>&1 || { echo "realpath is required but it's not installed, aborting." >&2; exit 1; }
TOP="$(realpath .)"
SOURCES="$TOP/sources"
SCRIPTS="$TOP/scripts"
CERTIFICATES="$SCRIPTS/certificates"

# shellcheck source=scripts/inc.sourceshelper.sh
. "$SCRIPTS/inc.sourceshelper.sh"
# shellcheck source=scripts/inc.tools.sh
. "$SCRIPTS/inc.tools.sh"

# Check tools
checktools aapt coreutils

##########################################################################################################################

allapps="$(find "$SOURCES/" -iname "*.apk" | sort | uniq)"

printf "%-45s|%-55s|%-20s|%-5s|%-20s|%-30s	%s\n" "Name" "Package" "ARCH" "API" "DPI" "VersionName (VersionCode)" "HASH"

for appname in $allapps;do
	getapkproperties "$appname"
	getarchitecturesfromlib "$appname"
	hash=`md5sum $appname`

	if [ "$compatiblescreens" = "" ] # we can't use -z here, because there can be a linecontrol character or such in it
	then
		dpis="nodpi"
	else
		dpis=$(echo "$compatiblescreens" | grep "compatible-screens:" | grep -oE "/([0-9][0-9])[0-9]" | uniq | tr -d '\012\015' | tr '/' '-' | cut -c 2-)
	fi
	
	printf "%-45s|%-55s|%-20s|%-5s|%-20s|%-30s	%s\n" "$name" "$package" "$architectures" "$sdkversion" "$dpis" "$versionname ($versioncode)" "$hash"
done

echo $result
