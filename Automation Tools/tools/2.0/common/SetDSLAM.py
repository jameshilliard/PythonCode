#!/usr/bin/python -u

import os, sys, re
from optparse import OptionParser
import db_helper
import SetDSLAM_HuaWei
import SetDSLAM_Zyxel
import SetDSLAM_Calix
import os, re, select, subprocess, time

swb_flag = os.getenv('U_CUSTOM_NO_WECB')


class SetDSLAM():
    """
    """
    linemode = ''
    tag = ''
    bonding = False
    vdslmode = 'vdsl2'
    dslamname = ''
    layer2mode = ''
    testbed = os.getenv('G_TBNAME')
    adslmode = 'adsl2+'
    pvc = os.getenv('U_DUT_DEF_VPI_VCI')
    connectport = '1'
    vlan = ''
    curmode = ''
    profile = ''

    def __init__(self, linemode='', tag='', bonding=False, vdslmode='', testbed='', dslamname='', remove=False,
                 adslmode='', pvc='', connectport=''):

        """
        """
        print 'SetDSLAM __init__'
        self.linemode = linemode
        self.tag = tag
        self.bonding = bonding
        self.remove = remove

        if self.tag:
            retag = '^[0-9]+$'
            rc = re.findall(retag, self.tag)
            if len(rc) > 0:
                pass
            else:
                self.tag = 'TAG'

        if pvc:
            self.pvc = pvc

        if self.linemode == 'ADSL':
            if not self.pvc:
                print 'AT_ERROR : VPI/VCI is Null!'
                exit(1)
            else:
                repvc = '[0-9]+/[0-9]+'
                rc = re.findall(repvc, self.pvc)
                if not rc:
                    print 'AT_ERROR : pvc ' + self.pvc + ' format Error!'
                    exit(1)

        if adslmode:
            self.adslmode = str(adslmode).lower()

        if vdslmode:
            self.vdslmode = str(vdslmode).lower()

        if testbed:
            self.testbed = testbed

        if not self.testbed:
            print 'AT_ERROR : testbed is Null,Please define it with -s!'
            exit(1)

        if self.bonding:
            if self.linemode == 'ADSL':
                self.layer2mode = self.linemode + '_B'
                self.curmode = self.adslmode
            elif self.linemode == 'VDSL':
                self.layer2mode = self.linemode + '_B'
                self.curmode = self.vdslmode
        else:
            if self.linemode == 'ADSL':
                self.layer2mode = self.linemode + '_S'
                self.curmode = self.adslmode
            elif self.linemode == 'VDSL':
                self.layer2mode = self.linemode + '_S'
                self.curmode = self.vdslmode

        if dslamname:
            self.dslamname = dslamname
        else:
            self.dslamname = get_dslam_name(self.testbed, self.layer2mode)
            if self.dslamname == 'Multiple' or self.dslamname == 'Null':
                print 'AT_ERROR : Can\'t judge Dslam Type!'
                exit(1)
        if connectport:
            self.connectport = connectport

    def gogo(self):
        """
        1     testbed     varchar(255)      
        2     dslamname     varchar(255)   
        3     dslamip     varchar(255)      
        4     dslamuser     varchar(255)   
        5     dslampwd     varchar(255)  
        6     dslamport     varchar(255)
        """
        if not get_dslam_userinfo(self.dslamname):
            return False
        self.profile = get_profile(self.dslamname, self.curmode)
        if not self.profile:
            return False

        if str(self.dslamname).lower().split('_')[0] == 'HuaWei'.lower():
            if self.linemode != 'VDSL':
                print 'AT_ERROR : HuaWei DSLAM only support VDSL mode!'
                return False
            aaa = SetDSLAM_HuaWei.SetDSLAM_HuaWei(linemode=self.linemode, tag=self.tag, bonding=self.bonding,
                                                  vdslmode=self.vdslmode, testbed=self.testbed,
                                                  connectport=self.connectport, profile_name=self.profile)
        elif str(self.dslamname).lower().split('_')[0] == 'zyxel'.lower():
            if self.linemode != 'ADSL':
                print 'AT_ERROR : Zyxel DSLAM only support ADSL mode!'
                return False
            aaa = SetDSLAM_Zyxel.SetDSLAM_Zyxel(linemode=self.linemode, tag=self.tag, bonding=self.bonding,
                                                vdslmode=self.vdslmode, testbed=self.testbed, adslmode=self.adslmode,
                                                pvc=self.pvc, connectport=self.connectport, profile_name=self.profile)
        elif str(self.dslamname).lower().split('_')[0] == 'Calix'.lower():
            if self.linemode != 'ADSL' and self.linemode != 'VDSL':
                print 'AT_ERROR : Calix DSLAM only support ADSL or VDSL mode!'
                return False
            aaa = SetDSLAM_Calix.SetDSLAM_Calix(linemode=self.linemode, tag=self.tag, bonding=self.bonding,
                                                vdslmode=self.vdslmode, testbed=self.testbed, adslmode=self.adslmode,
                                                pvc=self.pvc, connectport=self.connectport, profile_name=self.profile)
        else:
            print 'AT_ERROR : Don\'t konw how to set ' + self.dslamname
            return False
        self.vlan = aaa._vlan
        if self.remove:
            rc = aaa.remove()
        else:
            rc = aaa.set()
        return rc


