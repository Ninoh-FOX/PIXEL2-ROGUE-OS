# PIXEL2_system_mods
mods in stock SYSTEM file

These are minor changes made to the original system such as script improvements by unpacking the original SYSTEM file from the boot partition with the following commands:

sudo unsquashfs SYSTEM
sudo mksquashfs squashfs-root SYSTEM -noappend -comp gzip -Xcompression-level 9 -b 262144
