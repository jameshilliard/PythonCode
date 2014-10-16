#!/bin/bash
#-----------------------------------
#Name:Adny
#this script is to check the DHCP result is correct.
#-----------------------------------
REV="$0 version 1.0.1 (31 Oct 2011)"
# print REV

echo "${REV}"

usage="Usage: verifyDHCP.sh -i interface -m mask -s startAddress -e endAddress -g gateway -z DNSservers -f leasefile -n <negativeflag> -o option[igsd] -t [test mode]"

allcheckflag=1
negativeflag=0
result=0


Interface=$G_HOST_IF0_2_0
mask=$G_PROD_TMASK_BR0_0_0
startAddress=$G_PROD_DHCPSTART_BR0_0_0
endAddress=$G_PROD_DHCPEND_BR0_0_0
gateway=$G_PROD_GW_BR0_0_0

bash $U_PATH_TBIN/cli_dut.sh -v wan.dns -o $G_CURRENTLOG/DUTDNS.log

checkIPInRange()
{
    echo "=====IPaddress in range====="
    ifconfig $Interface | tee $G_CURRENTLOG/$Interface.log
    echo "range $startAddress $endAddress" > $G_CURRENTLOG/rangefile.conf
    bash $U_PATH_TBIN/check_ipaddress_in_range.sh -c $G_CURRENTLOG/rangefile.conf -l $G_CURRENTLOG/$Interface.log
    if [ $? -ne 0 ] ;then
        result=$(($result+1))
    fi
}

checkGateway()
{
    echo "=====gateway====="
    perl $U_PATH_TBIN/searchoperation.pl -e "option routers $gateway" -f $G_CURRENTLOG/dhclient.lease
    if [ $? -ne 0 ] ;then
        echo -e " AT_ERROR : gateway is incorrect! "
        result=$(($result+1))
    else
        echo -e " gateway is correct! "
    fi
}


checkSubMask(){
    echo "=====subnetmask====="
    perl $U_PATH_TBIN/searchoperation.pl -e "option subnet-mask $mask" -f $G_CURRENTLOG/dhclient.lease
    if [ $? -ne 0 ] ;then
        echo -e " AT_ERROR : submask is incorrect! "
        result=$(($result+1))
    else
        echo -e " submask is correct! "
    fi
}

checkDNS()
{
    echo "=====DNS($G_PROD_IP_BR0_0_0,WAN DNS 2)====="
    if [ -z $DNSservers ]; then
#        echo "perl $U_PATH_TBIN/DUTShellCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log"
#        perl $U_PATH_TBIN/DUTShellCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log
        #remove ^M
        dos2unix $G_CURRENTLOG/DUTDNS.log
	    DUTDNS=`cat $G_CURRENTLOG/DUTDNS.log | grep "TMP_DUT_WAN_DNS_2" | awk -F = '{print $2}'`
        DNSservers=$G_PROD_IP_BR0_0_0','$DUTDNS';'
    fi
    perl $U_PATH_TBIN/searchoperation.pl -e "option domain-name-servers $DNSservers" -f $G_CURRENTLOG/dhclient.lease
    if [ $? -ne 0 ] ;then
        echo -e " AT_ERROR : DNSServers is incorrect! "
        result=$(($result+1))
    else
        echo -e " DNSServers is correct! "
    fi
}

checkDNSbr0()
{
    echo "=====DNS($G_PROD_IP_BR0_0_0)====="
    DNSservers=$G_PROD_IP_BR0_0_0';'
    perl $U_PATH_TBIN/searchoperation.pl -e "option domain-name-servers $DNSservers" -f $G_CURRENTLOG/dhclient.lease
    if [ $? -ne 0 ] ;then
        echo -e " AT_ERROR : DNSServers is incorrect! "
        result=$(($result+1))
    else
        echo -e " DNSServers is correct! "
    fi
}

checkDNS1()
{
    echo "=====DNS($G_PROD_IP_BR0_0_0,WAN DNS 1)====="
    if [ -z $DNSservers ]; then
#        echo "perl $U_PATH_TBIN/DUTShellCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log"
#        perl $U_PATH_TBIN/DUTShellCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log
        #remove ^M
        dos2unix $G_CURRENTLOG/DUTDNS.log
	    DUTDNS=`cat $G_CURRENTLOG/DUTDNS.log | grep "TMP_DUT_WAN_DNS_1" | awk -F = '{print $2}'`
        DNSservers=$G_PROD_IP_BR0_0_0','$DUTDNS';'
    fi
    perl $U_PATH_TBIN/searchoperation.pl -e "option domain-name-servers $DNSservers" -f $G_CURRENTLOG/dhclient.lease
    if [ $? -ne 0 ] ;then
        echo -e " AT_ERROR : DNSServers is incorrect! "
        result=$(($result+1))
    else
        echo -e " DNSServers is correct! "
    fi
}

