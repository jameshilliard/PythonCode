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
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001050.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001051.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001052.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001053.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001054.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001055.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001056.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001057.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001058.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001059.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001060.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001061.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001062.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001063.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001064.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001065.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001066.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001067.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001068.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001069.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001070.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001071.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001072.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001073.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001074.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001075.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001076.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001077.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_invaildleasetime_03005001078.xml
#
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime_cclass.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime_bclass1.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime_bclass2.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime_aclass1.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime_aclass2.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime_aclass3.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime43200_cclass.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime43200_bclass1.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime43200_bclass2.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime43200_aclass1.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime43200_aclass2.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/bce/tcases/tc_dhcpwaneth_leasetime43200_aclass3.xml

# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
