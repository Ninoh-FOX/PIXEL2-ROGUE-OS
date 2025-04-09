CROSS_COMPILE ?= /mnt/ext-data/downloads/buildroot-2025.02/output/host/bin/aarch64-buildroot-linux-gnu-
SYSROOT = /mnt/ext-data/downloads/buildroot-2025.02/output/host/aarch64-buildroot-linux-gnu/sysroot
TARGET  = clockset
CROSS   = aarch64-buildroot-linux-gnu-
CFLAGS  = -I/mnt/ext-data/downloads/buildroot-2025.02/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/include/SDL2
LDFLAGS = -lSDL2 -lSDL2_ttf

export PATH=/mnt/ext-data/downloads/buildroot-2025.02/output/host/bin:$(shell echo $$PATH)

all:
	$(CROSS)gcc main.c $(CFLAGS) $(LDFLAGS) -o $(TARGET)

push:
	adb push $(TARGET) /mnt/SDCARD/App/rtc

clean:
	rm -rf $(TARGET)
