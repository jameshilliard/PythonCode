#!/bin/bash
# -----------------------------------------------------------------------------
# Parses an XML file from a device,
# and then sorts required data from another file to the corresponding XML data.
# It will then output to another file or STDOUT with the format of:
# RequiredArgName = Value
#
# Author:: Chris Born (cborn@actiontec.com)
# Copyright::Copyright (c) 2011 Actiontec Electronics, Inc.
# -----------------------------------------------------------------------------

# defaults
xml_file="mdmdump.xml"

while getopts ":f:o:p:h" opt; do
  case $opt in
    f ) xml_file=$OPTARG;;
    o ) output=$OPTARG;;
    p ) parameters=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    : ) echo "Option -$OPTARG requires an argument." >&2; exit 1;;
    h ) echo "Usage: `basename $0` options"; echo "-f XML file"; echo "-o Output"; echo "-p Parameter FILE"; exit 1;;
  esac
done

if [ -z "$parameters" ]; then
  echo "This requires the parameters file to be loaded in with the -p option."
  exit 1
else
  if [ -z "$xml_file" ]; then
    echo "This requires the XML from the modem to be in a file and passed to the script with the -f option."
    exit 1
  else
    if [ -n "$output" ]; then echo "# Output results" > $output; fi
    cat $parameters | while read LINE; do
      item_name=${LINE%=*}
      item_path=${LINE#*=}
      item_xpath=`echo ${item_path} | sed -r -e 's/\./\//g' -e 's/\/([[:digit:]])\//\[\1\]\//g'`
      if [ -n "$output" ]; then
        echo "$item_name = $(xmllint $xml_file --xpath /${item_xpath}/text\(\))" >> $output
      else
        echo "$item_name = $(xmllint $xml_file --xpath /${item_xpath}/text\(\))"
      fi
    done
  fi
fi
