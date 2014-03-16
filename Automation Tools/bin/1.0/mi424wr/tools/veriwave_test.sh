#!/bin/bash

# Throughput
# PBTC001 = UDP Upstream 802.11g - _1 = Static IP, _2 = DHCP
# PBTC002 = UDP Downstream 802.11g - _1 = Static IP, _2 = DHCP
# PBTC003 = UDP Bi-directional 802.11g - _1 = Static IP, _2 = DHCP
# PBTC001_Quick = Like PBTC001, but a fast test of 1 test case

# Packet loss
# PBTC019 - PBTC020 = Upstream/Downstream 802.11g

# Latency
# PBTC015 - PBTC016 = Upstream/Downstream 802.11g ; _1 = Static, _2 = DHCP

# TCP Goodput
# PBTC027 - PBTC028 = Upstream/Downstream ; _1 = Static, _2 = DHCP

# Maximum forwarding rate
# PBTC023 - PBTC024 = Upstream/Downstream ; _1 = Static, _2 = DHCP

# Veriwave tests to run
VW_TESTS="PBTC001_1 PBTC002_1 PBTC003_1"

# DUT information
DUT_IP="192.168.1.1"
DUT_USER="admin"
DUT_PASS="admin1"
DUT_VER=2

# Where the tests are stored
test1=$HOME/vwautomation/MasterTestPlan/BHR2-WiFi_to_LAN_Ethernet_11n_1
test2=$HOME/vwautomation/MasterTestPlan/BHR2-WiFi_to_LAN_Ethernet_11n_2
test3=$HOME/vwautomation/MasterTestPlan/BHR2-WiFi_to_LAN_Ethernet_11g
test4=$HOME/vwautomation/MasterTestPlan/BHR2_nwk10
test5=$HOME/vwautomation/MasterTestPlan/BHR2_nwk10_lan_to_lan
test6=$HOME/vwautomation/MasterTestPlan/BHR2_nwk10_wan_to_lan

# Message log
MESSAGES=$HOME/messages$$.log

# Test names for the above
t1="Wireless 802.11n LAN to Ethernet LAN using encryption types: None, WPA-PSK-AES, WPA2-PSK-AES"
t2="Wireless 802.11n LAN to Ethernet LAN using encryption types: WEP-Open-40, WEP-Open-128, WPA2-PSK-TKIP"
t3="WAN to LAN"

# Which tests to run based on above. 1 = run, 0 = dont
do_test1=0
do_test2=0
do_test3=1
do_test4=0
do_test5=0
do_test6=0
do_test7=0

# Mail list for results
MAIL_LIST="cborn@actiontec.com"

# Archive directory
ARCHIVE=$HOME/veriwave_archive

# Python 2.4
python_old=/opt/python2.4/bin/python

# Regular Python version
python_norm=/usr/bin/python2.6

# Python bin path
python_bin=/usr/bin/python

# Ruby script path
RUBY_HOME=$HOME/ruby_scripts

# Assign the model and firmware version variable by calling the script to get it for us
DUT_MODEL_AND_FIRMWARE_VERSION=`$RUBY_HOME/get_fwv.rb -i $DUT_IP -u $DUT_USER -p $DUT_PASS`

# Revert to Python 2.4 as required by Veriwave
rm -f $python_bin
cp $python_old $python_bin

# Trap method to do script clean up upon exiting or being killed
trap 'rm -f $python_bin >/dev/null 2>&1 && rm -f "${MESSAGES}" >/dev/null 2>&1 && cp $python_norm $python_bin >/dev/null 2>&1' 0
trap "exit 2" 1 2 3 15

# Function to run a test
run_test () {
    cd $2
    python masterplan.py --testNames="${VW_TESTS}"
    END_TS=`date +"%m-%d-%Y %H:%M %Z"`
    END_TS1=`date +"%m%d%Y-%H%M"`
    echo -e "\nFinished $1 test at ${END_TS}." >> $3
}

# Function to archive results, or call the archiving command
create_archive () {
    SUMMARY="$ARCHIVE/tmp/veriwave_summary_${DUT_MODEL_AND_FIRMWARE_VERSION}"
    [ -a $ARCHIVE ] || mkdir $ARCHIVE
    [ -a $ARCHIVE/tmp ] || mkdir $ARCHIVE/tmp
    ruby $RUBY_HOME/gather.rb -o "${SUMMARY}.pdf" -a $ARCHIVE/tmp -r $2 -b $1 --bhr $DUT_VER -i $DUT_IP -u $DUT_USER -p $DUT_PASS --silent --excel "${SUMMARY}.xls"
}

