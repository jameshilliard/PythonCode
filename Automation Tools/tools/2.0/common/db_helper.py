#!/usr/bin/env python
# coding=utf-8
from optparse import OptionParser
import sys, time, os, re, logging
from pprint import pprint, pformat
from traceback import format_exc
from copy import deepcopy
import csv
import MySQLdb


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


def queryDslamKinds(tb):
    """
    """
    tb = str(tb)
    sql = "SELECT * FROM `t_am_dslam` WHERE TBNAME=" + '"' + tb + '"' + " AND DslamName != 'NA'" + " AND DslamName != ''" + ' group by DslamName'
    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r = dbi.exec_SQL(sql)

    return r


def queryDslamName(tb, mode):
    """
    """
    tb = str(tb)
    mode = str(mode)
    table = os.getenv('TMP_DSLAM_TABLE')
    sql = "SELECT * FROM `" + table + "` WHERE TBNAME=" + '"' + tb + '" AND MODE="' + mode + '"' + ' group by DslamName'
    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r = dbi.exec_SQL(sql)

    return r


def queryTestbedDSLInfo(tb):
    """
    """
    table = os.getenv('TMP_DSLAM_TABLE')
    sql = "SELECT * FROM `" + table + "` WHERE TBNAME=" + '"' + str(tb) + '"' + " AND MODE !='ETH'"
    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r = dbi.exec_SQL(sql)

    return r


def queryTBDSLAM(d={}):
    """
    #     Column     Type     Collation     Attributes     Null     Default     Extra     Action
    1     TBNAME     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    2     DslamName     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
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
    table = os.getenv('TMP_DSLAM_TABLE')
    sql = "SELECT * FROM `" + table + "` "
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
            if field == 'TAG':
                retag = '[0-9]+$'
                rc = re.findall(retag, val)
                if len(rc) > 0:
                    opt = '='
                elif val == '':
                    opt = '='
                    val = ''
                elif val == 'TAG':
                    opt = ' <> '
                    val = ''
                else:
                    opt = ' <> '
                    val = ''

            tmp_arr.append(' ' + field + ' ' + opt + ' \"' + val + '\"')

        sql += ' AND '.join(tmp_arr)

    print('SQL : %s' % sql)

    host = os.getenv("U_CUSTOM_DB_SERVER", "192.168.20.108")
    dbi = DBI(host=host)
    r = dbi.exec_SQL(sql)

    return r


def queryDslamUserInfo(d={}):
    """
    1     testbed     varchar(255)     utf8_general_ci    
    2     DslamName     varchar(255)     utf8_general_ci    
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


def queryProfile(d={}):
    """
    1     DslamName     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    2     Linemode     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    3     Profile     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions  
    """

    sql = "SELECT * FROM `t_am_profile` "

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
    testInsertResult()
    #     testQueryCriteria()
    pass


if __name__ == '__main__':
    """
    """
    test()
    print('== DONE ==')


