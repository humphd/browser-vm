# Browser VM

A custom [Buildroot](https://buildroot.org/) config for [now](https://github.com/cemalgnlts/now).

* a custom Linux 4.15 kernel, which strips out many unnecessary drivers, modules, etc. and adds [Plan 9 filesystem](https://www.kernel.org/doc/Documentation/filesystems/9p.txt) sharing
* a root filesystem and Unix commands via [BusyBox](https://busybox.net/)
* an ISO-based bootloader (i.e., we create a "DVD" that is booted by v86)

## Running via Docker

To build the Docker image use the `build.sh` script:

```bash
./build
```

When it finishes, the built image is in `./output/images`.