def querydatabase(testbed, layer2mode, tag):
    """
     #     Column     Type     Collation     Attributes     Null     Default     Extra     Action
1     TBNAME     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
2     dslamname     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
3     PORT     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
4     MODE     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
5     TAG     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
6     PVC     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
7     ETHNo     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
8     VLAN     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
9     LineProfile     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
10     LineTemplate     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
11     BondGroupIndex     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
12     BondGroupMainPort     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
13     BondGrouplinkPort     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
14     DiscoverCode     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
(1L, (('at_sh1', 'HuaWei', 'NA', 'VDSL_B_8B', '101', 'NA', '300', '405', '112', '120', '5', '0/1/17', '0/1/18', '0000-0000-0001'),))
    """
    mytuple = []
    mytuple = db_helper.queryTBDSLAM({'TBNAME': testbed, 'MODE': layer2mode, 'TAG': tag})
    print mytuple
    num = str(mytuple[0])
    if num == '1':
        print 'AT_INFO : Find 1 data!'
    elif num == '0':
        print 'AT_ERROR : Can\'t find data!'
        return False
    else:
        print 'AT_ERROR : Find ' + num + ' data!'
        return False
    return mytuple


def get_dslam_name(testbed, layer2mode):
    """
    """
    print 'get dslam name'
    testbed = testbed
    layer2mode = layer2mode
    mytuple = db_helper.queryDslamName(testbed, layer2mode)
    print mytuple
    num = str(mytuple[0])
    if num == '1':
        print 'AT_INFO : Find 1 data!'
    elif num == '0':
        print 'AT_ERROR : Can\'t find data!'
        return 'Null'
    else:
        print 'AT_ERROR : Find ' + num + ' data!'
        return 'Multiple'
    dslamname = mytuple[1][0][1]
    return dslamname


def get_dslam_userinfo(dslamname):
    """
    """
    print 'get dslam user info'
    #    testbed = testbed
    mytuple = db_helper.queryDslamUserInfo({'dslamname': dslamname})
    print mytuple
    num = str(mytuple[0])
    if num == '1':
        print 'AT_INFO : Find 1 data!'
    elif num == '0':
        print 'AT_ERROR : Can\'t find data!'
        return False
    else:
        print 'AT_ERROR : Find ' + num + ' data!'
        return False

    _DSLAM_TELNET_IP = mytuple[1][0][1]
    _DSLAM_TELNET_USER = mytuple[1][0][2]
    _DSLAM_TELNET_PWD = mytuple[1][0][3]
    _DSLAM_TELNET_PORT = mytuple[1][0][4]

    os.environ.update({'U_DSLAM_TELNET_IP': _DSLAM_TELNET_IP,
                       'U_DSLAM_TELNET_USER': _DSLAM_TELNET_USER,
                       'U_DSLAM_TELNET_PWD': _DSLAM_TELNET_PWD,
                       'U_DSLAM_TELNET_PORT': _DSLAM_TELNET_PORT})
    return True


def get_profile(dslamname, linemode):
    """
    """
    print 'get profile'
    #    testbed = testbed
    mytuple = db_helper.queryProfile({'Dslamname': dslamname, 'Linemode': linemode})
    print mytuple
    num = str(mytuple[0])
    if num == '1':
        print 'AT_INFO : Find 1 data!'
    elif num == '0':
        print 'AT_ERROR : Can\'t find data!'
        return False
    else:
        print 'AT_ERROR : Find ' + num + ' data!'
        return False

    return mytuple[1][0][2]


