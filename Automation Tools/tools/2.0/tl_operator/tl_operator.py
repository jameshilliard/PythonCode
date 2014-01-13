#! /usr/bin/python
# -*- coding: UTF-8 -*-

from optparse import OptionParser
from pprint import pprint
from testlink import TestlinkAPIClient
import dbus
import dbus.decorators
import dbus.mainloop.glib
import gobject
import sys
import sys
import os
import time
import traceback


class TL_OPRTOR():
    """
    """

    profile_loc = '$SQAROOT/testsuites/$G_PFVERSION/common/testlink_id.csv'
    SERVER_URL = None
    DEV_KEY = None
    testplan = ''
    testbuild_id = ''
    testbuild = ''
    priority = None

    myTestLink = None
    testplan_id = None
    case_fetched = False
    cases = []
    tsuites = []
    tst_fetched = False

    def __init__(self, testplan, testbuild=None, proj_name=None, tester='lhu'):

        self.testplan = testplan

        key, id, val = self.read_profile('proj_name')
        proj_name = val
        self.proj_name = proj_name
        #    SERVER_URL

        key, id, val = self.read_profile('SERVER_URL')
        self.SERVER_URL = val

        if tester:
            print 'AT_INFO : tester --> ', tester
            #            if self.map_tester_key.has_key(tester):
            #                self.DEV_KEY = self.map_tester_key[tester]
            if not self.read_profile(tester):
                print 'AT_ERROR : tester %s is not defined in profile %s ' % (tester, self.profile_loc)
                raise Exception('AT_ERROR : tester [%s] is not defined in profile [%s] ' % (
                tester, os.path.expandvars(self.profile_loc)))
            name, id, devkey = self.read_profile(tester)

            self.DEV_KEY = devkey

        try:
            myTestLink = TestlinkAPIClient(self.SERVER_URL, self.DEV_KEY)

            if myTestLink.checkDevKey() != True:
                print "AT_ERROR : Error with the testlink devKey.", self.DEV_KEY
                raise Exception('AT_ERROR : Error with the testlink devKey.' + self.DEV_KEY)

            self.myTestLink = myTestLink

        except Exception, e:
            print 'AT_ERROR : ', str(e)
            raise Exception(e)

        proj_id = myTestLink.getTestProjectByName(proj_name)[0]['id']

        print 'project ID : ', proj_id

        test_plans = myTestLink.getProjectTestPlans(proj_id)

        test_p_ext = False

        for tp in test_plans:
            print('==testplan : ' + tp['name'])
            if tp['name'] == testplan:
                test_p_ext = True
                self.testplan_id = tp['id']
                print 'Found test plan , ID :', tp['id']
                break

        if not test_p_ext:
            print 'AT_ERROR : no such test plan'
            raise Exception('AT_ERROR : no such test plan')

        if not testbuild:
            print 'WARNING : test build not specified , using latest one'

            self.testbuild_id = myTestLink.getLatestBuildForTestPlan(self.testplan_id)['id']
            self.testbuild = myTestLink.getLatestBuildForTestPlan(self.testplan_id)['name']
            print 'AT_INFO : current test build --> %s : %s ' % (self.testbuild_id, self.testbuild)
        else:
            test_builds = myTestLink.getBuildsForTestPlan(self.testplan_id)
            test_b_ext = False

            for tb in test_builds:
                if tb['name'] == testbuild:
                    test_b_ext = True
                    self.testbuild_id = tb['id']
                    print 'Found test build , ID :', tb['id']
                    self.testbuild = testbuild
                    break
            if not test_b_ext:
                print 'AT_ERROR : no such test build'
                raise Exception('AT_ERROR : no such test build')


    def say_hello(self):
        print 'hello'


    def read_profile(self, key):
        """
        type=id or string
        """

        print 'AT_INFO : try to search value for key :', key
        prof_loc = self.profile_loc
        prof = open(os.path.expandvars(prof_loc), 'r')

        lines = prof.readlines()
        prof.close()

        name = ''
        id = ''
        devkey = ''

        def raw_str(str):
            #str = ''
            str = str

            if str.startswith('\"') or str.startswith('\''):
                str = ''.join(str[1:])

            if str.endswith('\"') or str.endswith('\''):
                str = ''.join(str[:-1])

            return str

        if_ext = False
        for line in lines:
            line = line.strip()
            if not line.startswith('#'):
                name, id, devkey = line.split(',')
                #print '%s -> %s -> %s' % (name, id, devkey)
                name = raw_str(name.strip()).strip()
                id = raw_str(id.strip()).strip()
                devkey = raw_str(devkey.strip()).strip()
                if name == key:
                    if_ext = True
                    break
        print 'name : >%s< , id : >%s< , devkey : >%s< ' % (name, id, devkey)

        if if_ext:
            return name, id, devkey
        else:
            return None


    def get_casename_by_uuid(self, uuid):
        """
        get the case name by uuid, such as 00900146

        return case name or None
        00400007_WAN:_VDSL,_Binded_Line,_PPPoE.case
        """

        id = uuid.split('_')[0]
        myTestLink = self.myTestLink

        cases = self.get_testcases()

        if len(cases) > 0:
            for c in cases:
                if c['uuid'].startswith(id):
                    return c['uuid'], c['testcase_id']
        else:
            print 'AT_ERROR : no case found'
            return False

        return False

    def get_testsuite_by_id(self, id):
        """
        """

        myTestLink = self.myTestLink

        #pprint(myTestLink.getTestSuiteByID(id))
        return myTestLink.getTestSuiteByID(id)


    def get_tst_info_by_name(self, name):
        """
        [{'id': '583423',
          'name': '004-Firmware Upgrade (Rev 1.1)',
          'parent_id': '572305'},
         {'id': '594471', 'name': '009-LAN', 'parent_id': '572305'},
         {'id': '608293', 'name': '018-Utilities', 'parent_id': '572305'},
         {'id': '595057', 'name': 'DNC Cache', 'parent_id': '594471'},
         {'id': '583424',
          'name': 'From Current Code to Current Code.X',
          'parent_id': '583423'},
         {'id': '608354', 'name': 'Ping Test', 'parent_id': '608293'},
         {'id': '583425', 'name': 'WAN', 'parent_id': '583424'},
         {'id': '583456', 'name': 'Wireless', 'parent_id': '583424'}]
         
        """

        tst = []

        if self.tst_fetched:
            tst = self.tsuites
        else:
            myTestLink = self.myTestLink
            tst = myTestLink.getTestSuitesForTestPlan(self.testplan_id)

        for t in tst:
            if t['name'] == name:
                return self.get_testsuite_by_id(t['id'])

        print 'no tst named ', name
        return False
        #return myTestLink.getTestSuitesForTestPlan(self.testplan_id)


    def get_tst(self):
        """
        """
        myTestLink = self.myTestLink
        #pprint(myTestLink.getTestSuitesForTestPlan(self.testplan_id))
        return myTestLink.getTestSuitesForTestPlan(self.testplan_id)


    def get_testcase_by_id(self, id):
        """
        """

        myTestLink = self.myTestLink

        cases = myTestLink.getTestCase(id)

        if len(cases) == 0:
            print 'AT_ERROR : no case found'
            return False
        elif len(cases) > 1:
            print 'AT_ERROR : cases duplicated'
            return False
        else:
            return cases[0]


    def filter_cases(self, cases, status=None, tester=None):
        """
            #    testcase_id
            #    user_id
        """

        if tester:
            key, id, val = self.read_profile(tester)
            tester = id

        myTestLink = self.myTestLink

        cases2return = []
        print 'filter cases , status ', status

        def add_status_cases(status, c_id):
            """
            user_id
            """

            lastet_res = myTestLink.getLastExecutionResult(self.testplan_id, c_id)[0]

            if status == 'n':
                if str(lastet_res['id']) == '-1':
                    print '    adding case %s because this case not tested ever' % (c_id)
                    return True
                elif lastet_res.has_key('build_id'):
                    if lastet_res['build_id'] != self.testbuild_id:
                        print '    adding case %s because this case never tested on this build' % (c_id)
                        return True
            elif status == 'f':
                if lastet_res.has_key('status'):
                    if lastet_res['status'] == 'f':
                        print '    adding case %s because this case failed on this build' % (c_id)
                        return True
            elif status == 'p':
                if lastet_res.has_key('status'):
                    if lastet_res['status'] == 'p':
                        print '    adding case %s because this case passed on this build' % (c_id)
                        return True

            print '    case %s did not fit the status' % (c_id)

            return False

        for case in cases:

            is_append = False

            if status:
                if add_status_cases(status, case['testcase_id']):
                    is_append = True
                else:
                    is_append = False
            else:
                is_append = True

            if tester:
                if case['user_id'] == tester:
                    if is_append:
                        is_append = True
                        print '    found case %s for tester %s' % (case['testcase_id'], tester)
                    else:
                        is_append = False
                        #print '    filtered case %s because this case is not for tester %s' % (case['testcase_id'], tester)
                else:
                    is_append = False
                    print '    filtered case %s because this case is not for tester %s' % (case['testcase_id'], tester)
            else:
                if is_append:
                    is_append = True

            if is_append:
                print '    appending case %s' % (case['testcase_id'])
                cases2return.append(case)

        return cases2return


    def get_testcases(self, priority=None, status=None, tester=None):
        """
        from test plan

            '595067': [{
             'active'                 : '1',
             'assigned_build_id'      : '',
             'assigner_id'            : '',
             'exec_id'                : '',
             'exec_on_build'          : '',
             'exec_on_tplan'          : '',
             'exec_status'            : 'n',
             'executed'               : '',
             'execution_notes'        : '',
             'execution_order'        : '0',
             'execution_run_type'     : '',
             'execution_ts'           : '',
             'execution_type'         : '2',
             'external_id'            : '5740',
             'feature_id'             : '77954',
             'importance'             : '3',
             'linked_by'              : '64',
             'linked_ts'              : '2012-12-20 10:02:57',
             'name'                   : '00900164_Restore Default',
             'platform_id'            : '0',
             'platform_name'          : '',
             'priority'               : '6',
             'status'                 : '',
             'summary'                : '<p>Restore Default</p>',
             'tc_id'                  : '595067',
             'tcversion_id'           : '595068',
             'tcversion_number'       : '',
             'tester_id'              : '',
             'testsuite_id'           : '595057',
             'tsuite_name'            : 'DNC Cache',
             'type'                   : '',
             'urgency'                : '2',
             'user_id'                : '',
             'version'                : '1',
             'z'                      : '0'
             }]

         from testlink

             {
               'active'                : '1',
               'author_first_name'     : 'Leon',
               'author_id'             : '4',
               'author_last_name'      : 'Penn',
               'author_login'          : 'lpan',
               'creation_ts'           : '2012-12-06 13:43:05',
               'execution_type'        : '2',
               'id'                    : '595062',
               'importance'            : '3',
               'is_open'               : '1',
               'layout'                : '1',
               'modification_ts'       : '2012-12-20 16:25:15',
               'name'                  : '00900166_DNS Cache is disabled',
               'node_order'            : '0',
               'preconditions'         : '<p>precondition by Howard , for test</p>',
               'status'                : '1',
               'steps'                 : [],
               'summary'               : '<p>Verify that Gateway will send DNS look up for all URLs.</p>',
               'tc_external_id'        : '5738',
               'testcase_id'           : '595061',
               'testsuite_id'          : '595057',
               'updater_first_name'    : 'Lin',
               'updater_id'            : '64',
               'updater_last_name'     : 'Guangwei',
               'updater_login'         : 'ares',
               'version'               : '1'
               }
        """

        if tester:
            key, id, val = self.read_profile(tester)
            tester = id

        case_fetched = self.case_fetched

        if case_fetched:
            return self.cases

        myTestLink = self.myTestLink

        prior = {
            'high': '3',
            'medium': '2',
            'low': '1'
        }

        arr_pr = []

        if not priority:
            #priority = self.priority
            #priority=[]
            arr_pr.append(None)
        else:

            prios = priority.split('.')
            #            if len(prios) > 1:
            #                pprint(prios)
            for pr in prios:
                if prior.has_key(pr):
                    arr_pr.append(prior[pr])
                else:
                    print 'no such priority', pr
                    return False

        print 'prioritys:'
        pprint(arr_pr)
        print '------'

        cases_2b_returned = []

        try:
            if status:
                if tester:
                    cases = myTestLink.getTestCasesForTestPlan(self.testplan_id, 'assignedto=' + tester,
                                                               'executestatus=' + status, 'executiontype=2',
                                                               'buildid=' + self.testbuild_id)
                else:
                    cases = myTestLink.getTestCasesForTestPlan(self.testplan_id, 'executestatus=' + status,
                                                               'executiontype=2', 'buildid=' + self.testbuild_id)
            else:
                if tester:
                    cases = myTestLink.getTestCasesForTestPlan(self.testplan_id, 'assignedto=' + tester,
                                                               'executiontype=2', 'buildid=' + self.testbuild_id)
                else:
                    cases = myTestLink.getTestCasesForTestPlan(self.testplan_id, 'executiontype=2',
                                                               'buildid=' + self.testbuild_id)
        except Exception, e:
            print 'AT_ERROR : ', str(e)
            print 'test_pan : %s , test_build : %s ' % (self.testplan, self.testbuild)
            raise Exception('AT_ERROR : ', str(e))

        if not type(cases) == type({}):
            print 'AT_ERROR : no case found'
            return cases_2b_returned
        else:
            print 'length : ', len(cases)

        for priority in arr_pr:
            print 'adding cases of priority : ', str(priority)

            testCases = []
            all_testCases = []
            id_name = {}
            id_case = {}

            try:


                for c_id in cases.keys():

                    c_n = cases[c_id][0]['name']
                    current_priority = cases[c_id][0]['urgency']

                    if not priority:
                    #                        if not status:
                        print 'adding case %s --> %s ' % (c_id, c_n)
                        print
                        testCases.append(c_n)
                        id_name[c_n.split('_')[0]] = c_id
                        id_case[c_id] = {}
                        for key in cases[c_id][0].keys():
                            #print 'key -- ', key
                            id_case[c_id][key] = cases[c_id][0][key]
                    else:
                        if priority == current_priority:
                            #if not status:
                            print 'adding case %s --> %s ' % (c_id, c_n)
                            print
                            testCases.append(c_n)
                            id_name[c_n.split('_')[0]] = c_id
                            id_case[c_id] = {}
                            for key in cases[c_id][0].keys():
                                #print 'key -- ', key
                                id_case[c_id][key] = cases[c_id][0][key]



            except Exception, e:
                print 'Exception : ', str(e)

            print '\ncount of automated cases of testplan %s (name  %s) : %d' % (
            self.testplan_id, self.testplan, len(testCases))

            testCases.sort(reverse=False)
            #pprint(id_case)

            for tCase in testCases:
                #print tCase
                print('== collecting case(%s) info' % tCase)
                uuid = tCase.split('_')[0]

                tmp_case = {
                    'uuid': uuid,
                    #'case':self.get_testcase_by_id(id_name[uuid]),
                    'result': '',
                    'err': ''
                }
                #pprint(self.get_testcase_by_id(id_name[uuid]))
                #    testcase_id
                cast_testPlan = self.get_testcase_by_id(id_name[uuid])
                for key in cast_testPlan.keys():
                    #print key
                    val = cast_testPlan[key]
                    if type(val) == type('string'):
                        tmp_case[key] = val
                    if key == 'testcase_id':
                        #print 'case if ',cast_testPlan[key]
                        case_testLink = id_case[cast_testPlan[key]]
                        for k in case_testLink.keys():
                            #print key
                            v = case_testLink[k]
                            if type(v) == type('string'):
                                if not tmp_case.has_key(k):
                                #                                if  v == tmp_case[k]:
                                #                                    print 'tmp_case already has key : %s , old val : %s , new val : %s' % (k, tmp_case[k], v)
                                #                                else:
                                #                                    print 'same value'
                                    tmp_case[k] = v

                all_testCases.append(tmp_case)
            cases_2b_returned.extend(all_testCases)

            #pprint(all_testCases)
        #        print('==to filter cases')
        #        cases_2b_returned = self.filter_cases(cases_2b_returned, status=status, tester=tester)
        #        print('==done filter cases')
        self.case_fetched = True
        self.cases = cases_2b_returned

        addFullpath = True
        if addFullpath:
            suites = self.get_tst()
            map_tst_fullpath = {}
            for case in self.cases:
                #fullpath = []
                pid = case.get('testsuite_id')
                fullpath = map_tst_fullpath.get(pid, [])
                if len(fullpath):
                    case['fullpath'] = fullpath
                    continue
                else:
                    pass
                    #
                while 1:
                    found = False
                    for tst in suites:
                        if tst['id'] == pid:
                            pid = tst['parent_id']
                            fullpath.append(tst['name'])
                            found = True
                            break
                    if found:
                        continue
                    else:
                        break
                    #print('=='*16)
                fullpath.reverse()
                map_tst_fullpath[pid] = fullpath
                case['fullpath'] = fullpath

        return cases_2b_returned


    def dbus_handler(self, info):
        """
        key = case , value =
        key = result , value = p
        key = err , value = error message
        key = uuid , value = 00400007

        """

        case_uuid = str(info['uuid'])
        case_res = str(info['result'])
        case_info = str(info['err'])

        if not case_uuid == '':
            self.report_test_result(case_uuid, case_res, case_info, self.testbuild)
        else:
            print 'AT_INFO : skip updating status for nc'


    def report_test_result(self, case_name, result, comment, build=None):
        """
        """
        myTestLink = self.myTestLink

        #c_id = myTestLink.getTestCaseIDByName(case_name)[0]['id']
        #pprint(self.get_casename_by_uuid(case_name))
        c_uuid, c_id = self.get_casename_by_uuid(case_name)

        print 'c_uuid : ', c_uuid

        print 'c_id : ', c_id

        res = {}

        if build:
            res = myTestLink.reportTCResult(c_id, self.testplan_id, build, result, comment)[0]
        else:
            res = myTestLink.reportTCResult(c_id, self.testplan_id, self.testbuild, result, comment)[0]

        pprint(res)

        if not res.has_key('status'):
            print 'AT_ERROR : report test result failed'
            pprint(res)
            return False
        else:
            if not res['status']:
                print 'AT_ERROR : report test result failed'
                return False
            else:
                print 'AT_INFO : update test result successful'
                return True


