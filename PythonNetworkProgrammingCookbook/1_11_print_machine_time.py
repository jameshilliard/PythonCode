# coding=utf-8
__author__ = 'root'

#!/usr/bin/env python
# Python Network Programming Cookbook -- Chapter - 1
# This program is optimized for Python 2.7. It may run on any
# other Python version with/without modifications.

import ntplib
from time import ctime


def print_time():
    ntp_client = ntplib.NTPClient()
    response = ntp_client.request('202.120.2.101')
    print ctime(response.tx_time)


if __name__ == '__main__':
    print_time()