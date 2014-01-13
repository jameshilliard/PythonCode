#!/usr/bin/python -u
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from zipfile import ZIP_DEFLATED
import mimetypes
import os
import smtplib
import tarfile
import zipfile
from optparse import OptionParser
#import zlib

class get_folder_size():
    all_size = 0

    def get_dir_size(self, dirn):
        """
        """
        #size_str = ''

        print 'INFO : getting all size of %s ' % (dirn)

        def func(a, b, c):
            for eFile in c:
                eFn = b + '/' + eFile
                try:
                    self.all_size += os.path.getsize(eFn)
                except Exception, e:
                    print '\tWARN : skipping file %s due to :%s' % (eFn, e)

        if os.path.isfile(dirn):
            self.all_size = os.path.getsize(dirn)
        elif os.path.isdir(dirn):
            os.path.walk(dirn, func, '')

        size_str = 'INFO : foler size about : %s M / %s K / %s' % (
        self.all_size / 1024 / 1024, self.all_size / 1024, self.all_size)

        return size_str


class Email_Sendor():
    """
    to send email using python email package
    """

    MAIL_HOST = ''
    username = ''
    userpass = ''
    #MAIL_FROM = ''
    _dozip = True

    def __init__(self, MAIL_HOST, username, userpass, nozip=False):
        """
        """
        self.MAIL_HOST = MAIL_HOST
        self.username = username
        self.userpass = userpass
        self._dozip = (not nozip)
        #self.MAIL_FROM = username + '<' + username.split('@')[0] + '@' + username.split('@')[1] + '>'
        #print self.MAIL_FROM
        print 'INFO : send from ', username
        #print 'password ', userpass
        print 'INFO : mail host :', MAIL_HOST


    def tarem(self, filename):
        """
            although the attachment files are zipped , 
            but still the file size is limited according to email server
        """

        tmp_dir = '/dev/shm/'
        zip_fn = tmp_dir + os.path.basename(os.path.realpath(filename)) + '.tar.bz2'

        sz = get_folder_size()

        print sz.get_dir_size(filename)

        tFile = tarfile.open(zip_fn, "w:bz2")

        if os.path.isdir(filename):
            print 'INFO : compressing a folder', filename
            #self.tar_dir(filename, tFile)
        elif os.path.isfile(filename):
            print 'INFO : compressing a file', filename

        tFile.add(filename)
        #print 'INFO : adding %s' % (filename)

        #close the tar file
        tFile.close()

        return zip_fn


    def zip_dir(self, dirn, tFile):
        """
        """

        def func(a, b, c):
            for eFile in c:
                eFn = b + '/' + eFile
                #print 'INFO : adding %s' % (eFn)
                try:
                    print 'INFO : zipping %s' % (eFn)
                    tFile.write(eFn)
                except Exception, e:
                    print '\tWARN : skipping file %s due to :%s' % (eFn, e)

        os.path.walk(dirn, func, 'arg')


    def zipem(self, filename):
        """
            although the attachment files are zipped , 
            but still the file size is limited according to email server
        """

        tmp_dir = '/dev/shm/'
        zip_fn = tmp_dir + os.path.basename(filename) + '.zip'
        #Create the zip file
        # 

        tFile = zipfile.ZipFile(zip_fn, 'w', compression=ZIP_DEFLATED)

        if os.path.isdir(filename):
            print 'INFO : compressing a folder'
            self.zip_dir(filename, tFile)
        elif os.path.isfile(filename):
            print 'INFO : compressing a file'
            tFile.write(filename)
            #print 'INFO : adding %s' % (filename)
        #List archived files
        for f in tFile.namelist():
            print ("\tAdded %s" % f)

        #close the zip file
        tFile.close()

        return zip_fn


    def sendMail(self, subject, content, recptr_addr, filename=None):
        #MAIL_FROM = MAIL_FROM
        recptr_addr = recptr_addr
        MAIL_HOST = self.MAIL_HOST
        username = self.username
        userpass = self.userpass
        MAIL_FROM = username

        if str(type(recptr_addr)) == str(type('str')):
            print 'INFO : sending to one receptor'
            recptr_addr = recptr_addr
        elif str(type(recptr_addr)) == str(type(['list'])):
            print 'INFO : sending to multiple receptors'
            recptr_addr = ';'.join(recptr_addr)

        try:
            smtp = smtplib.SMTP()

            print'INFO : connecting status\t%s\nINFO : connecting message\t%s' % (smtp.connect(MAIL_HOST))

            if not MAIL_HOST == 'localhost':
                print'INFO : login status\t%s\nINFO : login message\t%s' % (smtp.login(username, userpass))

            message = MIMEMultipart()
            message.attach(MIMEText(content, 'html'))
            message['Subject'] = subject
            message['From'] = username
            message['To'] = recptr_addr

            print 'INFO : sending to ', message['To']

            zip_fns = []

            def add_attachment(filename):
                """
                """
                print '=========' * 15 + '\n'

                if filename != None and os.path.exists(filename):
                    dozip = self._dozip
                    print 'INFO : attachment file %s exists' % (filename)
                    filename = os.path.realpath(filename)
                    #zip_fn = self.zipem(filename)
                    if dozip:
                        zip_fn = self.tarem(filename)

                        zip_fns.append(zip_fn)

                        size_zip_fn = os.path.getsize(zip_fn)

                        print 'INFO : adding %s as attachment , size about : %s M / %s K / %s' % (
                        zip_fn, str(size_zip_fn / 1024 / 1024), str(size_zip_fn / 1024), str(size_zip_fn))
                    else:
                        zip_fn = filename

                    ctype, encoding = mimetypes.guess_type(zip_fn)

                    print 'INFO : ctype\t%s\nINFO : encoding\t%s' % (ctype, encoding)

                    if ctype is None or encoding is not None:
                        ctype = 'application/octet-stream'
                    maintype, subtype = ctype.split('/', 1)

                    print 'INFO : maintype\t%s\nINFO : subtype\t%s' % (maintype, subtype)

                    attachment = MIMEImage((lambda f: (f.read(), f.close()))(open(zip_fn, 'rb'))[0], _subtype=subtype)

                    attachment.add_header('Content-Disposition', 'attachment', filename=zip_fn)

                    message.attach(attachment)

            if str(type(filename)) == str(type('str')):
                print 'INFO : adding one attachment'
                add_attachment(filename)
                #recptr_addr = recptr_addr
            elif str(type(filename)) == str(type(['list'])):
                print 'INFO : adding multiple attachments'
                for fname in filename:
                    add_attachment(fname)
                    #recptr_addr = ';'.join(recptr_addr)

            r_addrs = recptr_addr.split(';')

            for r_addr in r_addrs:
                print 'INFO : sending mail to ', r_addr
                errs = smtp.sendmail(MAIL_FROM, r_addr, message.as_string())

                print 'INFO : errs :', errs

        except Exception, e:
            print 'AT_ERROR : Send mail failed to :%s' % (e)

        finally:
            print 'INFO : quitting ...'
            smtp.quit()

            for zip_f in zip_fns:
                os.remove(zip_f)
                print 'INFO : removed sent attachment file : %s ' % (zip_f)


