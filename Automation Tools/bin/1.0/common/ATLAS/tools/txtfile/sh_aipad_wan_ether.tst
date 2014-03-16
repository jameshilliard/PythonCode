-v G_USER=jma
-v G_CONFIG=1.0
-v G_TBTYPE=aipad
-v G_PROD_TYPE=MC524WR
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb40
-v G_FROMRCPT=jma@actiontec.com
-v G_TST_TITLE="Advanced IP Address Distribution Broadband Connection Ethernet"
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
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/aipad/json
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
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/tc_init_ping.xml;fail=finish
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/enable_tnet.xml
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/disable_ath1.xml
#------------------------------
# Test cases
#------------------------------
-tc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/set_default_time.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000013.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000014.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000015.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000016.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000017.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000018.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000019.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000043.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000044.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000045.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000046.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000047.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000048.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000055.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000056.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000057.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000058.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000059.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000060.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000061.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000062.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000063.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000064.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000065.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000066.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000067.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000068.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000069.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000070.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000071.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000072.xml
#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
