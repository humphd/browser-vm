#!/usr/bin/env bash

mkdir -p buildroot-v86/board/v86/rootfs_overlay/usr/local/lib/nodejs

wget -P buildroot-v86/board/v86/rootfs_overlay/usr/local/lib/nodejs  https://unofficial-builds.nodejs.org/download/release/v16.20.0/node-v16.20.0-linux-x86.tar.xz

tar -xJf buildroot-v86/board/v86/rootfs_overlay/usr/local/lib/nodejs/node-v16.20.0-linux-x86.tar.xz
rm buildroot-v86/board/v86/rootfs_overlay/usr/local/lib/nodejs/node-v16.20.0-linux-x86.tar.xz

ls buildroot-v86/board/v86/rootfs_overlay/usr/local/lib/nodejs

docker build -t buildroot .

docker run \
    --rm \
    --name build-v86 \
    -v $PWD/dist:/build \
    -v $PWD/buildroot-v86/:/buildroot-v86 \
    buildroot

echo "See ./dist for built ISO"
