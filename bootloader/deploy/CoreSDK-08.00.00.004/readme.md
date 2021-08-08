```
#!/bin/bash

release="CoreSDK-08.00.00.004"

mkdir -p /home/voodoo/ti/${release}/

if [ -d /home/voodoo/ti/${release}/tisdk ] ; then
	rm -rf /home/voodoo/ti/${release}/tisdk/ || true
fi

cd /home/voodoo/ti/${release}/

rm -rf gcc-arm-* || true

cp -v /mnt/ti-processor-sdk/${release}/gcc-*.tar.xz /home/voodoo/ti/${release}/

pv gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz | tar -xJ
pv gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz | tar -xJ

export TOOLCHAIN_PATH_ARMV7=/home/voodoo/ti/${release}/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf
export TOOLCHAIN_PATH_ARMV8=/home/voodoo/ti/${release}/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu

${TOOLCHAIN_PATH_ARMV7}/bin/arm-none-linux-gnueabihf-gcc -v
${TOOLCHAIN_PATH_ARMV8}/bin/aarch64-none-linux-gnu-gcc -v

git clone git://git.ti.com/arago-project/oe-layersetup.git tisdk

if [ -d /home/voodoo/ti/${release}/tisdk/ ] ; then
	cd /home/voodoo/ti/${release}/tisdk/

	./oe-layertool-setup.sh -f configs/coresdk/coresdk-08.00.00.004-config.txt

	if [ -d /mnt/ti-processor-sdk/${release}/downloads/ ] ; then
		mkdir -p /home/voodoo/ti/${release}/tisdk/downloads
		rsync -av /mnt/ti-processor-sdk/${release}/downloads/ /home/voodoo/ti/${release}/tisdk/downloads/
	fi

	echo "run------"
	echo "cd /home/voodoo/ti/${release}/tisdk/build/"
	echo ". conf/setenv"
	echo "export TOOLCHAIN_PATH_ARMV7=/home/voodoo/ti/${release}/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf"
	echo "export TOOLCHAIN_PATH_ARMV8=/home/voodoo/ti/${release}/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu"

	echo "MACHINE=j7-evm bitbake -k tisdk-default-image"
	echo "run------"
	echo "rsync -av /home/voodoo/ti/${release}/tisdk/downloads/ /mnt/ti-processor-sdk/${release}/downloads/"
	echo "rsync -av --exclude=.git /home/voodoo/ti/${release}/tisdk/sources/ /mnt/ti-processor-sdk/${release}/sources/"
	echo "rsync -av /home/voodoo/ti/${release}/tisdk/build/arago-tmp-external-arm-glibc/deploy/ /mnt/ti-processor-sdk/${release}/deploy/"
	echo "rsync -av /home/voodoo/ti/${release}/tisdk/build/arago-tmp-external-arm-glibc/sysroots-components/j7_evm/ti-rtos-firmware/lib/firmware /mnt/ti-processor-sdk/${release}/firmware/"
	echo "run------"
fi
```
