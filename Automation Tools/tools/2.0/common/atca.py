#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#       atca.py
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
#       (2012/05/28)New features :
#       Make test case file name more readability.
#       Raw file name   : No-16270:No connection on Ethernet 1
#       Format          : File_Index:File_Desc
#       Replacement     : ' ' --> '_'
#                         ':' --> '__'
#       File name       : No-16270__No_connection_on_Ethernet_1.xml
#       Sheet name      : No-16270
#
#------------------------------------------------------------------------------
"""
This is Automation Test Cases Adapter
You can switch xml cases to xls and xls to xml cases.
For examples : 
1. transfer all Wireless Configuration cases to Excel file wi_con.xls :
    ./atca.py -m xml2xls -s "/root/automation/platform/2.0/common/tcases/wireless/CON/B-GEN-WI.CON-*.xml" -d "/root/Workspace/wi_con.xls"
2. Create cases from xls :
    ./atca.py -m xls2xml -s "/root/Workspace/wi_con.xls" -d "/root/test/mycases/WI.CON"
"""
import os, sys, re
from pprint import pprint
from copy import deepcopy
import types
import xml.dom.minidom as minidom
import codecs
from optparse import OptionParser

try:
    import xlrd, xlwt
except Exception, e:
    print 'Load xlrd and xlwt failed!'
    print "Please install xlrd and xlwt!"
    exit(5)

########################################################################
## These functions are used to transmit casename/filename/sheetname
## Sheetname SHOULD less than 31 characters
## Filename  SHOULD NOT contain special char ,such as ':',' ' and others
## casename is based on TestLink ,format is : No-Index:Case_Desciption
##

def path_name(s):
    """
    transmit 
        ':' --> '__'
        ' ' --> '_'
    """
    s = re.sub(':', '__', s)
    s = re.sub(' ', '_', s)
    return s


def raw_name(s):
    """
    transmit 
        '__' --> ':'
        '_'  --> ' '
    """
    s = re.sub('__', ':', s)
    s = re.sub('_', ' ', s)
    return s


def parse_filename(filename):
    """
    """
    sheetname = None
    casename = None

    fn = os.path.basename(filename)
    if fn.endswith('.xml'):
        fn = fn[:-4]
    print '-->', fn
    fn = raw_name(fn)
    sections = fn.split(':')
    sheetname = sections[0]
    casename = fn

    return sheetname, casename


def casename2sheetname(casename):
    """
    """
    sections = casename.split(':')
    casename = sections[0]
    return casename


def casename2filename(casename):
    """
    """
    filename = path_name(casename)
    filename += '.xml'
    return filename

########################################################################    
def myIndent(dom, node, indent=0):
    """
    """
    # Copy child list because it will change soon
    children = node.childNodes[:]
    #print node.nodeName

    # Main node doesn't need to be indented
    if indent:
        text = dom.createTextNode('\n' + '\t' * indent)
        node.parentNode.insertBefore(text, node)
    if children:
        for snode in children:
            if snode.nodeType == node.TEXT_NODE:
                nv = snode.nodeValue
                if nv and len(nv.strip()) == 0: continue
                newlines = []
                lines = nv.splitlines()
                endc = ''

                if snode.parentNode.nodeName == 'script':
                    endc = ';'
                    for line in lines:
                        zl = line.split(endc)
                        for l in zl:
                            l = l.strip()
                            #print '==== add line',l
                            if len(l) > 0:
                                newlines.append(l)
                else:
                    newlines = lines

                if len(nv) > 40 or len(newlines) > 1:
                    #print '-->',snode,snode.nodeValue
                    s = ''

                    for line in newlines:
                        line = line.strip()
                        s += ('\n' + '\t' * (indent + 1) + line + endc)
                    if len(s) > 0:
                        snode.nodeValue = s
                        # add after node
                        text = dom.createTextNode('\n' + '\t' * indent)
                        snode.parentNode.appendChild(text)


        # Append newline after last child, except for text nodes
        if children[-1].nodeType == node.ELEMENT_NODE:
            text = dom.createTextNode('\n' + '\t' * indent)
            node.appendChild(text)
            # Indent children which are elements
        for n in children:
            if n.nodeType == node.ELEMENT_NODE:
                myIndent(dom, n, indent + 1)


