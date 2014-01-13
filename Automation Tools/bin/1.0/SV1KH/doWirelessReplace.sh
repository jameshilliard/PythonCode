#! /bin/sh

bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_0 -v $U_WIRELESS_SSID1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_1 -v $U_WIRELESS_SSID2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_2 -v $U_WIRELESS_SSID3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n ssid_3 -v $U_WIRELESS_SSID4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";

#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_1_ssid1 -v $U_WIRELESS_SSID1_WEPKEY64_1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_2_ssid1 -v $U_WIRELESS_SSID1_WEPKEY64_2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_3_ssid1 -v $U_WIRELESS_SSID1_WEPKEY64_3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_4_ssid1 -v $U_WIRELESS_SSID1_WEPKEY64_4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";
#
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_1_ssid1 -v $U_WIRELESS_SSID1_WEPKEY128_1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_2_ssid1 -v $U_WIRELESS_SSID1_WEPKEY128_2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_3_ssid1 -v $U_WIRELESS_SSID1_WEPKEY128_3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_4_ssid1 -v $U_WIRELESS_SSID1_WEPKEY128_4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";
#
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_1_ssid2 -v $U_WIRELESS_SSID2_WEPKEY64_1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_2_ssid2 -v $U_WIRELESS_SSID2_WEPKEY64_2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_3_ssid2 -v $U_WIRELESS_SSID2_WEPKEY64_3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_4_ssid2 -v $U_WIRELESS_SSID2_WEPKEY64_4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";
#
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_1_ssid2 -v $U_WIRELESS_SSID2_WEPKEY128_1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_2_ssid2 -v $U_WIRELESS_SSID2_WEPKEY128_2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_3_ssid2 -v $U_WIRELESS_SSID2_WEPKEY128_3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_4_ssid2 -v $U_WIRELESS_SSID2_WEPKEY128_4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";

#-------------keep sequence-----------------------
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_1_ssid1 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_2_ssid1 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_3_ssid1 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_4_ssid1 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";

bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_1_ssid1 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_2_ssid1 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_3_ssid1 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_4_ssid1 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";

bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_1_ssid2 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_2_ssid2 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_3_ssid2 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom64_4_ssid2 -v $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";

bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_1_ssid2 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_2_ssid2 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_3_ssid2 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepcustom128_4_ssid2 -v $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";

bash  $U_PATH_TBIN/changeValueofRecord.sh -n wepdef -v $U_WIRELESS_WEPKEY_DEF_64 --v1Wep128 $U_WIRELESS_WEPKEY1 --v2Wep128 $U_WIRELESS_WEPKEY2 --v3Wep128 $U_WIRELESS_WEPKEY3 --v4Wep128 $U_WIRELESS_WEPKEY4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";
#-------------keep sequence-----------------------

#bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_0 -v $U_WIRELESS_WPAPSK1 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_1 -v $U_WIRELESS_WPAPSK2 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_2 -v $U_WIRELESS_WPAPSK3 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
#bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_3 -v $U_WIRELESS_WPAPSK4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";
bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_cus -v $U_WIRELESS_CUSTOM_WPAPSK -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";
bash  $U_PATH_TBIN/changeValueofRecord.sh -n psk_def -v "null" --v1WpaPsk $U_WIRELESS_WPAPSK1 --v2WpaPsk $U_WIRELESS_WPAPSK2 --v3WpaPsk $U_WIRELESS_WPAPSK3 --v4WpaPsk $U_WIRELESS_WPAPSK4 -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";



bash  $U_PATH_TBIN/changeValueofRecord.sh -n radius_server -v $U_WIRELESS_RADIUS_SERVER -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*"; 
bash  $U_PATH_TBIN/changeValueofRecord.sh -n radius_key -v $U_WIRELESS_RADIUS_KEY -f "$U_PATH_SANITYWICFG/B-$U_DUT_TYPE-WI*";

perl $U_PATH_TBIN/ping.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0;

exit 0
