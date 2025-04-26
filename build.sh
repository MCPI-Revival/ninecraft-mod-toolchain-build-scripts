#!/bin/sh

cd "$(dirname "$0")"

set -e

CHOSEN_GCC_VERSION="13.3.0"
CHOSEN_BINUTILS_VERSION="2.40"

if [ "$1" = "arm" ]; then
    CROSS_TARGET="arm-linux-androideabi"
    CROSS_SYSROOT="arch-arm"
    EXTRA_GCC_CONFIG="--with-arch=armv7-a --with-float=softfp --with-fpu=vfpv3-d16"
elif [ "$1" = "x86" ]; then
    CROSS_TARGET="i686-linux-android"
    CROSS_SYSROOT="arch-x86"
    EXTRA_GCC_CONFIG="--with-arch=i686 --with-tune=generic"
elif [ "$1" = "mips" ]; then
    CROSS_TARGET="mips-linux-android"
    CROSS_SYSROOT="arch-mips"
    EXTRA_GCC_CONFIG="--with-arch=mips32 --with-abi=32 --with-float=hard --with-tune=mips32"
else
    echo "Unknown architecture"
    exit 1
fi

if [ ! -d "binutils-$CHOSEN_BINUTILS_VERSION" ]; then
    wget https://ftp.gnu.org/gnu/binutils/binutils-$CHOSEN_BINUTILS_VERSION.tar.xz
    tar xvf binutils-$CHOSEN_BINUTILS_VERSION.tar.xz
fi

if [ ! -d "gcc-$CHOSEN_GCC_VERSION" ]; then
    wget https://ftp.gnu.org/gnu/gcc/gcc-$CHOSEN_GCC_VERSION/gcc-$CHOSEN_GCC_VERSION.tar.gz
    tar xvf gcc-$CHOSEN_GCC_VERSION.tar.gz
    cd gcc-$CHOSEN_GCC_VERSION
    ./contrib/download_prerequisites
    cd ..
fi

mkdir -p toolchain-$CROSS_TARGET
mkdir -p build-binutils-$CHOSEN_BINUTILS_VERSION-$CROSS_TARGET
mkdir -p build-gcc-$CHOSEN_GCC_VERSION-$CROSS_TARGET

cd build-binutils-$CHOSEN_BINUTILS_VERSION-$CROSS_TARGET

../binutils-$CHOSEN_BINUTILS_VERSION/configure \
    --target=$CROSS_TARGET \
    --prefix="$(pwd)/../toolchain-$CROSS_TARGET" \
    --with-sysroot="$(pwd)/../sysroot/$CROSS_SYSROOT" \
    --disable-nls \
    --disable-werror \
    --disable-doc

make -j$(nproc)
make install

cd ../build-gcc-$CHOSEN_GCC_VERSION-$CROSS_TARGET

../gcc-$CHOSEN_GCC_VERSION/configure \
    --target=$CROSS_TARGET \
    --prefix="$(pwd)/../toolchain-$CROSS_TARGET" \
    --with-sysroot="$(pwd)/../sysroot/$CROSS_SYSROOT" \
    --enable-languages=c,c++ \
    --disable-multilib \
    --disable-nls \
    --disable-libssp \
    --disable-libquadmath \
    --disable-libgomp \
    --disable-libmudflap \
    --enable-lto \
    --enable-shared \
    --enable-threads \
    --disable-doc \
    --disable-libsanitizer \
    $EXTRA_GCC_CONFIG

make -j$(nproc)
make install

cd ..

./setup_wrappers.sh "$1" "$CROSS_TARGET"
