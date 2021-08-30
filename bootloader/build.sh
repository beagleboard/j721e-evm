#!/bin/bash

#add: bc bison flex libssl-dev u-boot-tools python3-pycryptodome python3-pyelftools
#binutils-arm-linux-gnueabihf binutils-aarch64-linux-gnu
#gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu

#https://git.ti.com/gitweb?p=processor-firmware/ti-linux-firmware.git;a=summary
TIFIRM_TAG=08.00.00.004
#https://git.ti.com/gitweb?p=k3-image-gen/k3-image-gen.git;a=summary
KIG_TAG=08.00.00.004
#https://git.ti.com/git/atf/arm-trusted-firmware.git
ATF_TAG=08.00.00.004
#https://github.com/OP-TEE/optee_os.git
TEE_TAG=3.14.0
#https://git.ti.com/gitweb?p=ti-u-boot/ti-u-boot.git;a=summary
UBOOT_TAG=08.00.00.004

time=$(date +%Y-%m-%d)

if [ -d ./ti-linux-firmware/ ] ; then
	rm -rf ./ti-linux-firmware/ || true
fi

if [ -d ./k3-image-gen/ ] ; then
	rm -rf ./k3-image-gen/ || true
fi

if [ -d ./arm-trusted-firmware/ ] ; then
	rm -rf ./arm-trusted-firmware/ || true
fi

if [ -d ./optee_os/ ] ; then
	rm -rf ./optee_os/ || true
fi

if [ -d ./ti-u-boot/ ] ; then
	rm -rf ./ti-u-boot/ || true
fi

git clone -b ${TIFIRM_TAG} https://git.ti.com/git/processor-firmware/ti-linux-firmware.git --depth=1
cd ./ti-linux-firmware/
if [ -f ./ti-dm/j721e/ipc_echo_testb_mcu1_0_release_strip.xer5f ] ; then
	mkdir -p ../deploy/${time}/
	echo "*******************************************************************************"
	cp -v ./ti-dm/j721e/ipc_echo_testb_mcu1_0_release_strip.xer5f ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

cd ../
echo "*******************************************************************************"

git clone -b ${KIG_TAG} https://git.ti.com/git/k3-image-gen/k3-image-gen.git --depth=1
cd ./k3-image-gen/
echo "make -j2 CROSS_COMPILE=arm-linux-gnueabihf-"
make -j2 CROSS_COMPILE=arm-linux-gnueabihf-

if [ -f ./sysfw.itb ] ; then
	echo "*******************************************************************************"
	cp -v ./sysfw.itb ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

cd ../
echo "*******************************************************************************"

###
#gedit /arago-tmp-external-arm-glibc/work/j7_evm-linux/trusted-firmware-a/2.5-r0/temp/log.do_compile
#make -j 9 V=1 BUILD_BASE=/home/voodoo/ti/08_00_00/tisdk/build/arago-tmp-external-arm-glibc/work/j7_evm-linux/trusted-firmware-a/2.5-r0/build PLAT=k3 TARGET_BOARD=generic SPD=opteed all
#
git clone -b ${ATF_TAG} https://git.ti.com/git/atf/arm-trusted-firmware.git --depth=1
cd ./arm-trusted-firmware/
echo "make -j2 CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 PLAT=k3 TARGET_BOARD=generic SPD=opteed all"
make -j2 CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 PLAT=k3 TARGET_BOARD=generic SPD=opteed all

if [ -f ./build/k3/generic/release/bl31.bin ] ; then
	echo "*******************************************************************************"
	cp -v ./build/k3/generic/release/bl31.bin ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

cd ../
echo "*******************************************************************************"

#https://git.ti.com/gitweb?p=arago-project/meta-ti.git;a=blob;f=conf/machine/include/j7.inc;hb=HEAD
#https://git.ti.com/gitweb?p=arago-project/meta-ti.git;a=blob;f=recipes-security/optee/optee-os_%25.bbappend;hb=HEAD
git clone -b ${TEE_TAG} https://github.com/OP-TEE/optee_os.git --depth=1
cd ./optee_os/
echo "make -j2 PLATFORM=k3-j721e CFG_ARM64_core=y"
make -j2 PLATFORM=k3-j721e CFG_ARM64_core=y

if [ -f ./out/arm-plat-k3/core/tee-pager_v2.bin ] ; then
	echo "*******************************************************************************"
	cp -v ./out/arm-plat-k3/core/tee-pager_v2.bin ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

cd ../
echo "*******************************************************************************"

git clone -b ${UBOOT_TAG} https://git.ti.com/git/ti-u-boot/ti-u-boot.git --depth=1
cd ./ti-u-boot/
echo "make CROSS_COMPILE=arm-linux-gnueabihf- j721e_evm_r5_defconfig O=/tmp/r5"
make CROSS_COMPILE=arm-linux-gnueabihf- j721e_evm_r5_defconfig O=/tmp/r5
echo "make -j2 CROSS_COMPILE=arm-linux-gnueabihf- O=/tmp/r5"
make -j2 CROSS_COMPILE=arm-linux-gnueabihf- O=/tmp/r5

if [ -f /tmp/r5/tiboot3.bin ] ; then
	echo "*******************************************************************************"
	cp -v /tmp/r5/tiboot3.bin ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

echo "make CROSS_COMPILE=aarch64-linux-gnu- j721e_evm_a72_defconfig O=/tmp/a72"
make CROSS_COMPILE=aarch64-linux-gnu- j721e_evm_a72_defconfig O=/tmp/a72
cp -v ../deploy/${time}/bl31.bin /tmp/a72
cp -v ../deploy/${time}/tee-pager_v2.bin /tmp/a72
cp -v ../deploy/${time}/ipc_echo_testb_mcu1_0_release_strip.xer5f /tmp/a72
echo "make -j2 CROSS_COMPILE=aarch64-linux-gnu- ATF=/tmp/a72/bl31.bin TEE=/tmp/a72/tee-pager_v2.bin DM=/tmp/a72/ipc_echo_testb_mcu1_0_release_strip.xer5f O=/tmp/a72"
make -j2 CROSS_COMPILE=aarch64-linux-gnu- ATF=/tmp/a72/bl31.bin TEE=/tmp/a72/tee-pager_v2.bin DM=/tmp/a72/ipc_echo_testb_mcu1_0_release_strip.xer5f O=/tmp/a72

if [ -f /tmp/a72/tispl.bin ] ; then
	echo "*******************************************************************************"
	cp -v /tmp/a72/tispl.bin ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

if [ -f /tmp/a72/u-boot.img ] ; then
	cp -v /tmp/a72/u-boot.img ../deploy/${time}/
else
	echo "failure"
	exit 2
fi

