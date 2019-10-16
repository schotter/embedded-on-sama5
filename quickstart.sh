#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "usage: $0 arm,musl,uclibc,qemu"
    exit 1
fi

if [ ! -f .packages_are_installed ]; then
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME

        case $OS in
            "Arch Linux")
                #sudo pacman -Syu
                sudo pacman -S mtools dosfstools lzop flex git base-devel bc rsync which sed make binutils bash patch gzip bzip2 perl tar cpio python unzip file qemu qemu-arch-extra
                ;;
            "Debian")
                sudo apt install which sed make binutils build-essential gcc g++ bash patch gzip bzip2 perl tar cpio python unzip rsync file bc wget qemu qemu-system-arm
                ;;
            *)
                exit 1
                ;;
        esac

    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        sudo apt install which sed make binutils build-essential gcc g++ bash patch gzip bzip2 perl tar cpio python unzip rsync file bc wget qemu qemu-system-arm

    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        sudo apt install which sed make binutils build-essential gcc g++ bash patch gzip bzip2 perl tar cpio python unzip rsync file bc wget qemu qemu-system-arm

    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=Debian
        sudo apt install which sed make binutils build-essential gcc g++ bash patch gzip bzip2 perl tar cpio python unzip rsync file bc wget qemu qemu-system-arm

    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s)
        exit 1
    fi
fi

touch .packages_are_installed

if [ ! -d "buildroot" ]; then
    git clone https://github.com/buildroot/buildroot.git
    cd buildroot
    git checkout 2019.08
    cd ..
fi

if [ ! -d "buildroot-external-microchip" ]; then
    git clone https://github.com/linux4sam/buildroot-external-microchip.git
    cd buildroot-external-microchip
    git checkout linux4sam_6.1
    cd ..
fi

read -p 'company name: ' companyname
COMPANYN=`echo $companyname | tr a-z A-Z`
company=`echo $companyname | tr A-Z a-z`
read -p 'board name: ' boardname
brdname=`echo $boardname | tr A-Z a-z`

mkdir -p buildroot-external-$company/board/$company/$brdname
mkdir buildroot-external-$company/configs
mkdir buildroot-external-$company/package
mkdir buildroot-external-$company/patches
touch buildroot-external-$company/Config.in
echo "include \$(sort \$(wildcard \$(BR2_EXTERNAL_"$COMPANYN"_PATH)/package/*/*.mk))" > buildroot-external-$company/external.mk
echo "name: $COMPANYN" > buildroot-external-$company/external.desc
echo "desc: $companyname's project tree" >> buildroot-external-$company/external.desc

cd buildroot-external-$company
make O=$(pwd) BR2_EXTERNAL=../buildroot-external-microchip:$(pwd) -C ../buildroot
make clean

case $1 in
    "arm")
        cp ../.cfgs/arm.config .config
        ;;
    "musl")
        cp ../.cfgs/musl.config .config
        ;;
    "uclibc")
        cp ../.cfgs/uclibc.config .config
        ;;
    "qemu")
        make qemu_arm_vexpress_defconfig
	sed -i -e 's/# BR2_PACKAGE_OPENSSH is not set/BR2_PACKAGE_OPENSSH=y/g' .config
        echo '#!/bin/sh

qemu-system-arm \
        -M vexpress-a9 \
        -kernel images/zImage \
        -dtb images/vexpress-v2p-ca9.dtb \
        -drive file=images/rootfs.ext2,if=sd,format=raw \
        -append "rw console=ttyAMA0 console=tty root=/dev/mmcblk0" \
        -cpu cortex-a9 \
        -m 32 \
        -serial stdio \
        -nic user,hostfwd=tcp::222-:22,hostfwd=tcp::2459-:2459 \
        -name VexpressCortexA9
' > qemu.sh
        chmod +x qemu.sh
        ;;
esac

echo "change into the folder buildroot-external-$company and"
echo "start the build process by running 'make'."

