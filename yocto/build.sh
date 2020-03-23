#!/bin/bash

set -e
#set -x

. ../libShell/echo_color.lib
. ../libShell/sysEnv.lib

BUILD_CONTEXT_DIR="./dockerContext"

build_img_a9_func()
{
    TARGET=$1
    TARGET_VER=$2
    ARCH=$(arch)

    cp ./Dockerfile_${TARGET}${TARGET_VER}_a9.img ./Dockerfile_${TARGET}${TARGET_VER}_a9.img.${ARCH} 

    if [ ${TARGET} == build ]; then
        sed -i "s/yocto_arch/yocto_${ARCH}/" ./Dockerfile_${TARGET}${TARGET_VER}_a9.img.${ARCH}
    else
            echoR "Unsupport target:${TARGET} for image building."
            exit 1
    fi

    docker build --rm -t zlg/yocto_a9_${ARCH}:${TARGET}${TARGET_VER} \
        --build-arg "group=$(id -gn)" \
        --build-arg "gid=$(id -u)" \
        --build-arg "user=$(id -un)" \
        --build-arg	"uid=$(id -g)" \
        -f ./Dockerfile_${TARGET}${TARGET_VER}_a9.img.${ARCH} ${BUILD_CONTEXT_DIR}
}

build_img_ti_func()
{
    TARGET=$1
    TARGET_VER=$2
    ARCH=$(arch)

    cp ./Dockerfile_${TARGET}${TARGET_VER}_ti.img ./Dockerfile_${TARGET}${TARGET_VER}_ti.img.${ARCH} 

    if [ ${TARGET} == build ]; then
        sed -i "s/yocto_arch/yocto_${ARCH}/" ./Dockerfile_${TARGET}${TARGET_VER}_ti.img.${ARCH}
    else
            echoR "Unsupport target:${TARGET} for image building."
            exit 1
    fi

    docker build --rm -t zlg/yocto_ti_${ARCH}:${TARGET}${TARGET_VER} \
        --build-arg "group=$(id -gn)" \
        --build-arg "gid=$(id -u)" \
        --build-arg "user=$(id -un)" \
        --build-arg	"uid=$(id -g)" \
        -f ./Dockerfile_${TARGET}${TARGET_VER}_ti.img.${ARCH} ${BUILD_CONTEXT_DIR}
}

build_img_func()
{
    TARGET=$1
    TARGET_VER=$2
    ARCH=$(arch)

    cp ./Dockerfile_${TARGET}${TARGET_VER}.img ./Dockerfile_${TARGET}${TARGET_VER}.img.${ARCH} 

    if [ ${TARGET} == basic ]; then
        sed -i "s/ubt${TARGET_VER}/ubt${TARGET_VER}_${ARCH}/" ./Dockerfile_${TARGET}${TARGET_VER}.img.${ARCH}
    elif [ ${TARGET} == build ]; then
        sed -i "s/yocto/yocto_${ARCH}/" ./Dockerfile_${TARGET}${TARGET_VER}.img.${ARCH}
    else
        echoR "Unsupport target:${TARGET} for image building."
        exit 1
    fi

    docker build --rm -t zlg/yocto_${ARCH}:${TARGET}${TARGET_VER} \
        --build-arg "group=$(id -gn)" \
        --build-arg "gid=$(id -u)" \
        --build-arg "user=$(id -un)" \
        --build-arg	"uid=$(id -g)" \
        -f ./Dockerfile_${TARGET}${TARGET_VER}.img.${ARCH} ${BUILD_CONTEXT_DIR}
}

