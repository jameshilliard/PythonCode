#!/bin/sh
#------------------------------------------------------------------
#Name: Robin Ru
#
#Description:
# This script is used to parse result file of wget.
#
#                 block     accessable
# positive(p):    TRUE        FALSE
# negative(n):    FALSE       TRUE
#
#Created time: 04-01-2009
#
#------------------------------------------------------------------

function wgetResultParser
{
    echo " Verify result of $resultfilename"
    echo "  ------------------------- "
    echo " Content = $resultfilename"
    echo "  ------------------------- "
	if [ ! -s $resultfilename ]; then
		echo "error: $resultfilename is empty!"
		exit 1
	fi
       cat $resultfilename | grep "Connection timed out" 
       if [ $? -eq 0 ]; then
         echo "$URLLink is block"
  	 blocktag=1
       else
	 echo "$URLLink is accessable"
	 blocktag=0
       fi

       if [ "$control" = "p" ]; then
          if [ $blocktag -eq 1 ]; then
            exit 0
          else
            exit 1
          fi
       fi

       if [ "$control" = "n" ]; then
          if [ $blocktag -eq 1 ]; then
            exit 1
          else
            exit 0
          fi
       fi
}


#
# Main entry
#
resultfilename=$1
URLLink=$2
control=$3
wgetResultParser