checkDNS2()
{
    echo "=====DNS($G_PROD_IP_BR0_0_0,WAN DNS 2)====="
    if [ -z $DNSservers ]; then
#        echo "perl $U_PATH_TBIN/DUTShellCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log"
#        perl $U_PATH_TBIN/DUTShellCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log
        #remove ^M
        dos2unix $G_CURRENTLOG/DUTDNS.log
	    DUTDNS=`cat $G_CURRENTLOG/DUTDNS.log | grep "TMP_DUT_WAN_DNS_2" | awk -F = '{print $2}'`
        DNSservers=$G_PROD_IP_BR0_0_0','$DUTDNS';'
    fi
    perl $U_PATH_TBIN/searchoperation.pl -e "option domain-name-servers $DNSservers" -f $G_CURRENTLOG/dhclient.lease
    if [ $? -ne 0 ] ;then
        echo -e " AT_ERROR : DNSServers is incorrect! "
        result=$(($result+1))
    else
        echo -e " DNSServers is correct! "
    fi
}

checkDNS12()
{
    echo "=====DNS(WAN DNS 1,WAN DNS 2)====="
    if [ -z $DNSservers ]; then
#        echo "perl $U_PATH_TBIN/DUTShellCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log"
#        perl $U_PATH_TBIN/DUTShellCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log
        #remove ^M
        dos2unix $G_CURRENTLOG/DUTDNS.log
	    DUTDNS=`cat $G_CURRENTLOG/DUTDNS.log | grep "TMP_DUT_WAN_DNS_1" | awk -F = '{print $2}'`','`cat $G_CURRENTLOG/DUTDNS.log | grep "TMP_DUT_WAN_DNS_2" | awk -F = '{print $2}'`
        DNSservers=$DUTDNS';'
    fi
    
    DNSservers2=`echo $DNSservers|awk -F , '{print $2","$1";"}'`
    perl $U_PATH_TBIN/searchoperation.pl -e "option domain-name-servers $DNSservers" -f $G_CURRENTLOG/dhclient.lease
    if [ $? -ne 0 ] ;then
        perl $U_PATH_TBIN/searchoperation.pl -e "option domain-name-servers $DNSservers2" -f $G_CURRENTLOG/dhclient.lease
        if [ $? -ne 0 ] ;then
            echo -e " AT_ERROR : DNSServers is incorrect! "
            result=$(($result+1))
        else
            echo -e " DNSServers is correct! "
        fi
    else
        echo -e " DNSServers is correct! "
    fi
}
while getopts ":i:m:s:e:g:z:f:o:nt" opt ;
do
	case $opt in
        t)
            Interface=eth2
            mask=255.255.255.0
            startAddress=192.168.0.2
            endAddress=192.168.0.254
            gateway=192.168.0.1
            G_CURRENTLOG=/tmp
            U_PATH_TBIN=.
            G_PROD_IP_BR0_0_0=192.168.0.1
            U_DUT_TELNET_USER=admin
            U_DUT_TELNET_PWD=QwestM0dem
            ;;

        i)
            Interface=$OPTARG
            ;;

        m)
            mask=$OPTARG
            ;;

        s)
            startAddress=$OPTARG
            ;;

        e)
            endAddress=$OPTARG
            ;;

        g)
            gateway=$OPTARG
            ;;

        z)
            DNSservers=$OPTARG
            ;;

        f)
            leasefile=$OPTARG
            ;;

        n)
            negativeflag=1
            ;;

        o)
            option=$OPTARG
            allcheckflag=0
            ;;

		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

if [ -z "$leasefile" ] ;then
    tmp_leasefile=/var/lib/dhclient/dhclient.leases
    cat $tmp_leasefile |grep -A 11 "$Interface" |tee $G_CURRENTLOG/dhclient.lease
else
    cp $G_CURRENTLOG/$leasefile $G_CURRENTLOG/dhclient.lease
fi

if [ $allcheckflag -eq 1 ]; then
    checkIPInRange
    checkGateway
    checkSubMask
    checkDNS
else
    echo $option | grep i
    if [ $? -eq 0 ]; then 
        checkIPInRange
    fi
    echo $option | grep g
    if [ $? -eq 0 ]; then 
        checkGateway
    fi
    echo $option | grep s 
    if [ $? -eq 0 ]; then 
        checkSubMask
    fi
    echo $option | grep "^d$"
    if [ $? -eq 0 ]; then 
        checkDNS
    fi
    echo $option | grep "^d1$"
    if [ $? -eq 0 ]; then 
        checkDNS1
    fi
    echo $option | grep "^d2$"
    if [ $? -eq 0 ]; then 
        checkDNS2
    fi
    echo $option | grep "^d12$"
    if [ $? -eq 0 ]; then 
        checkDNS12
    fi
    echo $option | grep "^dbr0$"
    if [ $? -eq 0 ]; then 
        checkDNSbr0
    fi
fi

echo "the final result is : $result"

if [ $negativeflag -eq  0 ]; then
    if [ $result -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
else
     if [ $result -eq 0 ]; then
        exit 1
    else
        exit 0
    fi
fi
