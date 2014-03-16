-v G_USER=pcai
-v G_CONFIG=1.0
-v G_TBTYPE=adt
-v G_TST_TITLE="Advanced Date and Time"
-v G_PROD_TYPE=MC524WR
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb43
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
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/adt/json
#this value used to setup dut configuration
-v U_DEBUG=3
-v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin
-v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin
-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
-v U_COAX=1
-v DEFAULT_SAVE_PATH=/tmp
-v DEFAULT_SAVE_NAME=Wireless*.conf
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
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/tc_init_ping.xml;fail=finish
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/enable_tnet.xml
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/setipfw_wanpc.xml
#------------------------------
# Test cases 
#------------------------------
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/set_default_time.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_init.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000001.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000002.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000003.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000004.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000005.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000006.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000007.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000008.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000009.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000010.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000011.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000012.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000013.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/adt/tcases/tc_dat_03050000014.xml
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/clean_iptables.xml
#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
