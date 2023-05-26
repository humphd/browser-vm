#!/bin/sh

# Run after buildroot has built the image, and path to the built
# output/image dir is passed as first arg.  We copy the built ISO
# out of the container.
cp ${BINARIES_DIR}/rootfs.iso9660 /build/linux.iso
echo "Created linux.iso."