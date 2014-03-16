#!/usr/bin/bash

#   Name: displayStatusOfConnection.sh
#   Auth: Aleon
#   Date: 12.14/2010
#
#   Description: Display the number of status for client connection on GUI.
#

while [ $# -gt 0 ]
do 
    case $1 in
	-f)
	    file=$2
	    echo "The file is : $file\n"
	    shift 2
	    ;;
	-e)
	    expect=$2
	    echo "The selection key word is : $expect\n"
	    shift 2
	    ;;
	-l)
	    log=$2
	    echo "The selection key word is : $log\n"
	    shift 2
	    ;;

	-h)
	    echo "displayNumOfClient.sh -f <file> -e <Key word> -h <help>"
	    exit 1
	    ;;

	esac

done
key="(ip($expect))"
echo $key

echo $log

index=0
arr=(`cat $file`)
array_length=${#arr[@]}

echo "Total line is: ${array_length}"

i=0
while [ $i -lt $array_length ]
do 

    echo ${arr[$i]} | grep $key
    #echo $i
    if [ $? == 0 ]; then
	    
	    num_1=`expr $i - 4`
	    echo $num_1
	    #echo ${arr[$i]}
	    #echo ${arr[$num_1]}
	    export `echo ${arr[$num_1]} |awk '{print "PC_NUM=" substr($0,2,1)}'`

	    let PC_NUM=$PC_NUM+1 
	    echo "PC_NUM=${PC_NUM}" > $log/PC_NUM.txt
	    
	    echo "-| -------------------"
	    echo "-| The index of client is: ${PC_NUM}"
	    echo "-| -------------------"
	
	    num_2=`expr $i + 6`
	    #echo $num_2
	    export `echo ${arr[$num_2]} |awk '{print "PC_MAC=" substr($0,15,17)}'` 
	    echo "PC_MAC=${PC_MAC}" > $log/PC_MAC.txt
	    echo "-| -------------------"
	    echo "-| MAC Address is: ${PC_MAC}"
	    echo "-| -------------------"

	    num_3=`expr $i + 24`
	    #echo ${arr[$num_3]}
	    export `echo ${arr[$num_3]} |awk '{print "PC_TYPE=" substr($0,7,1)}'`
	    #echo $PC_TYPE
	    if [ $PC_TYPE == 1 ]; then 
		PC_TYPE=Ethernet
	    else
		PC_TYPE=Coax
	    fi
	    echo "PC_TYPE=${PC_TYPE}" > $log/PC_TYPE.txt
	    echo "-| -------------------"
	    echo "-| The type of interface is: ${PC_TYPE}"
	    echo "-| -------------------"

	fi

    let i=$i+1
done

exit 0


