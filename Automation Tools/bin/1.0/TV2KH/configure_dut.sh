#!/bin/bash
#echo $G_TST_TITLE
usage="bash $0 <configureFile>"
USAGE(){
cat <<usge
    USAGE : bash $0 [-test] configureFile  

    OPTIONS:

	  -test: setup the variables using in the scripts

    EXAMPLES:   bash $0 -test \$U_PATH_SANITYCFG/B-\$U_DUT_TYPE-BA.DMZ-001-C001

    NOTES:  if you want to use this case in testcase ,please make sure you set the variable G_TST_TITLE
            right,this script use it to decide if this case is a sanity case or wireless case or tr69 case etc..
            eg. set the G_TST_TITLE to sanity,then the script will use the config file under U_PATH_SANITYCFG
usge
}
while [ -n "$1" ];
do
    case "$1" in
    -test)
        G_TST_TITLE=sanity
        U_PATH_SANITYCFG=/root/automation/platform/1.0/TV2KH/config/31.60L.14/sanity/
        U_PATH_TBIN=/root/automation/bin/1.0/TV2KH
        U_DUT_TYPE=TV2KH
        U_AUTO_CONF_PARAM='-d 0'
        shift 1
        ;;
    -help|-h)
        USAGE
        exit 1
        ;;
    *)
        file=$1
        shift 1
        ;;
    esac
done

cd $U_PATH_TBIN/AutoConfig
echo "python -u autoconf.py $U_DUT_TYPE $file $U_AUTO_CONF_PARAM"
python -u autoconf.py $U_DUT_TYPE $file $U_AUTO_CONF_PARAM
exit $?
