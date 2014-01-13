#!/bin/sh 
# get info by telnet
#!/bin/bash
# print version info
VER="1.0.1"
echo "$0 version : ${VER}"
#2011-11-10 fix BUG: doesn't output variable to file


bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $1.tmp

tmpvar=""
for line in `cat $1.tmp`
do
    tmpvar=`echo $line`" "$tmpvar
done

echo $tmpvar | tee $1

exit 0
