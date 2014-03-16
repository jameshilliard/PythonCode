#!/usr/bin/python -u
# -*- coding: utf-8 -*-
"""

"""

from types import *
import sys, time, os
import re
from optparse import OptionParser
from optparse import OptionGroup
import logging
from pprint import pprint
from pprint import pformat
import xml.etree.ElementTree as etree
import subprocess, signal, select
from copy import deepcopy
import syslog
import traceback
from datetime import datetime
from datetime import date
from datetime import timedelta

try:
    import MySQLdb
except Exception, e:
    print 'Import MySQLdb failed!'
    print "Please install MySQLdb!"
    exit(5)

try:
    import xlrd, xlwt
except Exception, e:
    print 'Import xlrd and xlwt failed!'
    print "Please install xlrd and xlwt!"
    exit(5)

from pyh import *


class ExcelReportCreator():
    """
    ID	Test Bed	Tester	Product Type	DUT SW Version	Suites		Cases				"Test
Begin"	Report Time	Duration	Avg. 	Remain Time	Agile Bug	AT Version
					Done	Queue	Total	Pass	Fail	Skip							

    """

    _colname = ['ID', 'Test Bed', 'Tester', 'Product Type', 'DUT SW Version', {'Suites': ['Done', 'Queue']},
                {'Cases': ['Total', 'Pass', 'Fail', 'Skip']}, 'Test Begin', 'Report Time', 'Duration', 'Avg.',
                'Remain Time', 'Agile Bugs', 'AT Version', 'Status', 'Test Type']

    _cols = []
    _datas = []
    _page = None

    def __init__(self):
        """
        """
        project = "Automation Test"
        self._page = PyH('%s test report' % project)
        self._page << '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'


    def loadData(self, cols, datas):
        """
        """
        self._cols = cols
        self._datas = datas


    def save2xl(self, fn=None):
        """
        """
        if not fn:
            fn = 'test.xls'
        wb = xlwt.Workbook()
        # save menu sheet
        tbl = wb.add_sheet('summary', cell_overwrite_ok=True)
        #max_col_len = self.saveXlsMenuSheet(tbl)
        #self.fitSheetSize(tbl,max_col_len)
        #tbl.set_row_default_height(400*2)
        self._writeTitles(tbl)
        self._writeRecords(tbl)
        wb.save(fn)

    def save2Html(self, fn=None, cols=None):
        """
        """
        if not fn:
            fn = 'test.xls'
            #
        pg = self._page
        #
        sum_div = div(b('Test Results'), id='Test_Results')
        pg << sum_div
        tab_task = pg << table()
        self.tablecss(tab_task)
        tab_task = tab_task << tr()
        self.tr_title_css(tab_task)

        #ti = self._testInfo

        if True:
            #add task column title
            if not cols:
                cols = self._cols
            title_cols = cols
            for col in title_cols:
                val = col
                _td = tab_task << td('<b>' + val + '</b>')
                self.td_title_css(_td)

                # Add records
            for data in self._datas:
                _tr = value_tr_task = tab_task << tr()

                if data['Cases-Fail'] or data['Cases-Skip']:
                    self.tr_red_css(_tr)
                else:
                    self.tr_normal_css(_tr)

                for idx, col in enumerate(cols):
                #self.tr_normal_css(_tr)
                    cell = data[col]
                    _td = value_tr_task << td(str(cell))

        print '--> Save HTML : ', fn
        pg.printOut(fn)

    def tablecss(self, table=None, width='60%'):
        table.attributes['cellSpacing'] = 0
        table.attributes['cellPadding'] = 1
        table.attributes['border'] = 1

        table.attributes['borderColor'] = '#003399'
        table.attributes['width'] = width

        #table.attributes['style'] = "background-color:#EEEEEE;"    

    def tr_title_css(self, tr=None):
        tr.attributes['style'] = "background-color:#DFC5A4;font-family:Arial;font-size:18px;"
        pass

    def td_title_css(self, td=None):
        #tr.attributes['bgcolor'] = '#CCCC00'  
        td.attributes['style'] = "background-color:#DFC5A4;font-family:Arial;font-size:14px;"

    def td_red_css(self, td=None):
        #tr.attributes['bgcolor'] = '#CCCC00'  
        td.attributes['style'] = "color:#FF0000;font-family:Arial;font-size:14px;"

    def tr_red_css(self, tr=None):
        tr.attributes['style'] = "color:#FF0000;font-family:Arial;font-size:14px;"


    def td_normal_css(self, td=None):
        #tr.attributes['bgcolor'] = '#CCCC00'  
        td.attributes['style'] = "color:#000000;font-family:Arial;font-size:14px;"

    def tr_normal_css(self, tr=None):
        tr.attributes['style'] = "color:#000000;font-family:Arial;font-size:14px;"

    def _writeTitles(self, tbl):
        """
        """
        idx = 0
        style = self._HeadersStyle()
        for col in self._colname:
            if isinstance(col, dict):
                for k, v in col.items():
                    #
                    rlen = 0
                    idx_begin = idx
                    if isinstance(v, list):
                        rlen = len(v)
                        for vv in v:
                            tbl.write(1, idx, str(vv), style)
                            idx += 1
                    else:
                        tbl.write(1, idx, str(v), style)
                        idx += 1
                    idx_end = idx - 1
                    if rlen > 0:
                        tbl.write_merge(0, 0, idx_begin, idx_end, str(k), style)
                    else:
                        tbl.write(0, idx_begin, str(k), style)
            else:
                clen = 1
                tbl.write_merge(0, 1, idx, idx, str(col), style)
                idx += 1

    def _writeRecords(self, tbl):
        """
        """
        cols = self._cols
        datas = self._datas

        nrow = 2
        for data in datas:
            _style = self._TextStyle()
            print '===>', data['Cases-Fail'], data['Cases-Skip']
            if data['Cases-Fail'] or data['Cases-Skip']:
                _style = self._RedTextStyle()
            else:
                pass

            for idx, col in enumerate(cols):
                v = (data[col])
                if not isinstance(v, int):
                    v = str(v)
                tbl.write(nrow, idx, v, _style)
            nrow += 1

        self.fitSheetHeight(tbl, nrow)

    def _HeadersStyle(self):
        """
        """
        tittle_style = xlwt.easyxf(
            'font: height 240, name Arial , colour_index black, bold on; align: wrap on, vert centre, horiz center; pattern: pattern solid_fill, fore_color ice_blue;'    "borders: top thin, bottom thin, left thin, right thin;")
        return tittle_style

    def _TextStyle(self):
        """
        """
        normal_style = xlwt.easyxf(
            'font: height 200, name Arial, colour_index black, bold off; align: wrap on, vert centre, horiz left;'      "borders: top thin, bottom thin, left thin, right thin;")
        return normal_style

    def _RedTextStyle(self):
        """
        """
        _style = xlwt.easyxf(
            'font: height 200, name Arial, colour_index red, bold off; align: wrap on, vert centre, horiz left;'      "borders: top thin, bottom thin, left thin, right thin;")
        return _style

    def fitSheetHeight(self, tbl, rows):
        """
        """
        idx = 2
        while (idx < rows):
            sz = 30 * 10 * 2
            tbl.row(idx).height = sz
            idx += 1
            #print 'fit size :',idx,w


        #exit(3)
        return tbl


