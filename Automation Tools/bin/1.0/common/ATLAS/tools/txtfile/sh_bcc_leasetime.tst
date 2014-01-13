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

-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001050.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001051.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001052.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001053.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001054.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001055.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001056.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001057.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001058.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001059.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001060.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001061.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001062.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001063.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001064.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001065.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001066.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001067.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001068.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001069.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001070.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001071.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001072.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001073.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001074.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001075.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001076.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001077.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_invaildleasetime_03006001078.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime43200_aclass1.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime43200_aclass2.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime43200_aclass3.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime43200_bclass1.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime43200_bclass2.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime43200_cclass.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime_aclass1.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime_aclass2.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime_aclass3.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime_bclass1.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime_bclass2.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bcc/tcases/tc_dhcpwancoax_leasetime_cclass.xml

#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
