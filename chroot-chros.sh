#!/bin/bash
mkdir /tmp/mychroot
umount /dev/disk/by-partuuid/8a1c71d9-f13f-7840-83a9-4b9ffdd695f3
mount /dev/disk/by-partuuid/8a1c71d9-f13f-7840-83a9-4b9ffdd695f3 /tmp/mychroot
mount --rbind /dev /tmp/mychroot/dev
mount --make-rslave /tmp/mychroot/dev
mount -t proc /proc /tmp/mychroot/proc
mount --rbind /sys /tmp/mychroot/sys
mount --make-rslave /tmp/mychroot/sys
chroot /tmp/mychroot /bin/bash