"""



"""


class AutomationTestCaseCreator():
    """
    """
    m_wb = None
    m_cases = {
        'seq': [],
        'data': {},
    }
    m_case = {
        'headers': {},
        'steps': [],
    }

    m_step = {
        'seq': ['name', 'desc', 'script', 'getenv', 'noerrorcheck', 'passed', 'failed'],
        'data': {
            'name': '',
            'desc': '',
            'script': '',
            'getenv': '',
            'noerrorcheck': '',
            'passed': '',
            'failed': '',
        }
    }

    m_headers = {
        'seq': ['name', 'emaildesc', 'description', 'id/manual', 'id/auto', 'code'],
        'data': {
            'name': '',
            'emaildesc': '',
            'description': '',
            'id/manual': '',
            'id/auto': '',
            'code': '',
        }
    }

    def __init__(self):
        """
        """
        pass

    def newCase(self, name):
        """
        """
        if self.m_cases.has_key(name):
            #exit(0)
            print '==', 'Case duplicated : ', name
            return None

        case = deepcopy(self.m_case)
        headers = deepcopy(self.m_headers)
        case['headers'] = headers
        self.m_cases['data'][name] = case
        self.m_cases['seq'].append(name)
        return case

    def newStep(self):
        """
        """
        step = deepcopy(self.m_step)
        return step

    def reset(self):
        """
        """
        self.m_menu = []
        self.m_cases = []

    def border(self):
        """
        """
        border = xlwt.Borders()
        border.left = border.THIN
        border.right = border.THIN
        border.top = border.THIN
        border.bottom = border.THIN
        border.diag = border.THIN

        border.left_colour = 0x08
        border.right_colour = 0x08
        border.top_colour = 0x08
        border.bottom_colour = 0x08
        border.diag_colour = 0x08
        return border

    def font_headers(self):
        """
        """
        font = xlwt.Font()
        font.name = 'Times New Roman'
        font.bold = True
        #font.colour_index = 0x0E
        font.height = 240
        return font

    def font_text(self):
        """
        """
        font = xlwt.Font()
        font.name = 'Times New Roman'
        #font.bold = True
        #font.colour_index = 0x0E
        font.height = 240
        return font

    def pattern_headers(self):
        """
        """
        ptn = xlwt.Pattern()
        ptn.pattern = ptn.SOLID_PATTERN
        ptn.pattern_fore_colour = 0x2A
        return ptn

    def alignment(self):
        """
        """
        an = xlwt.Alignment()
        an.wrap = an.WRAP_AT_RIGHT
        an.shri = an.SHRINK_TO_FIT
        an.orie = an.ORIENTATION_STACKED
        return an


    def HeadersStyle(self):
        """
        """
        style = xlwt.XFStyle()
        style.font = self.font_headers()
        style.pattern = self.pattern_headers()
        style.borders = self.border()
        style.alignment = self.alignment()
        #return style

        tittle_style = xlwt.easyxf(
            'font: height 240, name Arial Black, colour_index blue, bold on; align: wrap on, vert centre, horiz center; pattern: pattern solid_fill, fore_color light_orange;'    "borders: top thin, bottom thin, left thin, right thin;")
        return tittle_style

    def TextStyle(self):
        """
        """
        style = xlwt.XFStyle()
        style.font = self.font_text()
        #style.pattern = self.pattern_headers()
        style.borders = self.border()
        #return style

        normal_style = xlwt.easyxf(
            'font: height 200, name Arial, colour_index black, bold off; align: wrap on, vert centre, horiz left;'      "borders: top thin, bottom thin, left thin, right thin;")
        return normal_style


    def fitSheetSize(self, tbl, max_col_len):
        """
        """

        for idx in range(0, len(max_col_len)):
            sz = max_col_len[idx]
            if sz < 8: sz = 8
            if sz > 30: sz = 30
            w = sz * 400
            tbl.col(idx).width = w
            print 'fit size :', idx, w


        #exit(3)
        return tbl

    def __getXmlTextValue(self, node):
        """
        """
        val = None
        snodes = node.childNodes
        if len(snodes) == 0:
            val = ''
        elif len(snodes) == 1:
            val = snodes[0].nodeValue.strip()

        return val

    def loadXmls(self, p):
        """
        """
        rc = False
        print 'loadXmls :', p

        import glob

        if os.path.isdir(p):
            print '-->', 'is a dir'
            p += '/*.xml'
            #m = os.path.join(path,'*.xml')
        fileList = glob.glob(p)
        fileList.sort()
        for filename in fileList:
            print 'filename :', filename
            self.loadXml(filename)


    def loadXml(self, fname):
        """
        """
        rc = False
        if not os.path.exists(fname):
            print '==', fname, ': File not exist!'
            return rc

        fn = os.path.basename(fname)
        #name = fn
        #print 'name : ',name
        sheetname, name = parse_filename(fn)

        case = self.newCase(name)

        dom = minidom.parse(fname)
        root = dom.documentElement

        headers = case['headers']
        steps = case['steps']

        # get headers
        for key in headers['seq']:
            if key.find('/') < 0:
                nodes = root.getElementsByTagName(key)
                if len(nodes) > 0:
                    node = nodes[0]
                    val = self.__getXmlTextValue(node)
                    print '==', node, node.nodeName, key, val
                    if not val == None:
                        headers['data'][key] = val
            else:
                zk = key.split('/')
                if len(zk) == 2:
                    pk = zk[0]
                    k = zk[1]
                    node = None
                    nodes = root.getElementsByTagName(pk)
                    if len(nodes) > 0:
                        node = nodes[0]

                    if node:
                        snodes = node.getElementsByTagName(k)
                        if len(snodes) > 0:
                            snode = snodes[0]
                            v = self.__getXmlTextValue(snode)
                            print '==>>', snode, snode.nodeName, k, v
                            if not v == None:
                                headers['data'][key] = v
            #
        if name.endswith('.xml'): name = name[:-4]

        if not headers['data']['name'] == name:
            print '==!', 'case name is not equal to case file name'
            headers['data']['name'] = name

        # stage
        nodes = root.getElementsByTagName('stage')
        if len(nodes) > 0:
            node = nodes[0]
            print '!!!'
            snodes = root.getElementsByTagName('step')
            # parse step
            for snode in snodes:
                if snode.nodeType == snode.TEXT_NODE: continue
                step = self.newStep()
                for k in step['seq']:
                    subNodes = snode.getElementsByTagName(k)
                    print '====', subNodes, k
                    if len(subNodes) > 0:
                        subNode = subNodes[0]
                        v = self.__getXmlTextValue(subNode)
                        step['data'][k] = v
                steps.append(step)

        print '--' * 16
        pprint(case)

        return


    def loadXls(self, fname):
        """
        """
        rc = False
        if not os.path.exists(fname):
            print '==', 'File not exist!'
            return rc
        self.m_wb = xlrd.open_workbook(fname)
        # parse menu sheet
        rc = self.parseXlsMenuSheet()

        # parse case sheet
        for name in self.m_cases['seq']:
            case = self.m_cases['data'][name]
            rc = self.parseXlsCaseSheet(case)
        return rc

    def save2Xml(self, path):
        """
        """
        for name in self.m_cases['seq']:
            case = self.m_cases['data'][name]
            self.saveCase2Xml(case, path)


    def saveCase2Xml(self, case, path):
        """
        """
        headers = case['headers']
        steps = case['steps']
        name = headers['data']['name']
        filename = casename2filename(name)

        # create file path to save
        if not os.path.exists(path):
            os.makedirs(path)
        fn = os.path.join(path, filename)
        if not fn.endswith('.xml'):
            fn += '.xml'
            # create file content from structure case
        impl = minidom.getDOMImplementation()
        _dom = impl.createDocument(None, u'testcase', None)
        _root = _dom.documentElement
        # add headers
        for key in headers['seq']:
            val = str(headers['data'][key])
            print '--', key, val
            if not val == None:
                if key.find('/') < 0:
                    newNode = _dom.createElement(key)
                    newText = _dom.createTextNode(val)
                    newNode.appendChild(newText)
                    _root.appendChild(newNode)
                else:
                    zk = key.split('/')
                    if len(zk) > 2:
                        print 'Not support more than 2 level :', key
                        continue
                        #
                    k1 = zk[0]
                    node1 = _root.getElementsByTagName(k1)
                    #print node1
                    if len(node1) == 0:
                        nd = _dom.createElement(k1)
                        _root.appendChild(nd)
                        node1.append(nd)
                        #
                    k2 = zk[1]
                    newNode = _dom.createElement(k2)
                    newText = _dom.createTextNode(val)
                    newNode.appendChild(newText)
                    node1[0].appendChild(newNode)

        # add case steps
        nodeStage = _dom.createElement('stage')
        _root.appendChild(nodeStage)
        for step in steps:
            print 'step', step
            nodeStep = _dom.createElement('step')
            nodeStage.appendChild(nodeStep)
            for key in step['seq']:
                val = str(step['data'][key]).strip()
                print '==', key, val
                if key == 'getenv' and not val:
                    continue
                if key == 'script' and not val:
                    continue
                newNode = _dom.createElement(key)
                newText = _dom.createTextNode(val)
                newNode.appendChild(newText)
                nodeStep.appendChild(newNode)


        # save to file

        domcopy = _dom.cloneNode(True)
        myIndent(domcopy, domcopy.documentElement)
        f = open(fn, 'wb')
        writer = codecs.lookup('utf-8')[3](f)
        #_dom.writexml(writer,indent="\t", addindent="\t", newl="\n", encoding='utf-8')
        #domcopy.writexml(writer,indent="\t", addindent="\t", newl="\n", encoding='utf-8')
        domcopy.writexml(writer, indent="", addindent="", newl="", encoding='utf-8')
        writer.close()
        f.close()

        # dump
        #os.system(fn)
        #print '==='*16
        #print 'xml :'
        #print (_root.toprettyxml(indent="\t", newl="\n") )


    def save2Xls(self, fn):
        """
        """
        if len(self.m_cases) == 0:
            print '==!', 'no case exist!'
            exit(4)

        wb = xlwt.Workbook()
        # save menu sheet
        tbl = wb.add_sheet('menu', cell_overwrite_ok=True)
        max_col_len = self.saveXlsMenuSheet(tbl)
        self.fitSheetSize(tbl, max_col_len)
        # save case sheet
        for name in self.m_cases['seq']:
            case = self.m_cases['data'][name]
            print '==', 'add case : ', name
            if len(name) > 30: name = name[:30]
            sheetname = casename2sheetname(name)
            tbl = wb.add_sheet(sheetname, cell_overwrite_ok=True)
            max_col_len = self.saveXlsCaseSheet(tbl, case)
            self.fitSheetSize(tbl, max_col_len)
            # save to file
        wb.save(fn)

    def saveXlsMenuSheet(self, tbl):
        """
        """
        max_col_len = []
        # save headers
        headers = self.m_headers['seq']
        style = self.HeadersStyle()

        for col, key in enumerate(headers):
            tbl.write(0, col, key, style)
            max_col_len.append(len(key))

        # save data
        for row, name in enumerate(self.m_cases['seq']):
            case = self.m_cases['data'][name]
            case_headers = case['headers']
            data = case_headers['data']
            style = self.TextStyle()
            for col, key in enumerate(headers):
                val = data[key]
                if val == None: val = ''
                if len(val) > max_col_len[col]:
                    max_col_len[col] = len(val)
                if val.isdigit(): val = int(val)
                tbl.write(row + 1, col, val, style)

        return max_col_len


    def saveXlsCaseSheet(self, tbl, case):
        """
        """
        max_col_len = []
        steps = case['steps']
        if len(steps) == 0:
            print '==', 'case : ', case['headers']['data']['name'], ' flow is empty!'
            #return
        # write headers
        headers = self.m_step['seq']
        style = self.HeadersStyle()

        for idx, key in enumerate(headers):
            tbl.write(0, idx, key, style)
            max_col_len.append(len(key))

        # add case step
        style = self.TextStyle()
        for row, step in enumerate(steps):
            for col, key in enumerate(headers):
                val = step['data'][key]
                if val == None: val = ''
                if len(val) > max_col_len[col]:
                    max_col_len[col] = len(val)
                if val.isdigit(): val = int(val)
                tbl.write(row + 1, col, val, style)

        return max_col_len


    def xls2xml(self):
        """
        """
        pass

    def xml2xls(self, fn):
        """
        """
        pass


    def parseXlsMenuSheet(self):
        """
        """
        try:
            sh = self.m_wb.sheet_by_name("menu")
        except:
            print "no sheet in %s named Sheet1" % fname
            return None
        nrows = sh.nrows
        ncols = sh.ncols

        if nrows < 1 or ncols < 1:
            print 'sheet menu is invalid'
            exit(2)
        else:
            print 'menu sheet(rows,cols) :', nrows, ncols
            # check headers
        headers = sh.row_values(0)
        if not 'name' in headers:
            print 'sheet menu MUST have header :', 'name'
            exit(2)

        for key in self.m_headers['seq']:
            if not key in headers:
                print 'loss header :', key
                exit(2)

        # parse data
        for i in range(0, nrows):
            row_data = sh.row_values(i)
            if i == 0: continue
            d = {}
            for index, val in enumerate(row_data):
                key = headers[index]
                d[key] = val
                #print '--',key,v
            case = self.newCase(d['name'])
            data = case['headers']['data']
            for (k, v) in d.items():
                if k in data: data[k] = v
                #print ''
                #pprint( self.m_cases)

    def parseXlsCaseSheet(self, case):
        """
        """
        casename = case['headers']['data']['name']
        sheetname = casename2sheetname(casename)
        steps = case['steps']

        try:
            print 'get sheet :', sheetname
            sh = self.m_wb.sheet_by_name(sheetname)
        except:
            print "no sheet in %s named Sheet1" % fname
            return None
        nrows = sh.nrows
        ncols = sh.ncols

        if nrows < 1 or ncols < 1:
            print 'case flow sheet (', casename, ') is invalid'
            return
        headers = []

        for i in range(0, nrows):
            row_data = sh.row_values(i)
            step = self.newStep()
            if i == 0:
                # check step headers
                headers = sh.row_values(0)
                for key in step['seq']:
                    if not key in headers:
                        print '==', 'loss case step key :', key
                        exit(3)
            else:
                for index, val in enumerate(row_data):
                    if types.FloatType == type(val):
                        val = int(val)
                        val = str(val)
                    key = headers[index]
                    if key in step['seq']:
                        step['data'][key] = val
                        print '==', 'Set Case Step : ', key, val
                    else:
                        print '==', key, ' is not in ', step['seq']
                case['steps'].append(step)
        print '==' * 16
        pprint(case)

    def createTemplateXls(self, caseListFn, dest):
        """
        """
        if not os.path.exists(caseListFn):
            print "File is not exist :", caseListFn
            return False
        else:
            print "Case list file is :", caseListFn
            #
        fd = open(caseListFn, 'r')
        case_list = []
        if fd:
            lines = fd.readlines()
            fd.close()
            for line in lines:
                line = line.strip()
                if len(line) == 0:
                    print '== Line is empty'
                    continue
                elif line.startswith('#'):
                    print '== Line is commnet : ', line
                    continue
                casename = line
                case = self.newCase(casename)
                case_headers = case['headers']
                data = case_headers['data']
                data['name'] = casename
        else:
            print "load file error : ", caseListFn
            return False

        #

        #os.makedirs(dest)
        self.save2Xls(dest)
        return True


