#!/bin/env python
import os
import sys
import time
import re
from optparse import OptionParser
from pexpect import run

class EthTool():
    """
    """
    def __init__(self, interface, speed, duplex, remote=False, debug=False):
        self.speed = speed
        self.duplex = duplex
        self.interface = interface
        self.remote = remote
        self.debug = debug

    def cmd_return(self, interface=None, speed=None, duplex=None, debug=False): 
        """
        """    
        if speed is None:
            speed = self.speed
        if duplex is None:
            duplex = self.duplex
        if interface is None:
            interface = self.interface
        if debug:
            print 'interface ==><%s>' % len(interface)
            print 'speed     ==><%s>' % len(speed)
            print 'duplex    ==><%s>' % len(duplex)
         
        cmd = 'ethtool -s %s %s %s %s %s'
        format = '%s'
        
        if interface is None:
            return False
        else:
            cmd = cmd % (interface, format, format, format, format)
        if  speed is not None:
            cmd = cmd % ('speed', speed, format, format)
        else:
            cmd = cmd % ('', '', format, format)
        if duplex is not None:
            cmd = cmd % ('duplex', duplex)
        else:
            cmd = cmd % ('', '')
        cmd = str(cmd).strip().replace('\s+', ' ')
        if debug:
            print 'cmd ==><%s>' % cmd
        return cmd
            
    def remote_set(self, interface=None, speed=None, duplex=None, debug=False):   
        """
        """
        ssh_host_cmd = "clicmd -d %s -u %s -p %s  -y ssh -v '%s'"
        remote_cmd = self.cmd_return(interface, speed, duplex)
        host = os.getenv('G_HOST_IP1', None)
        user = os.getenv('G_HOST_USR1', None)
        password = os.getenv('G_HOST_PWD1', None)
#        if debug:
#            host = '192.168.100.101'
#            user = 'root'
#            password = 'actiontec'
        
        ssh_host_cmd = ssh_host_cmd % (host, user, password, remote_cmd)
        if debug:
            print 'Remote command ==><%s>' % ssh_host_cmd
        
        if remote_cmd:
             cmd_log, cmd_result = run(ssh_host_cmd, timeout=60, withexitstatus=True, logfile=sys.stdout)     
             if not cmd_result:
                 return True
             else:
                 return False
        return False              
                
    def local_set(self, interface=None, speed=None, duplex=None, debug=False):
        """
        """
        local_cmd = self.cmd_return(interface, speed, duplex)
        if local_cmd:
            print '====><%s>' % local_cmd
            cmd_log, cmd_result = run(local_cmd, timeout=60, withexitstatus=True, logfile=sys.stdout)
            if not cmd_result:
                return True
            else:
                return False
        return False
        
        
                
def test():
    interface = 'eth2'
    duplex = 'full'
    speed = '100'
    
    eth2_set = EthTool(interface, speed, duplex, debug=True)
    print eth2_set.debug
    print eth2_set.cmd_return(debug=eth2_set.debug)
    print eth2_set.cmd_return('eth2', '100', 'half', debug=eth2_set.debug)
    print eth2_set.local_set('eth2', '100', 'full')
            

def optionsparser():
    """
    """
    usage = "usage: %prog [options]"
    option = OptionParser(usage=usage)
    option.add_option('-i',
                      '--interface',
                      dest='intf',
                      help='Specify what interface you want to set.'
                      )
    option.add_option('-s',
                      '--speed',
                      dest='speed',
                      type='choice',
                      choices=['10', '100', '1000'],
                      default='1000',
                      help="""Specify the interface work speed that you want to set;
                      choice from ['10', '100', '1000'];
                      default is 1000."""
                     )
    option.add_option('-m',
                      '--duplex',
                      dest='duplex',
                      type='choice',
                      choices=['full', 'half'],
                      default='full',
                      help="""Specify the interface work mode that you want to set;
                            choice from ['full', 'half'];
                            default is full."""
                      )                               
    option.add_option('-r',
                      '--remote',
                      dest='remote',
                      action='store_true',
                      default=False,
                      help='Specify the interface is remote PC or not.'                                     
                      )
    option.add_option('-D',
                      '--Debug',
                      dest='is_debug',
                      action='store_true',
                      default=False,
                      help='Specify is debug mode or not,default is not.'                                     
                      )    
    
    options, args = option.parse_args()
    return options, args

        
if __name__ == '__main__':
    opts, args = optionsparser()
    if not opts.intf:  
        exit(1)
    print 'Interfae ==><%s>' % opts.intf
    print 'Speed    ==><%s>' % opts.speed
    print 'Duplex   ==><%s>' % opts.duplex
    print 'Remote   ==><%s>' % opts.remote
    
    ethTest = EthTool(opts.intf, opts.speed, opts.duplex, opts.remote, opts.is_debug)
    if opts.remote:
        set_result = ethTest.remote_set(debug=ethTest.debug)
    else:
        set_result = ethTest.local_set(debug=ethTest.debug)
    
    print 'Set result ==><%s>' % set_result
    if set_result:
        exit(0)
    else:
        exit(1)
    
              
        
        
        
        
        
        
        
        
        
        
        
