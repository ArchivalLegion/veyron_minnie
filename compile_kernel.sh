#!/bin/sh

# Start by compiling and compressing the kernel + tidly bits
echo "Starting the hellacious process"
make Image
make dtbs
make modules
make INSTALL_DTBS_PATH="/boot/dtbs" dtbs_install
make INSTALL_MOD_PATH="/usr" modules_install
echo "Compiling done!"

# Make a initramfs
echo "Making a initramfs"
mkinitcpio -p ./linux-minnie-lts.preset
echo "initramfs done!"

# Generate the kernel image (vmlinux.uimg)
echo "Generating kernel image"
mkimage -C none -O linux -T kernel \
-b arch/boot/dts/rk3288-veyron-minnie.dtb \
-i /boot/initramfs-minnie.img \
-f kernel.its vmlinux.uimg
echo "Image done!"

# Empty placeholder for bootloader.bin
echo "Placing empty bootloader.bin"
dd if=/dev/zero of=bootloader.bin bs=512 count=1
echo "bootloader done!"

# Combine various files into a depthcharge kernel
echo "Generating vboot image"
vbutil_kernel \
--pack vmlinux.kpart \
--version 1 \
--vmlinuz vmlinux.uimg \
--arch arm \
--keyblock kernel.keyblock \
--signprivate kernel_data_key.vbprivk \
--config cmdline \
--bootloader bootloader.bin
echo "depthcharge kernel done!"

# Move files into /boot
cp arch/arm/boot/Image /boot/Image
cp vmlinux.kpart /boot/vmlinux.kpart
echo "Copied files into /boot"

# Flash the image
echo "Flashing the kernel image"
dd if=/boot/vmlinux.kpart of=/dev/mmcblk1p1
sync
echo "Flashed!, everything is done!"
