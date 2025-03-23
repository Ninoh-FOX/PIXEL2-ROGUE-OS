# GKD PIXEL2 system mods
mods in stock SYSTEM file

These are minor changes made to the original system such as script improvements by unpacking the original SYSTEM file from the boot partition with the following commands:

. sudo unsquashfs SYSTEM

. sudo mksquashfs squashfs-root SYSTEM -noappend -comp gzip -Xcompression-level 9 -b 262144

### Installation:

As this repository is structured, the three main folders refer to the three partitions contained on the console's microSD card.

In the releases, you'll find two files: SYSTEM and STORAGE.7z.

The SYSTEM file is used to overwrite the existing file on the EMUELEC fat32 partition, which is the OS file system with the corrections.

The STORAGE.7z file contains the files that should be located in the root of the EXT4 STORAGE partition.

All of this works on either a microSD card with the stock OS or with the configured PlumOS OS.