# Function to tar everything up in a nice and tidy package
archive () {
    archive_name="veriwave_results_${END_TS1}_${DUT_MODEL_AND_FIRMWARE_VERSION}.tgz"
    current_directory=`pwd`
    cd $ARCHIVE/tmp
    tar cfz $archive_name ./*
    mv $archive_name $ARCHIVE
    cd $current_directory
    echo -e "\nCreated archive file $archive_name in $ARCHIVE containing all the original Veriwave result documents." >> "${MESSAGES}"
}

# Function to email results
mail_test () {
    zip -D "${SUMMARY}.zip" "${SUMMARY}".*
    mutt -s "Veriwave test results: ${END_TS} ${DUT_MODEL_AND_FIRMWARE_VERSION}" $MAIL_LIST -a "${SUMMARY}.zip" < "${MESSAGES}"
    rm -f "${SUMMARY}.zip"
}

# uncomment while, do, and done lines for infinite test loop
#while :
# do
    # Test 1
    if [ $do_test1 -eq 1 ]; then
        # Remove old results from prior test
        rm -rf "${test1}/results"
        # Begin testing
        echo -e "Started testing $t1 on `date +"%m-%d-%Y %H:%M %Z"`.\n" >> "${MESSAGES}"
        run_test "$t1" "${test1}" "${MESSAGES}"
        # End loop
        echo -e "\nArchiving ${t1}.\n" >> "${MESSAGES}"
        create_archive "${test1}" "${test1}/results/Benchmarks/Performance"
        archive
        echo -e "\nSee the attached summary PDF for results." >> "${MESSAGES}"
        # Mail out
        mail_test

        # Remove message log
        rm -f "${MESSAGES}"
        rm -rf "${ARCHIVE}/tmp"
    fi

    # Test 2
    if [ $do_test2 -eq 1 ]; then
        # Remove old results from prior test
        rm -rf "${test2}/results"
        # Begin testing
        echo -e "Started testing $t2 on `date +"%m-%d-%Y %H:%M %Z"`.\n" >> "${MESSAGES}"
        run_test "$t2" "${test2}" "${MESSAGES}"
        # End loop
        echo -e "\nArchiving ${t2}.\n" >> "${MESSAGES}"
        create_archive "${test2}" "${test2}/results/Benchmarks/Performance"
        archive
        echo -e "\nSee the attached summary PDF for results." >> "${MESSAGES}"
        # Mail out
        mail_test

        # Remove message log
        rm -f "${MESSAGES}"
        rm -rf "${ARCHIVE}/tmp"
    fi

    # Test 3
    if [ $do_test3 -eq 1 ]; then
        # Remove old results from prior test
        rm -rf "${test3}/results"
        # Begin testing
        echo -e "Started testing $t3 on `date +"%m-%d-%Y %H:%M %Z"`.\n" >> "${MESSAGES}"
        run_test "$t3" "${test3}" "${MESSAGES}"
        # End loop
        echo -e "\nArchiving ${t3}.\n" >> "${MESSAGES}"
        create_archive "${test3}" "${test3}/results/Benchmarks/Performance"
        archive
        echo -e "\nSee the attached summary PDF for results." >> "${MESSAGES}"
        # Mail out
        mail_test

        # Remove message log
        rm -f "${MESSAGES}"
        rm -rf "${ARCHIVE}/tmp"
    fi

    # Test 4
    if [ $do_test4 -eq 1 ]; then
        # Remove old results from prior test
        rm -rf "${test4}/results"
        # Begin testing
        echo -e "Started testing $t4 on `date +"%m-%d-%Y %H:%M %Z"`.\n" >> "${MESSAGES}"
        run_test "$t4" "${test4}" "${MESSAGES}"
        # End loop
        echo -e "\nArchiving ${t4}.\n" >> "${MESSAGES}"
        create_archive "${test4}" "${test4}/results/Benchmarks/Performance"
        archive
        echo -e "\nSee the attached summary PDF for results." >> "${MESSAGES}"
        # Mail out
        mail_test

        # Remove message log
        rm -f "${MESSAGES}"
        rm -rf "${ARCHIVE}/tmp"
    fi

    # Test 5
    if [ $do_test5 -eq 1 ]; then
        # Remove old results from prior test
        rm -rf "${test5}/results"
        # Begin testing
        echo -e "Started testing $t5 on `date +"%m-%d-%Y %H:%M %Z"`.\n" >> "${MESSAGES}"
        run_test "$t5" "${test5}" "${MESSAGES}"
        # End loop
        echo -e "\nArchiving ${t5}.\n" >> "${MESSAGES}"
        create_archive "${test5}" "${test5}/results/Benchmarks/Performance"
        archive
        echo -e "\nSee the attached summary PDF for results." >> "${MESSAGES}"
        # Mail out
        mail_test

        # Remove message log
        rm -f "${MESSAGES}"
        rm -rf "${ARCHIVE}/tmp"
    fi

    # Test 6
    if [ $do_test6 -eq 1 ]; then
        # Remove old results from prior test
        rm -rf "${test6}/results"
        # Begin testing
        echo -e "Started testing $t6 on `date +"%m-%d-%Y %H:%M %Z"`.\n" >> "${MESSAGES}"
        run_test "$t6" "${test6}" "${MESSAGES}"
        # End loop
        echo -e "\nArchiving ${t6}.\n" >> "${MESSAGES}"
        create_archive "${test6}" "${test6}/results/Benchmarks/Performance"
        archive
        echo -e "\nSee the attached summary PDF for results." >> "${MESSAGES}"
        # Mail out
        mail_test

        # Remove message log
        rm -f "${MESSAGES}"
        rm -rf "${ARCHIVE}/tmp"
    fi

    # Test 7
    if [ $do_test7 -eq 1 ]; then
        # Remove old results from prior test
        rm -rf "${test7}/results"
        # Begin testing
        echo -e "Started testing $t7 on `date +"%m-%d-%Y %H:%M %Z"`.\n" >> "${MESSAGES}"
        run_test "$t7" "${test7}" "${MESSAGES}"
        # End loop
        echo -e "\nArchiving ${t7}.\n" >> "${MESSAGES}"
        create_archive "${test7}" "${test7}/results/Benchmarks/Performance"
        archive
        echo -e "\nSee the attached summary PDF for results." >> "${MESSAGES}"
        # Mail out
        mail_test

        # Remove message log
        rm -f "${MESSAGES}"
        rm -rf "${ARCHIVE}/tmp"
    fi

#done
sendmail -q
