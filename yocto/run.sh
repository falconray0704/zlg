#!/bin/bash

set -e
#set -x

. ../libShell/echo_color.lib
. ../libShell/sysEnv.lib

TARGET_YOCTO_DIR=/yocto

start_toaster_func()
{
    YOCTO_DIR=$1

    if [ -z ${YOCTO_DIR} ]
    then
        echoR "Yocto location must be passed from args."
        usage_func
        exit 1
    else
        echoY "Host's yocto dir is:${YOCTO_DIR}"
    fi

    docker run -it --rm -p 0.0.0.0:8000:8000 -v ${YOCTO_DIR}:${TARGET_YOCTO_DIR} -v $(realpath libShell):/libShell -v $(realpath ./scripts/launchToaster.sh):/launchToaster.sh --hostname toaster -u $(id -un) --workdir=/ zlg/yocto_x86_64:build1804
    #docker run -it --rm -p 0.0.0.0:8000:8000 -v ${YOCTO_DIR}:${TARGET_YOCTO_DIR} --hostname toaster -u $(id -un) --workdir=${TARGET_YOCTO_DIR} zlg/yocto_x86_64:build1804

}

usage_func()
{
    echoY "./run.sh <cmd> <target> [args...]"
    echo ""
    echoY "Supported cmd:"
    echo "[ start ]"
    echo ""
    echoY "Supported target:"
    echo "[ toasterEnv ]"
}

[ $# -lt 2 ] && echoR "Invalid args count:$# " && usage_func && exit 1

case $1 in
    start) echoY "Starting: $2 ..."
        if [ $2 == "toasterEnv" ]
        then
            start_toaster_func $3
        else
            echo "Unsupported target:$2 for start command."
        fi
        ;;
    *) echoR "Unsupported target:$1."
        usage_func
        exit 1
esac


exit 0

