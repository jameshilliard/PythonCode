#!/bin/bash - 
#===============================================================================
#
#          FILE: freeMem.sh
# 
#         USAGE: ./freeMem.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 09/17/2012 03:20:47 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


echo '----------'
echo 'Memory usage before release...'
free -m

echo ''
echo ''
echo '----------'
echo 'do sync...'
sync

echo ''
echo ''
echo '----------'
echo 'do free caches...'
echo 3 > /proc/sys/vm/drop_caches


echo ''
echo ''
echo '----------'
echo 'Memory usage after release...'
free -m

echo ''
echo ''
echo '----------'
echo 'Done!'
