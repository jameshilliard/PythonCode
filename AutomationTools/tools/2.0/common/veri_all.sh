#!/bin/bash


cfg_loc='/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/Performance/IXVeriwave'


# VDSL bonged

echo "VDSL bonded"
python Perf_test.py -t dslam2wifi -d d2l -l vb -p CTLC2KA -f "${cfg_loc}/VB_D.wml" -c VERI

python Perf_test.py -t dslam2wifi -d l2d -l vb -p CTLC2KA -f "${cfg_loc}/VB_U.wml" -c VERI

python Perf_test.py -t dslam2wifi -d bi -l vb -p CTLC2KA -f "${cfg_loc}/VB_B.wml" -c VERI

# VDSL single

echo "VDSL single"
python Perf_test.py -t dslam2wifi -d d2l -l vs -p CTLC2KA -f "${cfg_loc}/VS_D.wml" -c VERI

python Perf_test.py -t dslam2wifi -d l2d -l vs -p CTLC2KA -f "${cfg_loc}/VS_U.wml" -c VERI

python Perf_test.py -t dslam2wifi -d bi -l vs -p CTLC2KA -f "${cfg_loc}/VS_B.wml" -c VERI

# ADSL

#echo "ADSL single"
#python Perf_test.py -t dslam2wifi -d d2l -l as -p CTLC2KA -f "${cfg_loc}/AS_D.wml" -c VERI

#python Perf_test.py -t dslam2wifi -d l2d -l as -p CTLC2KA -f "${cfg_loc}/AS_U.wml" -c VERI

#python Perf_test.py -t dslam2wifi -d bi -l as -p CTLC2KA -f "${cfg_loc}/AS_B.wml" -c VERI

# ADSL bonded

#echo "ADSL bonded"
#python Perf_test.py -t dslam2wifi -d d2l -l ab -p CTLC2KA -f "${cfg_loc}/AB_D.wml" -c VERI

#python Perf_test.py -t dslam2wifi -d l2d -l ab -p CTLC2KA -f "${cfg_loc}/AB_U.wml" -c VERI

#python Perf_test.py -t dslam2wifi -d bi -l ab -p CTLC2KA -f "${cfg_loc}/AB_B.wml" -c VERI

# ETH

echo "ETH"
python Perf_test.py -t wan2wifi -d w2l -l wan -p CTLC2KA -f "${cfg_loc}/wan_D.wml" -c VERI

python Perf_test.py -t wan2wifi -d l2w -l wan -p CTLC2KA -f "${cfg_loc}/wan_U.wml" -c VERI

python Perf_test.py -t wan2wifi -d bi -l wan -p CTLC2KA -f "${cfg_loc}/wan_B.wml" -c VERI
