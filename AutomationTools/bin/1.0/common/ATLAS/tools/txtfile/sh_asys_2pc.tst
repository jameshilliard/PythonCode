-v G_USER=jnguyen
-v G_CONFIG=1.0
-v G_TBTYPE=asys
-v G_TST_TITLE="Advanced system config"
-v G_PROD_TYPE=MC524WR
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
-v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/asys/json
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
#------------------------------
# Test cases 
#------------------------------
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_mailcapacity_06041003900.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_mailcapacity_06041003901.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_mailcapacity_06041003902.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_mailcapacity_06041003903.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_mailcapacity_06041003904.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_mailcapacity_06041003905.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_logbuf_06041003906.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_logbuf_06041003907.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_logbuf_06041003908.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_logbuf_06041003909.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_logbuf_06041003910.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_logbuf_06041003911.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsyslog_06041003912.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsyslog_06041003913.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsyslog_06041003914.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsyslog_06041003915.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsyslog_06041003916.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsyslog_06041003917.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_secmailcapacity_06041003918.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_secmailcapacity_06041003919.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_secmailcapacity_06041003920.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_secmailcapacity_06041003921.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_secmailcapacity_06041003922.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_secmailcapacity_06041003923.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_seclogbuf_06041003924.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_seclogbuf_06041003925.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_seclogbuf_06041003926.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_seclogbuf_06041003927.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_seclogbuf_06041003928.xml
#-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_seclogbuf_06041003929.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsecsyslog_06041003930.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsecsyslog_06041003931.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsecsyslog_06041003933.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_rmsecsyslog_06041003934.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpport_06041003900.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpport_06041003901.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpport_06041003902.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpport_06041003903.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpsport_06041003904.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpsport_06041003905.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpsport_06041003906.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpsport_06041003907.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_telport_06041003849.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_telport_06041003850.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_telport_06041003851.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_telport_06041003852.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_telport_06041003853.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_logdisable_06041003908.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_logenable_06041003907.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_ses60_06041004100.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_ses7200_06041004101.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_ses59_06041004102.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_ses7201_06041004103.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_autorefresh_06041000001.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_autorefresh_06041000002.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_promptpasswd_06041000003.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_promptpasswd_06041000004.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_changewarn_06041000005.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_changewarn_06041000006.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpport_06041003841.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpport_06041003842.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpport_06041003843.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpport_06041003844.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpsport_06041003845.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpsport_06041003846.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpsport_06041003847.xml
-tc $SQAROOT/platform/1.0/verizon/testcases/asys/tcases/tc_httpsport_06041003848.xml


#
#------------------------------
# Checkout 
#------------------------------
-label finish
-nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
-nc $SQAROOT/config/$G_CONFIG/common/email.xml
