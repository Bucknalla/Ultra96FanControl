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
command -v bootgen >/dev/null 2>&1 || depends bootgen
command -v hsi >/dev/null 2>&1 || depends hsi

hsi_ver=$(hsi -version | head -1 | cut -d' ' -f2 | cut -c 2-)
if [ -z "$hsi_ver" ] ; then
	echo "Could not determine Vivado version"
	exit 1
fi
atf_version=xilinx-v$hsi_ver

export CROSS_COMPILE="/opt/Xilinx/SDK/$hsi_ver/gnu/aarch64/lin/aarch64-linux/bin/aarch64-linux-gnu-"


cd *.linux
git clone https://github.com/Xilinx/arm-trusted-firmware.git -b $atf_version >/dev/null 2>&1 || error
cd arm-trusted-firmware
make distclean
make CROSS_COMPILE=aarch64-linux-gnu- PLAT=zynqmp RESET_TO_BL31=1
cp build/zynqmp/release/bl31/bl31.elf ../bl31.elf
echo -e "\033[32mARM Trusted Firmware generated.\033[39m"
