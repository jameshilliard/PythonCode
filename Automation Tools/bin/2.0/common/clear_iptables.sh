#!/bin/bash

echo "================================================================================"

#accept-all policy
IPT='iptables'

$IPT -t nat -F
$IPT -t nat -X
$IPT -t nat -P PREROUTING ACCEPT
$IPT -t nat -P POSTROUTING ACCEPT
$IPT -t nat -P OUTPUT ACCEPT
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -t mangle -P PREROUTING ACCEPT
$IPT -t mangle -P INPUT ACCEPT
$IPT -t mangle -P FORWARD ACCEPT
$IPT -t mangle -P OUTPUT ACCEPT
$IPT -t mangle -P POSTROUTING ACCEPT
$IPT -F
$IPT -X
$IPT -P FORWARD ACCEPT
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -t raw -F
$IPT -t raw -X
$IPT -t raw -P PREROUTING ACCEPT
$IPT -t raw -P OUTPUT ACCEPT


echo 'Done!'
