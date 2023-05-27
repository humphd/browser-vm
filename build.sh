#!/usr/bin/env bash

# Create nodejs library directory if not exists
NODE_LIB_DIR='buildroot-v86/board/v86/rootfs_overlay/usr/local/lib/nodejs'
if [[ ! -d $NODE_LIB_DIR ]]
then
    mkdir -p $NODE_LIB_DIR
    cd $NODE_LIB_DIR

    # Download nodejs
    VERSION="v16.20.0"
    wget "https://unofficial-builds.nodejs.org/download/release/v16.20.0/node-$VERSION-linux-x86.tar.xz"

    # Unzip the binary archive
    tar -xJf "node-$VERSION-linux-x86.tar.xz"
    mv node-$VERSION-linux-x86/{bin,include,lib,share} .
    rm -rf "node-$VERSION-linux-x86" "node-$VERSION-linux-x86.tar.xz"

    cd -
fi

docker build -t buildroot .

docker run \
    --rm \
    --name build-v86 \
    -v $PWD/dist:/build \
    -v $PWD/buildroot-v86/:/buildroot-v86 \
    buildroot

echo "See ./dist for built ISO"
