#!/bin/bash - 
#===============================================================================
#
#          FILE: list_pm.sh
# 
#         USAGE: ./list_pm.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 05/30/2012 01:46:27 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
find `perl -e 'print "@INC"'` -name '*.pm' -print

