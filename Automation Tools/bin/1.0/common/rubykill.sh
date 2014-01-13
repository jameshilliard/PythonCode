#!/bin/bash
ps -ef | awk '/ruby/ && !/awk/ && !/assignment/ && !/begin_testing/ {print $2}' | xargs -r kill -9
