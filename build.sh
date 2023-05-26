#!/usr/bin/env bash

# Create nodejs directory
mkdir -p buildroot-v86/board/v86/rootfs_overlay/usr/local/lib/nodejs
cd buildroot-v86/board/v86/rootfs_overlay/usr/local/lib/nodejs

# Download nodejs
VERSION=v16.20.0
wget https://unofficial-builds.nodejs.org/download/release/v16.20.0/node-$VERSION-linux-x86.tar.xz

# Unzip the binary archive
tar -xJf node-$VERSION-linux-x86.tar.xz
mv node-$VERSION-linux-x86/{bin,include,lib,share} .
rm node-$VERSION-linux-x86 node-v16.20.0-linux-x86.tar.xz

cd -

docker build -t buildroot .

docker run \
    --rm \
    --name build-v86 \
    -v $PWD/dist:/build \
    -v $PWD/buildroot-v86/:/buildroot-v86 \
    buildroot

echo "See ./dist for built ISO"
