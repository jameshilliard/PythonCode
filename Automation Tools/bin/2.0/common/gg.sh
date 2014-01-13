#!/bin/sh

loop_time=1
run_file="run.cfg"
is_mail=0


# dbus required
if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
    ## if not found, launch a new one
    eval `dbus-launch --auto-syntax `
    echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
fi


while [ -n "$1" ];
do
    case "$1" in
    *)
        argx=$1
        
        if [ -f $argx ] ;then
            echo "run file : $argx !"
            run_file=$argx
        else
            echo $argx|grep -o "[^0-9]" 1>/dev/null

            rc=$?

            if [ $rc -gt 0 ]; then
                echo "loop time : $argx"
                loop_time=$argx
            else
                if [ "mail" == "$argx" ] ;then
                    is_mail=1
                else
                    is_mail=0
                fi
            fi
        fi
        
        shift 1
        ;;
    esac
done

for i in `seq 1 $loop_time`
do
    if [ $is_mail -eq 1 ] ;then
        $SQAROOT/bin/2.0/common/ATE -e -f $run_file --mail
    
        for idx in `seq 1 999`
        do
            fn=`echo $run_file|sed "s/\(run\)/\1${idx}/g"`
    
            if [ -f ${fn} ]; then
                $SQAROOT/bin/2.0/common/ATE -e -f ${fn} --mail
            else
                break
            fi
        done
    elif [ $is_mail -eq 0 ] ;then
        $SQAROOT/bin/2.0/common/ATE -e -f $run_file
    
        for idx in `seq 1 999`
        do
            fn=`echo $run_file|sed "s/\(run\)/\1${idx}/g"`
    
            if [ -f ${fn} ]; then
                $SQAROOT/bin/2.0/common/ATE -e -f ${fn}
            else
                break
            fi
        done
    fi
done
