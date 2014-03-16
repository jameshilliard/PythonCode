#!/usr/bin/python
#       _utils.py
#       
#       Copyright 2011 rayofox <rayofox@rayofox-test>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#       
#      
"""
the utilities for page handlers
"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "0.1"
__license__ = "MIT"
__history__ = """
Rev 0.1 : 2011/09/25
	Initial version
"""

import os, sys
import httplib2, urllib
import re
import types


def str2hash(s):
    """
    translate http query string or post string to hashmap
    """
    seq = []
    hashmap = {}
    match = r'([^=&]*)=([^=&]*)'
    res = re.findall(match, s)
    for (k, v) in res:
        seq.append(k)
        hashmap[k] = v
    return (seq, hashmap)


def hash2str(h, seq=None):
    """
    """
    rc = ""
    if seq and len(seq) > 0:
        val = ''
        for key in seq:
            val += (key + '=' + h[key] + '&')
        rc = val[:-1]
    else:
        rc = urllib.urlencode(h)
    return rc


def diff_form_str(s1, s2):
    """
    diff http query string or post string keywords with order
    """
    rc = False
    seq1, h1 = str2hashmap(s1)
    seq2, h2 = str2hashmap(s2)
    #
    return (seq1 != seq2)


def diff_form_hashmap_keys(h1, h2):
    """
    diff http query string or post string hashmap keywords without order
    """
    rc = False
    key_in_all = []
    key_in_h1 = []
    key_in_h2 = []

    # key in h1 only and in all
    for (k, v) in h1.items():
        if h2.has_key(k):
            key_in_all.append(k)
        else:
            key_in_h1.append(k)
            rc = True
    # key in h2 only
    for (k, v) in h2.items():
        if not h1.has_key(k):
            key_in_h2.append(k)
            rc = True

    # return
    return (rc, key_in_all, key_in_h1, key_in_h2)
	
