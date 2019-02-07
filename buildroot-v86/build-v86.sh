#!/bin/sh
set -e

# Build our v86 defconfig along with license files.
echo $PWD
make BR2_EXTERNAL=/buildroot-v86 v86_defconfig \
    && make legal-info \
    && make
