#!/bin/bash
if [ -f "$1" ]; then
    if [ "$2" == "true" ]; then
        echo "PASS";
        exit 0;
    else
        echo "FAIL";
        exit 1;
    fi
else 
    if [ "$2" == "false" ]; then
        echo "PASS";
        exit 0;
    else
        echo "FAIL";
        exit 1;
    fi
fi