#ATC = AutomationTestCaseCreator()

# from xls to mycases
#ATC.loadXls('D:\sample.xls')
#ATC.save2Xml('D:\mycases')


#ATC.loadXml(r'D:\testcase.xml')
#ATC.save2Xls('D:\mycases\sample2.xls')

#ATC.loadXmls(r'D:\test\cases\SSID1\*.xml')
#ATC.save2Xls(r'D:\test\mycases2.xls')
#ATC.save2Xml(r'D:\test\mycases')

#testXls()


def checkXmlSource(s):
    """
    """
    rc = False
    import glob

    fileList = glob.glob(s)
    fileList.sort()
    if len(fileList) == 0:
        return rc

    return True


def checkXmlDest(s):
    """
    """
    rc = False
    f = s
    fullpath = os.path.abspath(f)

    #if not os.path.ispath(fullpath) :
    #    print '==','Is not path :',s
    #    return rc
    return True


def checkXls(s):
    """
    """
    rc = False
    f = s
    fullpath = os.path.abspath(f)
    #if not os.path.exists(fullpath) :
    #    print '==','Not exist :',s
    #    return rc

    #if not os.path.isfile(fullpath) :
    #    print '==','Is not file :',s
    #    return rc

    if not fullpath.endswith('.xls'):
        print '==', 'File ext is not xls :', s
        return rc
    return True


