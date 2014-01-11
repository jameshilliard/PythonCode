__author__ = 'royxu'
#basic inetd server - Chapter 3- inetserver.py

import sys

print "Welcom."
print "Please enter a string: "
sys.stdout.flush()
line = sys.stdin.readline().strip()
print "You enter %d characters.* " % len(line)

