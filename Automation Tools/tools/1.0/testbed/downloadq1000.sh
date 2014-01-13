#!/bin/bash
rm -f bcm*.img
lftp -e "cd Release/broadcom/VDSL6368/$1; mget *.img;exit" -u shanghai,software sengftp.actiontec.com
