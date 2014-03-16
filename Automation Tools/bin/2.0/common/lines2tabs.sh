#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 FILE_NAME"
    exit 1
fi

fn=$1

if [ -f "$fn" ]; then
    echo ""
else
    echo "AT_ERROR : File is not exist : $fn"
    exit 1
fi

cat  $fn | dos2unix | awk '{printf("%s "),$0}'
exit 0
