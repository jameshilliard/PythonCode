#!/bin/bash
#$G_HOST_GW0_1_0=192.168.1.254 $G_HOST_IF0_1_0=eth1 $G_HOST_IF0_2_0=eth2
usage="curl_sites.sh [sites] [blocked | unblocked] [-test]"
while [ -n "$1" ];
do
    case "$1" in
    -test)
        G_HOST_GW0_1_0=192.168.1.254
        G_HOST_GW0_2_0=192.168.1.254
        G_HOST_IF0_1_0=eth1
        G_HOST_IF0_2_0=eth2
        G_HOST_TIP0_1_0=192.168.1.200
        G_HOST_TIP0_2_0=192.168.1.225
        U_PATH_TBIN=./
        G_CURRENTLOG=/tmp
        shift 1
        ;;
    *)
        tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $1 $G_CURRENTLOG/curl-$1-$2.log
        shift 2
        ;;
    esac
done
