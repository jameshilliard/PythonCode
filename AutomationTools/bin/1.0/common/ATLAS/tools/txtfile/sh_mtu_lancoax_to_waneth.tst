-v G_USER=jnguyen
-v G_CONFIG=1.0
-v G_TST_TITLE="My Network Network Home Office Ethernet"
-v G_TBTYPE=arc
-v G_PROD_TYPE=esx
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
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/nhoe/json
#this value used to setup dut configuration
-v U_DEBUG=3
-v U_DUT=192.168.1.1
-v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin
-v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin
-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
-v U_COAX=0
#$G_PFVERSION=1.0
#------------------------------
# Set up the test environment.
#------------------------------
-nc $SQAROOT/config/$G_CONFIG/common/testbedcfg.xml;
#-nc $SQAROOT/config/$G_CONFIG/common/testbedcfg_env.xml;
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
-tc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/set_default_time.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001040.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001041.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001042.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001043.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001044.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001045.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001046.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001047.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001048.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001049.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001050.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001051.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001052.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001053.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001054.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001055.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001056.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001057.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001058.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001059.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001060.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001061.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001062.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001063.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001064.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001065.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001066.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001067.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001068.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001069.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001070.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001071.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001072.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001073.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001074.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001075.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001076.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001077.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_lancoax_to_waneth/tc_mtu_lancoax_waneth_03001001078.xml
#------------------------------
## Checkout 
##------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
