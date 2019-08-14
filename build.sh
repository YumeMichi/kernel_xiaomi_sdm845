#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(nproc)"
export CROSS_COMPILE=$HOME/Workspace/toolchains/aarch64-elf-gcc/bin/aarch64-elf-

# Kernel Details
DEFCONFIG="polar_defconfig"
VER="-R25"

# Paths
KERNEL_DIR=`pwd`
AK_DIR="$HOME/Workspace/AnyKernel3"
ZIP_MOVE="$HOME/Workspace/AK-releases"
ZIMAGE_DIR="$KERNEL_DIR/out/arch/arm64/boot"

# Functions
function clean_all {
    echo
    cd $KERNEL_DIR
    git clean -fdx > /dev/null 2>&1
}

function make_kernel {
    echo
    make O=out $DEFCONFIG
    make O=out $THREAD
}

function make_zip {
    echo
    cd $AK_DIR

    git reset --hard > /dev/null 2>&1
    git clean -fdx > /dev/null 2>&1
    git checkout EAS

    mkdir -p {kernel,dtbs}
    cp -vr $ZIMAGE_DIR/Image.gz $AK_DIR/kernel/Image.gz
    find $ZIMAGE_DIR -name '*.dtb' -exec cp {} dtbs/ \;

    AK_FULL_VER=$AK_VER-Xiaomi-SDM845-$(date +%F | sed s@-@@g)

    zip -r9 $AK_FULL_VER.zip *
    mv $AK_FULL_VER.zip $ZIP_MOVE

    cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

echo -e "${green}"
echo "-----------------"
echo "Making Kernel:"
echo "-----------------"
echo -e "${restore}"

# Vars
BASE_AK_VER="PolarKernel"
AK_VER="$BASE_AK_VER$VER"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=YumeMichi
export KBUILD_BUILD_HOST=Ref:rain

echo

while read -p "Clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
    y|Y )
        clean_all
        echo
        echo "All Cleaned now."
        break
        ;;
    n|N )
        break
        ;;
    * )
        echo
        echo "Invalid try again!"
        echo
        ;;
esac
done

echo

while read -p "Start building (y/n)? " dchoice
do
case "$dchoice" in
    y|Y )
        make_kernel
        make_zip
        break
        ;;
    n|N )
        echo
	echo "Abort!"
	echo
        break
        ;;
    * )
        echo
        echo "Invalid try again!"
        echo
        ;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
