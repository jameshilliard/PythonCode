#!/usr/bin/env python
# coding=utf-8
from optparse import OptionParser
import sys, time, os, re, logging
from pprint import pprint, pformat
from traceback import format_exc
from copy import deepcopy
import csv
import MySQLdb
from pprint import pprint


class DBI():
    """
    """
    _host = ''
    _port = ''
    _user = ''
    _passwd = ''
    _dbname = ''
    _conn_timeout = 30
    _logger = None
    #    U_CUSTOM_DB_SERVER automation_test

    def __init__(self, host='127.0.0.1', port='3306', user='root', passwd='123qaz',
                 dbname=os.getenv('U_CUSTOM_DB_NAME', 'automation_test'), conn_timeout=30, logger=None):
        """
        """
        (self._host, self._port, self._user, self._passwd, self._dbname, self._conn_timeout) = (
        host, port, user, passwd, dbname, conn_timeout)
        self._logger = logger
        if not logger:
            # self._logger = getTestLogger()
            self._logger = logging.getLogger("DBI")
            # self._logger.setLevel(logging.DEBUG)
            stdhdlr = logging.StreamHandler(sys.stdout)
            FORMAT = '[%(levelname)s] %(message)s'
            stdhdlr.setFormatter(logging.Formatter(FORMAT))
            self._logger.addHandler(stdhdlr)
            stdhdlr.setLevel(logging.DEBUG)
            pass
        else:
            self._logger = logger

        pass

    def _openDB(self):
        """
        """
        conn = None
        try:
            conn = MySQLdb.connect(host=self._host, user=self._user, passwd=self._passwd, port=int(self._port),
                                   connect_timeout=self._conn_timeout)
            conn.select_db(self._dbname)
        except Exception, e:
            # self._logger.error('open db failed',exc_info=1)
            self._logger.error('open db failed : %s' % e)
            pass

        return conn

    def exec_SQL(self, sql):
        """
        """
        conn = self._openDB()
        r = False
        result_set = None
        if conn:
            try:
                cursor = conn.cursor()
                r = cursor.execute(sql)
                #                 r = conn.insert_id()
                conn.commit()
                result_set = cursor.fetchall()
                cursor.close()
                conn.close()
                pass
            except Exception, e:
                # self._logger.error("exec_SQL except :",exc_info=1)
                self._logger.error('open db failed : %s' % e)
        else:
            pass

        return (r, result_set)

    def exec_SQL2(self, sql):
        """
        """
        conn = self._openDB()
        r = False
        result_set = None
        if conn:
            try:
                cursor = conn.cursor()
                r = cursor.execute(sql)
                r = conn.insert_id()
                conn.commit()
                result_set = cursor.fetchall()
                cursor.close()
                conn.close()
                pass
            except Exception, e:
                # self._logger.error("exec_SQL except :",exc_info=1)
                self._logger.error('open db failed : %s' % e)
        else:
            pass

        return (r, result_set)

    def exec_SQLs(self, sqls):
        """
        """
        conn = self._openDB()
        r = False
        if conn:
            try:
                cursor = conn.cursor()
                r = []
                for sql in sqls:
                    _r = cursor.execute(sql)
                    r.append(_r)
                    pass

                conn.commit()
                cursor.close()
                conn.close()
                # return r
                pass
            except Exception, e:
                # self._logger.error("exec_SQLs except :",exc_info=1)
                self._logger.error('open db failed : %s' % e)
                pass
        else:
            pass

        return r

    def batch_SQL(self, sql_str, values):
        """
        """
        conn = self._openDB()
        r = False
        if conn:
            try:
                cursor = conn.cursor()
                r = cursor.executemany(sql_str, values)
                conn.commit()
                cursor.close()
                conn.close()
            except Exception, e:
                self._logger.error("batch_SQL except :", exc_info=1)
                pass

                # return r
        else:
            pass

        return r


