import re, os, sys
from pprint import pprint
from pprint import pformat
from optparse import OptionParser

import clicmd


class Jacs_tr_launcher():
    tc_loc = None
    output_file = None
    RPC = None

    conn_url = ''

    prod_port = {
        'TV2KH': '7547',
        'TDSV2200H': '4567',
        'CTLC2KA': '4567',
        'BAR1KH': '7547',
        'PK5K1A': '4567',
        'BHR2': '4567',
    }

    def cli_command_with_output(self, cmd_list, host, port, username, password, output='/tmp/cli_command.log',
                                cli_type='ssh', timeout=360):
        """
        True False
        """
        print 'in cli_command'

        CLI = clicmd.clicmd(has_color=False)

        res, last_error = CLI.run(cmd_list, cli_type, host, port, username, password, cli_prompt=None, mute=False,
                                  timeout=timeout)

        m_return_code = r'last_cmd_return_code:(\d)'

        out_rc = ''

        if res:

            for r in res:
                out_rc += r
                rc = re.findall(m_return_code, r)
                if len(rc) > 0:
                    print 'EACH command result :', rc
                    return_code = 0
                    for rc_idx in range(len(rc)):
                        return_code += int(rc[rc_idx])

                    if str(return_code) != '0':
                        all_rc = False
                        return all_rc, out_rc


        else:
            print 'AT_ERROR : cli command failed'
            return False, 'AT_ERROR : cli command failed'

        return True, out_rc

    def get_conn_url(self):
        U_DUT_TYPE = os.getenv('U_DUT_TYPE')

        if U_DUT_TYPE == 'BHR2':
            cmd = ['conf print cwmp']
            conn_url = None
            rc, out = self.cli_command_with_output(cmd,
                                                   os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1'),
                                                   os.getenv('U_DUT_TELNET_PORT ', '23'),
                                                   os.getenv('U_DUT_TELNET_USER', 'admin'),
                                                   os.getenv('U_DUT_TELNET_PWD', 'admin1'),
                                                   cli_type='telnet')

            m_conn_url = r'\(conn_req_url\((.*)\)\)'
            for line in out.split('\n'):
                rc = re.findall(m_conn_url, line)
                if len(rc) > 0:
                    conn_url = rc[0]
                    break

            if conn_url:
                return conn_url
            else:
                return False
        else:
            return ' '

    def create_tc_from_parameter(self, parameter):
        """
        """
        prefix = {
            'GPV': 'get_params ',
            'AddObj': 'rpc cwmp:AddObject ObjectName=',
            'DelObj': 'rpc cwmp:DeleteObject ObjectName=',
            'SPV': 'set_params ',
            #                 'GetRPCMethods':'rpc cwmp:GetRPCMethods',
            #                 'GetRPCMethods':'rpc cwmp:GetRPCMethods',
        }

        # 'U_DUT_ACS_PORT':'4567',

        U_DUT_ACS_PORT = os.getenv('U_DUT_ACS_PORT', self.prod_port.get(os.getenv('U_DUT_TYPE')))
        if not U_DUT_ACS_PORT:
            print 'AT_ERROR : U_DUT_ACS_PORT cannot be empty'
            return False

        tc_loc = self.tc_loc
        tc_f = open(tc_loc, 'w')

        tc_f.write('listen 1234\n')
        tc_f.write(os.path.expandvars(
            "connect http://$TMP_DUT_WAN_IP:" + U_DUT_ACS_PORT + "/" + self.conn_url + " actiontec actiontec NONE\n"))
        tc_f.write('wait\n')
        tc_f.write('rpc InformResponse MaxEnvelopes=1\n')
        tc_f.write('wait\n')
        tc_f.write(prefix.get(self.RPC) + parameter + '\n')
        tc_f.write('wait\n')

        tc_f.write('rpc0\n')
        tc_f.write('wait\n')
        tc_f.write('quit\n')

        tc_f.close()

        return True

    def create_tc_from_file(self, file_loc):
        """
        """
        prefix = {
            'GPV': 'get_params ',
            'AddObj': 'rpc cwmp:AddObject ObjectName=',
            'DelObj': 'rpc cwmp:DeleteObject ObjectName=',
            'SPV': 'set_params ',
            #                 'GetRPCMethods':'rpc cwmp:GetRPCMethods',
            #                 'GetRPCMethods':'rpc cwmp:GetRPCMethods',
        }

        U_DUT_ACS_PORT = os.getenv('U_DUT_ACS_PORT', self.prod_port.get(os.getenv('U_DUT_TYPE')))
        if not U_DUT_ACS_PORT:
            print 'AT_ERROR : U_DUT_ACS_PORT cannot be empty'
            return False

        file_f = open(file_loc, 'r')
        lines = file_f.readlines()
        file_f.close()

        tc_loc = self.tc_loc
        tc_f = open(tc_loc, 'w')

        tc_f.write('listen 1234\n')
        tc_f.write(os.path.expandvars(
            "connect http://$TMP_DUT_WAN_IP:" + U_DUT_ACS_PORT + "/" + self.conn_url + " actiontec actiontec NONE\n"))
        tc_f.write('wait\n')
        tc_f.write('rpc InformResponse MaxEnvelopes=1\n')
        tc_f.write('wait\n')
        for line in lines:
            tc_f.write(prefix.get(self.RPC) + line + '\n')
            tc_f.write('wait\n')

        tc_f.write('rpc0\n')
        tc_f.write('wait\n')
        tc_f.write('quit\n')

        tc_f.close()

        return True

    def execute_RPC_on_remote_PC(self):
        """
        'G_HOST_USR1':'root',
        'G_HOST_IP1':'192.168.100.121',
        'G_HOST_PWD1':'actiontec',
        
        perl executeTest.pl -s ./jacs -f test.tc -d /tmp -l jac.log
        """

        print 'self.tc_loc ', self.tc_loc
        print 'self.output_file ', self.output_file

        command_tc = 'perl executeTest.pl -s ./jacs -f ' + self.tc_loc + ' -d ' + os.getenv('G_CURRENTLOG',
                                                                                            os.path.expandvars(
                                                                                                '$SQAROOT/logs/current')) + ' -l ' + self.output_file

        cmd = [os.path.expandvars('cd $SQAROOT/bin/1.0/jacs/'),
               #                'killall jacs',
               'ls',
               command_tc
        ]

        rc, out = self.cli_command_with_output(cmd,
                                               os.getenv('G_HOST_IP1'),
                                               '22',
                                               os.getenv('G_HOST_USR1'),
                                               os.getenv('G_HOST_PWD1'),
                                               cli_type='ssh')
        # INFO: It's Successful to execute GPV

        m_pass = r'INFO: It\'s Successful to execute ' + self.RPC

        result = False

        for line in out.split('\n'):
            rc = re.findall(m_pass, line)
            if len(rc) > 0:
                pprint(rc)
                result = True
                break

        return result

    #     def

    def do_it(self, d={}):
        """
        d = {
           'RPC':RPC,
           'config_file':config_file,
           'parameter':parameter,
           'output_file':output_file,
           }
        """
        params = d

        pprint(params)

        RPC = params.get('RPC')
        if not RPC:
            print 'must specify operation type'
            return False
        else:
            self.RPC = RPC
            ########################################
        output_file = params.get('output_file')
        if not output_file:
            print 'must specify output_file'
            return False
        else:
            self.output_file = output_file

        conn_url = self.get_conn_url()
        if not conn_url:
            print 'get_bhr_conn_url failed'
            return False
        else:
            self.conn_url = conn_url

        parameter = params.get('parameter')
        if parameter:
            self.tc_loc = os.getenv('G_CURRENTLOG', os.path.expandvars(
                '$SQAROOT/logs/current')) + '/' + self.RPC + '_' + parameter + '.tc'
            if not self.create_tc_from_parameter(params.get('parameter')):
                print 'create_tc_from_parameter failed'
                return False

        config_file = params.get('config_file')
        if config_file:
            self.tc_loc = os.getenv('G_CURRENTLOG', os.path.expandvars(
                '$SQAROOT/logs/current')) + '/' + self.RPC + '_' + config_file + '.tc'
            if not self.create_tc_from_file(params.get('config_file')):
                print 'create_tc_from_file failed'
                return False

        return self.execute_RPC_on_remote_PC()


