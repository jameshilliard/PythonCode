#!/bin/bash


cfg_loc='/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate/1518'
cfg_loc_ori='/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXAutomate'

# LAN 2 LAN
echo "LAN 2 LAN"
python Perf_test.py -t lan2lan -d bi -l lbil -p CTLC2KA -f "${cfg_loc}/LAN/C2000A_LAN_BI.tcl" -c IXIA

python Perf_test.py -t lan2lan -d dw -l l2l -p CTLC2KA -f "${cfg_loc}/LAN/C2000A_LAN_DW.tcl" -c IXIA

# VDSL bonged
echo "VDSL bonded"
python Perf_test.py -t dslam2lan -d d2l -l vb -p CTLC2KA -f "${cfg_loc}/VDSLB/C2000_VB_DW_1518.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d l2d -l vb -p CTLC2KA -f "${cfg_loc}/VDSLB/C2000_VB_UP_1518.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d bi -l vb -p CTLC2KA -f "${cfg_loc}/VDSLB/C2000_VB_BI_1518.tcl" -c IXIA

# VDSL single
echo "VDSL single"
python Perf_test.py -t dslam2lan -d d2l -l vs -p CTLC2KA -f "${cfg_loc}/VDSLS/C2000_VS_DW_1518.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d l2d -l vs -p CTLC2KA -f "${cfg_loc}/VDSLS/C2000_VS_UP_1518.tcl" -c IXIA

python Perf_test.py -t dslam2lan -d bi -l vs -p CTLC2KA -f "${cfg_loc}/VDSLS/C2000_VS_BI_1518.tcl" -c IXIA

# ADSL
#echo "ADSL single"
#python Perf_test.py -t dslam2lan -d d2l -l as -p CTLC2KA -f "${cfg_loc}/ADSLS/C2000_AS_DW_1518.tcl" -c IXIA

#python Perf_test.py -t dslam2lan -d l2d -l as -p CTLC2KA -f "${cfg_loc}/ADSLS/C2000_AS_UP_1518.tcl" -c IXIA

#python Perf_test.py -t dslam2lan -d bi -l as -p CTLC2KA -f "${cfg_loc}/ADSLS/C2000_AS_BI_1518.tcl" -c IXIA

# ETH
echo "ETH"
python Perf_test.py -t wan2lan -d w2l -l wan -p CTLC2KA -f "${cfg_loc_ori}/WAN/WANETH_DW.tcl" -c IXIA

python Perf_test.py -t wan2lan -d l2w -l wan -p CTLC2KA -f "${cfg_loc_ori}/WAN/WANETH_UP.tcl" -c IXIA

python Perf_test.py -t wan2lan -d bi -l wan -p CTLC2KA -f "${cfg_loc_ori}/WAN/WANETH_BI.tcl" -c IXIA
