#! /bin/bash
#
# Author        :   Andy(aliu@actiontec.com)
# Description   :
#   This tool is used to check test bed.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#18 Jun 2012    |   1.0.0   | Andy      | Inital Version


REV="$0 version 1.0.0 (18 Jun 2012)"

echo "${REV}"

# USAGE
USAGE()
{
    cat <<usge
USAGE :

    bash $0 PC0_IP:PC0_USERNAME:PC0_PASSWORD:PC0_CHECK_FILE [PC1_IP:PC1_USERNAME:PC2_PASSWORD:PC1_CHECK_FILE ...]

usge
}

#tb_check.sh LAN_PC_IP:LAN_PC_USERNAME:LAN_PC_PASSWORD WAN_PC_IP:WAN_PC_USERNAME:WAN_PC_PASSWORD

#_PWD=../../../tools/2.0/common
_PWD=~/automation/tools/2.0/common

pc_info=()

# parse command line
while [ $# -gt 0 ];
do
    case "$1" in 
        -h)
            USAGE
            exit 1
            ;;
        *)
            len_pc_info=${#pc_info[@]}
            pc_info[len_pc_info]=$1
            echo "the PC${len_pc_info} information : ${pc_info[len_pc_info]}"
            shift 1
            ;;
    esac
done

# execute check_testbed.py
for ((i=0;i<${#pc_info[@]};i++));
do
    echo "the PC$i information : ${pc_info[$i]}"

    #paser parameter
    ip=`echo   ${pc_info[$i]} | cut -d : -f 1`
    name=`echo ${pc_info[$i]} | cut -d : -f 2`
    pswd=`echo ${pc_info[$i]} | cut -d : -f 3`
    cfg=`echo  ${pc_info[$i]} | cut -d : -f 4`

    if [ -z "$ip" -o -z "$name" -o -z "$pswd" -o -z "$cfg" ] ;then
        echo "ERROR : Bad PC information : PC${len_pc_info} -- ${pc_info[$i]}"
        continue
    fi

    echo "python $_PWD/check_testbed.py -c $_PWD/$cfg -d $ip -u $name -p $pswd -o tee /tmp/pc_check_PC$i.tmp"
    python $_PWD/check_testbed.py -c $_PWD/$cfg -d $ip -u $name -p $pswd -o /tmp/pc_check_PC$i.tmp

    if [ $? -ne 0 ] ;then
        echo "ERROR : Something wrong with check PC$i -- ${pc_info[$i]}" | tee -a /tmp/pc_check_PC$i.tmp
        echo "ERROR : You can execute : python $_PWD/check_testbed.py -c $_PWD/$cfg -d $ip -u $name -p $pswd" | tee -a /tmp/pc_check_PC$i.tmp
    fi
done

# format output
echo "#######################################"

echo "Summary :"

for ((i=0;i<${#pc_info[@]};i++));
do
    echo "LOG : PC$i -- ${pc_info[$i]}"
    echo "Check Results :"
    cat /tmp/pc_check_PC$i.tmp
    rm -f /tmp/pc_check_PC$i.tmp
    echo "---------------------------------------"
done