build_target_func()
{
    TARGET=$1
    TARGET_VER=$2
    case $2 in
        1404|1604|1804)
        do_clean_img_func ${TARGET} ${TARGET_VER}
        build_img_func ${TARGET} ${TARGET_VER}
        ;;
        1804ti)
        TARGET_VER=1804
        do_clean_img_ti_func ${TARGET} ${TARGET_VER}
        BUILD_CONTEXT_DIR="./dockerContext_ti"
        mkdir -p ${BUILD_CONTEXT_DIR}
        download_resource_ti_func
        build_img_ti_func ${TARGET} ${TARGET_VER}
        ;;
        1804a9)
        TARGET_VER=1804
        do_clean_img_a9_func ${TARGET} ${TARGET_VER}
        BUILD_CONTEXT_DIR="./dockerContext_a9"
        mkdir -p ${BUILD_CONTEXT_DIR}
        download_resource_a9_func
        build_img_a9_func ${TARGET} ${TARGET_VER}
        ;;
        *) echoR "Unsupported version:$2."
        exit 1
    esac
}

do_clean_img_a9_func()
{
    TARGET=$1
    TARGET_VER=$2
    ARCH=$(arch)
	docker rmi -f zlg/yocto_a9_${ARCH}:${TARGET}${TARGET_VER}
	docker image prune
}

do_clean_img_ti_func()
{
    TARGET=$1
    TARGET_VER=$2
    ARCH=$(arch)
	docker rmi -f zlg/yocto_ti_${ARCH}:${TARGET}${TARGET_VER}
	docker image prune
}

do_clean_img_func()
{
    TARGET=$1
    TARGET_VER=$2
    ARCH=$(arch)
	docker rmi -f zlg/yocto_${ARCH}:${TARGET}${TARGET_VER}
	docker image prune
}

download_resource_a9_func()
{
    pushd ${BUILD_CONTEXT_DIR}

    # download reop
    if [ -e ./repo ]; then
        echoG "repo is ready!"
    else
        echoY "repo is downloading......"
        curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ./repo
    fi

    popd

}

download_resource_ti_func()
{
    pushd ${BUILD_CONTEXT_DIR}

    # download reop
    if [ -e ./repo ]; then
        echoG "repo is ready!"
    else
        echoY "repo is downloading......"
        curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ./repo
    fi

        

    # download cross gcc
    if [ -e gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz ]; then
        echoG "gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz is ready!"
    else
        echoY "gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz is downloading......"
        wget -c https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz ./
    fi
    if [ -e gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz ]; then
        echoG "gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz is ready!"
    else
        echoY "gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz is downloading......"
        wget -c https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz ./
    fi

    if [ -e gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf.tar.xz ]; then
        echoG "gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf.tar.xz is ready!"
    else
        echoY "gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf.tar.xz is downloading......"
        wget -c https://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/arm-linux-gnueabihf/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf.tar.xz ./
    fi
    if [ -e gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz ]; then
        echoG "gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz is ready!"
    else
        echoY "gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz is downloading......"
        wget -c https://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/aarch64-linux-gnu/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz ./
    fi

    popd

}

ARCH=$(arch)

usage_func()
{
    echoY "./build.sh <target> <target version>"
    echo ""
    echoY "Supported target:"
    echo "[ basic, build ]"
    echo ""
    echoY "Supported target version:"
    echo "[ 1804, 1804ti, 1804a9 ]"

    echoY "Images usage:"
    echo 'docker run --rm -it -v  /<source path on host>/tisdk:/<mapping path in docker container>/tisdk --workdir=/<mapping path in docker container>/tisdk --hostname "ti" -u $(id -un) zlg/yocto_ti_x86_64:build1804'
    
}

[ $# -lt 2 ] && echoR "Invalid args count:$# " && usage_func && exit 1

case $1 in
    basic|build) echoY "Building image zlg/yocto_${ARCH}:$1$2 ..."
        build_target_func $1 $2
        ;;
    cleanBasic) echoY "Removing image zlg/yocto_${ARCH}:basic$2 ..."
        do_clean_img_func basic $2
        ;;
    cleanBuild) echoY "Removing image zlg/yocto_${ARCH}:build$2 ..."
        do_clean_img_func build $2
        ;;
    test)
        echoY "Testing..."
        BUILD_CONTEXT_DIR="./dockerContext_ti"
        mkdir -p ${BUILD_CONTEXT_DIR}
        download_resource_ti_func
        ;;
    *) echoR "Unsupported target:$1."
        usage_func
        exit 1
esac


exit 0

