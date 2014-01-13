#!/bin/bash
usage="bash_curl.sh -e <specify symbol> site1 site2 .. siten"
while [ -n "$1" ];
do
    case "$1" in

    -e)
        sp=$2
        echo "specify symbol : ${sp}"
        shift 2
        ;;
    *)
        echo "compare_dir_html.sh -s <source dir> -d <dest dir> -o <output dir>"
        exit 1
        ;;
    esac
done
#tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $U_WEBSITE_001 $G_CURRENTLOG/pc3_curl_U_WEBSITE_001_via_dut_blocked.log;tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $U_WEBSITE_002 $G_CURRENTLOG/pc3_curl_U_WEBSITE_002_via_dut_blocked.log;tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $U_WEBSITE_003 $G_CURRENTLOG/pc3_curl_U_WEBSITE_003_via_dut_blocked.log

