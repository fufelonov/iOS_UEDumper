TARGET := iphone:clang:latest:14.0

ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

ZSIGN_PATCH_IPA = 0
TWEAK_SCHEME = rootless

ifeq ($(ZSIGN_PATCH_IPA), 1)
THEOS_PACKAGE_DIR = ./packages/jailed
else
THEOS_PACKAGE_SCHEME = $(TWEAK_SCHEME)
THEOS_PACKAGE_DIR = ./packages/$(THEOS_PACKAGE_SCHEME)
endif

include $(THEOS)/makefiles/common.mk

RPM_USE_MEMCPY = 1

ZIP_ARCHIVE_DEFINES = -DHAVE_INTTYPES_H -DHAVE_PKCRYPT -DHAVE_STDINT_H -DHAVE_WZAES -DHAVE_ZLIB

# Пути к зависимостям (оставляем как есть, если папка deps в корне)
KITTYMEMORY_PATH = deps/KittyMemory/KittyMemory
KITTYMEMORY_SRC = $(wildcard $(KITTYMEMORY_PATH)/*.cpp)

DEPS_PATH = deps
DEPS_SRC = $(KITTYMEMORY_SRC) $(DEPS_PATH)/fmt/format.cc \
$(DEPS_PATH)/SSZipArchive/SSZipArchive.m $(wildcard $(DEPS_PATH)/SSZipArchive/minizip/*.c)

TWEAK_NAME = UEDumper

# --- ИСПРАВЛЕНИЕ ЗДЕСЬ ---
# Мы добавили "Tweak/" перед каждым "src/"
$(TWEAK_NAME)_FILES = Tweak/src/Tweak.mm Tweak/src/Dumper.cpp Tweak/src/UPackageGenerator.cpp \
Tweak/src/Utils/AlertUtils.mm Tweak/src/Utils/KittyAlertView.mm Tweak/src/Utils/BufferFmt.cpp \
$(wildcard Tweak/src/UE/*.cpp) $(DEPS_SRC)

$(TWEAK_NAME)_CFLAGS = -fobjc-arc $(ZIP_ARCHIVE_DEFINES) -Wno-deprecated-declarations

$(TWEAK_NAME)_CCFLAGS = -std=c++17 -O2 -I$(DEPS_PATH) -I$(KITTYMEMORY_PATH) -DkNO_KEYSTONE -DkNO_SUBSTRATE
ifeq ($(RPM_USE_MEMCPY), 1)
$(TWEAK_NAME)_CCFLAGS += -DRPM_USE_MEMCPY
endif

$(TWEAK_NAME)_LDFLAGS = -lz -liconv -ldl

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security Network QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
