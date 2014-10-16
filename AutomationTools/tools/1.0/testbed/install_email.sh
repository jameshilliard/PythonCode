#!/bin/bash
yum -y install sendmail-cf
cp -f $SQAROOT/tools/1.0/testbed/sendmail/sendmail.mc /etc/mail/.
make -C /etc/mail
cp -f $SQAROOT/tools/1.0/testbed/sendmail/sendmail.cf /etc/mail/.
service sendmail restart