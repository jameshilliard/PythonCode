#!/bin/bash




# ETH
echo "ETH"
python Perf_test.py -t wan2lan -d w2l -l as -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/WAN/WANETH_DW.tcl" -c IXIA

python Perf_test.py -t wan2lan -d l2w -l as -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/WAN/WANETH_UP.tcl" -c IXIA

python Perf_test.py -t wan2lan -d bi -l as -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/WAN/WANETH_BI.tcl" -c IXIA

# VDSL bonged
echo "VDSL bonded"
python Perf_test.py -t dslam2lan -d d2l -l vb -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/VDSL_bonding/C2000A_VB_DW.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d l2d -l vb -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/VDSL_bonding/C2000A_VB_UP.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d bi -l vb -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/VDSL_bonding/C2000A_VB_BI.tcl" -c IXIA

# VDSL single
echo "VDSL single"
python Perf_test.py -t dslam2lan -d d2l -l vs -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/VDSL_single/C2000A_VS_DW.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d l2d -l vs -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/VDSL_single/C2000A_VS_UP.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d bi -l vs -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/VDSL_single/C2000A_VS_BI.tcl" -c IXIA

# ADSL
echo "ADSL single"
python Perf_test.py -t dslam2lan -d d2l -l as -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/ADSL_single/C2000A_AS_DW.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d l2d -l as -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/ADSL_single/C2000A_AS_UP.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d bi -l as -p CTLC2KA -f "/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/ADSL_single/C2000A_AS_BI.tcl" -c IXIA
