#!/bin/bash

# Define static values
SOURCES="$1"
BUILD="$2"

#echo -e " \e[1m\e[92mTool tự động tách lib ra khỏi apk\e[0m"
echo -e " \e[1m\e[91m[S] $SOURCES\e[0m \e[1m\e[95m\n  -->\e[0m \e[1m\e[92m[D] $BUILD\e[0m"

#####---------CHECK FOR EXISTANCE OF SOME BINARIES---------
command -v install >/dev/null 2>&1 || { echo "coreutils is required but it's not installed.  Aborting." >&2; exit 1; } #coreutils also contains the basename command
command -v basename >/dev/null 2>&1 || { echo "basename is required but it's not installed.  Aborting." >&2; exit 1; }
command -v md5sum >/dev/null 2>&1 || { echo "md5sum is required but it's not installed.  Aborting." >&2; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "unzip is required but it's not installed.  Aborting." >&2; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "zip is required but it's not installed.  Aborting." >&2; exit 1; }
command -v zipalign >/dev/null 2>&1 || { echo "zipalign is required but it's not installed.  Aborting." >&2; exit 1; }

buildapk() {
	sourceapk="$1"
	apkname="$(basename "$2")"
	targetdir="$(dirname $2)"
	targetapk="$targetdir/$apkname"

	#echo "$targetdir" "$sourceapk" "$targetapk"
	zip -q -b "$targetdir" -U "$sourceapk" -O "$targetapk" --exclude "lib*"
}

buildlib() {
	sourceapk="$1"
	targetdir="$2"
	libsearchpath="lib/*" #default that should never happen: all libs
	
	libsearchpath="lib/armeabi*/*" #mind the wildcard
	libfallbacksearchpath=""

	#targetdir=$(dirname "$(dirname "$targetdir")")
	#echo $targetdir
	#echo $sourceapk
	#echo $libsearchpath
	if [ -n "$(unzip -qql "$sourceapk" "$libsearchpath" | cut -c1- | tr -s ' ' | cut -d' ' -f5-)" ]
	then
		install -d "$targetdir"
		unzip -q -j -o "$sourceapk" -d "$targetdir" "$libsearchpath"
	fi
}

#echo "Loading file list..."
mkdir -p $BUILD
APKLIST=`find $SOURCES -type f -name "*.apk"`
for filename in $APKLIST; do
	# Thư mục chứa APK vd: /home/phamthanh/Desktop/T8264/sources/asus/app
	source_dir=$(dirname "${filename}")
	# Tên file APK vd: com.asus.launcher.apk
	apkfilename=$(basename "${filename}")
	# Thư mục đích
	target_dir=$BUILD/${source_dir#${SOURCES}/}
	target_lib=$BUILD/lib

	# Debug Vars
	#echo ${SOURCES}
	#echo ${filename}
	#echo ${source_dir}
	#echo ${target_dir}
	#echo ${target_lib}
	#echo $filename | sed 's/\.apk/\.odex/' # odex

	mkdir -p $target_dir

	if [ $(echo $target_dir | grep "vendor") ]; then
		OUTPUT="\e[91mWorking on: ${apkfilename} skipped, vendor apk, nothing todo.\e[0m"
		#target_lib=$BUILD/vendor/lib
	else
		odexfile=`$filename | sed 's/\.apk/\.odex/'`

		if [ -e "$odexfile" ]
		then
			OUTPUT="\e[91mWorking on: ${apkfilename} skipped, odex found.\e[0m"
		else
			buildapk $(realpath $filename) "${target_dir}/${apkfilename}"
			buildlib $(realpath $filename) "$target_lib"
			OUTPUT="\e[96mWorking on: ${apkfilename} done.\e[0m"
		fi
	fi
	
	echo -e $OUTPUT

done