def main():
    """
    Entry if not imported
    """

    usage = "usage not ready yet \n"

    parser = OptionParser(usage=usage)

    parser.add_option("-t", "--testplan", dest="testplan",
                      help="the name of test plan")
    parser.add_option("-b", "--testbuild", dest="testbuild",
                      help="specified test build of test plan")
    parser.add_option("-p", "--priority", dest="priority",
                      help="specified test priority of test plan")
    parser.add_option("-d", "--dbus", dest="dbus", action='store_true',
                      help="specified test priority of test plan")

    (options, args) = parser.parse_args()

    if not len(args) == 0:
        print args

    testplan = ''
    testbuild = None

    priority = None

    if options.testplan:
        testplan = options.testplan
    else:
        print 'AT_ERROR : must specified the testplan'
        exit(1)

    if options.testbuild:
        testbuild = options.testbuild

    if options.priority:
        priority = options.priority

    TO = TL_OPRTOR(testplan, testbuild=testbuild, tester='howard yin')

    #cases = TO.get_testcases(priority='high', status='not_tested')

    is_dbus = False

    if options.dbus:
        is_dbus = True

    if is_dbus:
        print 'dbus mode'

        MSG_OBJ_PATH = '/com/example/TestService/object/automation'
        MSG_IFACE_URI = 'com.example.TestService.automation'

        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

        bus = dbus.SessionBus()

        bus.add_signal_receiver(TO.dbus_handler, dbus_interface=MSG_IFACE_URI, signal_name="HelloSignal")

        loop = gobject.MainLoop()
        loop.run()

    else:
        #cases = TO.get_testcases()
        cases = TO.get_testcases()

        #pprint(cases)
        #    'fullpath': ['004-Firmware Upgrade (Rev 1.1)',
        #               'From Current Code to Current Code.X',
        #               'WAN'],

        f_paths = []

        for case in cases:
        #pprint(case['fullpath'])
        #            c_fpath = '/'.join(case['fullpath'])
            c_fpath = case['fullpath']
            #print c_fpath
            if not c_fpath in f_paths:
                f_paths.append(c_fpath)

        #pprint(f_paths)

        nodes = []

        for f_path in f_paths:
            #pprint(f_path) 
            for i in range(len(f_path)):
                #pprint(f_path[:i])
                i_node = '/'.join(f_path[:i + 1])

                if not i_node in nodes:
                    nodes.append(i_node)
                    #print '    appending ',i_node

        #pprint(nodes)

        #exit(0)
        #print
        lines = ''

        for i_node in nodes:
            #print
            #print i_node
            lines += i_node + '\n'

            for case in cases:
                c_fpath = '/'.join(case['fullpath'])
                if c_fpath == i_node:
                    print '\t', case['name']
                    lines += '\t' + case['name'] + '\n'

        #print lines
        o_f = '/tmp/haha'
        out_f = open(o_f, 'w')

        out_f.write(lines)

        out_f.close()
        #pprint(TO.get_tst_info_by_name('DNC Cache'))
        #pprint(TO.get_tst_info_by_name('DNC Cache'))

        #TO.get_testsuite_by_id('595057')
        #TO.get_testsuite_by_id('594471')
        #TO.get_tst()
        #TO.report_test_result('00900165', 'p', 'line 1\nline2')
        #TO.report_test_result('00900165', 'p', 'line 1\nline2')


if __name__ == '__main__':
    """
    """

    main()
