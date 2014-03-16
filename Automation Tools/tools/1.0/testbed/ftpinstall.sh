#!/bin/bash
perl ~/actiontec/automation/bin/1.0/common/clicfg.pl  -d $1 -i 22  -f ~/actiontec/automation/tools/1.0/testbed/ftp_remote.txt -u root -p actiontec -m "ftpupdate*" -o 1000 