def insertTestResult(d={}):
    """
    """

    if not d:
        return False

    import types

    if not isinstance(d, types.DictionaryType):
        return False

    fields = []
    values = []
    for k, v in d.items():
        fields.append("`%s`" % str(k))
        values.append("'%s'" % str(v))
        pass

    sql = "INSERT INTO `t_am_performance_test_result` (%s) VALUES(%s)" % (','.join(fields), ','.join(values))
    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r, v = dbi.exec_SQL2(sql)

    return r


def updateTestCases(id_field, id_v, result_id, result_v):
    """
        UPDATE `test`.`t_am_performance_test_result` SET `testcase_id` = '1' WHERE `t_am_performance_test_result`.`id` =30
        'update test set info="I am rollen" where id=3'
    """

    sql = 'UPDATE t_am_performance_test_testcase SET ' + result_id + ' = ' + '"' + result_v + '"' + ' WHERE ' + id_field + ' = ' + id_v
    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r, v = dbi.exec_SQL2(sql)

    return r


def updateTestTask(id_field, id_v, result_id, result_v):
    """
        UPDATE `test`.`t_am_performance_test_result` SET `testcase_id` = '1' WHERE `t_am_performance_test_result`.`id` =30
        'update test set info="I am rollen" where id=3'
    """

    sql = 'UPDATE t_am_performance_test_testtask SET ' + result_id + ' = ' + '"' + result_v + '"' + ' WHERE ' + id_field + ' = "' + id_v + '"'
    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r, v = dbi.exec_SQL2(sql)

    return r


def updateTestHost(id_field, id_v, result_id, result_v):
    """
        UPDATE `test`.`t_am_performance_test_result` SET `testcase_id` = '1' WHERE `t_am_performance_test_result`.`id` =30
        'update test set info="I am rollen" where id=3'
        id     alias_name     ip_address     username     password     ssh_port     status     prod_br0_mac     product_name     env
    """

    sql = 'UPDATE t_am_performance_test_testhost SET ' + result_id + ' = ' + '"' + result_v + '"' + ' WHERE ' + id_field + ' = "' + id_v + '"'
    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r, v = dbi.exec_SQL2(sql)

    return r


def queryTBDSLAM(d={}):
    """
    #     Column     Type     Collation     Attributes     Null     Default     Extra     Action
    1     TBNAME     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    2     DSLAMTYPE     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
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
    
    """

    sql = "SELECT * FROM `t_am_dslam` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            print field + ' : ' + val
            if field == 'TAG' and val != '0':
                opt = ' <> '
                val = '0'

            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + '\"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r = dbi.exec_SQL(sql)

    return r


def queryDSLAMInfo(d={}):
    """
    1     testbed     varchar(255)     utf8_general_ci    
    2     dslamtype     varchar(255)     utf8_general_ci    
    3     dslamip     varchar(255)     utf8_general_ci    
    4     dslamuser     varchar(255)     utf8_general_ci 
    5     dslampwd     varchar(255)     utf8_general_ci   
    6     dslamport     varchar(255)     utf8_general_ci    
    """

    sql = "SELECT * FROM `tb_dslam_info` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            print field + ' : ' + val

            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + '\"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r = dbi.exec_SQL(sql)

    return r


def queryTestResult(d={}):
    """
    DB table format : 
    CREATE TABLE IF NOT EXISTS `t_am_performance_test_result` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `testcase` varchar(255) NOT NULL,
      `type` varchar(255) NOT NULL,
      `datapath` varchar(255) NOT NULL,
      `product` varchar(255) NOT NULL,
      `firmware` varchar(255) NOT NULL,
      `hardware` varchar(255) NOT NULL,
      `trial` int(11) NOT NULL COMMENT 'repeat times',
      `startime` datetime NOT NULL,
      `endtime` datetime NOT NULL,
      `64` float NOT NULL,
      `88` float NOT NULL,
      `128` float NOT NULL,
      `256` float NOT NULL,
      `512` float NOT NULL,
      `1024` float NOT NULL,
      `1280` float NOT NULL,
      `1518` float NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;
    
    
    """

    sql = "SELECT * FROM `t_am_performance_test_result` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + ' \"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r = dbi.exec_SQL(sql)

    return r


