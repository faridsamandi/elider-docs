#!/bin/bash

OUTPUT_DIR=$(pwd)
KERNEL_DIR="/home/farid/linux-5.4.284"

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    echo "Pass 0 to build the disk image from scratch (Buildroot's output), or pass 1 to build the disk image from the existing RootFS directory"
    exit 1
fi

# Check if the argument is 0 or 1
if [ "$1" -eq 0 ] || [ "$1" -eq 1 ]; then
    if [ "$1" -eq 0 ]; then
        mkdir -p $OUTPUT_DIR/RootFS
	tar xf $OUTPUT_DIR/images/rootfs.tar -C $OUTPUT_DIR/RootFS
	make -C $KERNEL_DIR ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- INSTALL_MOD_PATH=$OUTPUT_DIR/RootFS modules_install
	cp -a $RISCV/sysroot/usr/lib $OUTPUT_DIR/RootFS/usr/lib
    fi
else
    echo "Pass 0 to build the disk image from scratch (Buildroot's output), or pass 1 to build the disk image from the existing RootFS directory"
    exit 1
fi

cp -a $RISCV/sysroot/usr/lib $OUTPUT_DIR/RootFS/usr/lib
dd if=/dev/zero of=riscv_disk bs=1M count=8192
mkfs.ext2 -L riscv-rootfs riscv_disk
sudo mkdir -p /mnt/rootfs
sudo mount riscv_disk /mnt/rootfs
sudo cp -a $OUTPUT_DIR/RootFS/* /mnt/rootfs
sudo chown -R -h root:root /mnt/rootfs/
df /mnt/rootfs
sudo umount /mnt/rootfs
sudo rmdir /mnt/rootfs