def main():
    """
    main
    """
    usage = "python SetDSLAM.py [-l <ADSL|VDSL>] [-t tag] [-b]\n"
    usage = usage + "[-v <17a|12a|12b|8a|8b|8c|8d>] [-a <glite|gdmt|t1413|auto|adsl2|adsl2+>]\n"
    usage = usage + "[-x <pvc 0/32>] [-P <1|2>] [-k <dslamname>] [-q <tb name>] [-d <remove>]"

    parser = OptionParser(usage=usage)

    parser.add_option("-l", "--linemode", dest="linemode",
                      help="linemode , ADSL VDSL or ETC.")
    parser.add_option("-t", "--tag", dest="tag",
                      help="tag")
    parser.add_option("-v", "--vdslmode", dest="vdslmode",
                      help="vdslmode")
    parser.add_option("-a", "--adslmode", dest="adslmode",
                      help="adslmode")
    parser.add_option("-b", "--bonding", dest="bonding", action='store_true', default=False,
                      help="whether it is in bonding mode")
    parser.add_option("-d", "--remove", dest="remove", action='store_true', default=False,
                      help="remove link type")
    parser.add_option("-q", "--testbed", dest="testbed",
                      help="testbed")
    parser.add_option("-k", "--dslamname", dest="dslamname",
                      help="dslamname")
    parser.add_option("-x", "--pvc", dest="pvc",
                      help="pvc")
    parser.add_option("-P", "--connectport", dest="connectport",
                      help="connectport")
    (options, args) = parser.parse_args()

    tag = ''
    linemode = ''
    vdslmode = 'vdsl2'
    testbed = os.getenv('G_TBNAME')
    dslamname = ''
    adslmode = 'adsl2+'
    connectport = '1'
    pvc = os.getenv('U_DUT_DEF_VPI_VCI')
    curmode = ''
    linemode = options.linemode
    if not linemode:
        print 'AT_ERROR : linemode is Null,Please define it to ADSL or VDSL!'
        return False

    if options.connectport:
        connectport = options.connectport

    if options.adslmode:
        adslmode = options.adslmode

    if options.pvc:
        pvc = options.pvc

    if linemode == 'ADSL' and not pvc:
        print 'AT_ERROR : VPI/VCI is Null!'
        exit(1)

    if not len(args) == 0:
        print args

    if options.backupDslam:
        backupDslam = True

    if options.testbed:
        testbed = options.testbed

    if options.linemode:
        linemode = options.linemode

    if options.tag:
        tag = options.tag

    if options.bonding:
        bonding = True
    else:
        bonding = False

    if options.vdslmode:
        vdslmode = str(options.vdslmode).lower()

    if options.remove:
        remove = True
    else:
        remove = False

    if bonding:
        if linemode == 'ADSL':
            layer2mode = linemode + '_B'
            curmode = adslmode
        elif linemode == 'VDSL':
            layer2mode = linemode + '_B'
            curmode = vdslmode
        else:
            print 'AT_INFO : linemode should be ADSL or VDSL'
            return False
    else:
        if linemode == 'ADSL':
            layer2mode = linemode + '_S'
            curmode = adslmode
        elif linemode == 'VDSL':
            layer2mode = linemode + '_S'
            curmode = vdslmode
        else:
            print 'AT_INFO : linemode should be ADSL or VDSL!'
            return False

    if not testbed:
        print 'AT_ERROR : testbed is Null,Please define it by G_TBNAME or -q!'
        return False

    if options.dslamname:
        dslamname = options.dslamname
    else:
        dslamname = get_dslam_name(testbed, layer2mode)

        if dslamname == 'Multiple' or dslamname == 'Null':
            print 'AT_ERROR : Can\'t judge Dslam Type!'
            return False

    if not get_dslam_userinfo(dslamname):
        return False

    profile = get_profile(dslamname, curmode)
    if not profile:
        return False

    ### set dslam
    if str(dslamname).lower().split('_')[0] == 'HuaWei'.lower():
        if linemode != 'VDSL':
            print 'AT_ERROR : HuaWei DSLAM only support VDSL mode!'
            return False
        aaa = SetDSLAM_HuaWei.SetDSLAM_HuaWei(linemode=linemode, tag=tag, bonding=bonding, vdslmode=vdslmode,
                                              testbed=testbed, connectport=connectport, profile_name=profile)
    elif str(dslamname).lower().split('_')[0] == 'Zyxel'.lower():
        if linemode != 'ADSL':
            print 'AT_ERROR : Zyxel DSLAM only support ADSL mode!'
            return False
        aaa = SetDSLAM_Zyxel.SetDSLAM_Zyxel(linemode=linemode, tag=tag, bonding=bonding, vdslmode=vdslmode,
                                            testbed=testbed, adslmode=adslmode, pvc=pvc, connectport=connectport,
                                            profile_name=profile)
    elif str(dslamname).lower().split('_')[0] == 'Calix'.lower():
        if linemode != 'ADSL' and linemode != 'VDSL':
            print 'AT_ERROR : Calix DSLAM only support ADSL or VDSL mode!'
            return False
        aaa = SetDSLAM_Calix.SetDSLAM_Calix(linemode=linemode, tag=tag, bonding=bonding, vdslmode=vdslmode,
                                            testbed=testbed, adslmode=adslmode, pvc=pvc, connectport=connectport,
                                            profile_name=profile)
    else:
        print 'AT_ERROR : Don\'t konw how to set ' + dslamname
        return False

    if remove:
        rc = aaa.remove()
    else:
        rc = aaa.set()
    return rc


if __name__ == '__main__':
    for i in range(1):
        rc = main()
        if rc:
            exit(0)
    exit(1)
            
        
        
            
    
    
