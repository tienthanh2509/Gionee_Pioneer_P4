#!/bin/sh

SOURCES=$1

command -v aapt >/dev/null 2>&1 || { echo "aapt is required but it's not installed.  Aborting." >&2; exit 1; }
command -v file >/dev/null 2>&1 || { echo "file is required but it's not installed.  Aborting." >&2; exit 1; }
command -v install >/dev/null 2>&1 || { echo "coreutils is required but it's not installed.  Aborting." >&2; exit 1; }
#coreutils also contains the basename command
command -v unzip >/dev/null 2>&1 || { echo "unzip is required but it's not installed.  Aborting." >&2; exit 1; }

getapkproperties(){
	apkproperties="$(aapt dump badging $1 2>/dev/null)"
	name="$(echo "$apkproperties" | grep "application-label:" | sed 's/application-label://g' | sed "s/'//g")"
	package="$(echo "$apkproperties" | grep package: | awk '{print $2}' | sed s/name=//g | sed s/\'//g | awk '{print tolower($0)}')"
	versionname="$(echo "$apkproperties" | grep "versionName" | awk '{print $4}' | sed s/versionName=// | sed "s/'//g")"
	versioncode="$(echo "$apkproperties" | grep "versionCode=" | awk '{print $3}' | sed s/versionCode=// | sed "s/'//g")"
	sdkversion="$(echo "$apkproperties" | grep "sdkVersion:" | sed 's/sdkVersion://' | sed "s/'//g")"
	compatiblescreens="$(echo "$apkproperties" | grep "compatible-screens:")"
	native="$(echo "$apkproperties" | grep "native-code:" | sed 's/native-code://g' | sed "s/'//g")"
	leanback="$(echo "$apkproperties" | grep "uses-feature:'android.software.leanback'" | awk -F [.\'] '{print $4}')"
}

getarchitectures() {
	architectures=""
	native=$2
	if [ -z "$native" ]
	then
		#echo "No native-code specification defined"
		#Some packages don't have native-code specified, but are still depending on it.
		#So an extra check is necessary before declaring it suitable for all platforms
		libfiles=$(unzip -qql "$1" lib/* | tr -s ' ' | cut -d ' ' -f5-)
		for lib in $libfiles
		do
			#this gives all files found in the lib-folder(s), check their paths for which architectures' libs are included
			arch="$(echo "$lib" | awk 'BEGIN { FS = "/" } ; {print $2}')"
			echo "$architectures" | grep -q "$arch"
			if [ $? -eq 1 ] #only add if this architecture is not yet in the list
			then
				architectures="$architectures$arch "
				#echo "Manually found native code for: $arch"
			fi
		done
		if [ -z "$architectures" ] #If the package really has no native code
		then
			architectures="all"
		fi
	else
		for arch in $native
		do
				architectures="$architectures$arch "
		done
	fi
	#echo "Native code for architecture(s): $architectures"
}

##########################################################################################################################

allapps="$(find "$SOURCES/" -iname "*.apk" | sort | uniq)"

printf "%-45s|%-55s|%-20s|%-5s|%-20s|%-30s	%s\n" "Name" "Package" "ARCH" "API" "DPI" "VersionName (VersionCode)" "HASH"

for appname in $allapps;do
	getapkproperties "$appname"
	getarchitectures "$appname" "$native"
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
