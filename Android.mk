# LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
# LOCAL_MODULE := busybox
# LOCAL_MODULE_TAGS := eng

TC_DIR = $(shell dirname $(TARGET_TOOLS_PREFIX))
TC_PREFIX = $(shell basename $(TARGET_TOOLS_PREFIX))
COMPILER_FLAGS = $(subst -I ,-I../../,$(subst -include ,-include ../../,$(TARGET_GLOBAL_CFLAGS))) -I../../bionic/libc/include -I../../bionic/libc/kernel/common -I../../bionic/libc/arch-arm/include -I../../bionic/libc/kernel/arch-arm -I../../bionic/libm/include -fno-stack-protector

.phony: busybox

droid: busybox

systemtarball: busybox

busybox:
	cd external/busybox && \
	sed -e "s|^CONFIG_CROSS_COMPILER_PREFIX=.*|CONFIG_CROSS_COMPILER_PREFIX=\"$(TC_PREFIX)\"|;s|^CONFIG_EXTRA_CFLAGS=.*|CONFIG_EXTRA_CFLAGS=\"$(COMPILER_FLAGS)\"|" configs/android_defconfig >.config && \
	export PATH=$(TC_DIR):$(PATH) && \
	make oldconfig && \
	make busybox V=1 VERBOSE=1 && \
	mkdir -p ../../$(PRODUCT_OUT)/system/bin && \
	cp busybox ../../$(PRODUCT_OUT)/system/bin/

# LOCAL_PATH := $(call my-dir)
# include $(CLEAR_VARS)

# LOCAL_MODULE := busybox
# LOCAL_MODULE_TAGS := eng
# LOCAL_PREBUILT_EXECUTABLES := busybox
# include $(BUILD_MULTI_PREBUILT)

