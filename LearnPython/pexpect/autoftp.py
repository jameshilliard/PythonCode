from __future__ import unicode_literals
import pexpect
import sys
child = pexpect.spawn('ftp 172.16.10.241')
child.expect('(?i)name .*: ')
child.sendline('actiontec')
child.expect('(?i)password')
child.sendline('actiontec')
child.expect('ftp> ')
child.sendline('ls')
child.expect('ftp> ')
child.sendline('cd /temp')
child.sendline('get id_psa.pub')
sys.stdout.write (child.before)
print("Escape character is '^]'.\n")
sys.stdout.write (child.after)
sys.stdout.flush()
#child.interact() # Escape character defaults to ^]
child.sendline('bye')
child.close()