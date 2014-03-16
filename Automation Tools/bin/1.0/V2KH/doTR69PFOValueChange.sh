#!/bin/bash
$U_PATH_TBIN/changeValueofRecord.sh -n ppp -v $U_DUT_CUSTOM_PPP_USER -f "$U_PATH_TR069CFG/B-GEN-TR98-BA.PFO-022-C-FUN-001";
$U_PATH_TBIN/changeValueofRecord.sh -n ppppwd -v $U_DUT_CUSTOM_PPP_PWD -f "$U_PATH_TR069CFG/B-GEN-TR98-BA.PFO-022-C-FUN-001";
$U_PATH_TBIN/changeValueofRecord.sh -n portForwardSrvAddr -v $G_HOST_TIP0_1_0 -f "$U_PATH_TR069CFG/B-GEN-TR98-BA.PFO-008-C-FUN-001";
$U_PATH_TBIN/changeValueofRecord.sh -n portForwardSrvWanAddr -v $G_HOST_TIP1_1_0 -f "$U_PATH_TR069CFG/B-GEN-TR98-BA.PFO-008-C-FUN-001";
