cd *.linux
bootgen -arch zynqmp -image ../boot.bif -w -o boot.bin
echo -e "\033[32mboot.bin generated.\033[39m"
cd ..