class DB2Records():
    """
    """
    _dbinfo = {
        'host': '',
        'user': '',
        'passwd': '',
        'dbname': '',
    }

    _colname = ['ID', 'Test Bed', 'Tester', 'Product Type', 'DUT SW Version', 'Suites-Done', 'Suites-Queue',
                'Cases-Total', 'Cases-Pass', 'Cases-Fail', 'Cases-Skip', 'Test Begin', 'Report Time', 'Duration',
                'Avg.', 'Remain Time', 'Agile Bugs', 'AT Version', 'Status', 'Test Type']

    _colnameHTML = []
    _filter_startDateTime = {
        'after': None,
        'before': None,
    }
    _filter_status_exclude = []
    _db = None

    _reports = []

    def __init__(self):
        """
        """
        self._colnameHTML = []
        self._colnameHTML = deepcopy(self._colname)
        self._colnameHTML.append('Last Suite')
        self._colnameHTML.append('Last Case')
        self._colnameHTML.append('Log Path')


    def _newRpt(self):
        """
        """
        _rpt = {}
        for name in self._colname:
            _rpt[name] = ''

        return deepcopy(_rpt)


    def setupDBInfo(self, dbhost='127.0.0.1', user='root', passwd='123qaz', dbname='automation_test'):
        """
        """
        dbi = self._dbinfo
        dbi['host'] = dbhost
        dbi['user'] = user
        dbi['passwd'] = passwd
        dbi['dbname'] = dbname
        #dbi[''] = 

    def setupFilter_Date(self, startDatetime=None, endDatetime=None):
        """
        """
        self._filter_startDateTime['after'] = startDatetime
        self._filter_startDateTime['before'] = endDatetime

    def setupFilter_StatusExclude(self, st):
        """
        """
        self._filter_status_exclude.append(st)


    def do_load(self):
        """
        """
        self._loadDataFromDB()


    def save2Xls(self, fn):
        """
        """
        erc = ExcelReportCreator()
        erc.loadData(self._colname, self._reports)
        #fn = 'test.xls'
        erc.save2xl(fn)

        html_fn = os.path.join(os.path.dirname(fn), 'test_report.html')
        erc.save2Html(html_fn, self._colnameHTML)

    def _loadDataFromDB(self):
        """
        """
        db = None
        tasks = []
        db = self._openDB()
        tasks = self._selectTestTasks(db)
        for task in tasks:
            self._parseTask(db, task)

    def _parseTask(self, db, task):
        """
        _colname = ['ID','Test Bed','Tester','Product Type','DUT SW Version','Suites-Done','Suites-Queue','Cases-Total','Cases-Pass','Cases-Fail','Cases-Skip','Test Begin','Report Time','Duration','Avg.','Remain Time','Agile Bugs','AT Version']
        """
        rpt = self._newRpt()
        #pprint(task)
        rpt['ID'] = len(self._reports) + 1
        rpt['Test Bed'] = task['Testbed']
        rpt['Tester'] = task['Tester']
        rpt['Product Type'] = task['DutType']
        rpt['Test Type'] = task['TestType']
        rpt['DUT SW Version'] = task['DutVersion']
        rpt['Test Begin'] = task['StartTime']
        if task['EndTime']:
            rpt['Report Time'] = task['EndTime']
        else:
            rpt['Report Time'] = datetime.now()
        rpt['Duration'] = (rpt['Report Time'] - rpt['Test Begin']).total_seconds()
        rpt['AT Version'] = task['AT_Version']
        rpt['Status'] = task['Status']
        print '--' * 16
        print 'TUID : ', task['TUID']

        # Cases-Total
        sqlfmt = "SELECT CaseName,CaseStatus,SuiteFullName,AgileIssueID FROM records WHERE TUID='%s' AND CaseType='%s'  ;"
        sql = sqlfmt % (task['TUID'], 'TCASE')
        res = self._selectTaskRecords(db, sql)
        rpt['Cases-Total'] = len(res)

        # ignore test tasks without any tcase
        if rpt['Cases-Total'] == 0:
            return

        # Cases-Pass
        sqlfmt = "SELECT CaseName,AgileIssueID FROM records WHERE TUID='%s' AND CaseType='%s' AND CaseStatus='%s' ;"
        sql = sqlfmt % (task['TUID'], 'TCASE', 'PASSED')
        res = self._selectTaskRecords(db, sql)
        rpt['Cases-Pass'] = len(res)

        # Cases-Fail
        sqlfmt = "SELECT CaseName,AgileIssueID FROM records WHERE TUID='%s' AND CaseType='%s' AND CaseStatus='%s' ;"
        sql = sqlfmt % (task['TUID'], 'TCASE', 'FAILED')
        res = self._selectTaskRecords(db, sql)
        rpt['Cases-Fail'] = len(res)
        for r in res:
            r = list(r)
            iid = r[1]
            sp = '\n'
            seg = str(iid) + sp
            if iid > 0 and rpt['Agile Bugs'].find(seg) < 0:
                rpt['Agile Bugs'] += (seg)

        # Cases-Skip
        sqlfmt = "SELECT CaseName,AgileIssueID FROM records WHERE TUID='%s' AND CaseType='%s' AND CaseStatus='%s' ;"
        sql = sqlfmt % (task['TUID'], 'TCASE', 'SKIPPED')
        res = self._selectTaskRecords(db, sql)
        rpt['Cases-Skip'] = len(res)
        for r in res:
            r = list(r)
            iid = r[1]
            sp = '\n'
            seg = str(iid) + sp
            if iid > 0 and rpt['Agile Bugs'].find(seg) < 0:
                rpt['Agile Bugs'] += (seg)

        # Suites-Done
        sqlfmt = "SELECT SuiteFullName,CaseFullName FROM records WHERE TUID='%s' AND CaseType='%s' AND CaseStatus!='%s' ;"
        sql = sqlfmt % (task['TUID'], 'TCASE', 'checked')
        res = self._selectTaskRecords(db, sql)
        sqlfmt = "SELECT SuiteFullName,CaseFullName FROM records WHERE TUID='%s' AND CaseType='%s' AND CaseStatus='%s';"
        sql = sqlfmt % (task['TUID'], 'TCASE', 'checked')
        res2 = self._selectTaskRecords(db, sql)
        tst_has_tcase_done = []
        tst_has_tcase_todo = []
        for r in res:
            r = list(r)
            if len(r):
                tst_name = r[0]
                if tst_name not in tst_has_tcase_done:
                    tst_has_tcase_done.append(tst_name)

        # 
        adjust_updateTime = True
        rpt['Last Suite'] = ''
        rpt['Last Case'] = ''
        if adjust_updateTime:
            sqlfmt = "SELECT `Index`,RunIndex,SuiteFullName,CaseFullName,EndTime FROM records WHERE TUID='%s' AND CaseStatus!='%s' GROUP BY `Index`;"
            sql = sqlfmt % (task['TUID'], 'checked')
            res = self._selectTaskRecords(db, sql)
            if len(res):
                r = res[-1]
                r = list(r)
                tst_fullname = r[2]
                case_fullname = r[3]
                endtime = r[4]
                #rpt['Report Time'] = endtime
                #rpt['Duration'] = (endtime - rpt['Test Begin']).total_seconds()
                rpt['Last Suite'] = os.path.basename(tst_fullname)
                rpt['Last Case'] = os.path.basename(case_fullname)
                print "=======================>", len(res), r
                #exit(1)

        for r in res2:
            r = list(r)
            if len(r):
                tst_name = r[0]
                if tst_name not in tst_has_tcase_todo:
                    tst_has_tcase_todo.append(tst_name)

        tst_queue = [tst for tst in tst_has_tcase_todo if tst not in tst_has_tcase_done]
        print '--->', tst_has_tcase_done
        print '--->', tst_has_tcase_todo
        print '--->', tst_queue

        rpt['Suites-Done'] = len(tst_has_tcase_done)
        rpt['Suites-Queue'] = len(tst_queue)


        # Others
        num_tcases_tested = rpt['Cases-Pass'] + rpt['Cases-Fail']
        if num_tcases_tested > 0:
            rpt['Avg.'] = rpt['Duration'] / num_tcases_tested
        else:
            rpt['Avg.'] = rpt['Duration']

        rpt['Remain Time'] = rpt['Avg.'] * (
        rpt['Cases-Total'] - rpt['Cases-Pass'] - rpt['Cases-Fail'] - rpt['Cases-Skip'])

        if rpt['Status'] not in ["IN TESTING"]:
            rpt['Remain Time'] = 0

        # adjust time output format
        rpt['Avg.'] = timedelta(seconds=int(rpt['Avg.']))
        rpt['Remain Time'] = timedelta(seconds=int(rpt['Remain Time']))
        rpt['Duration'] = timedelta(seconds=int(rpt['Duration']))
        #rpt['Report Time'].microsecond = 0  
        if rpt['Agile Bugs'].endswith("\n"):
            rpt['Agile Bugs'] = rpt['Agile Bugs'][:-1]

        rpt['Log Path'] = task['LogPath']

        pprint(rpt)



        #
        self._reports.append(rpt)


    def _openDB(self):
        """
        """
        dbi = self._dbinfo
        try:
            host = dbi['host']
            user = dbi['user']
            passwd = dbi['passwd']
            dbname = dbi['dbname']
            _db = MySQLdb.connect(host, user, passwd, dbname)
            return _db
        except Exception, e:
            print e
            print dbi
            exit(1)
            pass

        return None

    def _selectTestTasks(self, db):
        """
        """
        tasks = []
        col_names = []
        try:
            # Get task structure
            cursor = db.cursor()
            sql = 'describe tasks;'
            print '==>SQL :', sql

            cursor.execute(sql)
            result_set = cursor.fetchall()
            #pprint(result_set)
            for rset in result_set:
                rr = list(rset)
                col_names.append(rr[0])
            cursor.close()

            # Get task records
            cursor = db.cursor()
            sqlfmt = "SELECT * FROM tasks %s GROUP BY `id`;"
            location = ''
            dt_before = self._filter_startDateTime['before']
            dt_after = self._filter_startDateTime['after']
            if dt_after:
                if len(location):
                    location += " AND "
                else:
                    location += " WHERE "
                location += ("StartTime >= '%s' " % dt_after)
            if dt_before:

                if len(location):
                    location += " AND "
                else:
                    location += " WHERE "
                location += ("StartTime <= '%s' " % dt_before)

            for ex in self._filter_status_exclude:
                if len(location):
                    location += " AND "
                else:
                    location += " WHERE "
                location += ("Status != '%s' " % ex)

            sql = sqlfmt % location
            print '==>SQL :', sql
            cursor.execute(sql)
            result_set = cursor.fetchall()
            pprint(result_set)
            for rset in result_set:
                t = list(rset)
                task = {}
                for i, key in enumerate(col_names):
                    task[key] = t[i]
                tasks.append(task)
                #pprint(task)
            cursor.close()


            #return tasks

        except Exception, e:
            print e
            exit(1)
            pass

        return tasks

    def _selectTaskRecords(self, db, sql):
        """
        """
        try:

            cursor = db.cursor()
            #sql = ""
            print 'SQL :', sql
            cursor.execute(sql)
            result_set = cursor.fetchall()
            #pprint(result_set)
            cursor.close()
            return result_set

        except Exception, e:
            print e
            exit(1)
            pass

        return None


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ("\nGet more info with command : pydoc " + os.path.abspath(__file__) + "\n")
    parser = OptionParser(usage=usage)

    parser.add_option("-s", "--saveas", dest="SAVEAS",
                      help="Save result to")

    parser.add_option("-a", "--after", dest="AFTER",
                      help="Filter test task begin time after,format is YY/mm/dd [HH:MM:SS] ")
    parser.add_option("-b", "--before", dest="BEFORE",
                      help="Filter test task begin time before,format is YY/mm/dd [HH:MM:SS] ")

    parser.add_option("-f", "--filter", dest="FILTER", action='append',
                      help="")

    parser.add_option("-d", "--host", dest="DB_HOST",
                      help="DB host ")

    parser.add_option("-u", "--username", dest="DB_USER",
                      help="DB username")
    parser.add_option("-p", "--password", dest="DB_PASS",
                      help="DB password")
    parser.add_option("-n", "--name", dest="DB_NAME",
                      help="DB name")

    parser.add_option("--ignore-aborted", dest="IGNORE_ABORTED", action='store_true', default=False,
                      help="Only show tasks which status is not ABORTED")

    (options, args) = parser.parse_args()


    # output the options list
    print '==' * 32
    print 'Args :'
    for arg in args:
        print arg
        # output the options list
    print '==' * 32
    print 'Options :'
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(options):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(options, k)
        print '%-16s : %s' % (k, v)
    print '==' * 32
    print '\n' * 2
    #if len(args) < 1 :
    #    print '==','1 arguments required'
    #    parser.print_help()
    #    exit(1)
    return args, options


