#!/usr/bin/env bash
set -euo pipefail
# set -xv
COMMON_FLAGS="-march=native -mtune=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
MAKEFLAGS="-j$(nproc)"

echo "Compiling the kernel" && {
make zImage
make dtbs
make modules
make INSTALL_DTBS_PATH="/boot/dtbs" dtbs_install
make INSTALL_MOD_PATH="/usr" modules_install
echo "Compiling done!"
}

: '
echo "Generating initramfs" && {
mkinitcpio -p ./linux-minnie-lts.preset
echo "Initramfs done!"
}
:

echo "Generating kernel image" && {
mkimage \
-D "-I dts -O dtb -p 2048" \
-f kernel.its vmlinux.uimg
echo "Kernel image done!"
}

echo "Generating empty bootloader.bin" && {
dd if=/dev/zero of=bootloader.bin bs=512 count=1
echo "Bootloader done!"
}

echo "Generating Depthcharge image" && {
vbutil_kernel \
--pack vmlinux.kpart \
--version 1 \
--vmlinuz vmlinux.uimg \
--arch arm \
--keyblock kernel.keyblock \
--signprivate kernel_data_key.vbprivk \
--config kernel.cmdline \
--bootloader bootloader.bin
echo "Depthcharge image done!"
}

echo "Copying kernel image to /boot" && {
cp arch/arm/boot/zImage /boot/zImage
cp vmlinux.kpart /boot/vmlinux.kpart
echo "Copied files into /boot"
}

echo "Flashing the kernel image" && {
dd if=/boot/vmlinux.kpart of=/dev/disk/by-partlabel/Kernel-A
sync
echo "Flashed! Everything is done!"
}
