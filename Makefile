TOPDIR := $(realpath . )
BUILD_SYSTEM := $(TOPDIR)/scripts
BUILDDIR := $(TOPDIR)/build
SOURCEDIR := $(TOPDIR)/sources
OUTDIR := $(TOPDIR)/out

ROMDATE := $(shell /bin/date +%Y%m%d%H%M%S)
VERSION := "T8264"

build:
	echo "${ROMDATE} - Tạo thư mục làm việc..."
	mkdir -p "$(BUILDDIR)"
	mkdir -p "$(OUTDIR)"

	# Build Step
	# Copy rom
	cp -rn $(SOURCEDIR)/gionee/* $(BUILDDIR)/
	# Tách lib ra khỏi APK
	$(BUILD_SYSTEM)/build_system_lib.sh $(SOURCEDIR)/asus $(BUILDDIR)/addon/asus
	$(BUILD_SYSTEM)/build_system_lib.sh $(SOURCEDIR)/custom $(BUILDDIR)/addon/custom
	$(BUILD_SYSTEM)/build_system_lib.sh $(SOURCEDIR)/google $(BUILDDIR)/addon/google
	# Copy lại những file khác
	cp -rn $(SOURCEDIR)/asus $(BUILDDIR)/addon/
	cp -rn $(SOURCEDIR)/custom $(BUILDDIR)/addon/
	cp -rn $(SOURCEDIR)/google $(BUILDDIR)/addon/
	cp -rn $(SOURCEDIR)/supersu $(BUILDDIR)/addon/

	# Kết xuất thông tin các file apk ra file báo cáo tổng quan
	$(BUILD_SYSTEM)/report_sources.sh $(BUILDDIR) > $(BUILDDIR)/report-$(ROMDATE).txt
	# Đóng gói Rom
	cd $(BUILDDIR) && zip -9 -r $(OUTDIR)/$(VERSION)-$(ROMDATE).zip ./*
	md5sum $(OUTDIR)/$(VERSION)-$(ROMDATE).zip > $(OUTDIR)/$(VERSION)-$(ROMDATE).zip.md5

clean:
	@rm -fr "$(BUILDDIR)"
	@echo "[${ROMDATE}] $(tput setaf 2)Đã dọn dẹp thư mục out và log !$(tput sgr 0)"

