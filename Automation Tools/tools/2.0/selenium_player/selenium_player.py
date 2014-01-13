from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support.ui import Select
import time, os, re
from pprint import pprint
import subprocess, signal, select
from optparse import OptionParser


class selenium_player():
    driver = None
    sub_p = []
    async_log = None

    runner = None

    #runtime_env = {}


    def __init__(self, GUI=True):
        """
        """
        if GUI:
            print 'AT_INFO : GUI mode'
            self.driver = webdriver.Firefox()
        else:
            server_cmd = 'java -jar ' + os.path.expandvars(
                '$SQAROOT/lib/$G_LIBVERSION/common/') + 'selenium-server-standalone-2.25.0.jar'
            p = self.start_async_subproc(server_cmd)

            self.sub_p.append(p)

            conn_server_retry = 60
            conn_server_interval = 5

            for i in range(conn_server_retry):
                print 'try connecting to selenium server attempt : ', str(i + 1)
                try:
                    self.driver = webdriver.Remote("http://localhost:4444/wd/hub",
                                                   webdriver.DesiredCapabilities.HTMLUNIT)
                    break
                except Exception, e:
                    print 'Exception : ' + str(e)

                    if int(i + 1) < conn_server_retry:
                        print 'connecting failed , try again'
                        time.sleep(conn_server_interval)
                    else:
                        self.kill_async()
                        exit(1)

        product_id = os.getenv('U_DUT_TYPE')

        if product_id:

            cmd = 'from Runner import ' + product_id + ' as RUNNER'
            print cmd

            try:
                exec (cmd)

                Runner = RUNNER.getRunner()
                self.runner = Runner(self.driver)
            except Exception, e:
                print 'Exception : ' + str(e)
                self.quit_drv()
                exit(1)

            if not self.runner:
                self.error('Can not find Runner for ' + product_id)
                self.quit_drv()
                exit(1)
        else:
            print 'AT_ERROR : must specify DUT type'
            exit(1)


    def quit_drv(self):
        print 'in function quit_drv'
        driver = self.driver
        driver.quit()

        self.kill_async()


    def abort(self):
        self.quit_drv()
        exit(1)


    def start_async_subproc(self, cmd):
        """
        subprogress to run command
        """
        print 'start_async_subproc : ' + cmd
        rc = None
        output = ''

        try:
            self.async_log = open('/tmp/selenium.log', 'w')
            #    /tmp/selenium.log
            #p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True, shell=True)
            p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=self.async_log, stderr=subprocess.PIPE,
                                 close_fds=True, shell=True)
            pi, po, pe = p.stdin, p.stdout, p.stderr
            rc = p

        except Exception, e:
            print 'Exception : ' + str(e)
            rc = False

        return rc


    def stop_async_subporc(self, p):
        rc = None
        if not isinstance(p, subprocess.Popen):
            return rc
        inf = os.popen('ps aux | grep -v grep | grep ' + str(p.pid)).read()
        print 'stop async subproc : ' + inf
        try:
            p.terminate()
            #p.kill()
            #rc = p.wait()
            to = 15
            for i in range(to):
                time.sleep(1)
                rc = p.poll()
                if rc is not None:
                    break


            # force to kill the progress
            if rc == None:
                print 'kill async subproc : ' + inf
                p.kill()

            for i in range(to):
                time.sleep(1)
                rc = p.poll()
                if rc is not None:
                    break
            if rc == None:
                print 'kill subproc : ' + inf
                os.system('kill -9 ' + str(p.pid))

            p.stdin.close()
            p.stdout.close()
            p.stderr.close()

            rc = p.returncode
        except Exception, e:
            print 'Exception : ' + str(e)
            rc = False
        return rc


    def kill_async(self):
        for p in self.sub_p:
            self.stop_async_subporc(p)


    def login(self):
        """
        login 
        True
        False
        """

        try:
            if self.runner.login():
                return True
            else:
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            return False

    def logout(self):
        """
        logout 
        True
        False
        """

        try:
            if self.runner.logout():
                return True
            else:
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            return False


def parseVerb(kv):
    """
    """
    match = r'(\w*)=(.*)'
    #print '==',kv
    res = re.findall(match, kv)
    for (k, v) in res:
        (k, v) = res[0]
        print '==', 'import env :', k, ' = ', v
        #os.environ[k] = v
        os.environ.update({
            k: v
        })


def main():
    """
    Entry if not imported
    """

    usage = "usage not ready yet \n"

    parser = OptionParser(usage=usage)

    parser.add_option("-t", "--type", dest="type",
                      help="GUI setting operation type")
    parser.add_option("-v", "--variableOption", dest="vos", action="append",
                      help="The environment to set, format is key=val")

    (options, args) = parser.parse_args()

    if not len(args) == 0:
        print args

    type = ''

    if options.type:
        type = options.type
    else:
        print 'AT_ERROR : must specified an operation type'
        exit(1)

    if options.vos:
        for kv in options.vos:
            parseVerb(kv)

    types = type.split('_')

    type = types[0]

    params = types[1:]

    print 'AT_INFO : operation -- ', type
    print 'AT_INFO : params    -- '
    print params
    ############################################################################
    GUI = False

    isGUI = os.getenv('U_CUSTOM_SELENIUM_GUI', '0')

    if isGUI == '0':
        GUI = False
    else:
        GUI = True

    sp = selenium_player(GUI)



    #pprint(sp.runtime_env)

    if sp.login():
        print 'AT_INFO : login passed'
    else:
        print 'AT_ERROR : login failed'
        sp.quit_drv()
        exit(1)


    #current_result = False

    cmd = 'sp.runner.' + type + '('

    real_params = []

    for p in params:
        real_params.append("'" + p + "'")

    if len(params) > 0:
        #for p in params:
        cmd += ','.join(real_params)

    cmd += ')'

    print cmd

    try:
        eval(cmd)
    except Exception, e:
        print 'Exception : ' + str(e)
        #sp.quit_drv()
        #return False
    current_result = os.getenv('current_result', False)
    print 'current result : ', str(current_result)

    if not current_result == 'True':
        print 'AT_ERROR : setting failed'

        try:
            sp.logout()
        except Exception, e:
            print 'Exception : ' + str(e)
            current_result = 'False'
    else:
        print 'AT_INFO : setting passed'

    if not type == 'resetDUT':
        try:
            sp.logout()
        except Exception, e:
            print 'Exception : ' + str(e)
            current_result = 'False'

    sp.quit_drv()

    if current_result == 'True':
        print 'AT_INFO : selenium_playback PASSED !'
        exit(0)
    else:
        print 'AT_ERROR : selenium playback FAILED'
        exit(1)


if __name__ == '__main__':
    """
    """
    #INIT_ATE_LOG()
    #print ATE_LOGGER
    main()
