```
#!/bin/bash

release="08_00_00"

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

	./oe-layertool-setup.sh -f configs/processor-sdk-linux/processor-sdk-linux-08_00_00.txt

	echo "run------"
	echo "cd /home/voodoo/ti/${release}/tisdk/build/"
	echo ". conf/setenv"
	echo "export TOOLCHAIN_PATH_ARMV7=/home/voodoo/ti/${release}/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf"
	echo "export TOOLCHAIN_PATH_ARMV8=/home/voodoo/ti/${release}/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu"

	echo "MACHINE=j7-evm bitbake -k tisdk-default-image"
	echo "run------"
fi
```
