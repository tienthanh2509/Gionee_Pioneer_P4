preparebuildarea() {
  build="$BUILD"
  echo "Cleaning build area: $build"
  rm -rf "$build"
  install -d "$build"
}

copy() {
  if [ -d "$1" ]; then
    for f in $1/*; do
      copy "$f" "$2/$(basename "$f")"
    done
  fi
  if [ -f "$1" ]; then
      install -D -p "$1" "$2"
  fi
}

buildapp() {
	source="$1"
	build="$2"

	echo -e " \e[1m\e[91m[S] $source\e[0m \e[1m\e[95m\n  -->\e[0m \e[1m\e[92m[D] $build\e[0m"

	#echo "Loading file list..."
	mkdir -p $build
	APKLIST=`find $source -type f -name "*.apk"`
	for filename in $APKLIST; do
		# Thư mục chứa APK vd: /home/phamthanh/Desktop/T8264/sources/asus/app
		source_dir=$(dirname "${filename}")
		# Tên file APK vd: com.asus.launcher.apk
		apkfilename=$(basename "${filename}")
		# Thư mục đích
		target_dir=$build/${source_dir#${source}/}
		target_lib=$build/lib

		# Debug Vars
		#echo ${source}
		#echo ${filename}
		#echo ${source_dir}
		#echo ${target_dir}
		#echo ${target_lib}
		#echo $filename | sed 's/\.apk/\.odex/' # odex

		mkdir -p $target_dir

		# Xử lý các file apk của vendor, bỏ qua bước tách lib cho các app:
		# Google+, Hangouts, Messenger, Photos và YouTube vì xung đột lib
		if [ $(echo $target_dir | grep "\/vendor\/") ]; then
			target_lib=$build/vendor/lib
			OUTPUT="\e[91m-->${apkfilename}\e[0m - skipped"

			#com.google.android.apps.messaging
			#com.google.android.apps.photos
			#com.google.android.apps.plus
			#com.google.android.talk
			#com.google.android.youtube

		else
			odexfile=`echo $filename | sed 's/\.apk/\.odex/'`

			# Nếu có file odex đi kèm thì chỉ copy file lib thôi
			if [ -e "$odexfile" ]
			then
				OUTPUT="\e[93m-->${apkfilename}\e[0m - odexed"
				buildapk2 $(realpath $filename) "${target_dir}/${apkfilename}"
				buildlib $(realpath $filename) "$target_lib"
			else
				buildapk $(realpath $filename) "${target_dir}/${apkfilename}"
				buildlib $(realpath $filename) "$target_lib"
				OUTPUT="\e[96m-->${apkfilename}\e[0m - done"
			fi
		fi
	
		echo -e $OUTPUT

	done
}

buildapk() {
	sourceapk="$1"
	apkname="$(basename "$2")"
	targetdir="$(dirname $2)"
	targetapk="$targetdir/$apkname"

	#echo "$targetdir" "$sourceapk" "$targetapk"
	zip -q -b "$targetdir" -U "$sourceapk" -O "$targetapk" --exclude "lib*"
}

# Dành cho apk có file odex
buildapk2() {
	sourceapk="$1"
	apkname="$(basename "$2")"
	targetdir="$(dirname $2)"
	targetapk="$targetdir/$apkname"

	#echo "$targetdir" "$sourceapk" "$targetapk"
	zip -q -b "$targetdir" -U "$sourceapk" -O "$targetapk" --exclude "lib*" --exclude "classes.dex"
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
