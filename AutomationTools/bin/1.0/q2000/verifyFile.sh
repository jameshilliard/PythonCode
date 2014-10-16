if [ -f "$1" ]; then
    if [ "$2" == "true" ]; then
        echo "PASSED";
        exit 0;
    else
        echo "FAILED";
        exit 1;
    fi
else 
    if [ "$2" == "false" ]; then
        echo "PASSED";
        exit 0;
    else
        echo "FAILED";
        exit 1;
    fi
fi
