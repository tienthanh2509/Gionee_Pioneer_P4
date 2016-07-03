ROMDATE := $(shell /bin/date +%Y%m%d%H%M%S)
VERSION := "T8264"

TOPDIR := $(realpath . )
BUILD_SYSTEM := $(TOPDIR)/scripts
BUILDDIR := /tmp/build
SOURCEDIR := $(TOPDIR)/sources
OUTDIR := $(TOPDIR)/out

build:
	@$(BUILD_SYSTEM)/build_rom.sh

tidy:
	rm -fr "$(BUILDDIR)/report-*"
	rm -fr "$(BUILDDIR)/addon/"
	@echo "[${VERSION}] Đã dọn dẹp xong!"

clean:
	@rm -fr "$(BUILDDIR)"
	@echo "[${VERSION}] $(tput setaf 2)Đã dọn dẹp thư mục out và log !$(tput sgr 0)"

