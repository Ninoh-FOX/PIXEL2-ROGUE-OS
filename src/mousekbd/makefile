# Toolchain (ajusta esta ruta según la ubicación de tu compilador)
CROSS_COMPILE ?= /opt/gkdpixel-toolchain/bin/aarch64-buildroot-linux-gnu-
SYSROOT = /opt/gkdpixel-toolchain/aarch64-gkdpixel-linux-gnu/sysroot

# Compilador y flags
CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -O2 -march=armv8-a+crc -mtune=cortex-a35 -ffast-math -I$(SYSROOT)/usr/include
LDFLAGS = -L$(SYSROOT)/usr/lib -lSDL2 -levdev

# Archivos fuente y binario
SRC = mousekbd.c
OBJ = $(SRC:.c=.o)
TARGET = mousekbd

# Regla principal
all: $(TARGET)

# Compilación del ejecutable
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Compilación de los archivos objeto
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Limpieza
clean:
	rm -f $(OBJ) $(TARGET)

.PHONY: all clean
