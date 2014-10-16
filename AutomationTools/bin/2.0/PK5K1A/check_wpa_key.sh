#/bin/bash
   echo "sleep 120 for all config ready"
   sleep 120
   echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o rc_conf.tmp -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"cat /etc/rc.conf\" "
   # perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o rc_conf.tmp -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cat /etc/rc.conf" 
    $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/rc_conf.tmp  -y  telnet -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0  -v "cat /etc/rc.conf" 
    dos2unix  $G_CURRENTLOG/rc_conf.tmp
    value_a=`cat $G_CURRENTLOG/rc_conf.tmp | grep "wlDf_psk_0" | awk -F "=" '{print $2}' | sed "s/^\"//g"|sed 's/\"$//g'` 
    echo "value_a=$value_a"
    value_b=`cat $G_CURRENTLOG/rc_conf.tmp | grep "wlpsk1_0_passPhrase" | awk -F "=" '{print $2}' | sed "s/^\"//g"|sed 's/\"$//g'` 
    echo "value_b=$value_b"
    value_c=`cat $G_CURRENTLOG/rc_conf.tmp | grep "wlpsk1_0_psk=" | awk -F "=" '{print $2}' | sed "s/^\"//g"|sed 's/\"$//g'` 
    echo "value_c=$value_c"
   echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o WPAKEY.tmp -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"uboot_env --get --name WPAKEY\" "
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o WPAKEY.tmp -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "uboot_env --get --name WPAKEY" 
    dos2unix  $G_CURRENTLOG/WPAKEY.tmp
    value_d=`cat $G_CURRENTLOG/WPAKEY.tmp |tail -3|head -1`
    echo "value_d=$value_d"
 if [ "$value_a" == "" ] ;then
       exit 1
 fi
 if [ "$value_b" == "" ] ;then
       exit 2
 fi
 if [ "$value_c" == "" ] ;then
       exit 3
 fi
 if [ "$value_d" == "" ] ;then
       exit 4
 fi
 if [ "$value_a" == "$value_b" ] ;then
     echo "value_a=value_b"
     if [ "$value_b" == "$value_c" ] ;then
         echo "value_b=value_c"
         if [ "$value_c" == "$value_d" ] ;then
           echo "WPAkeys are same "
           exit 0
         else 
            echo "wlpsk1_0_psk and uboot_env --get value are not same"    
            exit 3
         fi
     else 
       echo "wlsk1_0_passPhrasea and wlpsk1_0_psk are not same"    
       exit 2
     fi      
 else
    echo "wlDf_psk_0 and wlsk1_0_passPhrase are not same"    
    exit 1
 fi
