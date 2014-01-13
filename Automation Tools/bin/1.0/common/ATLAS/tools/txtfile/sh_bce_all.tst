-v G_USER=jnguyen
-v G_CONFIG=1.0
-v G_TBTYPE=bce
-v G_TST_TITLE="My Network Broadband Connection Ethernet"
-v G_PROD_TYPE=MC524WR
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb1
-v G_FROMRCPT=qaman
-v G_FTPUSR=root
-v G_FTPPWD=@ctiontec123
-v U_USER=admin
-v U_PWD=admin1
-v G_LIBVERSION=1.0
-v G_LOG=$SQAROOT/automation/logs
-v U_COMMONLIB=$SQAROOT/lib/$G_LIBVERSION/common
-v U_COMMONBIN=$SQAROOT/bin/$G_LIBVERSION/common
-v U_TBCFG=$SQAROOT/config/$G_LIBVERSION/testbed
-v U_TBPROF=$SQAROOT/config/$G_LIBVERSION/common
-v U_VERIWAVE=$SQAROOT/bin/1.0/veriwave/
-v U_MI424=$SQAROOT/bin/1.0/mi424wr/
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/bce/json
#this value used to setup dut configuration
-v U_DEBUG=3
-v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin
-v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin
-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
-v U_COAX=0
#$G_PFVERSION=1.0
#------------------------------
# Set up the test environment.
#------------------------------
#-nc $SQAROOT/config/$G_CONFIG/common/testbedcfg_env.xml
-nc $SQAROOT/config/$G_CONFIG/common/testbedcfg.xml;
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/login_logout.xml
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/fw_upgrage_image.xml;pass=init
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/fw_upgrage_image.xml;pass=init
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/fw_upgrage_image.xml;fail=finish
-label init
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/reset_dut_to_default.xml
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/tc_init_dut.xml;pass=next
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/tc_init_dut.xml;pass=next
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/tc_init_dut.xml;fail=finish
-label next
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/set_default_time.xml
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/tc_init_ping.xml;fail=finish
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/enable_tnet.xml
#-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/disable_ath1.xml
#------------------------------
# Test cases 
#------------------------------
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpclient_03005000831.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpclient_03005000832.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpclient_03005000833.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpclient_03005000834.xml
#
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_03005000807.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_03005000808.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_03005000809.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_03005000810.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_03005000811.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_03005000812.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_napt_03005000807.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_napt_03005000808.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_napt_03005000809.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_napt_03005000810.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_napt_03005000811.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcprelay_napt_03005000812.xml
##
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_disabledhcp_03005000800.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dnsserver_03005000835.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dnsserver_03005000836.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dnsserver_03005000837.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dnsserver_03005000838.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_enabledhcp_03005000801.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_enabledhcp_03005000802.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_enabledhcp_03005000803.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_enabledhcp_03005000804.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_enabledhcp_03005000805.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_enabledhcp_03005000806.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000819.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000820.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000821.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000822.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000823.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000824.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000825.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000826.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000827.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000828.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000829.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_hostname_03005000830.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_nohostname_03005000813.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_nohostname_03005000814.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_nohostname_03005000815.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_nohostname_03005000816.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_nohostname_03005000817.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_nohostname_03005000818.xml
#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
