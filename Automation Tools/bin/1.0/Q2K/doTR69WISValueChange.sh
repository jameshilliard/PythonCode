#! /bin/sh
bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_0 -v $U_WIRELESS_SSID1 -f "$U_PATH_TR069CFG/*FUN*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_1 -v $U_WIRELESS_SSID2 -f "$U_PATH_TR069CFG/*FUN*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_2 -v $U_WIRELESS_SSID3 -f "$U_PATH_TR069CFG/*FUN*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_3 -v $U_WIRELESS_SSID4 -f "$U_PATH_TR069CFG/*FUN*";

########################################################

# custom wep
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_1 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -f "$U_PATH_TR069CFG/*FUN*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_2 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -f "$U_PATH_TR069CFG/*FUN*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_3 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -f "$U_PATH_TR069CFG/*FUN*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_4 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -f "$U_PATH_TR069CFG/*FUN*";

bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_1 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -f "$U_PATH_TR069CFG/*FUN*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_2 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -f "$U_PATH_TR069CFG/*FUN*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_3 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -f "$U_PATH_TR069CFG/*FUN*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_4 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -f "$U_PATH_TR069CFG/*FUN*";
# default wep
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepdef -v $U_WIRELESS_WEPKEY_DEF_64 --v1Wep128 $U_WIRELESS_WEPKEY1 --v2Wep128 $U_WIRELESS_WEPKEY2 --v3Wep128 $U_WIRELESS_WEPKEY3 --v4Wep128 $U_WIRELESS_WEPKEY4 -f "$U_PATH_TR069CFG/*FUN*";


########################################################

# custom psk
bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_cus -v $U_WIRELESS_CUSTOM_WPAPSK -f "$U_PATH_TR069CFG/*FUN*";

# default psk
bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_def -v "null" --v1WpaPsk $U_WIRELESS_WPAPSK1 --v2WpaPsk $U_WIRELESS_WPAPSK2 --v3WpaPsk $U_WIRELESS_WPAPSK3 --v4WpaPsk $U_WIRELESS_WPAPSK4 -f "$U_PATH_TR069CFG/*FUN*";
