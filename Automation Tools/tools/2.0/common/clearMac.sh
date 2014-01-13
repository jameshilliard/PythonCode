#!/bin/bash - 
#===============================================================================
ifconfig eth2 173.164.155.66/24 up
ifconfig 
ping 173.164.155.65
telnet 173.164.155.65 23
Username:ADMIN
Password:PASSWORD


Invalid Login... Please Try Again


User Access Verification

Username:ADMIN    
Password:

Last Login Date      : Apr 19 2013 21:31:20 
Last Login Type      : IP Session(CLI)  - 173.164.155.66
Login Failures       : 0 (Since Last Login)
                     : 7 (Total for Account)
TA5000>enable
TA5000#clear
% Invalid or incomplete command
TA5000#clear mac address
TA5000#clear mac address-table 
clicmd -d 173.164.155.65 -P 23 -y telnet -u 'ADMIN' -p 'PASSWORD' -v "enable" -v "clear mac address-table" -o /temp/clearMac.log
