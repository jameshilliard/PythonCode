#!/bin/bash

# check input parameter list
if [ $# -lt 1 ]
then
    echo "bad argument count,must more than 1";
    echo "Usage : $0 TESTSUITE_FILE [VARIABLE_TABLE [VARIABLE_TABLE]..]";
    exit -1;
fi

# backup old 
tst_dir="./tsuites"
if [ -e $tst_dir ]
then
    echo "$tst_dir is exist";
else
    mkdir $tst_dir;
fi

tm=`date +%y%m%d-%H%M%S`;
tsfile=$tst_dir"/run_tst_$tm.tst";
tcfile=$1;

# combine new test suite file
for args in $@
do
    if [ "$args" = "$tcfile" ]
    then
        echo 'ignore'
    else
        if [ -e $args ]
        then
            echo "append file $args"
            echo "#{==>from file $args" >> $tsfile;
            cat $args >> $tsfile;
            echo "#}==>end from file $args" >> $tsfile;
            echo -e "\n\n" >> $tsfile;
            echo "append file $args end"
        else
            echo "== file $args is not exist!";
            exit -2;
        fi
    fi
done
echo "append file $tcfile"
echo "#{==>from file $tcfile" >> $tsfile;
cat $tcfile >> $tsfile;
echo "#}==>end from file $tcfile" >> $tsfile;

# make sylink
ln -sf $tsfile current.tst;

# load gflaunch.pl to run test suite
perl $SQAROOT/bin/1.0/common/gflaunch.pl -f $tsfile

#perl $SQAROOT/bin/1.0/common/gflaunch.pl  -v G_BUILD=$SQAROOT/download/MI424WR-GEN2.rmt -v G_USER=$MY_EMAIL -f $SQAROOT/testsuites/1.0/q2000h/sanity/$1  -v G_HTTP_DIR=test -v G_TESTBED=$MY_TB -v G_PROD_TYPE=MC524WR -v G_CC=$MY_DIST
