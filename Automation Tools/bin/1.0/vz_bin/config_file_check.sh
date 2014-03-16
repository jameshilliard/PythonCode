#! /bin/bash -w
file1=$1
file2=$2
shift
shift
result=1
while [ $# -gt 0 ]
do
    diff $file1 $file2 | grep $1
    result=`expr $result \* $?`
    shift
done
echo $result
if [ $result -gt 0 ]
    then
	exit 0
    else
	exit 1
fi
