#! /usr/bin/env python
import re, os, sys
import urllib2

from url_repl import UrlReplacer
from url_repl import wi_sec_match
from url_repl import wi_sec_cbReplace


def mySetEnv(k, v):
    os.environ[k] = v


def test():
    sss = """
parser.cgi?wlDefaultKeyFlagWep64Bit=1&wlDefaultKeyFlagWep128Bit=9&wlDefaultKeyWep64Bit=FFA8FFFFA9&wlDefaultKeyWep128Bit=ffc5aa8bff82dfc8ce7a667f7e&wlDefaultKeyWep128Bit=ffc5aa89ff82dfc7ce7a667f8c&wlDefaultKeyWep128Bit=ffc5aa87ff82dfc6ce7a657f82&wlDefaultKeyWep128Bit=ffc5aa85ff82dfc5ce7a657f84&wlKeyBit_wl0v0=2&wlKeyIndex_wl0v0=1&wlKeyIndex_wl0v0=1&wlKey1_128_wl0v0=ffc5aa8bff82dfc8ce7a667f7e&wlAuthMode_wl0v0=open&wlWep_wl0v0=enabled&wlDefaultKeyFlagPsk=15&wlDefaultKeyPsk0=87e14477bb00c0e415dbeb1cb2&wlDefaultKeyPsk1=87e14477bb00c0e415dbeb1cb2&wlDefaultKeyPsk2=87e14477bb00c0e415dbeb1cb2&wlDefaultKeyPsk3=87e14477bb00c0e415dbeb1cb2&needthankyou=1

    """
    # import ENV value
    mySetEnv('U_WIRELESS_SSID1', 'ssid_test001')
    mySetEnv('U_WIRELESS_SSID2', 'ssid_test002')
    mySetEnv('U_WIRELESS_SSID3', 'ssid_test003')
    mySetEnv('U_WIRELESS_SSID4', 'ssid_test004')

    mySetEnv('U_WIRELESS_WEPKEY_DEF_64', '123456789A')

    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY64bit1', '123456789A')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY64bit2', '123456789B')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY64bit3', '123456789C')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY64bit4', '123456789D')

    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY128bit1', 'abcdef0123456789wepkey128A')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY128bit2', 'abcdef0123456789wepkey128B')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY128bit3', 'abcdef0123456789wepkey128C')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY128bit4', 'abcdef0123456789wepkey128D')

    mySetEnv('U_WIRELESS_WEPKEY1', 'mytest')
    mySetEnv('U_WIRELESS_WEPKEY2', 'mytest2')
    mySetEnv('U_WIRELESS_WEPKEY3', 'mytest3')
    mySetEnv('U_WIRELESS_WEPKEY4', 'mytest4')

    mySetEnv('U_WIRELESS_WPAPSK1', 'WPAPSK1')
    mySetEnv('U_WIRELESS_WPAPSK2', 'WPAPSK2')
    mySetEnv('U_WIRELESS_WPAPSK3', 'WPAPSK3')
    mySetEnv('U_WIRELESS_WPAPSK4', 'WPAPSK4')

    mySetEnv('U_WIRELESS_CUSTOM_WPAPSK', 'cuswpapsk1')
    mySetEnv('U_WIRELESS_CUSTOM_WPAPSK', 'cuswpapsk2')
    mySetEnv('U_WIRELESS_CUSTOM_WPAPSK', 'cuswpapsk3')
    mySetEnv('U_WIRELESS_CUSTOM_WPAPSK', 'cuswpapsk4')

    #for (k,v) in os.environ.items() :
    #    print k,' : ',v
    sss = sss.strip()
    print '[' + sss + ']'
    print '\n'.join(sss.split('&'))
    print '-' * 32
    UR = UrlReplacer()
    UR.importKV('ttt')
    UR.addRule(wi_sec_match, wi_sec_cbReplace)

    ss = UR.replace(sss)
    print 'result : '
    print '|', '\n'.join(ss.split('&')), '|'
    print '[' + ss + ']'


test()
