#!/bin/bash
echo `date` | mutt -s "`hostname`:BHR2 DUT INFO" celab@actiontec.com shqa@actiontec.com  -a /tmp/dutstatus.txt