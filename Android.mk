include $(CLEAR_VARS)

BB_TC_DIR := $(shell dirname $(TARGET_TOOLS_PREFIX))
BB_TC_PREFIX := $(shell basename $(TARGET_TOOLS_PREFIX))
BB_LDFLAGS := -Xlinker -z -Xlinker muldefs -nostdlib -Bdynamic -Xlinker -T../../$(BUILD_SYSTEM)/armelf.x -Xlinker -dynamic-linker -Xlinker /system/bin/linker -Xlinker -z -Xlinker nocopyreloc -Xlinker --no-undefined ../../$(TARGET_CRTBEGIN_DYNAMIC_O) ../../$(TARGET_CRTEND_O) -L../../$(TARGET_OUT_STATIC_LIBRARIES)
BB_COMPILER_FLAGS := $(subst -I ,-I../../,$(subst -include ,-include ../../,$(TARGET_GLOBAL_CFLAGS))) -I../../bionic/libc/include -I../../bionic/libc/kernel/common -I../../bionic/libc/arch-arm/include -I../../bionic/libc/kernel/arch-arm -I../../bionic/libm/include -fno-stack-protector -Wno-error=format-security
BB_LDLIBS := dl m c gcc

.PHONY: busybox

droid: busybox

systemtarball: busybox

busybox: $(TARGET_CRTBEGIN_DYNAMIC_O) $(TARGET_CRTEND_O) $(TARGET_OUT_STATIC_LIBRARIES)/libm.so $(TARGET_OUT_STATIC_LIBRARIES)/libc.so $(TARGET_OUT_STATIC_LIBRARIES)/libdl.so
	cd external/busybox && \
	sed -e "s|^CONFIG_CROSS_COMPILER_PREFIX=.*|CONFIG_CROSS_COMPILER_PREFIX=\"$(BB_TC_PREFIX)\"|;s|^CONFIG_EXTRA_CFLAGS=.*|CONFIG_EXTRA_CFLAGS=\"$(BB_COMPILER_FLAGS)\"|" configs/android_defconfig >.config && \
	export PATH=$(BB_TC_DIR):$(PATH) && \
	$(MAKE) oldconfig && \
	$(MAKE) EXTRA_LDFLAGS="$(BB_LDFLAGS)" LDLIBS="$(BB_LDLIBS)" && \
	mkdir -p ../../$(PRODUCT_OUT)/system/bin && \
	cp busybox ../../$(PRODUCT_OUT)/system/bin/
