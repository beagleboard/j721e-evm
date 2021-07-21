#!/bin/bash

#add: bc bison flex libssl-dev gcc-arm-linux-gnueabihf u-boot-tools python3-pycryptodome python3-pyelftools

#https://git.ti.com/gitweb?p=k3-image-gen/k3-image-gen.git;a=summary
KIG_TAG=08.00.00.003
#https://github.com/ARM-software/arm-trusted-firmware
ATF_TAG=master
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

git clone -b ${KIG_TAG} https://github.com/rcn-ee/k3-image-gen --depth=1
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

git clone -b ${ATF_TAG} https://github.com/ARM-software/arm-trusted-firmware.git --depth=1
cd ./arm-trusted-firmware/
make CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 PLAT=k3 TARGET_BOARD=generic SPD=opteed

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

