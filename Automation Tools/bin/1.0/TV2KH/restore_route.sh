#!/bin/bash
route del default
route add default gw $G_HOST_GW0_1_0 dev $G_HOST_IF0_1_0
ifconfig
route -n
