-v G_USER=qaman
-v G_CONFIG=1.0
-v G_TBTYPE=pf
-v G_PROD_TYPE=bhr2
-v G_TST_TITLE="Advanced Dynamic DNS"
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb42
-v G_FROMRCPT=hpeng@actiontec.com
-v G_FTPUSR=root
-v G_FTPPWD=@ctiontec123
-v U_USER=admin
-v U_PWD=admin1
-v G_LIBVERSION=1.0
-v G_LOG=$SQAROOT/automation/logs
-v U_COMMONLIB=$SQAROOT/lib/$G_LIBVERSION/common
-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
-v U_COMMONBIN=$SQAROOT/bin/$G_LIBVERSION/common
-v U_TBCFG=$SQAROOT/config/$G_LIBVERSION/testbed
-v U_TBPROF=$SQAROOT/config/$G_LIBVERSION/common
-v U_VERIWAVE=$SQAROOT/bin/1.0/veriwave/
-v U_MI424=$SQAROOT/bin/1.0/mi424wr/
-v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/addns/json
#this value used to setup dut configuration
-v U_DEBUG=3
-v U_COAX=0
-v U_DUT=192.168.1.1
-v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin


#$G_PFVERSION=1.0

# Configuethe testbed.
#-nc $SQAROOT/config/$G_CONFIG/common/testbedcfg_env.xml;
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
#------------------------------
# Test cases 
#------------------------------
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/set_default_time.xml


-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_checkhostname_06019000001.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_checkhostname_06019000002.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_checkhostname_06019000003.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_checkhostname_06019000004.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_checkhostname_06019000005.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_checkhostname_06019000006.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_checkhostname_06019000007.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_checkhostname_06019000008.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_mailexchange_ether_06019000024.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_mailexchange_ether_06019000025.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_mailexchange_ether_06019000026.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_multiHostName_06019000020.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_multiHostName_06019000021.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_multiHostName_06019000022.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_wildcard_ether_06019000023.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_changewanip_ether_06019000009.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/addns/tcases/tc_changewanip_pppoe_06019000011.xml

-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
