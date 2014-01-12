__author__ = 'roy'
#basic connection - chapter 13 - connect.py

from ftplib import FTP

f = FTP('ftp.ibiblio.org')
print "Welcome", f.getwelcome()
f.login()

print "CWD:", f.pwd()
f.quit()