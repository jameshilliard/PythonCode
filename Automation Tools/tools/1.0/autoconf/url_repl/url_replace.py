#! /usr/bin/env python


"""
Class UrlReplacer is a class to do replace url request.
1. GET query
2. POST data
3. format : "k1=v1&k2=v2&k3=v3" 

The common rule is replace value by key, such as :
s = "username=admin&password=admin1"
UrlReplacer ur()
ur.addKV('username','user')
ur.addKV('password','1')
res = ur.replace(s)
print res

the result is :
username=user&password=1


you can set the common replace data in files ,such as :

# rule file comm_repl_data 
# wireless SSID
wlSsid_wl0v0            =$U_WIRELESS_SSID1
wlSsid_wl0v1            =$U_WIRELESS_SSID2
wlSsid_wl0v2            =$U_WIRELESS_SSID3
wlSsid_wl0v3            =$U_WIRELESS_SSID4

#########################################################
# default WEP KEY 64 bit
wlDefaultKeyWep64Bit    =$U_WIRELESS_WEPKEY_DEF_64 

#########################################################
# default WEP KEY 128 bit
# special replace rule

the word begin with $ will replace with env value.
you can import the file :

UR.importKV('comm_repl_data')


And you can also special your replace rule such as :

sp_match = 'key=([^&=]*)&key=([^&=]*)*key=([^&=]*)'
def sp_cbReplace(m ):
    return 'key=1&key=11*key=111'
UR.addRule(sp_match,sp_cbReplace)

the new rule will always append to end of the rule list 

"""
__author__ = 'rayofox'
__version__ = '1.0'

import re, os, sys
import urllib2


class UrlReplacer:
    # hash map k-v replace
    mapKV = {}
    rex = []

    def __init__(self):
        """
        add common rule into rule list
        """
        match = '([^&=?]*)=([^&=]*)'
        self.rex.append((match, self.commRepl))
        return

    def commRepl(self, match):
        """
        the common replacement callback function
        """
        #print match.groups()
        s = match.group(0)
        key = match.group(1)
        val = match.group(2)
        #print '=====1',key,val
        mkv = self.mapKV
        if mkv.has_key(key):
            return key + '=' + mkv[key]
        return s

    def replace(self, s):
        """
        invoke all rules in list
        """
        match = '([^&=]*)=([^&=]*)'
        r = s
        for (m, fm) in self.rex:
            #print m
            p = re.compile(m)
            r = p.sub(fm, r)
            #print '---',r
        return r

    def addKV(self, k, v, need_url_encode=True):
        """
        add common data item
        """
        mkv = self.mapKV
        if need_url_encode:
            k = urllib2.quote(k)
            v = urllib2.quote(v)
        mkv[k] = v

    def addKVmap(self, hmap, need_url_encode=True):
        """
        add common data with a hash
        """
        for (k, v) in hmap.items():
            addKV(k, v, need_url_encode)

    def importKV(self, fn):
        """
        import common data from a file
        '#' is a comment line indication
        """
        lines = []
        f = open(fn)
        if f:
            lines = f.readlines()
            f.close()
        else:
            print "==open file", fn, "error"
            return False

        for line in lines:
            if not line.startswith('#'):
                res = os.popen('echo ' + line).read()
                #print res
                match = '([^=\s]*)\s*=\s*(.*)'
                rr = re.findall(match, res)
                #print rr
                if len(rr) > 0:
                    (k, v) = rr[0]
                    self.addKV(k, v)
        return True

    def addRule(self, m, f):
        """
        add replacement rule in list
        the order can not specify and only append to tail
        """
        self.rex.append((m, f))
   
