#! /bin/sh

bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_0 -v $U_WIRELESS_SSID1 -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_1 -v $U_WIRELESS_SSID2 -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_2 -v $U_WIRELESS_SSID3 -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_3 -v $U_WIRELESS_SSID4 -f "$U_PATH_WIFICFG/*";

########################################################

# custom wep
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_1 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_2 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_3 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_4 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -f "$U_PATH_WIFICFG/*";

bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_1 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_2 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_3 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_4 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -f "$U_PATH_WIFICFG/*";
# default wep
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepdef -v $U_WIRELESS_WEPKEY_DEF_64 --v1Wep128 $U_WIRELESS_WEPKEY1 --v2Wep128 $U_WIRELESS_WEPKEY2 --v3Wep128 $U_WIRELESS_WEPKEY3 --v4Wep128 $U_WIRELESS_WEPKEY4 -f "$U_PATH_WIFICFG/*";


########################################################

# custom psk
bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_cus -v $U_WIRELESS_CUSTOM_WPAPSK -f "$U_PATH_WIFICFG/*";

# default psk
bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_def -v "null" --v1WpaPsk $U_WIRELESS_WPAPSK1 --v2WpaPsk $U_WIRELESS_WPAPSK2 --v3WpaPsk $U_WIRELESS_WPAPSK3 --v4WpaPsk $U_WIRELESS_WPAPSK4 -f "$U_PATH_WIFICFG/*";


########################################################
bash  $U_PATH_TBIN/changeValueofRecord.sh -n radius_server -v $U_WIRELESS_RADIUS_SERVER -f "$U_PATH_WIFICFG/*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n radius_key -v $U_WIRELESS_RADIUS_KEY -f "$U_PATH_WIFICFG/*";


########################################################
#perl $U_PATH_TBIN/ping.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0;

#$U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-$U_DUT_TYPE-WI.CON-001-C999 $U_AUTO_CONF_PARAM;

exit 0
