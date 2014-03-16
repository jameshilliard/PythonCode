#! /bin/sh

rm -f tmp.txt 2>/dev/null
for alltst in `ls *.tst`
do
  for i in `cat $alltst | grep '\-tc' | awk '{print $2}'`
  do
  	file=`echo $i | sed 's/$SQAROOT/\/root\/actiontec\/automation/'`
  	filename=`echo $file | awk -F '/' '{print $11}'`
	echo -n $filename >> tmp.txt
	echo -n ">" >> tmp.txt
  	cat $file | grep email | grep -v grep | awk -F '>' '{print $2}'| sed 's/<\/emaildesc//' >> tmp.txt
  done
done
