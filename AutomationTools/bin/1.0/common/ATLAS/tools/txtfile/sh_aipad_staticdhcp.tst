-v G_USER=hugo
-v G_CONFIG=1.0
-v G_TBTYPE=aipad
-v G_PROD_TYPE=MC524WR
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb40
-v G_TST_TITLE="Advanced IP Address Distribution Network Home Office"
-v G_FROMRCPT=shqa@actiontec.com
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
-v U_DUT=192.168.1.1
-v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin
-v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin
-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
-v U_COAX=0

#$G_PFVERSION=1.0

# Initialize the testbed.
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

# Execute the test cases step.
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_dynlease_0001.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_dynlease_0002.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_dynlease_0003.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_dynlease_0004.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_dynlease_0005.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_dynlease_0006.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_dynlease_0007.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_dynlease_0008.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_dynlease_0009.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_staticlease_0001.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_staticlease_0002.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_staticlease_0003.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_staticlease_0004.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_staticlease_0005.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_staticlease_0006.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_newstatic_0001.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_newstatic_0002.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_newstatic_0003.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_newstatic_0004.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_acl_0001.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_acl_0002.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/aipad/tcases/tc_acl_0003.xml

-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