def main():
    """
    Usage: launchtr69.sh -v <RPC> -c <config file> [-h]\nexpample:\nlaunchtr69.sh -v GPV -c B-GEN-TR98-BA.PFO-003-RPC001 \n
    """
    usage = "usage not ready yet \n"

    parser = OptionParser(usage=usage)

    parser.add_option("-v", "--RPC", dest="RPC",
                      help="such as GPV , SPV and so on ...")
    parser.add_option("-c", "--config_file", dest="config_file",
                      help="RPC file to be executed")
    parser.add_option("-p", "--parameter", dest="parameter",
                      help="using parameter instead of RPC files")
    parser.add_option("-o", "--output_file", dest="output_file",
                      help="the operation output log , such as GPV result etc.")
    #########################################################################################
    parser.add_option("-s", "--serial_number", dest="serial_number",
                      help="the serial number of tested DUT")
    parser.add_option("-x", "--debug_level", dest="debug_level",
                      help="debug_level")
    #########################################################################################
    parser.add_option("-g", "--image_location", dest="image_location",
                      help="image_location")
    parser.add_option("-l", "--ruby_runtime_log", dest="ruby_runtime_log",
                      help="the ruby runtime log")
    parser.add_option("-f", "-- communication_log", dest="communication_log",
                      help=" communication log")
    parser.add_option("-e", "--e_timeout", dest="e_timeout",
                      help="using set expirationTimeOut in ACS server")
    parser.add_option("-d", "--nothing", dest="nothing",
                      help="nothing")
    parser.add_option("-m", "--stepmask", dest="stepmask",
                      help="stepmask")

    (options, args) = parser.parse_args()

    RPC = None
    config_file = None
    parameter = None
    output_file = None

    if options.RPC:
        RPC = options.RPC

    if options.config_file:
        config_file = options.config_file

    if options.parameter:
        parameter = options.parameter

    if options.output_file:
        output_file = options.output_file

    if RPC == None:
        print 'by pass'

        device_id_f = open(os.path.expandvars("$G_CURRENTLOG/ruby_find_device_output.log"), 'w')
        device_id_f.write('fake_device_id=00000000')
        device_id_f.close()

        dcs_f = open(os.path.expandvars("$G_CURRENTLOG/defaultConnectionService.log"), 'w')
        dcs_f.write('dcs=no_such_thing')
        dcs_f.close()

        sys.exit(0)
        ###############################################

    d = {
        'RPC': RPC,
        'config_file': config_file,
        'parameter': parameter,
        'output_file': os.path.basename(output_file),
    }

    jtl = Jacs_tr_launcher()

    rc = jtl.do_it(d=d)

    if not rc:
        print '%s failed' % (RPC)
        sys.exit(1)
    else:
        print '%s passed' % (RPC)
        sys.exit(0)


if __name__ == '__main__':
    """
    $TMP_DUT_WAN_IP:$U_DUT_ACS_PORT
    """
    #     os.environ.update({
    #                         'TMP_DUT_WAN_IP':'192.168.55.1',
    #                         'U_DUT_TYPE':'CTLC2KA',
    #                         'G_HOST_USR1':'root',
    #                         'G_HOST_IP1':'192.168.100.121',
    #                         'G_HOST_PWD1':'actiontec',
    #                         })
    main()
