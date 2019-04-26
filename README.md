# Browser VM

A custom [Buildroot](https://buildroot.org/) config for a Linux x86 VM, meant to
be run in the browser as part of [browser-shell](https://github.com/humphd/browser-shell).
The resulting Linux ISO is meant to be run under
emulation in the browser via [v86](https://github.com/copy/v86), and includes:

* a custom Linux 4.15 kernel, which strips out many unnecessary drivers, modules, etc. and adds [Plan 9 filesystem](https://www.kernel.org/doc/Documentation/filesystems/9p.txt) sharing
* a root filesystem and Unix commands via [BusyBox](https://busybox.net/)
* an ISO-based bootloader (i.e., we create a "DVD" that is booted by v86)

Following the [Buildroot customization docs](https://buildroot.org/downloads/manual/manual.html#customize)
we create a folder `buildroot-v86/` with all the necessary config files,
filesystem overlay, and scripts necessary to build our distribution.

## Running via Docker

To build the Docker image use the `build.sh` script, or:

```bash
$ docker build -t buildroot .
```

And then to run the build:

```bash
$ docker run \
    --rm \
    --name build-v86 \
    -v $PWD/dist:/build \
    -v $PWD/buildroot-v86/:/buildroot-v86 \
    buildroot
```

NOTE: we define two [volumes](https://docs.docker.com/engine/reference/builder/#volume) to 
allow the container to access the v86 config, and also to write the ISO once complete.  In the
above I've used `$PWD`, but you can use any absolute path.

When the build completes, an ISO file will be places in `./dist/v86-linux.iso`
in your source tree (i.e., outside the container).

If you need to re-configure things, instead of just running the build, do the following:

```bash
$ docker run \
    --rm \
    --name build-v86 \
    -v $PWD/dist:/build \
    -v $PWD/buildroot-v86/:/buildroot-v86 \
    -ti \
    --entrypoint "bash" \
    buildroot
```

Now in the resulting bash terminal, you can run `make menuconfig` and [other make commands](https://buildroot.org/downloads/manual/manual.html#make-tips).

## `buildroot-v86/` Layout

We define a `v86` buildroot "board" via the following files and directories:

```
+-- board/
    +-- v86
        +-- linux.config        # our custom Linux kernel config (make linux-menuconfig)
        +-- post_build.sh       # script to copy ISO file out of docker container
        +-- rootfs_overlay/     # overrides for files in the root filesystem
            +-- etc/
                +-- inittab     # we setup a ttyS0 console terminal to auto-login
                +-- fstab       # we auto-mount the Plan 9 Filer filesystem to /mnt
    +-- configs/
        +-- v86_defconfig       # our custom buildroot config (make menuconfig)
    +-- Config.in               # empty, but required https://buildroot.org/downloads/manual/manual.html#outside-br-custom
    +-- external.mk             # empty, but required https://buildroot.org/downloads/manual/manual.html#outside-br-custom
    +-- external.desc           # our v86 board config for make
    +-- build-v86.sh            # entrypoint for Docker to run our build
```

If you need or want to update these config files, do the following:

```bash
$ make BR2_EXTERNAL=/buildroot-v86 v86_defconfig
$ make menuconfig
...
$ make savedefconfig
$ make linux-menuconfig
...
$ make linux-savedefconfig
```

## Configuration Notes

These are the options I set when configuring buildroot for v86.  I'm only
specifying the things I set.

```bash
$ cd buildroot-2018.02
$ make menucofing
```

Then follow these config steps in the buildroot config menu (NOTE: these docs
may have drifted from the actual config in the source, so consult that first):

### Target options

* Target Architecture: i386
* Target Architecture Variant: pentium mobile (Pentium with MMX, SSE)

### Build options

* Enable compiler cache (not strictly necessary, but helps with rebuilds)

### Toolchain

* C library: uLibc-ng (I'd like to experiment with musl too)

### System configuration

* remount root filesystem read-write during boot (I think this is unnecessary)
* Root filesystem overlay directories: /build/overlay-fs (for etc/inittab)

### Kernel

* Linux Kernel: true
* Defconfig name: i386
* Kernel binary format: bzImage (vmlinux seemed to break on boot)

### Target packages

Need to figure this out.  I tried adding imagemagik, git, uemacs, but they
are all adding too much size to the image.

### Filesystem images

* cpio the root filesystem (for use as an initial RAM filesystem)
* initial RAM filesystem linked into the linux kernel (not sure I need this, trying without...)
* iso image
    * Use initrd
* tar the root filesystem Compression method (no compression)

### Bootloaders

* syslinux
    * install isolinux

## Linux configuration

Now configure the Linux Kernel:

```
$ make linux-menuconfig
```

And set the following options to accomplish this:

```
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
CONFIG_PCI=y
CONFIG_VIRTIO_PCI=y
CONFIG_PCI=y
CONFIG_VIRTIO_PCI=y
```

# Processor type and features

* Processor family (Pentium-Pro) also tried Pentium M before. 

# Bus options (PCI, etc.)

* PCI Debugging: true (I want to see what's happening with PCI errors, normally not needed)

# Networking support

* Plan 9 Resource Sharing Support (9P2000) (built into kernel * vs. M)
    * 9P Virtio Transport (* - make this is on, it won't exist if virtio is off)
    * Debug information (* - optional)

# Device Drivers

* Virtio drivers
    * PCI driver for virtio devices (built into kernel * vs. M)
        * Support for legacy virtio draft 0.9.X and older devices (New)
    * Platform bus driver for memory mapped virtio devices (* vs. M) - not sure I need this...
        * Memory mapped virtio devices parameter parsing - or this...

# Filesystems

* Caches
    * General filesystem local caching manager (*)
        * Filesystem caching on files (*)

* Network File Systems
    * Plan 9 Resource Sharing Support (9P2000) (*)
        * Enable 9P client caching support
        * 9P Posic Access Control Lists

Now run `make`

When it finishes, the built image is in `./output/images`.
