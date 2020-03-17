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

# Proton Clang
CLANG_PATH="$TOOLCHAINS_PATH/proton-clang"

# arter97's GCC
GCC64_PATH="$TOOLCHAINS_PATH/aarch64-elf"
GCC32_PATH="$TOOLCHAINS_PATH/arm-eabi"

# Path to executables in Clang toolchain
CLANG_BIN="$CLANG_PATH/bin"

# 64-bit GCC toolchain prefix
GCC64_PREFIX="$GCC64_PATH/bin/aarch64-elf-"

# 32-bit GCC toolchain prefix
GCC32_PREFIX="$GCC32_PATH/bin/arm-eabi-"

# Setup variables
export LD_LIBRARY_PATH="$CLANG_BIN/../lib:$CLANG_BIN/../lib64:$LD_LIBRARY_PATH"
export PATH="$CLANG_BIN:$PATH"
export CROSS_COMPILE="$GCC64_PREFIX"
export CROSS_COMPILE_ARM32="$GCC32_PREFIX"
export CLANG_TRIPLE="aarch64-linux-gnu-"

# Setup Clang flags
CLANG_FLAGS="CC=clang AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip"

# Kernel Details
DEFCONFIG="dipper_user_defconfig"
VER="-MIUI+"

# Paths
KERNEL_DIR=`pwd`
AK_DIR="$KERNEL_DIR/anykernel"
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
    make O=out $CLANG_FLAGS $DEFCONFIG
    make O=out $CLANG_FLAGS savedefconfig
    make O=out $CLANG_FLAGS $THREAD
}

function make_zip {
    echo
    cd $AK_DIR

    cp -vr $ZIMAGE_DIR/Image.gz-dtb $AK_DIR/Image.gz-dtb

    AK_FULL_VER=$AK_VER-$(date +%F | sed s@-@@g)-dipper

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
