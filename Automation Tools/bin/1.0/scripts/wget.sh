#!/bin/bash
while [ 1 ]
do
    xterm -e wget http://10.10.10.1/junk/ftptest.libcab -O http.libcab &
    xterm -e wget ftp://root:actiontec@10.10.10.1/Download/ftptest.libcab -O test1.libcab  &
    wget ftp://root:actiontec@10.10.10.1/Download/ftptest.libcab -O test2.libcab  
done
