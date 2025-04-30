CROSS_COMPILE ?= /mnt/ext-data/downloads/buildroot-2025.02/output/host/bin/aarch64-buildroot-linux-gnu-
SYSROOT = /mnt/ext-data/downloads/buildroot-2025.02/output/host/aarch64-buildroot-linux-gnu/sysroot
TARGET  = rumble-test
CROSS   = aarch64-buildroot-linux-gnu-
CFLAGS  = -I/mnt/ext-data/downloads/buildroot-2025.02/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/include
LDFLAGS =

export PATH=/mnt/ext-data/downloads/buildroot-2025.02/output/host/bin:$(shell echo $$PATH)

all:
	$(CROSS)gcc rumble.c $(CFLAGS) $(LDFLAGS) -o $(TARGET)

clean:
	rm -rf $(TARGET)
