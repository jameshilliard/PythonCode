#!/bin/bash
REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"

#colour_scr

usage="verifyVarInRange.sh -b <base file> -f <verify file> -r <range> -e <varName> ... -e <varName> -n <varName>"

result=0
rc=0
VarArr=()

while [ -n "$1" ];
do
    case "$1" in
        -e)
            VarArr=("${VarArr[@]}" $2)

            shift 2
            ;;

        -n)
            nVarArr=("${VarArr[@]}" $2)

            shift 2
            ;;

        -r)
            range=$2

            shift 2
            ;;
        -d)
            difference=$2
            shift 2
            ;;

        -b)
            basefile=$2

            echo "basefile name : ${basefile}"

            shift 2
            ;;

        -f)
            verifyfile=$2

            echo "verifyfile name : ${verifyfile}"

            shift 2
            ;;

        -var1)
            var1=$2
            shift 2
            ;;

        -var2)
            var2=$2
            shift 2
            ;;


        *)
            echo $usage
            exit 1
            ;;
    esac
done

abs() { tmp=`echo $1 | tr -d -`
}

cecho() {
    case $1 in
        black_fore)
            echo -e "$2 "
            ;;
        red_fore)
            echo -e "$2 "
            ;;
        green_fore)
            echo -e "$2 "
            ;;
        blown_fore)
            echo -e "$2 "
            ;;
        blue_fore)
            echo -e "$2 "
            ;;
        purple_fore)
            echo -e "$2 "
            ;;
        black_back)
            echo -e "$2 "
            ;;
        red_back)
            echo -e "$2 "
            ;;
        green_back)
            echo -e "$2 "
            ;;
        blown_back)
            echo -e "$2 "
            ;;
        blue_back)
            echo -e "$2 "
            ;;
        purple_back)
            echo -e "$2 "
            ;;
        blue_red)
            echo -e "\033[42;31m $2 "
    esac
}

colourecho(){
    echo -e " $1 "
}

if [ -e $basefile ]; then
    echo ""
else
    cecho red_back "the file $basefile is no found"
    exit 1
fi

if [ -e $verifyfile ]; then
    echo ""
else
    cecho red_back "the file $verifyfile is no found"
    exit 1
fi

compare(){

    if [ -n "$basefile" ] ;then
        var1=`grep ".*$varName" $basefile |awk -F = '{print $(NF)}'`
        echo "in the file $basefile :$varName = $var1"
    else
        echo "first  number: $var1"
    fi

    if [ -n "$verifyfile" ] ;then
        var2=`grep ".*$varName" $verifyfile |awk -F = '{print $(NF)}'`
        echo "in the file $verifyfile :$varName = $var2"
    else
        echo "second number: $var2"
    fi

    if [ -z "$var1" -o -z "$var2" ]; then
        cecho red_back "at least one of the variables is empty"
        exit 1
    fi
    let "tmp=$var1-$var2"    
    abs $tmp
    echo "Actual difference is : $tmp"
    if [ -n "$difference" ];then
        echo "Expect difference is : $difference"
        let tmp=$tmp-$difference
        abs $tmp
    fi
    if [ $tmp -le $range ]; then
        rc=0
    else
        rc=1
    fi
}
#echo ${VarArr[@]}
if [ ${#VarArr[@]} -ne 0 ] ;then
    for varName in "${VarArr[@]}"
    do
        echo "variale name is : $varName"
        compare
        if [ $rc -eq 0 ];then
            let "result=$result+0"
        else
            let "result=$result+1"
            cecho red_back "the value difference is : $tmp"
        fi
    done
else
    echo "Expect range : $range"
    compare
    if [ $rc -eq 0 ];then
        let "result=$result+0"
        echo "pass"
    else
        let "result=$result+1"
        if [ -n "$difference" ];then
            let a=$difference-$range
            let b=$difference+$range
            echo "AT_ERROR :  Actual difference out of range!"
            echo "$difference-$range=$a < Actual difference should < $difference+$range=$b"
        else
            echo "AT_ERROR :  Actual difference out of range!"
        fi
    fi
fi

exit $result
