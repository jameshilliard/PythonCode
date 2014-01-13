#! /usr/bin/bash -w

active_string=`grep minutes $1 | tr -d "[a-z A-Z \" ( ) : ,]"`
echo $active_string
if [ $active_string -gt 2 ]
    then
	exit 1
    else
	exit 0
fi

