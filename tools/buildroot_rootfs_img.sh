#!/bin/bash

set -e

ROOTFS_TAR=$1
ROOTFS_IMG=$2
WORK_DIR=$3

if [ -z "$ROOTFS_TAR" ] || [ -z "$ROOTFS_IMG" ] || [ -z "$WORK_DIR" ]; then
	echo "Usage: $0 <rootfs.tar> <rootfs.img> <work-dir>"
	exit 1
fi

if [ ! -f "$ROOTFS_TAR" ]; then
	echo "Buildroot rootfs tar doesn't exist: $ROOTFS_TAR"
	exit 1
fi

if ! command -v mke2fs >/dev/null 2>&1; then
	echo "mke2fs not found. Please install e2fsprogs."
	exit 1
fi

rm -rf "$WORK_DIR" "$ROOTFS_IMG"
mkdir -p "$WORK_DIR"

tar -C "$WORK_DIR" -xf "$ROOTFS_TAR"

# Leave enough slack for package growth and writable state on first boot.
sz=$(du -sb "$WORK_DIR" | cut -f1)
partition_size_mib=$((sz * 14 / 10 / 1024 / 1024 + 32))

echo "Create Buildroot ext4 rootfs image: $ROOTFS_IMG (${partition_size_mib} MiB)"
mke2fs -t ext4 -b 4096 -d "$WORK_DIR" "$ROOTFS_IMG" "${partition_size_mib}M"