def main():
    """
    main entry
    """

    args, opts = parseCommandLine()

    dbr = DB2Records()
    dt_after = None
    dt_before = None

    year = 0
    month = 0
    day = 0
    hour = 0
    minute = 0
    second = 0
    dt_yesterday = datetime.today() - timedelta(hours=24)
    print '-->yesterday :', dt_yesterday
    #exit(1)
    year = dt_yesterday.year
    month = dt_yesterday.month
    day = dt_yesterday.day
    if opts.AFTER:
        m1 = r'(\d*)/(\d*)/(\d*)'
        m2 = r'(\d*):(\d*):(\d*)'
        res1 = re.findall(m1, opts.AFTER)
        res2 = re.findall(m2, opts.AFTER)
        if len(res1):
            year, month, day = res1[0]
        if len(res2):
            hour, minute, second = res2[0]
    dt_after = datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))

    #
    if opts.BEFORE:
        dt_nextday = datetime.today() - timedelta(hours=24)
        #print '-->yesterday :',dt_yesterday
        #exit(1)
        year = dt_nextday.year
        month = dt_nextday.month
        day = dt_nextday.day

        m1 = r'(\d*)/(\d*)/(\d*)'
        m2 = r'(\d*):(\d*):(\d*)'
        res1 = re.findall(m1, opts.BEFORE)
        res2 = re.findall(m2, opts.BEFORE)
        if len(res1):
            year, month, day = res1[0]
        if len(res2):
            hour, minute, second = res2[0]

        dt_before = datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))

    dbr.setupFilter_Date(startDatetime=dt_after, endDatetime=dt_before)

    if opts.IGNORE_ABORTED:
        dbr.setupFilter_StatusExclude('ABORTED')

    host = '127.0.0.1'
    user = 'root'
    passwd = '123qaz'
    dbname = 'automation_test'
    if opts.DB_HOST: host = opts.DB_HOST
    if opts.DB_USER: user = opts.DB_USER
    if opts.DB_PASS: passwd = opts.DB_PASS
    if opts.DB_NAME: dbname = opts.DB_NAME

    dbr.setupDBInfo(host, user, passwd, dbname)
    dbr.do_load()
    #dbr.save2Xls('test.xls')
    if opts.SAVEAS:
        dbr.save2Xls(opts.SAVEAS)
    else:
        dbr.save2Xls('test_rpt.xls')


    #epc = ExcelReportCreator()

    #if opts.SAVEAS :
    #    dbr.save2Xls('test.xls')
    #    #dbe.save2xl(opts.SAVEAS)
    #    epc.save2xl(opts.SAVEAS)
    #else :
    #    epc.save2xl()



    print '--' * 16
    print '==DONE!'
    exit(0)


if __name__ == '__main__':
    """
    """

    main()
