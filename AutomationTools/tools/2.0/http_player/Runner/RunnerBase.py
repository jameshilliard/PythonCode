import clicmd
import inspect
import os
import re


def get_current_function_name():
    return inspect.stack()[1][3]


class RunnerBase():
    """
    """
    m_prod_ver = None
    m_player = None
    m_sender = None
    m_msglvl = 2
    m_next_page = {
        'id': '',
        'title': '',
        'type': '',
    }
    m_hashENV = {}

    def __init__(self, player, pv, Sender, loglevel=2):
        """
        """
        self.m_player = player
        self.m_prod_ver = pv
        self.m_sender = Sender
        self.m_msglvl = loglevel
        self.loadEnv()
        #self.m_player.info('Runner for FiberTech ' + self.m_prod_ver)

    def loadEnv(self):
        """
        """
        for (k, v) in os.environ.items():
            if 0 == k.find('G_'):
                self.m_hashENV[k] = v
            elif 0 == k.find('U_'):
                self.m_hashENV[k] = v
            elif 0 == k.find('TMP_'):
                self.m_hashENV[k] = v

    def debug(self, msg):
        """
        """
        if self.m_msglvl > 2:
            pprint('== ' + self.__class__.__name__ + ' Debug : ' + pformat(msg))
        return True

    def info(self, msg):
        """
        """
        if self.m_msglvl > 1:
            print '== ' + self.__class__.__name__ + ' Info : ', str(msg)
        return True

    def warning(self, msg):
        """
        """
        if self.m_msglvl > 0:
            print '== ' + self.__class__.__name__ + ' Warning : ', str(msg)
        return True

    def error(self, msg):
        """
        """
        print '== ' + self.__class__.__name__ + ' Error : ', str(msg)
        return True

    def parseNextPage(self, resp, content):
        """
         
        """
        typePage = ''
        return typePage


    def login(self):
        """
        """
        return True

    def logout(self):
        """
        """
        return True


    def beforeReqeust(self, Reqs, idx):
        """
        """
        # 
        return True

    def afterReqeust(self, Reqs, idx):
        """
        """
        return True

    def upgradeFirmware(self, filepath, ver=None):
        """
        """
        self.error('No method to upgradeFirmware!')
        #return self.m_player.uploadFile(filepath)

        return True

    def cli_command(self, cmd_list, host, port, username, password, output='/tmp/cli_command.log', cli_type='telnet'):
        """
        True False
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
