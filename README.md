# Embedded Linux for SAMA5D27-SOM1-EK

This is a simple script that installs all necessary programs in order to create a linux image for the [evaluation kit](https://www.microchip.com/Developmenttools/ProductDetails/ATSAMA5D27-SOM1-EK1).
The script was written on and for [Arch Linux](https://www.archlinux.org/).
It should also run under [Debian](https://www.debian.org/) and debian-based Distros but it's untested.

## Gettings started

Simply clone the repository

```
$ git clone https://github.com/schotter/embedded-on-sama5.git
```

enter the folder and run the script.

```
$ cd embedded-on-sama5
$ ./quickstart.sh
usage: ./quickstart.sh arm,musl,uclibc,qemu
```

Possible parameters are:

* Cortex-A5
  * [ARM](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-a/downloads) Toolchain
  * [musl](https://www.musl-libc.org/) Toolchain
  * [uclibc](https://uclibc-ng.org/) Toolchain
* Cortex-A9
  * QEMU ([vexpress-a9](https://wiki.qemu.org/Documentation/Platforms/ARM))

There is no support for Cortex-A5 in QEMU, therefore the slightly different Cortex-A9 is used in order to offer a virtual solution.

