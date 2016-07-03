getapkproperties(){
  apkproperties="$(aapt dump badging "$1" 2>/dev/null)"
  name="$(echo "$apkproperties" | grep -a "application-label:" | sed 's/application-label://g' | sed "s/'//g")"
  package="$(echo "$apkproperties" | awk '/package:/ {print $2}' | sed s/name=//g | sed s/\'//g | awk '{print tolower($0)}')"
  versionname="$(echo "$apkproperties" | awk -F="'" '/versionName=/ {print $4}' | sed "s/'.*//g")"
  versioncode="$(echo "$apkproperties" | awk -F="'" '/versionCode=/ {print $3}' | sed "s/'.*//g")"
  sdkversion="$(echo "$apkproperties" | grep -a "sdkVersion:" | sed 's/sdkVersion://' | sed "s/'//g")"
  compatiblescreens="$(echo "$apkproperties" | grep -a "compatible-screens:'")" #the ' is added to prevent detection of lines that only have compatiblescreens but without any values
  native="$(echo "$apkproperties" | grep -av "alt-native-code:" | grep -a "native-code:" | sed 's/native-code://g' | sed "s/'//g") " # add a space at the end
  altnative="$(echo "$apkproperties" | grep -a "alt-native-code:" | sed 's/alt-native-code://g' | sed "s/'//g") " # add a space at the end
  leanback="$(echo "$apkproperties" | grep -a "android.software.leanback" | awk -F [.\'] '{print $(NF-1)}')"
  case "$versionname" in
    *leanback*) leanback="leanback";;
  esac

  if [ -n "$leanback" ]; then
    case "$package" in
      *inputmethod*) ;; #if package is an inputmethod, it will have leanback as feature described, but we don't want it recognized as such
      *.leanback) ;; #if package already has leanback at the end of its name, we don't need to add it ourselves
      *) package="$package.$leanback";; #special leanback versions need a different packagename
    esac
  fi

  case $package in
    "com.android.hotwordenrollment" |\
    "com.android.vending" |\
    "com.android.vending.leanback" |\
    "com.google.android.androidforwork" |\
    "com.google.android.apps.mediashell.leanback" |\
    "com.google.android.apps.gcs" |\
    "com.google.android.athome.remotecontrol" |\
    "com.google.android.athome.globalkeyinterceptor" |\
    "com.google.android.atv.customization" |\
    "com.google.android.backuptransport" |\
    "com.google.android.configupdater" |\
    "com.google.android.contacts" |\
    "com.google.android.dialer" |\
    "com.google.android.feedback" |\
    "com.google.android.gms" |\
    "com.google.android.gms.leanback" |\
    "com.google.android.googlequicksearchbox" |\
    "com.google.android.gsf" |\
    "com.google.android.gsf.login" |\
    "com.google.android.katniss.leanback" |\
    "com.google.android.leanbacklauncher.leanback" |\
    "com.google.android.onetimeinitializer" |\
    "com.google.android.packageinstaller" |\
    "com.google.android.partnersetup" |\
    "com.google.android.setupwizard" |\
    "com.google.android.tungsten.setupwraith" |\
    "com.google.android.tag" |\
    "com.google.android.tungsten.overscan" |\
    "com.google.android.tungsten.setupwraith" |\
    "com.google.android.tv.leanback" |\
    "com.google.android.tv.remote" |\
    "com.google.android.tv.remotepairing") type="priv-app";;
    *) type="app";;
  esac

  #we do this on purpose after the priv-app detection to emulate the priv-app of the normal app
  if [ -n "$BETA" ]; then
    package="$package.$BETA"
  fi

  beta="" #make sure value is initialized
  case "$1" in
    *.beta/*) beta="beta"  #report beta status as a property
              case "$package" in
                *.beta);;
                *) package="$package.beta";;  # set .beta in package name if not set yet
              esac;;
  esac

  if [ "$(echo $compatiblescreens)" = "" ]; then # we can't use -z here, because there can be a linecontrol character or such in it
    dpis="nodpi"
  else
    dpis=$(echo "$compatiblescreens" | grep "compatible-screens:" | grep -oE "/([0-9][0-9])[0-9]" | sort -u | tr -d '\012\015' | tr '/' '-' | cut -c 2-)
  fi
}

getarchitecturesfromlib() {
  # Some packages don't have native-code specified, but are still depending on it
  # If multiple architectures are found; we assume it to be only compatible with the highest architecture and not multi-arch
  architectures=""
  libfiles=$(unzip -qqql "$1" "lib/*" | tr -s ' ' | cut -d ' ' -f5-)
  for lib in $libfiles; do
    #this gives all files found in the lib-folder(s), check their paths for which architectures' libs are included
    arch="$(echo "$lib" | awk 'BEGIN { FS = "/" } ; {print $2}')" #add a space at the end
    if ! echo "$architectures" | grep -q "$arch "; then #only add if this architecture is not yet in the list; use a space to distinguish substrings (e.g. x86 vs x86_64)
      architectures="$architectures$arch "
    fi
  done
  if [ -z "$architectures" ]; then #If the package really has no native code
    architectures="all"
  fi
}

