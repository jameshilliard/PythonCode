#!/bin/sh 
# get info by telnet
#!/bin/bash
# print version info
VER="1.0.0"
echo "$0 version : ${VER}"

bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $1 
exit 0
