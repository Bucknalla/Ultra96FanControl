sudo apt-get install qemu-user-static debootstrap binfmt-support
cd *.linux

OUTPUT=./rootfs

sudo debootstrap --arch=arm64 --foreign $DISTRO     $OUTPUT
sudo cp /usr/bin/qemu-aarch64-static                $OUTPUT/usr/bin
sudo cp /etc/resolv.conf                            $OUTPUT/etc
sudo cp ../debian10.sh  $OUTPUT
sudo cp linux-image-*-xlnx-v2018.3-zynqmp-fpga_*.deb $OUTPUT

chroot $OUTPUT /bin/bash -c "bash debian10.sh"
bash debian10.sh