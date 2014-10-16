#!/usr/bin/python
#       http_player.py
#       
#       Copyright 2011 rayofox <lhu@actiontec.com>
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
    Tool to parse TR098 Data Model XML file ,and save to file with format as follows :
        InternetGatewayDevice. object
        InternetGatewayDevice.DeviceSummary string
        InternetGatewayDevice.LANDeviceNumberOfEntries unsignedInt
        InternetGatewayDevice.WANDeviceNumberOfEntries unsignedInt
        InternetGatewayDevice.UserNumberOfEntries unsignedInt
        InternetGatewayDevice.Capabilities. object
        ...
        
"""
import os, sys
from pprint import pprint
from copy import deepcopy
import types
import xml.dom.minidom as minidom
#from xml.dom.minidom import Node
import codecs
from optparse import OptionParser


def ver_info():
    """
    """
    s = """
    
    HISTORY
    --------------------------------------------------------------------
    DATE    : 
        Sat Dec 17 14:55:45 CST 2011
    VERISON : 
        V 1.0.0
    AUTHOR  : 
        rayofox(lhu@actiontec.com)
    COMMENT :
        Initial Version
    --------------------------------------------------------------------
    
    """
    return s


def getXmlTextValue(node):
    """
    """
    val = None
    snodes = node.childNodes
    if len(snodes) == 0:
        val = ''
    elif len(snodes) == 1:
        val = snodes[0].nodeValue.strip()
    return val


"""
def parseNode(node,zname=[],res=[]) :
   
    nnames = node.getElementsByTagName('parameterName') 
    ntypes = node.getElementsByTagName('parameterType') 
    nparms = node.getElementsByTagName('parameters') 
    _name = None
    _type = None
    if nnames and len(nnames) :
        _name = getXmlTextValue(nnames[0])
    if ntypes and len(ntypes) :
        _type = getXmlTextValue(ntypes[0])
    if not _name or not _type :
        print 'Bad node :',fullname
        return False
    #
    if _type == 'object' :
        zn = deepcopy(zname)
        zn.append(_name)
        print '.'.join(zn) + '.',_type
        #res.append('.'.join(zn) + '. ' +_type)
        if nparms and len(nparms):
            nparam = nparms[0]
            nps = nparam.getElementsByTagName('parameter') 
            for np in nps :
                #print '=1=>','.'.join(zn) ,_type
                parseNode(np,zn,res)
                pass
            #print '=2=>','.'.join(zn) ,_type
    else :
        zn = deepcopy(zname)
        zn.append(_name)
        #print '.'.join(zn) ,_type
        res.append('.'.join(zn) + ' ' +_type)
    
    return res
"""


def getNodeInfo(node):
    """
    """
    nnames = node.getElementsByTagName('parameterName')
    ntypes = node.getElementsByTagName('parameterType')
    nparms = node.getElementsByTagName('parameters')
    _name = None
    _type = None
    if nnames and len(nnames):
        _name = getXmlTextValue(nnames[0])
    if ntypes and len(ntypes):
        _type = getXmlTextValue(ntypes[0])
    if not _name or not _type:
        print 'Bad node :', fullname
        return False
    return (_name, _type)


def parseNode(node, zname=[], res=[], level=0):
    """
    """
    nnames = node.getElementsByTagName('parameterName')
    ntypes = node.getElementsByTagName('parameterType')
    nparms = node.getElementsByTagName('parameters')
    _name = None
    _type = None
    if nnames and len(nnames):
        _name = getXmlTextValue(nnames[0])
    if ntypes and len(ntypes):
        _type = getXmlTextValue(ntypes[0])
    if not _name or not _type:
        print 'Bad node :', fullname
        return False
        #
    zn = deepcopy(zname)
    zn.append(_name)
    print '    ' * level + '=======>', '.'.join(zn), _type

    if _type == 'object':
        res.append('.'.join(zn) + '. ' + _type)
        narr = node.getElementsByTagName('array')
        _narr = None
        if narr and len(narr):
            _narr = getXmlTextValue(narr[0])

        if len(nparms):
            for child in nparms[0].childNodes:
                if child.nodeType == minidom.Node.ELEMENT_NODE:
                    parseNode(child, zn, res, level + 1)


    else:
        res.append('.'.join(zn) + ' ' + _type)
        pass

    return res


def findIGD(root):
    """
    """
    igd = None
    # find dataModel/parameters/parameter/parameterName
    dm_paras = root.getElementsByTagName('parameters')
    if not dm_paras or not len(dm_paras):
        print 'not found dataModel/parameters/'
        exit(1)
    for pp in dm_paras:
        nodes = pp.getElementsByTagName('parameter')
        if not nodes or not len(nodes):
            print 'not found dataModel/parameters/parameter'
            exit(1)
        for node in nodes:
            nnames = node.getElementsByTagName('parameterName')
            ntypes = node.getElementsByTagName('parameterType')
            if nnames and ntypes:
                _name = getXmlTextValue(nnames[0])
                _type = getXmlTextValue(ntypes[0])
                #print 'name :',_name
                #print 'type :',_type
                if _name == 'InternetGatewayDevice':
                    igd = node
                    return igd


def parseXmlDataModelFile(fname):
    """
    """
    #fname = 'dataModel_q2k.xml'
    try:
        dom = minidom.parse(fname)
        root = dom.documentElement
        igd = findIGD(root)
    except Exception, e:
        print 'catch exception', e
        exit(1)

    return parseNode(igd)


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ('\nGet more info with command : pydoc ' + os.path.abspath(__file__) + '\n')
    parser = OptionParser(usage=usage)

    #parser.description = desc
    parser.add_option("-c", "--data_model_file", dest="src",
                      help="data model xml file")
    parser.add_option("-o", "--outputFile", dest="dest",
                      help="output result to file")
    parser.add_option("-x", "--loglevel", type="int", dest="loglevel", default=2,
                      help="the log level, 0 : error, 1 : warning, 2 : info , 3 : debug")

    (options, args) = parser.parse_args()

    # check option
    if not options.src:
        print 'Error : ', 'No data model file!'
        parser.print_help()
        exit(1)

    return options


def main():
    """
    """
    opts = parseCommandLine()
    src = opts.src
    dst = opts.dest
    if not os.path.exists(src):
        print 'Data Model File not found :', src
        exit(1)

    #
    res = parseXmlDataModelFile(src)
    if not res:
        print 'parse xml failed '
        exit(1)
    if not dst:
        print '\n' * 2
        print '--' * 32
        print 'result is :\n'
        for line in res:
            print line
    else:
        fd = open(dst, 'w')
        if not fd:
            print 'open file failed :', dst
            exit(1)
            #
        #fd.writelines(res)
        for line in res:
            fd.write(line + '\n')
        fd.close()


if __name__ == '__main__':
    """
    """
    print ver_info()
    main()





