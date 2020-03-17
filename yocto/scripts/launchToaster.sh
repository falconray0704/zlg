#!/bin/bash

set -e
#set -x

. ./libShell/echo_color.lib
. ./libShell/sysEnv.lib

YOCTO_DIR=/yocto
POKY_DIR=${YOCTO_DIR}

start_toaster_func()
{
    #pip3 install --user -r /yocto/poky/bitbake/toaster-requirements.txt
    pip3 install --user -r ${POKY_DIR}/bitbake/toaster-requirements.txt

    pushd ${YOCTO_DIR}
    source oe-init-build-env
#    source toaster start
    source toaster start webport=0.0.0.0:8000
    popd

}

stop_toaster_func()
{
    pushd ${YOCTO_DIR}
    source oe-init-build-env
    source toaster stop 
    popd
}

usage_func()
{
    echoY "./run.sh <cmd> <target> [args...]"
    echo ""
    echoY "Supported cmd:"
    echo "[ start, stop ]"
    echo ""
    echoY "Supported target:"
    echo "[ toaster ]"
    echo ""
}

[ $# -lt 2 ] && echoR "Invalid args count:$# " && usage_func && exit 1

case $1 in
    start) echoY "Starting: $2 ..."
        if [ $2 == "toaster" ]
        then
            start_toaster_func
        else
            echo "Unsupported target:$2 for start command."
        fi
        ;;
    stop) echoY "Stoping: $2 ..."
        if [ $2 == "toaster" ]
        then
            stop_toaster_func
        else
            echo "Unsupported target:$2 for stop command."
        fi
        ;;
    *) echoR "Unsupported target:$1."
        usage_func
        exit 1
esac


exit 0

