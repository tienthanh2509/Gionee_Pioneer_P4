alignbuild() {
  for f in $(find "$BUILD" -name '*.apk'); do
    mv "$f" "$f.orig"
    zopfli=""
    if [ -n "$ZIPALIGNRECOMPRESS" ]; then
      zopfli="-z"
    fi
	echo -e "\e[96m-->${f#${BUILD}/}\e[0m"
    zipalign -f -p $zopfli 4 "$f.orig" "$f"
    rm "$f.orig"
  done
}

createzip() {
  echo "INFO: Total size uncompressed applications: $(du -hs "$BUILD/addon" | awk '{ print $1 }')"
  echo "INFO: Total size uncompressed system rom: $(du -hs "$BUILD/system" | awk '{ print $1 }')"

  find "$BUILD" -exec touch -d "2008-02-28 21:33:46.000000000 +0100" {} \;
  cd "$BUILD"

  echo "INFO: Total size of rom: $(du -hs "$BUILD" | awk '{ print $1 }')"

  unsignedzip="$BUILD/ROM.zip"
  if [ -n "$OUTFILE" ]; then
    signedzip="$( eval "echo \"$OUTFILE\"")"
  else
    signedzip="$OUTFOLDER/P4-$ARCH-$PLATFORM-$VERSION-$DATE-UNOFFICIAL.zip"
  fi

  if [ -f "$unsignedzip" ]; then
    rm "$unsignedzip"
  fi

  cd "$BUILD"
  echo "Packaging and signing $signedzip..."
  zip -q -r -D -X -$ZIPCOMPRESSIONLEVEL "$unsignedzip" ./* #don't doublequote zipfolders, contains multiple (safe) arguments
  cd "$TOP"

  signzip
}

signzip() {
  install -d "$(dirname "$signedzip")"
  if [ -f "$signedzip" ]
  then
    rm "$signedzip"
  fi

  if [ -z "$CERTIFICATEFILE" ] || [ ! -e "$CERTIFICATEFILE" ]; then
    CERTIFICATEFILE="$CERTIFICATES/testkey.x509.pem"
  else
    echo "INFO: using $CERTIFICATEFILE as certificate file"
  fi
  if [ -z "$KEYFILE" ] || [ ! -e "$KEYFILE" ]; then
    KEYFILE="$CERTIFICATES/testkey.pk8"
  else
    echo "INFO: using $KEYFILE as cryptographic key file"
  fi

  if java -Xmx2048m -jar "$SCRIPTS/inc.signapk.jar" -w "$CERTIFICATEFILE" "$KEYFILE" "$unsignedzip" "$signedzip"; then #if signing did succeed
    rm "$unsignedzip"
  else
    echo "ERROR: Creating Flashable ZIP-file failed, unsigned file can be found at $unsignedzip"
    exit 1
  fi

  echo "SUCCESS: Built GIONEE PIONNER P4 - $VERSION, with API 19 level for arm as $signedzip"
}
