#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Number of parallel jobs to run
THREAD="-j$(nproc)"

# Toolchains
TOOLCHAINS_PATH="$HOME/Workspace/toolchains"

# arter97's GCC
GCC64_PATH="$TOOLCHAINS_PATH/aarch64-elf"
GCC32_PATH="$TOOLCHAINS_PATH/arm-eabi"

# 64-bit GCC toolchain prefix
GCC64_PREFIX="$GCC64_PATH/bin/aarch64-elf-"

# 32-bit GCC toolchain prefix
GCC32_PREFIX="$GCC32_PATH/bin/arm-eabi-"

# Setup variables
export CROSS_COMPILE="$GCC64_PREFIX"
export CROSS_COMPILE_ARM32="$GCC32_PREFIX"

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
    make O=out $1_defconfig
    make O=out savedefconfig
    make O=out $THREAD
}

function make_zip {
    echo
    cd $AK_DIR

    git reset --hard > /dev/null 2>&1
    git clean -fdx > /dev/null 2>&1
    git checkout stock

    cp -vr $ZIMAGE_DIR/Image.gz-dtb $AK_DIR/Image.gz-dtb

    AK_FULL_VER=$AK_VER-$(date +%F | sed s@-@@g)-$1-YumeMichi

    zip -r9 $AK_FULL_VER.zip *
    mv $AK_FULL_VER.zip $ZIP_MOVE

    cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

# Vars
BASE_AK_VER="PolarKernel"
AK_VER="$BASE_AK_VER$VER"
export LOCALVERSION=`echo $VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=violet
export KBUILD_BUILD_HOST=Evergarden

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

clear

echo -e "${green}"
echo "-----------------"
echo "Target list:"
echo "-----------------"
echo "1. Xiaomi MI 8 (dipper)"
echo "2. Xiaomi MI 8 UD (equuleus)"
echo "3. Xiaomi MI 8 EE (ursa)"
echo "4. Xiaomi MIX 2S (polaris)"
echo "5. Xiaomi Poco F1 (beryllium)"
echo "6. Xiaomi MIX 3 (perseus)"
echo -e "${restore}"

echo

while read -p "Select target to build: " dchoice
do
case "$dchoice" in
    1 )
        make_kernel dipper
        make_zip dipper
        break
        ;;
    2 )
        make_kernel equuleus
        make_zip equuleus
        break
        ;;
    3 )
        make_kernel ursa
        make_zip ursa
        break
        ;;
    4 )
        make_kernel polaris
        make_zip polaris
        break
        ;;
    5 )
        make_kernel beryllium
        make_zip beryllium
        break
        ;;
    6 )
        make_kernel perseus
        make_zip perseus
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
