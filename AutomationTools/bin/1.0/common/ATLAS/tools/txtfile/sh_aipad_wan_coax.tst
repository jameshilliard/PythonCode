-v G_USER=jma
-v G_CONFIG=1.0
-v G_TBTYPE=aipad
-v G_PROD_TYPE=MC524WR
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb40
-v G_TST_TITLE="Advanced IP Address Distribution Broadband Connection Coax"
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
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/aipad/json
#this value used to setup dut configuration
-v U_DEBUG=3
-v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin
-v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin
-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
-v U_COAX=1
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
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000025.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000026.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000027.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000028.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000029.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000030.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000031.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000073.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000074.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000075.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000076.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000077.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000078.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000079.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000080.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000081.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000082.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000083.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000084.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000085.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000086.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000087.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000088.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000089.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000090.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000049.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000050.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000051.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000052.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000053.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_06071000054.xml
#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