def xml2xls(src, dst):
    """
    """
    ATC = AutomationTestCaseCreator()
    ATC.loadXmls(src)
    ATC.save2Xls(dst)


def xls2xml(src, dst):
    """
    """
    ATC = AutomationTestCaseCreator()
    ATC.loadXls(src)
    ATC.save2Xml(dst)


def createTemplateXls(src, dst):
    """
    """
    ATC = AutomationTestCaseCreator()
    ATC.createTemplateXls(src, dst)


#------------------------------------------------------------------------------

def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ('\nGet more info with command : pydoc ' + os.path.abspath(__file__) + '\n')
    parser = OptionParser(usage=usage)

    parser.add_option("-d", "--destination", dest="dest",
                      help="destination path to save xml files or file path to save xls file")
    parser.add_option("-m", "--mode", dest="mode",
                      help="working mode : xml2xls , xls2xml or tmplxls")
    parser.add_option("-s", "--source", dest="src",
                      help="source xml files or source xls file")
    parser.add_option("-x", "--loglevel", type="int", dest="loglevel", default=30,
                      help="the log level, default is 30(WARNING)")

    (options, args) = parser.parse_args()
    if not options.mode or not options.dest or not options.dest:
        print '==', 'loss mode,source or destnation'
        parser.print_help()
        exit(1)

    if options.mode not in ['xml2xls', 'xls2xml', 'tmplxls']:
        print '==', 'bad mode'
        parser.print_help()
        exit(1)

    # output the options list
    print '==' * 32
    print 'Options :'
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(options):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(options, k)
        print k, ':', v
        #exit(1)
    print '==' * 32
    print ''

    return options
    #------------------------------------------------------------------------------


def main():
    """
    main entry
    """
    opts = parseCommandLine()
    src = opts.src
    dest = opts.dest

    print 'current mode :', opts.mode

    if opts.mode == 'xml2xls':

        rc = checkXmlSource(src)
        if not rc: exit(2)
        rc = checkXls(dest)
        if not rc: exit(2)
        xml2xls(src, dest)
    elif opts.mode == 'xls2xml':
        rc = checkXls(src)
        if not rc: exit(2)
        rc = checkXmlDest(dest)
        if not rc: exit(2)
        xls2xml(src, dest)
    elif opts.mode == 'tmplxls':
        createTemplateXls(src, dest)
    else:
        print '==', 'No handler'
    return 0


if __name__ == '__main__':
    """
    """
    main()


