-v G_USER=qaman
-v G_CONFIG=1.0
-v G_TBTYPE=pf
-v G_TST_TITLE="Advanced Remote Administration"
-v G_PROD_TYPE=MC524WR
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb36
-v G_FROMRCPT=qaman@actiontec.om
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
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/ara/json_1
-v U_TCPATH=$SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1
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
#------------------------------
# Test cases 
#------------------------------
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/set_default_time.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_disableall_06017000001.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_icmpecho_06017000009.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_port23_06017000002.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_port443_06017000007.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_port80_06017000005.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_port8023_06017000003.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_port8080_06017000006.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_port8443_06017000008.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_port992_06017000004.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/ara/tcases_1/tc_udptraceroute_06017000010.xml
#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
