#!/bin/bash - 
#===============================================================================
#
#          FILE: sqliteadmin.sh
# 
#         USAGE: ./sqliteadmin.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 01/31/2013 03:09:15 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

wine  $SQAROOT/tools/2.0/db/sqliteadmin/sqliteadmin.exe &

