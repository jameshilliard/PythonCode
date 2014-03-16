bash $U_PATH_TBIN/changeValueofRecord.sh -n vpi -v $U_DUT_CUSTOM_VPI -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WA.CON*";
bash $U_PATH_TBIN/changeValueofRecord.sh -n vci -v $U_DUT_CUSTOM_VCI -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WA.CON*";
bash $U_PATH_TBIN/changeValueofRecord.sh -n ppp -v $U_DUT_CUSTOM_PPP_USER -f "$U_PATH_SANITYCFG/*";
bash $U_PATH_TBIN/changeValueofRecord.sh -n ppppwd -v $U_DUT_CUSTOM_PPP_PWD -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WA.CON*";
bash $U_PATH_TBIN/changeValueofRecord.sh -n wanip -v $U_DUT_CUSTOM_STATIC_WAN_IP -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WA.CON*"
bash $U_PATH_TBIN/changeValueofRecord.sh -n submask -v $U_DUT_CUSTOM_STATIC_WAN_NETMASK -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WA.CON*"
bash $U_PATH_TBIN/changeValueofRecord.sh -n defaultgw -v $U_DUT_CUSTOM_STATIC_WAN_DEF_GW -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WA.CON*"
bash $U_PATH_TBIN/changeValueofRecord.sh -n dns1 -v $U_DUT_CUSTOM_STATIC_WAN_DNS1 -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WA.CON*"
bash $U_PATH_TBIN/changeValueofRecord.sh -n dns2 -v $U_DUT_CUSTOM_STATIC_WAN_DNS2 -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WA.CON*"
bash $U_PATH_TBIN/changeValueofRecord.sh -n vlanid -v $U_DUT_CUSTOM_WAN_VLAN_ID -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WA.CON*"

# TR69
bash $U_PATH_TBIN/changeValueofRecord.sh -n tr69Requser -v $U_DUT_SN -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-TR.069-001-C001"
bash $U_PATH_TBIN/changeValueofRecord.sh -n tr69ACSuser -v $U_DUT_SN -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-TR.069-001-C001"

# wireless
bash $U_PATH_TBIN/changeValueofRecord.sh -n ssid_0 -v $U_WIRELESS_SSID1 -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WI.MAF*"
bash $U_PATH_TBIN/changeValueofRecord.sh -n ssid0_authMac -v $U_WIRELESSCARD_MAC -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-WI.MAF*"

#sanity
bash $U_PATH_TBIN/changeValueofRecord.sh -n remoteTelNet -v "null" -f $U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.RTE-001-C001;
bash $U_PATH_TBIN/changeValueofRecord.sh -n portFrwd -v "TCP" -f $U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.PFO-001-C001; 
bash $U_PATH_TBIN/changeValueofRecord.sh -n portFrwd -v "TCP" -f $U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.PFO-001-C002;
bash $U_PATH_TBIN/changeValueofRecord.sh -n portFrwd -v "UDP" -f $U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.PFO-002-C001; 
bash $U_PATH_TBIN/changeValueofRecord.sh -n portFrwd -v "UDP" -f $U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.PFO-002-C002;
bash $U_PATH_TBIN/changeValueofRecord.sh -n remoteGUI -v "nu" -f $U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.RGU-001-C001;
bash $U_PATH_TBIN/changeValueofRecord.sh -n dmzIp -v $G_HOST_TIP0_1_0 -f $U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.DMZ-001-C001;
bash $U_PATH_TBIN/changeValueofRecord.sh -n dmzIp -v $G_HOST_TIP0_1_0 -f $U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.DMZ-001-C002;
bash $U_PATH_TBIN/changeValueofRecord.sh -n serviceBlock -v $G_HOST_TIP0_2_0 -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.SBL*";
bash $U_PATH_TBIN/changeValueofRecord.sh -n wbl -v "null" -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-BA.WBL*";
bash $U_PATH_TBIN/changeValueofRecord.sh -n hostName -v "null" -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-UT.PIN-*";
bash $U_PATH_TBIN/changeValueofRecord.sh -n hostName -v "null" -f "$U_PATH_SANITYCFG/B-$U_DUT_TYPE-UT.TRO-*";