def queryTestTask(d={}):
    """
    DB table format : 
       id     uid     status     test_host     ssh_port     loop_time     chassis_type
    """

    sql = "SELECT * FROM `t_am_performance_test_testtask` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + ' \"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host, dbname=os.getenv('U_CUSTOM_DB_NAME', 'automation_test'))
    r = dbi.exec_SQL(sql)

    return r


def queryTestCases(d={}):
    """
    DB table format : 
       id     uid     status     test_host     ssh_port     loop_time     chassis_type
    """

    sql = "SELECT * FROM `t_am_performance_test_testcase` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + ' \"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host, dbname=os.getenv('U_CUSTOM_DB_NAME', 'automation_test'))
    r = dbi.exec_SQL(sql)

    return r


def queryHost(d={}):
    """
    DB table format : 
       id     uid     status     test_host     ssh_port     loop_time     chassis_type
    """

    sql = "SELECT * FROM `t_am_performance_test_testhost` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + ' \"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host, dbname=os.getenv('U_CUSTOM_DB_NAME', 'automation_test'))
    r = dbi.exec_SQL(sql)

    return r


def queryValueMap(d={}):
    """
    DB table format : 
       id     uid     status     test_host     ssh_port     loop_time     chassis_type
    """

    sql = "SELECT * FROM `t_am_custom_valuemap` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + ' \"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host, dbname=os.getenv('U_CUSTOM_DB_NAME', 'automation_test'))
    r = dbi.exec_SQL(sql)

    return r


def queryGlobalValue(d={}):
    """
    DB table format : 
       id     uid     status     test_host     ssh_port     loop_time     chassis_type
       SELECT * FROM `t_am_global_valuemap`JOIN `t_am_global_variables` ON t_am_global_valuemap.variables_id = t_am_global_variables.id
    WHERE products_id = '3'
    """

    sql = "SELECT * FROM `t_am_global_variables` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + ' \"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host, dbname=os.getenv('U_CUSTOM_DB_NAME', 'automation_test'))
    r = dbi.exec_SQL(sql)

    return r


def queryCustomlValue(d={}):
    """
    DB table format : 
       id     uid     status     test_host     ssh_port     loop_time     chassis_type
       SELECT * FROM `t_am_global_valuemap`JOIN `t_am_global_variables` ON t_am_global_valuemap.variables_id = t_am_global_variables.id
    WHERE products_id = '3'
    """

    sql = "SELECT * FROM `t_am_global_valuemap`JOIN `t_am_global_variables` ON t_am_global_valuemap.variables_id = t_am_global_variables.id "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + ' \"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host, dbname=os.getenv('U_CUSTOM_DB_NAME', 'automation_test'))
    r = dbi.exec_SQL(sql)

    return r


def queryGlobalProd(d={}):
    """
    DB table format : 
       id     uid     status     test_host     ssh_port     loop_time     chassis_type
    """

    sql = "SELECT * FROM `t_am_global_products` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            rc = re.findall(m, val)
            if len(rc) > 0:
                opt, val = rc[0]
            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + ' \"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host, dbname=os.getenv('U_CUSTOM_DB_NAME', 'automation_test'))
    r = dbi.exec_SQL(sql)

    return r


