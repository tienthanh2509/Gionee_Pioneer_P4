buildtarget() {
	preparebuildarea

	# Copy rom
	echo 'Đang chép các file của rom gốc...'
	cp -rn $SOURCES/gionee/* $BUILD/
	# Tách lib ra khỏi APK
	echo 'Đang xử lý các addon...'
	buildapp $SOURCES/asus $BUILD/addon/asus
	buildapp $SOURCES/custom $BUILD/addon/custom
	buildapp $SOURCES/google $BUILD/addon/google

	# Copy lại những file khác
	cp -rn $SOURCES/asus $BUILD/addon/
	cp -rn $SOURCES/custom $BUILD/addon/
	cp -rn $SOURCES/google $BUILD/addon/
	cp -rn $SOURCES/supersu $BUILD/addon/
}

