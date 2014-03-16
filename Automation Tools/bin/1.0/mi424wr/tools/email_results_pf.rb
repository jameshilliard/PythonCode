#!/usr/bin/env ruby

gr = "/root/actiontec/automation/logs/current/result.txt"
results = File.open(gr).read
failures = results.scan(/\[\d+\]\.Testcase FAILED: .*xml$/).length
passes = results.scan(/\[\d+\]\.Testcase Passed: .*xml$/).length

`perl $U_COMMONBIN/sendemail.pl -v TO=$G_USER -v NCFAIL=$G_NCFAIL -v NCPASS=$G_NCPASS -v TCPASS=#{passes} -v TCFAIL=#{failures} -v ATTACHMENT=$G_RESULT -v TESTSUITE=$G_TSUITE -V BUILD=$G_BUILD -v CC=$G_CC -v FROM=$G_FROMRCPT -v XLSFILE=$G_LOG/$(echo ${G_TSUITE##*/} | sed 's/.tst/_result.xls/g') -v FWVERSION=$G_FWVERSION -l $G_LOG`