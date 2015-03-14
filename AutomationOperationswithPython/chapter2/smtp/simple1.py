#!/usr/bin/env PYTHON
#coding=utf-8
import smtplib
import string

HOST = "smtp.126.com"
SUBJECT = "test mail from 126"

TO = "zxu@actiontec.com"
FROM = "xxjbs001@126.com"
text = "Python rules then all"
BODY = string.join((
        "From: %s" % FROM,
        "To: %s" % TO,
        "Subject: %s" % SUBJECT ,
        "",
        text
        ), "\r\n")

server = smtplib.SMTP()
server.connect(HOST, 25)
server.starttls()
server.login("xxjbs001@126.com", "13837359007roy")
server.sendmail(FROM, [TO], BODY)
server.quit()