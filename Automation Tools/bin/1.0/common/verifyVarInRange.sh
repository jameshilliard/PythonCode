#!/bin/bash
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
    
    *)
        echo $usage
        exit 1
        ;;
    esac
done

abs() { cha=`echo $1 | tr -d -`
#    echo "cha=$cha"
}

cecho() {
    case $1 in
        black_fore)
            echo -e "\033[30m $2 \033[0m"
            ;;
        red_fore)
            echo -e "\033[31m $2 \033[0m"
            ;;
        green_fore)
            echo -e "\033[32m $2 \033[0m"
            ;;
        blown_fore)
            echo -e "\033[33m $2 \033[0m"
            ;;
        blue_fore)
            echo -e "\033[34m $2 \033[0m"
            ;;
        purple_fore)
            echo -e "\033[35m $2 \033[0m"
            ;;
        black_back)
            echo -e "\033[40m $2 \033[0m"
            ;;
        red_back)
            echo -e "\033[41m $2 \033[0m"
            ;;
        green_back)
            echo -e "\033[42m $2 \033[0m"
            ;;
        blown_back)
            echo -e "\033[43m $2 \033[0m"
            ;;
        blue_back)
            echo -e "\033[44m $2 \033[0m"
            ;;
        purple_back)
            echo -e "\033[45m $2 \033[0m"
            ;;
        blue_red)
            echo -e "\033[42;31m $2 \033[0m"
    esac
}

colourecho(){
    echo -e "\033[41m $1 \033[0m"
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

    var1=`grep ".*$varName" $basefile |awk -F = '{print $(NF)}'`
    var2=`grep ".*$varName" $verifyfile |awk -F = '{print $(NF)}'`
    echo "in the file $basefile :$varName = $var1"
    echo "in the file $verifyfile :$varName = $var2"
    if [ -z "$var1" -o -z "$var2" ]; then
        cecho red_back "at least one of the variables is empty"
        exit 1
    fi
    let "tmp=$var1-$var2"
    abs $tmp

    if [ $cha -le $range ]; then
        rc=0
    else
        rc=1
    fi
    }
#echo ${VarArr[@]}
for varName in "${VarArr[@]}"
do
    echo "variale name is : $varName"
    compare
    if [ $rc -eq 0 ];then
        let "result=$result+0"
    else
        let "result=$result+1"
#        colour black_blue
#        echo -e "\033[41m the value difference is $cha \033[0m"
        cecho red_back "the value difference is : $cha"
    fi
done

cecho green_fore "the number of variable out of range : $result"

exit $result
