#!/bin/sh
cd /tmp
sudo apt install -y git bc bison flex libssl-dev bc make
sudo wget https://github.com/raspberrypi/linux/archive/refs/tags/stable_20241008.zip -O rpi-source && unzip ./rpi-source
cd linux-stable_20241008
cp /boot/config-$(uname -r) .config
yes "" | make oldconfig scripts prepare modules_prepare
wget https://raw.githubusercontent.com/awawa-dev/P010_for_V4L2/refs/heads/master/p010.patch
patch -p0 < ./p010.patch
sudo apt install linux-headers-$(uname -r)
cp /usr/src/linux-headers-$(uname -r)/Module.symvers .
make -j $(nproc) M=drivers/media/usb/uvc modules
sudo make -j $(nproc) M=drivers/media/usb/uvc modules_install
make -j $(nproc) M=drivers/media/common modules
sudo make -j $(nproc) M=drivers/media/common modules_install
sudo cp /lib/modules/6.6.51-v8/updates/uvcvideo.ko.xz /lib/modules/6.6.51+rpt-rpi-v8/kernel/drivers/media/usb/uvc/uvcvideo.ko.xz
sudo cp /lib/modules/6.6.51-v8/updates/uvc.ko.xz /lib/modules/6.6.51+rpt-rpi-v8/kernel/drivers/media/common/uvc.ko.xz
sudo depmod
sudo apt remove -y git bc bison flex libssl-dev bc make