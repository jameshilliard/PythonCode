#!/usr/bin/env python
# coding=utf-8
__author__ = 'root'

from email import encoders
from email.mime.text import MIMEText
from email import MIMEBase
from email.header import Header
from email.utils import parseaddr, formataddr
from email.mime.multipart import MIMEMultipart
import smtplib


def _format_addr(s):
    name, addr = parseaddr(s)
    return formataddr(( \
        Header(name, 'utf-8').encode(), \
        addr.encode('utf-8') if isinstance(addr, unicode) else addr))


from_addr = 'xxjbs001@126.com'
password = '13837359007roy'
smtp_server = 'smtp.126.com'
to_addr = 'zxu@actiontec.com'

msg = MIMEMultipart()
msg['From'] = _format_addr(u'Python爱好者 <%s>' % from_addr)
msg['To'] = _format_addr(u'管理员 <%s>' % to_addr)
msg['Subject'] = Header(u'来自SMTP的问候……', 'utf-8').encode()
msg.attach(MIMEText('send with file ... ', 'plain', 'utf-8'))

att1 = MIMEText(open('/tmp/RIDEs59v39.d/report.html', 'rb').read(), 'base64', 'gb2312')
att1["Content-Type"] = 'application/octet-stream'
att1["Content-Disposition"] = 'attachment; filename=" Robotframwork test report"'
msg.attach(att1)

server = smtplib.SMTP(smtp_server, 25)
server.set_debuglevel(1)
server.login(from_addr, password)
server.sendmail(from_addr, [to_addr], msg.as_string())
server.quit()
