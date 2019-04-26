#!/usr/bin/env bash

docker build -t buildroot .

docker run \
    --rm \
    --name build-v86 \
    -v $PWD/dist:/build \
    -v $PWD/buildroot-v86/:/buildroot-v86 \
    buildroot

echo "See ./dist for built ISO"
