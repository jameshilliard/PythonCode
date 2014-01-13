-v G_USER=jma
-v G_CONFIG=1.0
-v G_TBTYPE=bcc
-v G_TST_TITLE="My Network Broadband Connection Coax"
-v G_PROD_TYPE=MC524WR
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb40
-v G_FROMRCPT=jma@actiontec.com
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
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/bcc/json
# this value used to setup hytrust.cfg
-v U_DEBUG=3
-v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin
-v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin
-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
-v U_COAX=1
# $G_PFVERSION=1.0
#-----------------------------
# Set up the test environment.
#-----------------------------
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
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/tc_init_ping.xml;fail=finish
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/enable_tnet.xml
#-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/disable_ath1.xml
#------------------------------
# Test cases 
#------------------------------
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/set_default_time.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpclient_03006000809.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpclient_03006000810.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpclient_03006000811.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpclient_03006000812.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpdisable_03006000825.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelay_03006000819.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelay_03006000820.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelay_03006000821.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelay_03006000822.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelay_03006000823.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelay_03006000824.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelaynapt_03006000819.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelaynapt_03006000820.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelaynapt_03006000821.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelaynapt_03006000822.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelaynapt_03006000823.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcprelaynapt_03006000824.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpserver_03006000813.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpserver_03006000814.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpserver_03006000815.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpserver_03006000816.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpserver_03006000817.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpserver_03006000818.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dnsserver_03006000844.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dnsserver_03006000845.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dnsserver_03006000846.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dnsserver_03006000847.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000826.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000827.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000828.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000829.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000830.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000831.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000832.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000833.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000834.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000835.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000836.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000837.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000838.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000839.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000840.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000841.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000842.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_hostname_03006000843.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_autoDetection_03006001080.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_autoDetection_03006001081.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_autoDetection_03006001082.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_autoDetection_03006001083.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_autoDetection_03006001084.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_autoDetection_03006001085.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_autoDetection_03006001086.xml
#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
