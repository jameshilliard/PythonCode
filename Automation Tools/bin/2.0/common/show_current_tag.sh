#!/bin/bash - 
#===============================================================================
#
#          FILE: show_current_tag.sh
# 
#         USAGE: ./show_current_tag.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 11/21/2012 07:13:50 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

cat /root/automation/.git/FETCH_HEAD  | grep "`cat /root/automation/.git/HEAD`" | grep tag | grep -o "'.*'"

