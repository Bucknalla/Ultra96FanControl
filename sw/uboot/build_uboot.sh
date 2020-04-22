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

export CROSS_COMPILE="/opt/Xilinx/SDK/$hsi_ver/gnu/aarch64/lin/aarch64-linux/bin/aarch64-linux-gnu-"


cd *.linux
git clone --depth=1 -b xilinx-v$hsi_ver https://github.com/Xilinx/u-boot-xlnx.git u-boot-xlnx-v$hsi_ver
cd u-boot-xlnx-v$hsi_ver
git checkout -b xilinx-v$hsi_ver-ultra96

# patch for ultra96
patch -p1 < ../../ultra.diff
git add arch/arm/dts/zynqmp-ultra96.dts
git add board/xilinx/zynqmp/zynqmp-ultra96/psu_init_gpl.c
git add board/xilinx/zynqmp/zynqmp-ultra96/psu_init_gpl.h
git add configs/xilinx_zynqmp_ultra96_defconfig
git add include/configs/xilinx_zynqmp_ultra96.h
git add --update
git commit -m "patch for Ultra96"
git tag -a xilinx-v$hsi_ver-ultra96-0 -m "release xilinx-v$hsi_ver-ultra96 release 0"

# patch for ultra96 bootmenu
patch -p1 < ../../ultra-bootmenu.diff
git add --update
git commit -m "[update] for boot menu command"
git tag -a xilinx-v$hsi_ver-ultra96-1 -m "release xilinx-v$hsi_ver-ultra96 release 1"

export ARCH=arm
make xilinx_zynqmp_ultra96_defconfig
make
cp u-boot.elf ../u-boot.elf

echo -e "\033[32mboot.elf generated.\033[39m"
