#!/usr/bin/python -u
import os, re, select, subprocess, time, rpt_html, sys, logging, syslog
from pprint import pprint
import clicmd


class Scheduled_Mail():
    current_ate_pid = 0
    idle_count = 0
    idle_deadline = 3
    old_ate_pid = 0
    failed_cases = []
    sent_cases = []
    runtime_env = {}
    currentlog_path = ''
    oldlog_path = ''
    sent_logpath = []
    finished_ate = []
    check_ate_interval = 60
    slept_interval = 0
    mail_info_file = '$SQAROOT/testsuites/2.0/common/required.cfg'

    fail_limit = 5
    mail_interval = 86400
    interval_sent = 0

    mail_host = ''
    mail_usr = ''
    mail_pwd = ''
    mail_rcptr = ''
    mail_subject = ''
    log_dir = ''
    real_subject = ''
    mail_require_users = ['yhwang@actiontec.com', 'lhu@actiontec.com', 'hying@actiontec.com', 'lpan@actiontec.com',
                          'pwang@actiontec.com', 'aliu@actiontec.com', 'psu@actiontec.com', 'alin@actiontec.com']

    is_new_ATE = False

    m_failed_case = r'.*(?:FAILED|SKIPPED) *TCASE'
    m_first_case = r'(?:FAILED|PASSED|SKIPPED) *TCASE'
    m_checked_case = r'.*checked.*CASE'
    m_all_done = r'Test Status .*: .*\(ALL DONE\)'
    m_in_testing = r'Test Status .*: .*\(IN TESTING\)'
    m_not_start = r'Test Status .*: .*Not Start'
    m_all_passed = r'Test Status .*: .*\(ALL PASSED\)'
    m_all_skipped = r'Test Status .*: .*\(ALL SKIPPED\)'

    ALL_PASSED_GREEN = "#8CEB94"
    ALL_DONE_YELLOW = "#F9F45D"
    IN_TESTING_BLUE = "#9FB1ED"
    ALL_SKIPPED_RED = "#ECA3A3"
    NOT_START_GRAY = "#BFBFBF"

    m_prod = r'AT_TAG.*\nDUT_PRODUCT_TYPE.*\nDUT_MODEL_NAME.*\nDUT_SN.*\nDUT_FW.*\nDUT_POST_FILES_VER.*\n-*\nUPDATE TIME.*\nTEST BEGIN.*\nDURATION.*'

    m_tst_info = r'Test Suite Name.*\nTest Status.*\nExpected.*\nTotal test time of the test suite .*\nAverage test time of the test suite.*'

    m_sum_result = r'Test suites sum results.*\n\nTotal suites.*\nNot start suites.*\nTested suites.*\nTotal test time of the test suite.*\nAverage test time of the test suite.*'

    ATE_cmd = 'pgrep ATE'

    program_status = ''
    cases_rpt_file = ''
    #grep_ATE_cmd='ps aux |grep -v grep|grep root'+'17606 "

    u_path_tbin = ''
    common_tools = ''
    logs = ''
    runtime_status_file = ''
    sent_fail_case = []
    all_fail_case = []
    start_mail_time = 0
    interval_count = 1
    wait_redmine_time = 60
    ate_error_sum = 1
    fail_mail_count = 1

    _logger = None
    _loghdlr = None
    circle_time = 0

    def __init__(self):
        """
        """

    def safe2Int(self, s):
        """
        """
        rc = None
        try:
            rc = int(s)
        except:
            rc = None
        return rc

    def sec2time(self, sec):
        print 'sec : ' + str(sec) + ' seconds'
        H = 0
        M = 0
        S = 0
        res = ''
        sec = int(sec)
        if sec >= 60:
            M = sec / 60
            S = sec % 60
            if M >= 60:
                H = M / 60
                M = M % 60
            print '%dH %dM %dS' % (H, M, S)
            if H == 0:
                res = '%dM %dS' % (M, S)
                if M == 0:
                    res = '%dS' % S
                if S == 0:
                    res = '%dM' % M
            else:
                res = '%dH %dM %dS' % (H, M, S)
                if S == 0:
                    res = '%dH %dM' % (H, M)
                if S == 0 and M == 0:
                    res = '%dH' % H
        else:
            res = '%dS' % sec
        return res


    def cli_command(self, cmd_list, host, port, username, password, output='/tmp/cli_command.log', cli_type='ssh'):
        """
        True False
        cmdlist=[]
        line_rc = self.cli_command(cmdlist, host, port, username, password)
        """
        print 'in cli_command'

        CLI = clicmd.clicmd(has_color=False)

        res, last_error = CLI.run(cmd_list, cli_type, host, port, username, password, cli_prompt=None, mute=False,
                                  timeout=60)

        m_return_code = r'last_cmd_return_code:(\d)'

        if res:

            for r in res:
                rc = re.findall(m_return_code, r)
                if len(rc) > 0:
                    print 'EACH command result :', rc
                    return_code = rc[0]
                    if str(return_code) != '0':
                        all_rc = False
                        return all_rc

            CLI.saveResp2file(output)
        else:
            print 'AT_ERROR : cli command failed'
            return False

        return True


    def subproc(self, cmdss, timeout=3600):
        """
        subprogress to run command
        0 pass
        else false
        """
        rc = None
        output = ''

        print '    Commands to be executed :', cmdss

        all_rc = 0
        all_output = ''

        cmds = cmdss.split(';')

        for cmd in cmds:
            if not cmd.strip() == '':
                print 'INFO : executing > ', cmd

                try:
                    #
                    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                         close_fds=True, shell=True)
                    while_begin = time.time()
                    while True:

                        to = 600
                        fs = select.select([p.stdout, p.stderr], [], [], to)

                        if p.stdout in fs[0]:
                            tmp = p.stdout.readline()
                            if tmp:
                                output += tmp
                                print 'INFO : ', tmp
                            else:
                                while None == p.poll(): pass
                                break
                        elif p.stderr in fs[0]:
                            tmp = p.stderr.readline()
                            if tmp:
                                output += tmp
                                print 'ERROR : ', tmp
                            else:
                                while None == p.poll(): pass
                                break
                        else:
                            s = os.popen('ps -f| grep -v grep |grep sleep').read()

                            if len(s.strip()):
                                continue

                            p.kill()

                            break
                            # Check the total timeout
                        dur = time.time() - while_begin
                        if dur > timeout:
                            print 'ERROR : The subprocess is timeout due to taking more time than ', str(timeout)
                            break
                    rc = p.poll()
                    # close all fds
                    p.stdin.close()
                    p.stdout.close()
                    p.stderr.close()

                    print 'INFO : return value', str(rc)

                except Exception, e:
                    print 'ERROR :Exception', str(e)
                    rc = 1

            all_rc += rc
            all_output += output

        return all_rc, all_output
        #ctypes.


    def str2raw(self, s):
        """
        """
        s = str(s)
        if s.startswith('"') and s.endswith('"'):
            return s[1:-1]
        if s.startswith("'") and s.endswith("'"):
            return s[1:-1]
        return s


    def load_mail_info(self):

        file = os.path.expandvars(self.mail_info_file)

        print 'load env from :', file

        env_f = open(file, 'r')

        lines = env_f.readlines()

        env_f.close()

        m_kv = r'(\w*)\s*=\s*(.*?)#'

        for line in lines:
            if not line.startswith('#'):
                rc_kv = re.findall(m_kv, line)
                #print rc_kv
                if len(rc_kv) > 0:
                    k, v = rc_kv[0]
                    v = self.str2raw(v.strip())
                    if not v == '':
                        if not self.runtime_env.has_key(k):
                            #v = ''
                            if v.startswith('$'):
                                if self.runtime_env.has_key(v[1:]):
                                    v = self.runtime_env[v[1:]]
                            print 'load_MAIL :adding %s = %s' % (k, v)
                            self.runtime_env[k] = v
                        else:
                            if not self.runtime_env[k] == v:
                                if v.startswith('$'):
                                    if self.runtime_env.has_key(v[1:]):
                                        v = self.runtime_env[v[1:]]
                                print 'load_MAIL :updating %s = %s' % (k, v)

                                self.runtime_env[k] = v

        if self.runtime_env.has_key('U_CUSTOM_TEST_MAIL_HOST'):
            self.mail_host = self.runtime_env['U_CUSTOM_TEST_MAIL_HOST']
        else:
            print 'ERROR : U_CUSTOM_TEST_MAIL_HOST need to be specified .'
            do_send_mail = False

        if self.runtime_env.has_key('U_CUSTOM_TEST_MAIL_USR'):
            self.mail_usr = self.runtime_env['U_CUSTOM_TEST_MAIL_USR']
        else:
            print 'ERROR : U_CUSTOM_TEST_MAIL_USR must be specified .'
            do_send_mail = False

        if self.runtime_env.has_key('U_CUSTOM_TEST_MAIL_PWD'):
            self.mail_pwd = self.runtime_env['U_CUSTOM_TEST_MAIL_PWD']
        else:
            print 'ERROR : U_CUSTOM_TEST_MAIL_PWD must be specified .'
            do_send_mail = False

        if self.runtime_env.has_key('U_CUSTOM_TEST_MAIL_DST'):
            self.mail_rcptr = self.runtime_env['U_CUSTOM_TEST_MAIL_DST']
            for mail_req_user in self.mail_require_users:
                if str(self.mail_rcptr).find(mail_req_user) >= 0:
                    pass
                else:
                    self.mail_rcptr = self.mail_rcptr + '+' + str(mail_req_user)
            print self.mail_rcptr
        else:
            print 'ERROR : U_CUSTOM_TEST_MAIL_DST must be specified .'
            do_send_mail = False

        if self.runtime_env.has_key('U_CUSTOM_TEST_MAIL_SUBJECT'):
            self.mail_subject = self.runtime_env['U_CUSTOM_TEST_MAIL_SUBJECT']

        else:
            print 'ERROR : U_CUSTOM_TEST_MAIL_SUBJECT must be specified .'
            do_send_mail = False

        if self.runtime_env.has_key('U_CUSTOM_TEST_MAIL_FAIL_COUNT'):
            self.fail_limit = int(self.runtime_env['U_CUSTOM_TEST_MAIL_FAIL_COUNT'])

        if self.runtime_env.has_key('U_CUSTOM_TEST_MAIL_MAIL_INTERVAL'):
            self.mail_interval = int(self.runtime_env['U_CUSTOM_TEST_MAIL_MAIL_INTERVAL'])

        print 'mailhost          :', self.mail_host
        print 'mail_usr          :', self.mail_usr
        print 'mail_pwd          :', self.mail_pwd
        print 'mail_rcptr        :', self.mail_rcptr
        print 'mail_title_prefix :', self.mail_subject
        print 'fail_limit        :', self.fail_limit
        print 'mail_interval     :', self.mail_interval


    def load_env_from_file(self, file):
        """
        """

        env_f = open(file, 'r')

        lines = env_f.readlines()

        env_f.close()

        m_kv = r'(.*)=(.*)'

        for line in lines:
            #line=''
            if not line.startswith('#'):
                line = ' '.join(line.strip().split()[1:])
                #print line
                rc_kv = re.findall(m_kv, line)
                if len(rc_kv) > 0:
                    k, v = rc_kv[0]
                    #
                    v = self.str2raw(v.strip())
                    v = v.split('#')[0]
                    v = self.str2raw(v.strip())
                    if not v == '':
                        if not self.runtime_env.has_key(k):
                            if v.startswith('$'):
                                if self.runtime_env.has_key(v[1:]):
                                    v = self.runtime_env[v[1:]]
                            print 'load_ENV :adding %s = %s' % (k, v)
                            self.runtime_env[k] = v
                        else:
                            if not self.runtime_env[k] == v:
                                if v.startswith('$'):
                                    if self.runtime_env.has_key(v[1:]):
                                        v = self.runtime_env[v[1:]]
                                print 'load_ENV :updating %s = %s' % (k, v)
                                self.runtime_env[k] = v


                            #

    def create_content(self):
        """
        """
        print 'self.currentlog_path : ' + self.currentlog_path
        currentlog_path = os.path.realpath(os.path.expandvars(self.currentlog_path))
        print 'currentlog_path : ' + currentlog_path
        ate_report = currentlog_path + '/ATE_report.html'
        print 'ate_report : ' + ate_report
        #ATE_reporter = rpt_html.HTMLPageCreator()
        print '*******************************************************'
        rc, ate_report = rpt_html.createRptHtmlFile(currentlog_path, ate_report)
        print rc

        print '------------------------------------------------'
        print rc
        print '------------------------------------------------'
        print ate_report

        if rc:
            return ate_report
        else:
            return 'Create report failed'

    def info(self, msg):
        """
        log info
        """
        msg = str(msg)
        #print '==',str(msg)
        #        if self._cfg['SYSLOG'] :
        #            syslog.syslog(str(msg) )

        if self._logger:
            self._logger.info('[' + self.program_status + '][' + str(self.circle_time) + '] ' + msg)
            #print '--> log : ',msg


    def error(self, msg):
        """
        log error
        """
        msg = str(msg)
        #print '==',str(msg)
        #        if self._cfg['SYSLOG'] :
        #            syslog.syslog(syslog.LOG_ERR, str(msg))
        if self._logger:
            self._logger.error('[' + self.program_status + '][' + str(self.circle_time) + '] ' + msg)

    def send_fail_mail(self):

        """
        """
        print 'Entry function send_failed_log'
        self.info('====Entry function send_fail_mail')

        while True:
            if not self.circle_time == 0:
                self.info('====Start the next cycle in send_fail_mail!')
            self.circle_time = self.circle_time + 1

            rcc, output_c = self.subproc(self.ATE_cmd)
            self.info('rcc : ' + str(rcc))
            if rcc == 0:
                try:
                    ate_pid = int(output_c.strip())
                    self.info('ate_pid         : ' + str(ate_pid))
                    self.info('current_ate_pid : ' + str(self.current_ate_pid))
                except Exception, e:
                    print 'ate_pid         : ' + str(ate_pid)
                    print e
                    self.error(str(e) + ' (' + str(self.ate_error_sum) + ')')
                    if self.ate_error_sum > 5:
                        self.error('Leave function send_fail_mail!')
                        print sys.argv[0] + ' will close automaticly!'
                        self.error(sys.argv[0] + ' will close automaticly!')
                        exit(1)
                    self.ate_error_sum = self.ate_error_sum + 1
                    print 'Waiting ' + str(self.check_ate_interval) + ' seconds to check again......'
                    self.error('Waiting ' + str(self.check_ate_interval) + ' seconds to check again......')
                    time.sleep(self.check_ate_interval)
                    self.send_fail_mail()

            if rcc == 0:
                if ate_pid == self.current_ate_pid:
                    #send fail mail
                    self.info('ate_pid = current_ate_pid')
                    self.info('Check fail case and send fail email!')
                    if os.path.exists(self.cases_rpt_file):
                        fd = open(self.cases_rpt_file, 'r')
                        lines = fd.readlines()
                        fd.close()
                        checked_cases = []
                        intesting_case = ''
                        for line in lines:
                            line = line.strip()
                            print line
                            rc = re.findall(self.m_failed_case, line)
                            if len(rc) > 0:
                                failnum = rc[0].split(' ')[0]
                                if failnum not in self.all_fail_case:
                                    self.all_fail_case.append(failnum)

                            rcd = re.findall(self.m_checked_case, line)
                            if len(rcd) > 0:
                                checked_cases.append(str(rcd[0].split(' ')[0]))

                        sorted(checked_cases)
                        intesting_case = checked_cases[0]

                        print 'all_fail_case : ' + str(self.all_fail_case)
                        print 'sent_fail_case : ' + str(self.sent_fail_case)
                        print 'intesting_case : ' + str(intesting_case)

                        self.info('all_fail_case : ' + str(self.all_fail_case))
                        self.info('sent_fail_case : ' + str(self.sent_fail_case))
                        self.info('intesting_case : ' + str(intesting_case))
                        print '--------------------------------------------------'

                        new_fail_case = []
                        #time.sleep(self.check_ate_interval)
                        cur_time = time.time()
                        intervals_time = cur_time - self.start_mail_time
                        aaaa = self.mail_interval * self.interval_count
                        print 'intervals_time : ' + str(intervals_time)
                        self.info('intervals_time : ' + str(intervals_time))
                        print 'mail_interval : ' + str(self.mail_interval)
                        self.info('mail_interval : ' + str(self.mail_interval))
                        print 'self.mail_interval * self.interval_count = ' + str(self.mail_interval) + ' * ' + str(
                            self.interval_count) + ' = ' + str(aaaa)
                        self.info('self.mail_interval * self.interval_count = ' + str(self.mail_interval) + ' * ' + str(
                            self.interval_count) + ' = ' + str(aaaa))
                        if intervals_time > aaaa:
                            print 'Send Interval mail!'
                            self.info('Send Interval mail!')
                            INTERVAL_STR = str(self.interval_count) + '/(' + str(
                                self.sec2time(self.mail_interval)) + ') '
                            self.interval_count = self.interval_count + 1
                            runtime_status_file_html = self.create_content()
                            mail_str = '"python ' + self.common_tools + '/at_mail_sendor.py -c ' + runtime_status_file_html
                            mail_str += ' -s \\\"' + INTERVAL_STR + self.mail_subject + '\\\" -H '
                            mail_str += self.mail_host
                            mail_str += ' -u ' + self.mail_usr + ' -p ' + self.mail_pwd
                            mail_str += ' -r ' + self.mail_rcptr + '" '

                            mail_cmd = self.u_path_tbin + '/clicmd -o /tmp/haha -s /tmp -d ' + self.runtime_env[
                                'G_HOST_IP1'] + ' -u ' + self.runtime_env['G_HOST_USR1'] + ' -p ' + self.runtime_env[
                                           'G_HOST_PWD1'] + ' -v ' + mail_str

                            print mail_cmd
                            self.info(mail_cmd)
                            i = 0
                            while True:
                                return_code, send_mail_output = self.subproc(mail_cmd)
                                print 'return code : ' + str(return_code)
                                self.info('return code : ' + str(return_code))
                                if return_code == 0:
                                    print 'Send Interval mail OK!'
                                    self.info('Send Interval mail OK!')
                                    break
                                else:
                                    i = i + 1
                                    if i >= 3:
                                        print 'Interval mail send Fail!'
                                        self.error('Interval mail send Fail!')
                                        break
                                    print 'Interval mail send fail,waitting ' + str(
                                        self.check_ate_interval) + ' seconds to check again!'
                                    self.error('Interval mail send fail,waitting ' + str(
                                        self.check_ate_interval) + ' seconds to check again!')
                                    time.sleep(self.check_ate_interval)
                            print 'Waiting ' + str(self.check_ate_interval) + ' seconds to check again......'
                            self.info('Waiting ' + str(self.check_ate_interval) + ' seconds to check again......')
                            time.sleep(self.check_ate_interval)

                        elif len(self.all_fail_case) == 0:
                            print 'No fail case now,No need send mail!'
                            self.info('No fail case now,No need send mail!')
                            print 'Waiting ' + str(self.check_ate_interval) + ' seconds to check again......'
                            self.info('Waiting ' + str(self.check_ate_interval) + ' seconds to check again......')
                            time.sleep(self.check_ate_interval)

                        elif len(self.all_fail_case) > len(self.sent_fail_case):
                            #may be need send mail
                            for i in self.all_fail_case:
                                if i not in self.sent_fail_case:
                                    new_fail_case.append(i)
                            print 'new fail case : ' + str(new_fail_case)
                            new_fail_case.append(str(intesting_case))
                            tmp_cases = new_fail_case
                            i = j = 1
                            while j < len(tmp_cases):
                                if self.safe2Int(tmp_cases[j]) - self.safe2Int(tmp_cases[j - 1]) == 1:
                                    i = i + 1
                                j = j + 1
                            if i == j:
                                print 'new fail case + intesting case is seqence,No need send fail!'
                                self.info('new fail case + intesting case is seqence,No need send fail!')
                                print 'Waiting ' + str(self.check_ate_interval) + ' seconds to check again......'
                                self.info('Waiting ' + str(self.check_ate_interval) + ' seconds to check again......')
                                time.sleep(self.check_ate_interval)
                            else:
                                print 'new fail case + intesting case is NOT seqence,Need send fail!'
                                self.info('new fail case + intesting case is NOT seqence,Need send fail!')
                                #send fail mail
                                runtime_status_file_html = self.create_content()
                                mail_str = '"python ' + self.common_tools + '/at_mail_sendor.py -c ' + runtime_status_file_html
                                mail_str += ' -s \\\"FAIL:' + str(
                                    self.fail_mail_count) + ' ' + self.mail_subject + '\\\" -H '
                                mail_str += self.mail_host
                                mail_str += ' -u ' + self.mail_usr + ' -p ' + self.mail_pwd
                                mail_str += ' -r ' + self.mail_rcptr + '" '

                                mail_cmd = self.u_path_tbin + '/clicmd -o /tmp/haha -s /tmp -d ' + self.runtime_env[
                                    'G_HOST_IP1'] + ' -u ' + self.runtime_env['G_HOST_USR1'] + ' -p ' +
                                           self.runtime_env['G_HOST_PWD1'] + ' -v ' + mail_str
                                self.info(mail_cmd)
                                print mail_cmd
                                i = 0
                                while True:
                                    return_code, send_mail_output = self.subproc(mail_cmd)
                                    print 'return code : ' + str(return_code)
                                    self.info('return code : ' + str(return_code))
                                    if return_code == 0:
                                        print 'Send Fail mail OK!'
                                        self.info('Send Fail mail OK!')
                                        break
                                    else:
                                        i = i + 1
                                        if i >= 3:
                                            print 'Fail mail send Fail!'
                                            self.error('Fail mail send Fail!')
                                            break
                                        print 'Fail mail send fail,waitting ' + str(
                                            self.check_ate_interval) + ' seconds to check again!'
                                        self.error('Fail mail send fail,waitting ' + str(
                                            self.check_ate_interval) + ' seconds to check again!')
                                        time.sleep(self.check_ate_interval)

                                self.fail_mail_count = self.fail_mail_count + 1
                                self.sent_fail_case = []
                                for i in self.all_fail_case:
                                    self.sent_fail_case.append(i)
                                print 'all_fail_case : ' + str(self.all_fail_case)
                                print 'sent_fail_case : ' + str(self.sent_fail_case)
                                print 'Waiting ' + str(self.check_ate_interval) + ' seconds to check again......'
                                self.info('all_fail_case : ' + str(self.all_fail_case))
                                self.info('sent_fail_case : ' + str(self.sent_fail_case))
                                self.info('Waiting ' + str(self.check_ate_interval) + ' seconds to check again......')
                                time.sleep(self.check_ate_interval)

                        else:
                            print 'No create new fail case,No need send mail!'
                            self.info('No create new fail case,No need send mail!')
                            print 'Waiting ' + str(self.check_ate_interval) + ' seconds to check again......'
                            self.info('Waiting ' + str(self.check_ate_interval) + ' seconds to check again......')
                            time.sleep(self.check_ate_interval)

                else:
                    #send finish or abort mail
                    #check finish or abort
                    self.info('ate_pid != current_ate_pid')
                    self.info('Check send Finish or Abort mail')
                    abort_flags = 0
                    if os.path.exists(self.cases_rpt_file):
                        fd = open(self.cases_rpt_file, 'r')
                        lines = fd.readlines()
                        fd.close()
                        for line in lines:
                            line = line.strip()
                            print line
                            rcddd = re.findall(self.m_checked_case, line)
                            if len(rcddd) > 0:
                                abort_flags = 1
                                break
                    if abort_flags == 1:
                        print 'ATE program ' + str(self.current_ate_pid) + ' closed,current ATE PID is ' + str(ate_pid)
                        self.info(
                            'ATE program ' + str(self.current_ate_pid) + ' closed,current ATE PID is ' + str(ate_pid))
                        print 'but there are still some cases not run about ' + str(
                            self.current_ate_pid) + ',we will send Abort mail after ' + str(
                            self.wait_redmine_time) + ' seconds!'
                        self.info('but there are still some cases not run about ' + str(
                            self.current_ate_pid) + ',we will send Abort mail after ' + str(
                            self.wait_redmine_time) + ' seconds!')
                        time.sleep(self.wait_redmine_time)
                        runtime_status_file_html = self.create_content()
                        mail_str = '"python ' + self.common_tools + '/at_mail_sendor.py -c ' + runtime_status_file_html
                        mail_str += ' -s \\\"ABORT:' + self.mail_subject + '\\\" -H '
                        mail_str += self.mail_host
                        mail_str += ' -u ' + self.mail_usr + ' -p ' + self.mail_pwd
                        mail_str += ' -r ' + self.mail_rcptr + '" '

                        mail_cmd = self.u_path_tbin + '/clicmd -o /tmp/haha -s /tmp -d ' + self.runtime_env[
                            'G_HOST_IP1'] + ' -u ' + self.runtime_env['G_HOST_USR1'] + ' -p ' + self.runtime_env[
                                       'G_HOST_PWD1'] + ' -v ' + mail_str
                        self.info(mail_cmd)
                        print mail_cmd
                        i = 0
                        while True:
                            return_code, send_mail_output = self.subproc(mail_cmd)
                            print 'return code : ' + str(return_code)
                            self.info('return code : ' + str(return_code))
                            if return_code == 0:
                                print 'Send Abort mail OK!'
                                self.info('Send Abort mail OK!')
                                self.info('Leave function send_fail_mail!')
                                print sys.argv[0] + ' will close automaticly!'
                                self.info(sys.argv[0] + ' will close automaticly!')
                                exit(0)
                            else:
                                i = i + 1
                                if i >= 3:
                                    print 'Abort mail send Fail!'
                                    self.error('Abort mail send Fail!')
                                    exit(1)
                                print 'Abort mail send fail,waitting ' + str(
                                    self.check_ate_interval) + ' seconds to check again!'
                                self.error('Abort mail send fail,waitting ' + str(
                                    self.check_ate_interval) + ' seconds to check again!')
                                time.sleep(self.check_ate_interval)
                    else:
                        print 'ATE program ' + str(self.current_ate_pid) + ' closed,current ATE PID is ' + str(
                            ate_pid) + ',we begin to send finish mail about ' + str(
                            self.current_ate_pid) + ' after ' + str(self.wait_redmine_time) + ' seconds!'
                        self.info('ATE program ' + str(self.current_ate_pid) + ' closed,current ATE PID is ' + str(
                            ate_pid) + ',we begin to send finish mail about ' + str(
                            self.current_ate_pid) + ' after ' + str(self.wait_redmine_time) + ' seconds!')
                        time.sleep(self.wait_redmine_time)
                        runtime_status_file_html = self.create_content()
                        mail_str = '"python ' + self.common_tools + '/at_mail_sendor.py -c ' + runtime_status_file_html
                        mail_str += ' -s \\\"FINISH:' + self.mail_subject + '\\\" -H '
                        mail_str += self.mail_host
                        mail_str += ' -u ' + self.mail_usr + ' -p ' + self.mail_pwd
                        mail_str += ' -r ' + self.mail_rcptr + '" '

                        mail_cmd = self.u_path_tbin + '/clicmd -o /tmp/haha -s /tmp -d ' + self.runtime_env[
                            'G_HOST_IP1'] + ' -u ' + self.runtime_env['G_HOST_USR1'] + ' -p ' + self.runtime_env[
                                       'G_HOST_PWD1'] + ' -v ' + mail_str
                        self.info(mail_cmd)
                        print mail_cmd
                        i = 0
                        while True:
                            return_code, send_mail_output = self.subproc(mail_cmd)
                            print 'return code : ' + str(return_code)
                            self.info('return code : ' + str(return_code))
                            if return_code == 0:
                                print 'Send Finish mail OK!'
                                self.info('Send Finish mail OK!')
                                self.info('Leave function send_fail_mail!')
                                print sys.argv[0] + ' will close automaticly!'
                                self.info(sys.argv[0] + ' will close automaticly!')
                                exit(0)
                            else:
                                i = i + 1
                                if i >= 3:
                                    print 'Finish mail send Fail!'
                                    self.error('Finish mail send Fail!')
                                    exit(1)
                                print 'Finish mail send fail,waitting ' + str(
                                    self.check_ate_interval) + ' seconds to check again!'
                                self.error('Finish mail send fail,waitting ' + str(
                                    self.check_ate_interval) + ' seconds to check again!')
                                time.sleep(self.check_ate_interval)
            else:
            #send finish or abort mail
                #check finish or abort
                self.info('Check send Finish or Abort mail')
                abort_flag = 0
                if os.path.exists(self.cases_rpt_file):
                    fd = open(self.cases_rpt_file, 'r')
                    lines = fd.readlines()
                    fd.close()
                    for line in lines:
                        line = line.strip()
                        print line
                        rcdd = re.findall(self.m_checked_case, line)
                        if len(rcdd) > 0:
                            abort_flag = 1
                            break
                if abort_flag == 1:
                    print 'ATE program ' + str(self.current_ate_pid) + ' closed,NOT exist ATE program now!'
                    self.info('ATE program ' + str(self.current_ate_pid) + ' closed,NOT exist ATE program now!')
                    print 'but there are still some cases not run about ' + str(
                        self.current_ate_pid) + ',we will send Abort mail after ' + str(
                        self.wait_redmine_time) + ' seconds!'
                    self.info('but there are still some cases not run about ' + str(
                        self.current_ate_pid) + ',we will send Abort mail after ' + str(
                        self.wait_redmine_time) + ' seconds!')
                    time.sleep(self.wait_redmine_time)
                    runtime_status_file_html = self.create_content()
                    mail_str = '"python ' + self.common_tools + '/at_mail_sendor.py -c ' + runtime_status_file_html
                    mail_str += ' -s \\\"ABORT:' + self.mail_subject + '\\\" -H '
                    mail_str += self.mail_host
                    mail_str += ' -u ' + self.mail_usr + ' -p ' + self.mail_pwd
                    mail_str += ' -r ' + self.mail_rcptr + '" '

                    mail_cmd = self.u_path_tbin + '/clicmd -o /tmp/haha -s /tmp -d ' + self.runtime_env[
                        'G_HOST_IP1'] + ' -u ' + self.runtime_env['G_HOST_USR1'] + ' -p ' + self.runtime_env[
                                   'G_HOST_PWD1'] + ' -v ' + mail_str
                    self.info(mail_cmd)
                    print mail_cmd
                    i = 0
                    while True:
                        return_code, send_mail_output = self.subproc(mail_cmd)
                        print 'return code : ' + str(return_code)
                        self.info('return code : ' + str(return_code))
                        if return_code == 0:
                            print 'Send Abort mail OK OK!'
                            self.info('Send Abort mail OK OK!')
                            self.info('Leave function send_fail_mail!')
                            print sys.argv[0] + ' will close automaticly!'
                            self.info(sys.argv[0] + ' will close automaticly!')
                            exit(0)
                        else:
                            i = i + 1
                            if i >= 3:
                                print 'Abort mail send Fail!'
                                self.error('Abort mail send Fail!')
                                exit(1)
                            print 'Abort mail send fail,waitting ' + str(
                                self.check_ate_interval) + ' seconds to check again!'
                            self.error('Abort mail send fail,waitting ' + str(
                                self.check_ate_interval) + ' seconds to check again!')
                            time.sleep(self.check_ate_interval)

                else:
                    print 'ATE program ' + str(
                        self.current_ate_pid) + ' closed,NOT exist ATE program now,we begin to send finish mail about ' + str(
                        self.current_ate_pid) + ' after ' + str(self.wait_redmine_time) + ' seconds!'
                    self.info('ATE program ' + str(
                        self.current_ate_pid) + ' closed,NOT exist ATE program now,we begin to send finish mail about ' + str(
                        self.current_ate_pid) + ' after ' + str(self.wait_redmine_time) + ' seconds!')
                    time.sleep(self.wait_redmine_time)
                    runtime_status_file_html = self.create_content()
                    mail_str = '"python ' + self.common_tools + '/at_mail_sendor.py -c ' + runtime_status_file_html
                    mail_str += ' -s \\\"FINISH:' + self.mail_subject + '\\\" -H '
                    mail_str += self.mail_host
                    mail_str += ' -u ' + self.mail_usr + ' -p ' + self.mail_pwd
                    mail_str += ' -r ' + self.mail_rcptr + '" '

                    mail_cmd = self.u_path_tbin + '/clicmd -o /tmp/haha -s /tmp -d ' + self.runtime_env[
                        'G_HOST_IP1'] + ' -u ' + self.runtime_env['G_HOST_USR1'] + ' -p ' + self.runtime_env[
                                   'G_HOST_PWD1'] + ' -v ' + mail_str
                    self.info(mail_cmd)
                    print mail_cmd
                    i = 0
                    while True:
                        return_code, send_mail_output = self.subproc(mail_cmd)
                        print 'return code : ' + str(return_code)
                        self.info('return code : ' + str(return_code))
                        if return_code == 0:
                            print 'Send Finish mail OK OK!'
                            self.info('Send Finish mail OK OK!')
                            self.info('Leave function send_fail_mail!')
                            print sys.argv[0] + ' will close automaticly!'
                            self.info(sys.argv[0] + ' will close automaticly!')
                            exit(0)
                        else:
                            i = i + 1
                            if i >= 3:
                                print 'Finish mail send Fail!'
                                self.error('Finish mail send Fail!')
                                exit(1)
                            print 'Finish mail send fail,waitting ' + str(
                                self.check_ate_interval) + ' seconds to check again!'
                            self.error('Finish mail send fail,waitting ' + str(
                                self.check_ate_interval) + ' seconds to check again!')
                            time.sleep(self.check_ate_interval)


    def send_start_mail(self, interval=False):
        """
        """
        print 'send start mail'
        print 'entry function send_start_mail()'
        cmd_lsof = 'lsof -p ' + str(self.current_ate_pid) + ' |grep raw_ATE |awk \'{print $NF}\''
        while True:
            self.circle_time = self.circle_time + 1

            rcc, output_c = self.subproc(self.ATE_cmd)
            if rcc == 0:
                try:
                    ate_pid = int(output_c.strip())
                    self.ate_error_sum = 0
                except Exception, e:
                    print 'ate_pid : ' + str(ate_pid)
                    print e
                    if self.ate_error_sum > 5:
                        print 'Leave function send_start_mail!'
                        print sys.argv[0] + ' will close automaticly!'
                        exit(1)
                    self.ate_error_sum = self.ate_error_sum + 1
                    print 'Waiting ' + str(self.check_ate_interval) + ' seconds to check again......'
                    time.sleep(self.check_ate_interval)
                    self.send_start_mail()

            if rcc == 0:
                print 'ATE exist,PID : ' + str(ate_pid)
                if ate_pid == self.current_ate_pid:
                    rc_lsof, output_lsof = self.subproc(cmd_lsof)

                    output_lsof = output_lsof.strip()
                    output_lsof = output_lsof.split('\n')[-1]
                    print 'output_lsof : ' + output_lsof
                    if not output_lsof == '':
                        print 'output_lsof :>' + output_lsof + '<'
                        if os.path.exists(output_lsof):
                            self.log_dir = os.path.dirname(os.path.realpath(output_lsof))
                            self.currentlog_path = os.path.realpath(os.path.expandvars(self.log_dir))
                            if not self._loghdlr:
                                logfile = os.path.join(self.currentlog_path, 'scheduled_mail.log')
                                self._loghdlr = logging.FileHandler(logfile)
                                #self._loghdlr.setFormatter(logging.Formatter('[pid=%(process)d][%(asctime)-15s][(levelname)s]%(message)s'))
                                FORMAT = '[%(asctime)-15s %(levelname)-s] %(message)s'
                                self._loghdlr.setFormatter(logging.Formatter(FORMAT))
                                self._logger.addHandler(self._loghdlr)
                                self._logger.setLevel(11)

                            runtime_env_file = self.currentlog_path + '/' + 'runtime_env'
                            if os.path.exists(runtime_env_file):
                                self.info('====Entry function send_start_mail')
                                self.info('currentlog_path : ' + self.currentlog_path)
                                self.info('logfile : ' + logfile)
                                self.info('ate_pid         : ' + str(ate_pid))
                                self.info('current_ate_pid : ' + str(self.current_ate_pid))
                                print 'runtime_env_file : ' + runtime_env_file + ' Existed!'
                                self.info('runtime_env_file : ' + runtime_env_file)
                                self.load_mail_info()
                                self.load_env_from_file(runtime_env_file)
                                self.cases_rpt_file = self.currentlog_path + '/' + 'cases.rpt'
                                self.info('cases_rpt_file : ' + self.cases_rpt_file)
                                if os.path.exists(self.cases_rpt_file):
                                    print 'cases.rpt : ' + self.cases_rpt_file + ' Existed!'
                                    fd = open(self.cases_rpt_file, 'r')
                                    lines = fd.readlines()
                                    fd.close()
                                    first_tcase_completed = 0
                                    for line in lines:
                                        line = line.strip()
                                        print line
                                        rc = re.findall(self.m_first_case, line)
                                        print rc
                                        print len(rc)
                                        print '----------------------------------------'
                                        if len(rc) > 0:
                                            first_tcase_completed = 1
                                            break
                                    print 'first_tcase_completed : ' + str(first_tcase_completed)
                                    if first_tcase_completed == 1:
                                        #send start mail
                                        print 'first tcase has been completed!'
                                        self.info('first tcase has been completed !')
                                        if self.runtime_env.has_key('G_TESTER'):
                                            self.mail_subject = self.runtime_env['G_TESTER'] + '_'
                                            print 'mail_subject', self.mail_subject
                                        if self.runtime_env.has_key('U_DUT_TYPE'):
                                            self.mail_subject += self.runtime_env['U_DUT_TYPE'] + '_'
                                            print 'mail_subject', self.mail_subject

                                        if self.runtime_env.has_key('U_DUT_SW_VERSION'):
                                            self.mail_subject += self.runtime_env['U_DUT_SW_VERSION']
                                            print 'mail_subject', self.mail_subject
                                            self.info('mail_subject : ' + self.mail_subject)

                                        self.mail_usr = self.runtime_env['G_TBNAME'] + '@actiontec.com'
                                        self.u_path_tbin = self.runtime_env['U_PATH_TBIN']
                                        self.common_tools = self.runtime_env['U_PATH_TOOLS'] + '/common'
                                        #self.logs = os.listdir(self.currentlog_path)                                            
                                        #self.runtime_status_file = self.currentlog_path + '/' + 'runtime_status_' + self.runtime_env['U_DUT_TYPE']
                                        print 'mail_usr : ' + self.mail_usr
                                        self.info('mail_usr : ' + self.mail_usr)
                                        runtime_status_file_html = self.create_content()

                                        mail_str = '"python ' + self.common_tools + '/at_mail_sendor.py -c ' + runtime_status_file_html
                                        mail_str += ' -s \\\"START:' + self.mail_subject + '\\\" -H '
                                        mail_str += self.mail_host
                                        mail_str += ' -u ' + self.mail_usr + ' -p ' + self.mail_pwd
                                        mail_str += ' -r ' + self.mail_rcptr + '" '

                                        print 'mail_str : ' + str(mail_str)
                                        self.info('mail_str : ' + str(mail_str))
                                        mail_cmd = self.u_path_tbin + '/clicmd -o /tmp/haha -s /tmp -d ' +
                                                   self.runtime_env['G_HOST_IP1'] + ' -u ' + self.runtime_env[
                                                       'G_HOST_USR1'] + ' -p ' + self.runtime_env[
                                                       'G_HOST_PWD1'] + ' -v ' + mail_str

                                        print 'mail_cmd : ' + str(mail_cmd)
                                        self.info('mail_cmd : ' + str(mail_cmd))
                                        i = 0
                                        while True:
                                            return_code, send_mail_output = self.subproc(mail_cmd)
                                            print 'return code : ' + str(return_code)
                                            self.info('return code : ' + str(return_code))
                                            if return_code == 0:
                                                print 'Send Start mail OK!'
                                                self.info('Send Start mail OK!')
                                                self.program_status = 'INTESTING'
                                                self.info('====Leave function send_start_mail')
                                                self.circle_time = 0
                                                self.start_mail_time = time.time()
                                                return
                                            else:
                                                i = i + 1
                                                if i >= 3:
                                                    print 'START mail send Fail!'
                                                    self.error('START mail send Fail!')
                                                    self.circle_time = 0
                                                    self.start_mail_time = time.time()
                                                    return
                                                print 'START mail send fail,waitting ' + str(
                                                    self.check_ate_interval) + ' seconds to check again!'
                                                self.error('START mail send fail,waitting ' + str(
                                                    self.check_ate_interval) + ' seconds to check again!')
                                                time.sleep(self.check_ate_interval)

                                    else:
                                        print 'first tcase has not been completed!'
                                        self.error('first tcase has not been completed!')
                                        print 'Wait ' + str(self.check_ate_interval) + ' to check it again!'
                                        self.error('Wait ' + str(self.check_ate_interval) + ' to check again!')
                                        time.sleep(self.check_ate_interval)
                                else:
                                    print 'Check cases_rpt_file : ' + self.cases_rpt_file
                                    self.error('cases_rpt_file : ' + self.cases_rpt_file + ' not exist!')
                                    print 'Wait ' + str(self.check_ate_interval) + ' to check it again!'
                                    self.error('Wait ' + str(self.check_ate_interval) + ' to check again!')
                                    time.sleep(self.check_ate_interval)
                            else:
                                print 'runtime_env_file : ' + runtime_env_file + ' not exist!'
                                self.error('runtime_env_file : ' + runtime_env_file + ' not exist!')
                                print 'Wait ' + str(self.check_ate_interval) + ' to check it again!'
                                self.error('Wait ' + str(self.check_ate_interval) + ' to check again!')
                                time.sleep(self.check_ate_interval)
                        else:
                            print 'output_lsof : ' + output_lsof + ' not exist!'
                            self.error('output_lsof : ' + output_lsof + ' not exist!')
                            print 'log_dir:still preparing ATE running on pid :', ate_pid
                            time.sleep(self.check_ate_interval)
                    else:
                        print 'output_lsof is NULL'
                        self.error('output_lsof is NULL')
                        print 'log_dir:still preparing ATE running on pid :', ate_pid
                        time.sleep(self.check_ate_interval)
                else:
                    self.error(
                        'ATE program ' + str(self.current_ate_pid) + ' closed,current ATE PID is ' + str(ate_pid))
                    print 'ATE program ' + str(self.current_ate_pid) + ' closed,current ATE PID is ' + str(ate_pid)
                    self.error('Leave function send_start_mail!')
                    print sys.argv[0] + ' will close automaticly!'
                    self.error(sys.argv[0] + ' will close automaticly!')
                    exit(1)
            else:
                print 'ATE program ' + str(self.current_ate_pid) + ' closed,NOT exist ATE program now!'
                self.error('ATE program ' + str(self.current_ate_pid) + ' closed,NOT exist ATE program now!')
                print 'ATE may not started normally!'
                self.error('ATE may not started normally!')
                print 'program status : ' + self.program_status
                self.error('Leave function send_start_mail!')
                print sys.argv[0] + ' will close automaticly!'
                self.error(sys.argv[0] + ' will close automaticly!')
                exit(1)

    def check_ATE(self):
        """
        """
        print 'start checking ATE'
        count = 0
        self._logger = logging.getLogger('Scheduled_mail.SYS')
        if self._loghdlr:
            self._logger.removeHandler(self._loghdlr)
            self._loghdlr.close()
            self._loghdlr = None

        while True:
            self.program_status = 'START'
            print 'program status : ' + self.program_status
            rc, output = self.subproc(self.ATE_cmd)
            if rc == 0:
                self.program_status = 'INITIAL'
                print 'program status : ' + self.program_status
                ate_pid = int(output.strip())
                print 'ATE is runing,pid is ' + str(ate_pid)
                if self.current_ate_pid != ate_pid:
                    if self.current_ate_pid == 0:
                        print 'A new ATE started as pid :', str(ate_pid)
                        self.current_ate_pid = ate_pid
                        self.send_start_mail()
                        self.send_fail_mail()
                    else:
                        print 'Old ATE :%s finished , New ATE :%s started ' % (str(self.current_ate_pid), str(ate_pid))
                        print sys.argv[0] + ' will close automaticly!'
                        return
            else:
                self.program_status = 'IDLE'
                count = count + 1
                if count > 5:
                    print 'No ATE startup in 5 minutes ,' + sys.argv[0] + ' will close automaticly!'
                    return
                print 'program status : ' + self.program_status
                print 'count : ' + str(count) + ',No ATE is running!'
                time.sleep(self.check_ate_interval)


def main():
    """
    Entry if not imported
    """

    sm = Scheduled_Mail()

    sm.check_ATE()


if __name__ == '__main__':
    main()