##################################
def queryTestCriteria(d={}):
    """
    DB table format : 
    CREATE TABLE IF NOT EXISTS `t_am_performance_test_result` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `testcase` varchar(255) NOT NULL,
      `type` varchar(255) NOT NULL,
      `datapath` varchar(255) NOT NULL,
      `product` varchar(255) NOT NULL,
      `firmware` varchar(255) NOT NULL,
      `hardware` varchar(255) NOT NULL,
      `trial` int(11) NOT NULL COMMENT 'repeat times',
      `startime` datetime NOT NULL,
      `endtime` datetime NOT NULL,
      `64` float NOT NULL,
      `88` float NOT NULL,
      `128` float NOT NULL,
      `256` float NOT NULL,
      `512` float NOT NULL,
      `1024` float NOT NULL,
      `1280` float NOT NULL,
      `1518` float NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;
    
    `t_am_performance_test_criteria`
    
    """

    sql = "SELECT * FROM `t_am_performance_test_criteria` "

    if len(d) > 0:
        tmp_arr = []
        sql += " WHERE "
        #         m = r'([<>=]+)(.*)'
        for field, val in d.items():
            opt = ' = '
            #             rc = re.findall(m, val)
            #             if len(rc) > 0:
            #                 opt, val = rc[0]
            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + ' \"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r = dbi.exec_SQL(sql)

    return r


def testInsertResult():
    """
    """
    d = {
        "testcase": "ADSL Single -> LAN",
        "type": "Throughput",
        "datapath": "Downstream",
        "product": "CTLC2KA",
        "firmware": "FW002",
        "hardware": "HW001",
        "trial": "1",
        "startime": "2013-05-29 15:00:00",
        "endtime": "2013-05-29 15:10:00",
        #         "64" : "0",
        #         "88" : "82",
        #         "128" : "83",
        #         "256" : "84",
        #         "512" : "85",
        #         "1024" : "86",
        #         "1280" : "87",
        "1518": "88",

    }
    rc = insertTestResult(d)
    if not rc:
        print('== FAIL')
        pass
    else:
        print('== PASS')
        pass
    pass


def testQueryCriteria():
    """
    id,testcase,type,datapath,min64,max64,min88,max88,min128,max128,min256,max256,min512,max512,min1024,max1024,min1280,max1280,min1518,max1518
    """
    cases = []
    rc = queryTestCriteria()
    if not rc:
        print('== FAIL')
        pass
    else:
    #         pprint(rc)
        count, records = rc
        #         print count
        for i in range(count):
            id, testcase, type, datapath, min64, max64, min88, max88, min128, max128, min256, max256, min512, max512, min1024, max1024, min1280, max1280, min1518, max1518 =
            records[i]
            if not str(testcase) in cases:
                cases.append(str(testcase))
        print('== PASS')
        pprint(cases)
        pass
    pass


def getDBInfo(sql):
    """
    """
    host = os.getenv('U_CUSTOM_AT_DB_HOST', '192.168.20.108')
    port = os.getenv('U_CUSTOM_AT_DB_PORT', '3306')
    user = os.getenv('U_CUSTOM_AT_DB_USERNAME', 'root')
    passwd = os.getenv('U_CUSTOM_AT_DB_PASSWORD', '123qaz')
    dbname = os.getenv('U_CUSTOM_AT_DB_NAME', 'automation_test')
    dbi = DBI(host=host, port=port, user=user, passwd=passwd, dbname=dbname, logger=None)
    r_sql, result_sql = dbi.exec_SQL(sql)
    return r_sql, result_sql

#def refind(d_str,d_range,m=r'\d{1}',debug=False):
#    p_id = re.findall(m, str(result_case_df))
#    all_point = range(len(result_case_df))
#    all_point_l = []
#    for i in all_point:
#        all_point_l.append(result_case_df[i][0])
#    if debug:
#        print all_point_l
#    return all_point_l 


