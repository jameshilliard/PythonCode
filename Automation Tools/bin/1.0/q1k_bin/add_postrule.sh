#! /bin/sh
#################################################
#  add_postrule.sh 
#
#  
# 
#
#  Hugo 12/04/2009
#################################################

if [ "$#" != "6" ]; then
   echo "Usage: add_postrule.sh -s <source net> -o <out interface> -t <to source>"
   exit 1
fi

while [ $# -gt 0 ]
do
  case "$1" in
    -s)
      source_net=$2
      shift
      shift
      ;;
    -o)
      out_interf=$2
      shift
      shift
      ;;
    -t)
      to_target=$2
      shift
      shift
      ;;
    *)
      echo "Usage: add_postrule.sh -s <source net> -o<out interface> -t<to source>"
      exit 1
  esac
done


sshcli.pl -t 500 -l $G_CURRENTLOG -o $G_CURRENTLOG/add_iptable_rule.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "iptables -t nat -A POSTROUTING -s $source_net -o $out_interf -j SNAT --to-source $to_target"

