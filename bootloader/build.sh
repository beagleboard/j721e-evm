#!/bin/bash

#add: bc bison flex libssl-dev u-boot-tools python3-pycryptodome python3-pyelftools
#binutils-arm-linux-gnueabihf binutils-aarch64-linux-gnu
#gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu

#https://git.ti.com/gitweb?p=k3-image-gen/k3-image-gen.git;a=summary
KIG_TAG=08.00.00.004
#https://git.ti.com/git/atf/arm-trusted-firmware.git
ATF_TAG=08.00.00.004
#https://github.com/OP-TEE/optee_os.git
TEE_TAG=3.14.0

time=$(date +%Y-%m-%d)

if [ -d ./k3-image-gen/ ] ; then
	rm -rf ./k3-image-gen/ || true
fi

if [ -d ./arm-trusted-firmware/ ] ; then
	rm -rf ./arm-trusted-firmware/ || true
fi

if [ -d ./optee_os/ ] ; then
	rm -rf ./optee_os/ || true
fi

git clone -b ${KIG_TAG} https://git.ti.com/git/k3-image-gen/k3-image-gen.git --depth=1
cd ./k3-image-gen/
make CROSS_COMPILE=arm-linux-gnueabihf-

if [ -f ./sysfw.itb ] ; then
	mkdir -p ../deploy/${time}/
	cp -v ./sysfw.itb ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

cd ../

###
#gedit /arago-tmp-external-arm-glibc/work/j7_evm-linux/trusted-firmware-a/2.5-r0/temp/log.do_compile
#make -j 9 V=1 BUILD_BASE=/home/voodoo/ti/08_00_00/tisdk/build/arago-tmp-external-arm-glibc/work/j7_evm-linux/trusted-firmware-a/2.5-r0/build PLAT=k3 TARGET_BOARD=generic SPD=opteed all
#
git clone -b ${ATF_TAG} https://git.ti.com/git/atf/arm-trusted-firmware.git --depth=1
cd ./arm-trusted-firmware/
make CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 PLAT=k3 TARGET_BOARD=generic SPD=opteed all

if [ -f ./build/k3/generic/release/bl31.bin ] ; then
	cp -v ./build/k3/generic/release/bl31.bin ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

cd ../

git clone -b ${TEE_TAG} https://github.com/OP-TEE/optee_os.git --depth=1
cd ./optee_os/
make PLATFORM=k3-j721e CFG_ARM64_core=y

if [ -f ./out/arm-plat-k3/core/tee-pager_v2.bin ] ; then
	cp -v ./out/arm-plat-k3/core/tee-pager_v2.bin ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

cd ../