def getGUICheckPoint(caseID, proID, dutVer=None, dstTable='t_am_gui_check_point', debug=False):
    """
    """
    #t_am_gui_check_point

    if not caseID or not proID:
        if debug:
            print 'AT_ERROR : The case ID is <%s> and the product ID is <%s>.' % (caseID, proID)
        return False
    sql_case_base = "select `ID` from " + dstTable + " where `Case ID` like '" + caseID + "%' and `Product_ID` = '" + str(
        proID) + "'"
    if dutVer:
        sql_case = sql_case_base + " and `Applicable to FW` = %s" % dutVer
    else:
        sql_case = sql_case_base
    if debug:
        print 'Current SQL command is <%s>.' % sql_case
    r_case, result_case = getDBInfo(sql_case)
    if not r_case:
        sql_case_df = sql_case_base + " and `default` = 1"
        r_case_df, result_case_df = getDBInfo(sql_case_df)
        if not r_case_df:
            if debug:
                print 'AT_ERROR : Failed to get <%s> default information from <%s>.' % (caseID, dstTable)
            return False
        else:
            if debug:
                print 'The <%s> default information get from <%s> is :\n <%s>' % (caseID, dstTable, result_case)
            m = r'\d{1}'
            p_id = re.findall(m, str(result_case_df))
            all_point = range(len(result_case_df))
            all_point_l = []
            for i in all_point:
                all_point_l.append(result_case_df[i][0])
            if debug:
                print all_point_l
            return all_point_l
    else:
        if debug:
            print 'The <%s> information get from <%s> is :\n <%s>' % (caseID, dstTable, result_case)
        m = r'\d{1}'
        p_id = re.findall(m, str(result_case))
        all_point = range(len(result_case))
        all_point_l = []
        for i in all_point:
            all_point_l.append(result_case[i][0])
        if debug:
            print all_point_l
        return all_point_l


def getGUICheckMap(cPointID, proID, dstTable='t_am_gui_check_map', debug=False):
    """
    """
    if not cPointID:
        if debug:
            print 'AT_ERROR : Don\'t Know what check point info you want to get from %s.' % dstTable
        return False

    sql_if = "SELECT * FROM `%s` where `check_point_id` = '%s' and `products_id` = '%s' ORDER BY `page_navige` ASC" % (
    dstTable, cPointID, proID)
    r_if, result_if = getDBInfo(sql_if)
    if not r_if:
        if debug:
            print 'AT_ERROR : Failed to get check point <%s> and product ID <%s> info from <%s>.' % (
            cPointID, proID, dstTable)
        return False
    else:
        if debug:
            print result_if
        return result_if


def getLocationMap(pageNavige, dutVer=None, dstTable='t_am_location_map', debug=False):
    """
    """
    sql_lm_base = "SELECT `method`,`value`  from `%s` where `alias` = '%s'" % (dstTable, pageNavige)
    if dutVer:
        sql_lm = sql_lm_base + " and `FW` = '%s'" % dutVer
    else:
        sql_lm = sql_lm_base
    if debug:
        print sql_lm

    r_lm, result_lm = getDBInfo(sql_lm)
    if not r_lm:
        sql_lm_df = sql_lm_base + " and `default` = 1"
        r_lm_df, result_lm_df = getDBInfo(sql_lm_df)
        if not r_lm_df:
            return False
        else:
            return result_lm_df
    else:
        return result_lm


