-v G_USER=jma
-v G_CONFIG=1.0
-v G_TBTYPE=wppp
-v G_TST_TITLE="My Network WAN PPPoE"
-v G_PROD_TYPE=esx
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb21
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
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/wppp/json
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
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autoip_03007000001.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autoip_03007000002.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autoip_03007000003.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autoip_03007000004.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autoip_03007000005.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autoip_03007000006.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autoip_03007000007.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autoip_03007000008.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualip_03007000009.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualip_03007000010.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualip_03007000011.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualip_03007000012.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualip_03007000013.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualip_03007000014.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualip_03007000015.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualip_03007000016.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autodns_03007000017.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autodns_03007000018.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autodns_03007000019.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autodns_03007000020.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autodns_03007000021.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_autodns_03007000022.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualdns_03007000023.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualdns_03007000024.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualdns_03007000025.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualdns_03007000026.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualdns_03007000027.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/wppp/tcases/tc_manualdns_03007000028.xml
#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
