checktools() {
  missing=""
  # Check existance of specified tools and notify user of missing tools
  for command in "$@"; do
    # To check pseudo tool "coreutils" we check one of it's tools absent from any other package
    if [ "$command" = "coreutils" ]; then command="basename"; fi

    if ! command -v $command >/dev/null 2>&1; then
      case $command in
        basename|install|readlink|md5sum|mktemp)
          echo 'Coreutils is required for install, basename, readlink, md5sum and other utilities, but is not installed or found in sh $PATH.';;
        jarsigner|keytool)
          echo 'JDK is required for jarsigner and keytools utilities, but is not installed or found in sh $PATH.';;
        aapt|zipalign)
          echo 'Android SDK is required for aapt and zipalign utilities, but is not installed or found in sh $PATH.';;
        *)
          echo "$command is required but is not installed.";;
      esac
      missing="$missing $command"
    else
      case $command in
        zipalign)
          if ! zipalign 2>&1 | grep -q "page align stored shared object files"; then
            echo 'zipalign is outdated. Install a more recent version from the Android SDK and findable in sh $PATH.' >&2
            missing="$missing $command"
          fi;;
        aapt)
          av="0$(aapt v 2>&1 | sed -n 's/.*v0\.2-\?\([0-9]*\)/\1/p')"
          if [ "$av" -lt "02300000" ] ; then
            echo 'aapt is outdated. Install a more recent version from the Android SDK and findable in sh $PATH.' >&2
            missing="$missing $command"
          fi;;
      #*)
          #echo "$command tool found and it is up to date." >&2;;
      esac
    fi
  done

  # Bail out if any of the requested tools are missing
  if [ -n "$missing" ]; then
    echo "Aborting." >&2
    exit 1
  #else
    #echo "All tools are set."
  fi
}
