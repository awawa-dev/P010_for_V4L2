#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ $# -eq 0 ]
  then
  echo " Please enter any one of the following values and press Enter"
  echo "1 for Raspberry Pi OS"
  echo "2 for other Debian/Ubuntu x64 system"
  echo "Enter value:"
  read selectedOS
else
  selectedOS=$1
fi

echo "Selected option: $selectedOS"

(sudo apt-get update && apt-get install --no-install-recommends -y dkms build-essential bc wget ca-certificates) || exit 2

SCRIPT_PATH="https://raw.githubusercontent.com/awawa-dev/P010_for_V4L2/refs/heads/master"
sudo mkdir -p /usr/src/v4l2-p010-1.0
sudo wget $SCRIPT_PATH/dkms/p10_dkms.patch -O /usr/src/v4l2-p010-1.0/p10_dkms.patch
sudo wget $SCRIPT_PATH/dkms/dkms.conf -O /usr/src/v4l2-p010-1.0/dkms.conf
if [ "$selectedOS" -ne 2 ]
    then (echo "Building for RPi OS" && sudo wget $SCRIPT_PATH/dkms/dkms-patchmodule.sh -O /usr/src/v4l2-p010-1.0/dkms-patchmodule.sh && sudo chmod +x /usr/src/v4l2-p010-1.0/dkms-patchmodule.sh) || exit 2
    wget $SCRIPT_PATH/rpi-source/rpi-source -O /usr/local/bin/rpi-source && sudo chmod +x /usr/local/bin/rpi-source && /usr/local/bin/rpi-source -q --tag-update --processor 4
else
    (echo "Building for Debian/Ubuntu OS" && sudo wget $SCRIPT_PATH/dkms/dkms-patchmodule-pc.sh -O /usr/src/v4l2-p010-1.0/dkms-patchmodule.sh && sudo chmod +x /usr/src/v4l2-p010-1.0/dkms-patchmodule.sh) || exit 2
fi

sudo dkms add -m v4l2-p010 -v 1.0 || exit 2
sudo dkms install -m v4l2-p010/1.0
