#!/bin/bash

if dpkg -s raspberrypi-bootloader &>/dev/null; then
  echo "Please uninstall raspberrypi-bootloader package. Kernel changelog can be already damaged."
  exit 2
fi

/usr/local/bin/rpi-source -q --download-only --processor 4 --default-config --skip-update --dest .

echo "Extracting original source"
tar --wildcards --one-top-level=src --strip-components 1 -xf linux-*.tar.* linux-*/drivers/media/common linux-*/drivers/media/usb/uvc

# The new module version should be increased to allow the new module to be
# installed during kernel upgrade
echo "Increase module version"
sed -i 's/MODULE_VERSION(DRIVER_VERSION)/MODULE_VERSION("999")/g' src/drivers/media/usb/uvc/uvc_driver.c
echo 'MODULE_VERSION("999");' >> src/drivers/media/common/uvc.c

cd src
for i in `ls ../*.patch`
do
  echo "Applying $i"
  patch -p1 < $i
done
