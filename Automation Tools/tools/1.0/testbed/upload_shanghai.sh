#!/bin/bash
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d shesxd001-pc1 -u root -p actiontec -v "cd $SQAROOT/download" -v "put MI424WR-GEN2.rmt" -m "sftp> "
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d shesxd001-pc3 -u root -p actiontec -v "cd $SQAROOT/download" -v "put MI424WR-GEN2.rmt" -m "sftp> "
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d shesxd001-pc5 -u root -p actiontec -v "cd $SQAROOT/download" -v "put MI424WR-GEN2.rmt" -m "sftp> "
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d shesxd001-pc7 -u root -p actiontec -v "cd $SQAROOT/download" -v "put MI424WR-GEN2.rmt" -m "sftp> "
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d shesxd001-pc9 -u root -p actiontec -v "cd $SQAROOT/download" -v "put MI424WR-GEN2.rmt" -m "sftp> "
perl $SQAROOT/bin/1.0/common/clicfg.pl -o 300 -n -c  -d shesxd001-pc11 -u root -p actiontec -v "cd $SQAROOT/download" -v "put MI424WR-GEN2.rmt" -m "sftp> "
rm clicfg* -f