def getAllInfoForGUICheck(case_id, dutType, dutVer, Adebug=False):
    """
    """
    if not case_id or not dutType:
        if Adebug:
            print "AT_ERROR : haven't specify the case id or dut type you want to get."
        return False
    if Adebug:
        print "Current case id is :<%s>" % case_id
        print "Current dutType id is :<%s>" % dutType
        print "Current dutVer is :<%s>" % dutVer
    if dutType:
        sql_dt = "select `id` from t_am_global_products where `name` = '%s'" % dutType
        r_dt, result_dt = getDBInfo(sql_dt)
        if not r_dt:
            if Adebug:
                print 'AT_ERROR : Failed to get <%s> from t_am_global_products.' % dutType
            return False
        else:
            if Adebug:
                print result_dt[0][0]
                #product_id =   result_dt[0][0]
    all_check_point = getGUICheckPoint(case_id, result_dt[0][0], dutVer, debug=Adebug)
    cp_l = len(all_check_point)
    if not cp_l:
        if Adebug:
            print 'AT_ERROR : Failed to get check information from DB,Please check your DB info.'
        return False
    else:
        if Adebug:
            print all_check_point
    map_info = []
    proID = result_dt[0][0]
    for i in all_check_point:
        rc_map = getGUICheckMap(i, proID, debug=Adebug)
        map_info.append(rc_map)
    if Adebug:
        print map_info
    return_list = []

    for j in map_info:
        if j:
            for v in j:
                l_v = len(v)
                if l_v == 11:
                    c_dict = {'page_navige': {'name': '', 'method': '', 'value': ''},
                              'check_type': v[5],
                              'element_location': {'method': '', 'value': ''},
                              'property': v[7],
                              'attribute': v[8],
                              'element_type': v[9],
                              'expected_value': v[10],
                              'page_title': v[4]
                    }
                    if v[3]:
                        result_pn = getLocationMap(v[3], dutVer, debug=Adebug)
                        if result_pn:
                            result_pn = result_pn[0]

                        if result_pn:
                            l_result_pn = len(result_pn)
                            if l_result_pn == 2:
                                pn_dict = {'page_navige': {'name': v[3], 'method': result_pn[0], 'value': result_pn[1]}}
                            else:
                                print 'AT_ERROR : Value got from db of <%s> error:<%s>' % (v[3], result_pn)
                                pn_dict = {'page_navige': {'name': v[3], 'method': result_pn[0], 'value': result_pn[1]}}
                            c_dict.update(pn_dict)

                    if v[6]:
                        result_el = getLocationMap(v[6], dutVer, debug=Adebug)
                        if result_el:
                            result_el = result_el[0]
                        if result_el:
                            l_result_el = len(result_el)
                            if l_result_el == 2:
                                el_dict = {'element_location': {'method': result_el[0], 'value': result_el[1]}}
                            else:
                                print 'AT_ERROR : Value got from db of <%s> error:<%s>' % (v[6], result_el)
                                el_dict = {'element_location': {'method': '', 'value': ''}}
                            c_dict.update(el_dict)
                    return_list.append(c_dict)
                else:
                    print 'AT_ERROR : Check point of <%s> got from <t_am_location_map> error.' % case_id
                    print v
                    return False
    if Adebug:
        pprint(len(return_list))
        pprint(return_list)
    return return_list


def getCheckPoint(case_id, dutType, dutVer, debug=False):
    """
    t_am_location_map 5 ['ID', 'alias', 'method', 'value', 'FW','default']
    t_am_gui_check_point 11 ['ID', 'Case ID', 'Product_ID', 'Check Item', 'Web Page', 'Keyword', 'Content', 'Color', 'Others', 'Applicable to FW', 'Comment']
    t_am_global_products 4 ['id', 'name', 'version', 'comment']
    t_am_gui_check_map 11 ['ID', 'check_point_id', 'products_id', 'page_navige', 'Page_title', 'check_type', 'element_location', 'property', 'attribute', 'element_type', 'expected_value']
    """
    if not case_id or not dutType:
        if debug:
            print "AT_ERROR : haven't specify the case id or dut type you want to get."
        return False
    if debug:
        print "Current case id is :<%s>" % case_id
        print "Current dutType id is :<%s>" % dutType
        print "Current dutVer is :<%s>" % dutVer

    host = os.getenv('U_CUSTOM_AT_DB_HOST', '192.168.20.108')
    port = os.getenv('U_CUSTOM_AT_DB_PORT', '3306')
    user = os.getenv('U_CUSTOM_AT_DB_USERNAME', 'root')
    passwd = os.getenv('U_CUSTOM_AT_DB_PASSWORD', '123qaz')
    dbname = os.getenv('U_CUSTOM_AT_DB_NAME', 'automation_test')  # automation_test

    dbi = DBI(host=host, port=port, user=user, passwd=passwd, dbname=dbname, logger=None)
    t_list = ['t_am_location_map', 't_am_gui_check_point', 't_am_global_products', 't_am_gui_check_map']
    if case_id:
    #        sql_case = """select ID from t_am_gui_check_point join t_am_global_products on `t_am_gui_check_point.Product_ID`=
    #
    #        `t_am_global_products.id` where
    #        """
        sql_case = "select `ID` from t_am_gui_check_point where `Case ID` like '" + case_id + "%'"
        #    sql = "select * from t_am_gui_check_point where `Case ID` like '%s%'"%case_id
        if debug:
            print "Current SQL command is :<%s>" % sql_case
        r_case, result_case = dbi.exec_SQL(sql_case)
        if debug:
            print len(result_case), result_case
    if dutType:
        sql_dt = "select `id` from t_am_global_products where `name` = '%s'" % dutType
        r_dt, result_dt = dbi.exec_SQL(sql_dt)
        if debug:
            print result_dt[0][0]
    m = r'\d{1}'
    p_id = re.findall(m, str(result_dt))[0]
    all_point = len(result_case)
    all_point_l = []
    for i in range(all_point):
        all_point_l.append(result_case[i][0])
    print all_point_l
    for i in all_point_l:
        sql_if = "SELECT * FROM `t_am_gui_check_map` where `check_point_id` = '%s' and `products_id` = '%s'" % (i, p_id)
        print sql_if
        r_if, result_if = dbi.exec_SQL(sql_if)
        if debug:
            print result_if