def main():
    """
    Entry if not imported
    """

    usage = "usage not ready yet \n"

    parser = OptionParser(usage=usage)

    parser.add_option("-f", "--attach", dest="attach", action="append",
                      help="The attachments to be sent")

    parser.add_option("-s", "--subject", dest="subject",
                      help="subject of Email")

    parser.add_option("-c", "--content", dest="content", action="append",
                      help="content of Email")

    parser.add_option("-H", "--MAIL_HOST", dest="MAIL_HOST",
                      help="MAIL HOST")

    parser.add_option("-u", "--username", dest="username",
                      help="username of Email Account")

    parser.add_option("-p", "--userpass", dest="userpass",
                      help="password of Email Account")

    parser.add_option("-r", "--recptr", dest="recptr_addr",
                      help="mail receiver")
    parser.add_option("--no-zip", dest="nozip", action='store_true', default=False,
                      help="do not zip attachment file(s)")

    (options, args) = parser.parse_args()

    if not len(args) == 0:
        print args

    subject = ''

    content = ''

    fn = []

    MAIL_HOST = ''

    username = ''

    userpass = ''

    recptr_addr = []

    if options.subject:
        subject = options.subject

    if options.content:
        for ctnt in options.content:
            if os.path.exists(ctnt) and os.path.isfile(ctnt):
                print 'append content from file :', content
                tmp_f = open(ctnt)
                lines = tmp_f.readlines()

                for line in lines:
                    content += line

                tmp_f.close()
            else:
                print 'content is not file : ', content
                content = options.content[0]
    nozip = False
    if options.nozip:
        nozip = True
    if options.attach:
        fn = options.attach

    if options.MAIL_HOST:
        MAIL_HOST = options.MAIL_HOST

    if options.username:
        username = options.username

    if options.userpass:
        userpass = options.userpass

    if options.recptr_addr:
        recptr_addrs = options.recptr_addr.split('+')

        for ra in recptr_addrs:
            recptr_addr.append(ra)

    #print 'content : ', content

    #content='haha'

    ##########################################################

    sendor = Email_Sendor(MAIL_HOST, username, userpass, nozip=nozip)

    sendor.sendMail(subject, content, recptr_addr, fn)


if __name__ == '__main__':
    main()




