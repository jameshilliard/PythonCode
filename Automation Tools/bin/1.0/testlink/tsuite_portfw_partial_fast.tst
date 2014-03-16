-v G_USER=jnguyen
-v G_CONFIG=1.0
-v G_TBTYPE=pf
-v G_TST_TITLE="Firewall Settings Port Forwarding"
-v G_PROD_TYPE=MC524WR
-v G_HTTP_DIR=test/
-v G_FTP_DIR=/log/autotest	
-v G_TESTBED=tb1
-v G_FROMRCPT=qaman
-v G_FTPUSR=root
-v G_FTPPWD=@ctiontec123
-v U_PCUSER=root
-v U_PCPWD=actiontec
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
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon2/testcases/port_forwarding/json
-v U_TCPATH=$SQAROOT/platform/1.0/verizon2/testcases/port_forwarding/tcases
-v U_COMMONTC=$SQAROOT/platform/1.0/verizon2/testcases/common/tcases
-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
-v U_DEBUG=3
-v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin
-v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin
-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
-v U_COAX=0

-nc $SQAROOT/config/$G_CONFIG/common/testbedcfg_nokill.xml;
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/tc_init_dut.xml

#------------------------------
#--TC
#------------------------------

#------------------------------
# Finishing items
#------------------------------
-label finish
-nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/updatelogs.xml
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
