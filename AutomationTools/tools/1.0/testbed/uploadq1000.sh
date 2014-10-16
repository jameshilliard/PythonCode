#!/bin/bash
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d esxd002-pc7 -u root -p actiontec -v "cd $SQAROOT/download" -v "put Q1000H.img" -m "sftp> "
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d esxd002-pc9 -u root -p actiontec -v "cd $SQAROOT/download" -v "put Q1000H.img" -m "sftp> "
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d esxd002-pc11 -u root -p actiontec -v "cd $SQAROOT/download" -v "put Q1000H.img" -m "sftp> "
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d esxd002-pc13 -u root -p actiontec -v "cd $SQAROOT/download" -v "put Q1000H.img" -m "sftp> "

