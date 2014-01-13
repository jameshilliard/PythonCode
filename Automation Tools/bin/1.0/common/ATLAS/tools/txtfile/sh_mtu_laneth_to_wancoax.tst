-v G_USER=jnguyen
-v G_CONFIG=1.0
-v G_TBTYPE=arc
-v G_TST_TITLE="My Network Network Home Office Ethernet"
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
#------------------------------
# Test cases 
#------------------------------
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/set_default_time.xml

-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001080.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001081.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001082.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001083.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001084.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001085.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001086.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001087.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001088.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001089.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001090.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001091.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001092.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001093.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001094.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001095.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001096.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001097.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001098.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001099.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001100.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001101.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001102.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001103.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001104.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001105.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001106.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001107.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001108.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001109.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001110.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001111.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001112.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001113.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001114.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001115.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001116.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001117.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/nhoe/tcases/mtu_laneth_to_wancoax/tc_mtu_laneth_wancoax_03001001118.xml

#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
