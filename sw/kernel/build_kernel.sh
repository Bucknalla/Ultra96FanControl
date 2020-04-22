#!/bin/bash

depends () {
	echo "Xilinx $1 must be installed and in your PATH"
	echo "try: source /opt/Xilinx/Vivado/201x.x/settings64.sh"
	exit 1
}

error () {
	echo "Cannot reach https://github.com/Xilinx/arm-trusted-firmware.git repo"
	exit 1
}


command -v xsdk >/dev/null 2>&1 || depends xsdk
command -v hsi >/dev/null 2>&1 || depends hsi

hsi_ver=$(hsi -version | head -1 | cut -d' ' -f2 | cut -c 2-)
if [ -z "$hsi_ver" ] ; then
	echo "Could not determine Vivado version"
	exit 1
fi

CURRENT_DIR=`pwd`
LINUX_BUILD_DIR=*.linux

cd *.linux
### Download Linux Kernel Source
git clone --depth 1 -b xilinx-v$hsi_ver https://github.com/Xilinx/linux-xlnx.git kernel
cd kernel
git checkout -b linux-xlnx-v$hsi_ver-zynqmp-fpga

### Patch for linux-xlnx-v2018.2-zynqmp-fpga
patch -p1 < ../../zynqmp-fpga.diff
git add --update
git add arch/arm64/boot/dts/xilinx/zynqmp-uz3eg-iocc.dts
git add arch/arm64/boot/dts/xilinx/zynqmp-ultra96.dts 
git commit -m "[patch] for linux-xlnx-v$hsi_ver-zynqmp-fpga."

### Patch for linux-xlnx-v2018.2-builddeb
patch -p1 < ../../builddeb.diff
git add --update
git commit -m "[fix] build wrong architecture debian package when ARCH=arm64 and cross compile."

### Patch for linux-xlnx-v2018.2-zynqmp-fpga-patch
### Not needed for 2018.3 (?)


# patch -p1 < ../../zynqmp-fpga-patch.diff
# git add --update
# git commit -m "[patch] drivers/fpga/zynqmp-fpga.c for load raw file format"

### Create tag and .version
git tag -a xilinx-v$hsi_ver-zynqmp-fpga -m "release xilinx-v$hsi_ver-zynqmp-fpga"
echo 0 > .version

### Setup for Build 
export ARCH=arm64
export export CROSS_COMPILE=aarch64-linux-gnu-
make xilinx_zynqmp_defconfig

### Build Linux Kernel and device tree
export DTC_FLAGS=--symbols
make deb-pkg

# #### Build kernel image and devicetree to target/UltraZed-EG-IOCC/boot/

# cp arch/arm64/boot/Image ../target/UltraZed-EG-IOCC/boot/image-4.14.0-xlnx-v2018.2-zynqmp-fpga
# cp arch/arm64/boot/dts/xilinx/zynqmp-uz3eg-iocc.dtb ../target/UltraZed-EG-IOCC/boot/devicetree-4.14.0-xlnx-v2018.2-zynqmp-fpga-uz3eg-iocc.dtb
# ./scripts/dtc/dtc -I dtb -O dts --symbols -o ../target/UltraZed-EG-IOCC/boot/devicetree-4.14.0-xlnx-v2018.2-zynqmp-fpga-uz3eg-iocc.dts ../target/UltraZed-EG-IOCC/boot/devicetree-4.14.0-xlnx-v2018.2-zynqmp-fpga-uz3eg-iocc.dtb

#### Build kernel image and devicetree to target/Ultra96/boot/

cp arch/arm64/boot/Image ../image-4.14.0-xlnx-v$hsi_ver-zynqmp-fpga
cp arch/arm64/boot/dts/xilinx/zynqmp-ultra96.dtb ../devicetree-4.14.0-xlnx-v$hsi_ver-zynqmp-fpga-ultra96.dtb
./scripts/dtc/dtc -I dtb -O dts --symbols -o ../devicetree-4.14.0-xlnx-v$hsi_ver-zynqmp-fpga-ultra96.dts ../devicetree-4.14.0-xlnx-v$hsi_ver-zynqmp-fpga-ultra96.dtb

echo -e "\033[32mKernel generated.\033[39m"

cd ..