#        return r,result_set
#    for i in t_list:
#          
# #        sql = " show columns from `%s`"%i
#        sql = "DESC `%s`"%i
#        if not sql: 
#            sql = "select product_name from t_am_dut"
#        print('--'*16)
#        r,result_set = dbi.exec_SQL(sql)
#        print result_set
#        columns_t = len(result_set)
#        columns_l = []
#        for j in range(columns_t):
#            columns_l.append(result_set[j][0])
#        print i,len(columns_l),columns_l      
def optionParser():
    usage = "usage: %prog [options]"

    option = OptionParser(usage=usage)

    option.add_option("-v", "--version", dest="dut_ver", default=os.getenv('U_CUSTOM_CURRENT_FW_VER'),
                      help="The DUT current version you want to check!")
    option.add_option("-i", "--case ID", dest="caseID",
                      help="Specify the current case id you want to get from datebase.")
    option.add_option("-D", "--Debug", dest="is_Debug", action='store_true', default=False,
                      help="whether it is in debug mode.")
    option.add_option("-u", "--datebase username", dest="db_user", default="root",
                      help="Specify download db username.")
    option.add_option("-p", "--datebase password", dest="db_passwd", default="123qaz",
                      help="Specify donwload db loggin password.")
    option.add_option("-t", "--dut type", dest="dut_type", default=os.getenv('U_DUT_TYPE'),
                      help="Specify current dut type.")
    (opts, args) = option.parse_args()
    if not opts.caseID:
        print 'AT_ERROR : Unknow what case info you want to get from the database.'
    return opts, args


def testDBI():
    """
    """
    dbi = DBI(host='192.168.20.108')
    #
    sql = "show columns from `t_am_performance_test_criteria`"
    res = dbi.exec_SQL(sql)
    print(res)
    #
    sql = "show columns from `t_am_performance_test_result`"
    res = dbi.exec_SQL(sql)
    print(res)
    pass


def test():
    """
    """
    #    testInsertResult()
    #     testQueryCriteria()
    opts, args = optionParser()

    #    case_id = "00203506"


    case_id = opts.caseID
    if case_id is None:
        case_id = '00203506'
    dutType = opts.dut_type
    if not dutType:
        print 'Unknow dut type,set it to TV2KH'
        dutType = "TV2KH"
    dutVer = opts.dut_ver
    if not dutVer:
        dutVer = '31.128L.01'
    getAllInfoForGUICheck(case_id, dutType, dutVer, Adebug=True)
    #    r,result_set=getCheckPoint(case_id,dutType,dutVer,debug=True)
    #    return r,result_set
    pass


if __name__ == '__main__':
    """
    """
    test()

    #    for i,j in enumerate(result_set):
    #        print len(j),i,j

    print('== DONE ==')


