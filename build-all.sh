#!/bin/sh

./build.sh arm
./build.sh x86
# disabled mips cause for some reason all dynamic libraries are actually compiled as static-pie instead of dynamic which causes gcc to fail?
# ./build.sh mips
