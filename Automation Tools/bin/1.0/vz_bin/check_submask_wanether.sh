#! /bin/sh
###########################################
#
#	This script is composed to grep DUT Wan ethernet 
#	subnet mask
#
#	By Hugo 
#	May, 2009
############################################
ret_tem=`grep netmask $G_CURRENTLOG/productwaneth.log | awk '{ print $2 }'`
ret_temraw=`echo ${ret_tem#*=}`
# cut last bit in subnet mask since 255.255.255.0 always has suffix character
ret=`echo ${ret_temraw%\.*}`

ret_tempjson=`cat $SQAROOT/platform/1.0/verizon/testcases/bce/json/$1 | grep 'Override Subnet Mask Address' | cut -d : -f 2`
ret_tempjsoncut=`echo ${ret_tempjson#\"}`
ret_jsonraw=`echo ${ret_tempjsoncut%\"*}`
ret_json=`echo ${ret_jsonraw%\.*}`

if [ $ret = $ret_json ]; then
	echo "DUT Wan ethernet netmask is correct"
	exit 0
else
	exit 1
fi

