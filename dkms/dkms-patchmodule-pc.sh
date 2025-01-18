#!/bin/bash
# https://www.collabora.com/news-and-blog/blog/2021/05/05/quick-hack-patching-kernel-module-using-dkms/

if [ -z "$kernelver" ] ; then
  echo "using DPKG_MAINTSCRIPT_PACKAGE instead of unset kernelver"
  kernelver=$( echo $DPKG_MAINTSCRIPT_PACKAGE | sed -r 's/linux-(headers|image)-//')
fi

vers=(${kernelver//./ })   # split kernel version into individual elements
major="${vers[0]}"
minor="${vers[1]}"
version="$major.$minor"    # recombine as needed
# In Debian (and some Debian derivatives), the linux headers are split in
# two packages: an arch-specific and an arch-independent package.
# For example: linux-headers-6.1.0-6-amd64 and linux-headers-6.1.0-6-common.
# The arch-specific Makefile is just a one-line include directive.
makefile=/usr/src/linux-headers-${kernelver}/Makefile
if [ $(wc -l < $makefile) -eq 1 ] && grep -q "^include " $makefile ; then
  makefile=$(tr -s " " < $makefile | cut -d " " -f 2)
fi
subver=$(grep "SUBLEVEL =" $makefile | tr -d " " | cut -d "=" -f 2)

echo "Downloading kernel source $version.$subver for $kernelver"
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v$major.x/linux-$version.$subver.tar.xz

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
