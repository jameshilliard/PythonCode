#! /bin/sh
#------------------------------------------------------------------
#Name: Hugo Kung
#
#Description:
# This script is used to check if www1.cbsd.org is available after configuring Parentol control
# This is a regression testcase, for more detail information, Please refer to its bug number in 
# sirid.actiontec.com
#
#Bug number: 14606
#
#Created time: 04-01-2009
#
#------------------------------------------------------------------

function verifyTarget
{
	rm -rf $tmpdir/$downfilename 2>/dev/null
	`wget www1.cbsd.org -P $tmpdir`&
	bgpid=`echo $!`
	sleep 10
	ls $tmpdir/$downfilename
	retinfo=`echo $?`
	if [ "$retinfo" = 0 ]; then
		echo "regression test bug 14606 PASS"
		exit 0
	else
		echo "Error : regression test bug 14606 FAIL"
		kill $bgpid
		exit 1
	fi
}


#
# Main entry
#
tmpdir="/home"
tmpdir=$1
downfilename="Default.aspx"
verifyTarget
