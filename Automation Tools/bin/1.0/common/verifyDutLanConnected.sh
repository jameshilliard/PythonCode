#!/bin/bash

perl $G_SQAROOT/bin/$G_BINVERSION/common/verifyPing.pl -d $G_PROD_IP_BR0_0_0 -I $G_HOST_IF0_1_0 -t 10 -l $G_CURRENTLOG 2>/dev/null

if [ $? -eq 0 ]; then
	exit 0
else
    echo -e "\033[33m verifyPing.pl failed! \033[0m"
	exit 1
fi
