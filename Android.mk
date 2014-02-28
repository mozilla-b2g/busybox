LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

# busybox --list | sed 's/$/ \\/' | sed 's/^/\t/'
BUSYBOX_TOOLS := \
	[ \
	[[ \
	ar \
	arp \
	ash \
	awk \
	base64 \
	basename \
	beep \
	blkid \
	blockdev \
	bunzip2 \
	bzcat \
	bzip2 \
	cal \
	cat \
	catv \
	chat \
	chattr \
	chgrp \
	chmod \
	chown \
	chpst \
	chroot \
	chrt \
	chvt \
	cksum \
	clear \
	cmp \
	comm \
	cp \
	cpio \
	cttyhack \
	cut \
	dc \
	dd \
	deallocvt \
	depmod \
	devmem \
	diff \
	dirname \
	dmesg \
	dnsd \
	dos2unix \
	dpkg \
	dpkg-deb \
	du \
	dumpkmap \
	echo \
	ed \
	egrep \
	envdir \
	envuidgid \
	expand \
	fakeidentd \
	false \
	fbset \
	fbsplash \
	fdflush \
	fdformat \
	fdisk \
	fgconsole \
	fgrep \
	find \
	findfs \
	flash_lock \
	flash_unlock \
	flashcp \
	flock \
	fold \
	freeramdisk \
	ftpd \
	ftpget \
	ftpput \
	fuser \
	getopt \
	grep \
	gunzip \
	gzip \
	halt \
	hd \
	hdparm \
	head \
	hexdump \
	httpd \
	ifconfig \
	ifdown \
	ifup \
	init \
	inotifyd \
	insmod \
	install \
	iostat \
	ip \
	ipaddr \
	ipcalc \
	iplink \
	iproute \
	iprule \
	iptunnel \
	kill \
	klogd \
	linuxrc \
	ln \
	loadkmap \
	losetup \
	lpd \
	lpq \
	lpr \
	ls \
	lsattr \
	lsmod \
	lspci \
	lsusb \
	lzcat \
	lzma \
	lzop \
	lzopcat \
	makedevs \
	makemime \
	man \
	md5sum \
	mesg \
	mkdir \
	mkfifo \
	mknod \
	mkswap \
	mktemp \
	modinfo \
	modprobe \
	more \
	mpstat \
	mv \
	nbd-client \
	nc \
	netstat \
	nice \
	nmeter \
	nohup \
	od \
	openvt \
	patch \
	pidof \
	ping \
	pipe_progress \
	pmap \
	popmaildir \
	poweroff \
	powertop \
	printenv \
	printf \
	ps \
	pscan \
	pstree \
	pwd \
	pwdx \
	raidautorun \
	rdev \
	readlink \
	readprofile \
	realpath \
	reboot \
	reformime \
	renice \
	reset \
	resize \
	rev \
	rm \
	rmdir \
	rmmod \
	route \
	rpm \
	rpm2cpio \
	rtcwake \
	run-parts \
	runsv \
	runsvdir \
	rx \
	script \
	scriptreplay \
	sed \
	sendmail \
	seq \
	setconsole \
	setkeycodes \
	setlogcons \
	setserial \
	setsid \
	setuidgid \
	sha1sum \
	sha256sum \
	sha512sum \
	showkey \
	sleep \
	smemcap \
	softlimit \
	sort \
	split \
	start-stop-daemon \
	strings \
	stty \
	sum \
	sv \
	svlogd \
	sync \
	sysctl \
	tac \
	tail \
	tar \
	tcpsvd \
	tee \
	telnet \
	telnetd \
	test \
	time \
	timeout \
	top \
	touch \
	tr \
	traceroute \
	true \
	ttysize \
	tunctl \
	tune2fs \
	udhcpc \
	uname \
	uncompress \
	unexpand \
	uniq \
	unix2dos \
	unlzma \
	unlzop \
	unxz \
	unzip \
	uptime \
	uudecode \
	uuencode \
	vi \
	volname \
	watch \
	wc \
	wget \
	which \
	whoami \
	whois \
	xargs \
	xz \
	xzcat \
	yes \
	zcat

BB_TC_DIR := $(shell dirname $(TARGET_TOOLS_PREFIX))
BB_TC_PREFIX := $(shell basename $(TARGET_TOOLS_PREFIX))
BB_LDFLAGS := -Xlinker -z -Xlinker muldefs -nostdlib -Bdynamic -Xlinker -T../../$(BUILD_SYSTEM)/armelf.x -Xlinker -dynamic-linker -Xlinker /system/bin/linker -Xlinker -z -Xlinker nocopyreloc -Xlinker --no-undefined ../../$(TARGET_CRTBEGIN_DYNAMIC_O) ../../$(TARGET_CRTEND_O) -L../../$(TARGET_OUT_STATIC_LIBRARIES)
# FIXME remove -fno-strict-aliasing once all aliasing violations are fixed
BB_COMPILER_FLAGS := $(subst -I ,-I../../,$(subst -include ,-include ../../,$(TARGET_GLOBAL_CFLAGS))) -I../../bionic/libc/include -I../../bionic/libc/kernel/common -I../../bionic/libc/arch-arm/include -I../../bionic/libc/kernel/arch-arm -I../../bionic/libm/include -fno-stack-protector -Wno-error=format-security -fno-strict-aliasing
BB_LDLIBS := dl m c gcc
ifneq ($(strip $(SHOW_COMMANDS)),)
BB_VERBOSE="V=1"
endif

LOCAL_MODULE := busybox
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := busybox

include $(BUILD_PREBUILT)

$(LOCAL_PATH)/busybox: $(TARGET_CRTBEGIN_DYNAMIC_O) $(TARGET_CRTEND_O) $(TARGET_OUT_STATIC_LIBRARIES)/libm.so $(TARGET_OUT_STATIC_LIBRARIES)/libc.so $(TARGET_OUT_STATIC_LIBRARIES)/libdl.so
	cd external/busybox && \
	sed -e "s|^CONFIG_CROSS_COMPILER_PREFIX=.*|CONFIG_CROSS_COMPILER_PREFIX=\"$(BB_TC_PREFIX)\"|;s|^CONFIG_EXTRA_CFLAGS=.*|CONFIG_EXTRA_CFLAGS=\"$(BB_COMPILER_FLAGS)\"|" configs/android_defconfig >.config && \
	export PATH=$(BB_TC_DIR):$(PATH) && \
	$(MAKE) oldconfig > /dev/null && \
	$(MAKE) $(BB_VERBOSE) EXTRA_LDFLAGS="$(BB_LDFLAGS)" LDLIBS="$(BB_LDLIBS)"

# Make #!/system/bin/busybox launchers for each tool.
#
SYMLINKS := $(addprefix $(TARGET_OUT)/bin/,$(BUSYBOX_TOOLS))
$(SYMLINKS): BUSYBOX_BINARY := $(LOCAL_MODULE)
$(SYMLINKS): $(LOCAL_INSTALLED_MODULE) $(LOCAL_PATH)/Android.mk
	@echo "Symlink: $@ -> $(BUSYBOX_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(BUSYBOX_BINARY) $@

ALL_DEFAULT_INSTALLED_MODULES += $(SYMLINKS)

# We need this so that the installed files could be picked up based on the
# local module name
ALL_MODULES.$(LOCAL_MODULE).INSTALLED := \
    $(ALL_MODULES.$(LOCAL_MODULE).INSTALLED) $(SYMLINKS)
