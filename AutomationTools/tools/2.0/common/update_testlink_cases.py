#!/usr/bin/python -u
import os, sys, re
import time

from pprint import pprint
from pprint import pformat
import logging
from copy import deepcopy

import signal
from optparse import OptionParser
#import subprocess,signal,select


print(sys.argv)
argc = len(sys.argv)
if argc < 2:
    print('You need pass 2 parameters : %s DUT "tl_case_name at_tst_name at_case_name" ' % sys.argv[0])
    exit(1)
print("\n" * 10)
print('Argv : %s' % str(sys.argv) )
[dut_types, para] = sys.argv[1:]

dut_type = 'TMPL_TST'
tl_case = ''
at_tst = ''
at_case = ''

z = para.split()
if len(z) == 3:
    tl_case = z[0].strip()
    at_tst = z[1].strip()
    at_case = z[2].strip()
else:
    print('[ERROR] : %s' % para)
    exit(1)

m = r'[^/]*\.tst'
z = re.findall(m, at_tst)
if len(z):
    at_tst = z[0]
    pass

m = r'[^/]*\.xml'
z = re.findall(m, at_case)
if len(z):
    at_case = z[0]
    pass
#print(at_tst,at_case)
#exit(1)
#[dut_type,tl_case,at_tst,at_case] = ['TV2KH','00400031','ping.tst','No-17311__Ping_Test_with_WAN_URL']

# Find tl_case_file

case = {
    'fn_tl_case': '',
    'fn_at_run_cfg': '',
    'fn_at_tst': '',
    #
    'precondition': [],
    'pre_jobs': [],
    'pre_check': [],
    'premise': [],
    'jobs': [],
    'after_jobs': [],
    'postcondition': [],
}

print('--' * 16)
print('\n\n')

z = dut_types.split(',')
if len(z) == 1:
    dut_type = z[0]
    pass
else:
    dut_type = 'TMPL_TST'

print('==> %s' % dut_type)

tst_path = '/root/automation/testsuites/2.0'
tl_case_path = os.path.join(tst_path, dut_type + '/tl_cases')
cmd = 'find %s -type f | grep %s | grep -e "case$" ' % (tl_case_path, tl_case)
print('==> [TODO] : Find testlink case with command : %s' % cmd)
resp = os.popen(cmd).read().strip()
if len(resp) and os.path.exists(resp):
    #tl_case = resp
    case['fn_tl_case'] = resp
    print('==> [PASS] : Find testlink case : %s' % resp )
    pass
else:
    print('==> [FAIL] : Find testlink case : %s' % resp )
    print('[ERROR] : %s' % para)
    exit(1)


#print('--'*16)
#print('\n\n')
# Find run.cfg
#print('==> [TODO] : Find run.cfg')
#run_cfg_path = os.path.join(tst_path,'%s/run.cfg'%(dut_type))
#if os.path.exists(run_cfg_path):
#    print('==> [PASS] : Find run.cfg file : %s' % (run_cfg_path) )
#    pass
#else :
#    print('==> [FAIL] : Find run.cfg file : %s' % run_cfg_path )
#    exit(1)

print('--' * 16)
print('\n\n')

found = False
for dut in z:
    print('==> [%s] : Find tst file(%s) contains at case(%s)' % ('TODO', at_tst, at_case) )
    run_cfg_path = os.path.join(tst_path, '%s/run.cfg' % (dut))
    at_tst_path = os.path.join(tst_path, '%s/tsuites' % (dut))
    cmd = 'grep %s %s' % (at_tst, run_cfg_path)
    resp = os.popen(cmd).read().strip()
    if not len(resp):
        continue
    cmd = 'grep -r -i %s %s | grep /%s | grep -e "-tc" | grep -i "%s" ' % (at_case, at_tst_path, at_tst, at_case)
    resp = os.popen(cmd).read().strip()
    #print(resp)
    #exit(0)
    if len(resp):
        p = resp.find(':')
        #tl_case = resp
        case['fn_at_tst'] = resp[:p]
        #case['jobs'] = [resp[p+1:]]
        #print('jobs : %s' % (case['jobs']) )
        print('==> [%s] : Find tst file contains at case : %s' % ('PASS', case['fn_at_tst']) )
        found = True
        break
    else:
        #print('==> [%s] : Find tst file contains at case : %s' % ('FAIL',case['fn_at_tst']) )
        #print(cmd)
        #exit(1)
        pass

if not found:
    print('==> [%s] : Find tst file contains at case : %s' % ('FAIL', case['fn_at_tst']) )
    #print(cmd)
    print('[ERROR] : %s' % para)
    exit(1)

print('--' * 16)
print('\n\n')
print('==> [%s] : Find tst tst precondition in run.cfg' % ('TODO'))
fd = open(run_cfg_path, 'r')
lines = []
if fd:
    lines = fd.readlines()
    fd.close()
    pass

last_pre = ''
for line in lines:
    m = r'-f .*/pre_.*\.tst'
    res = re.findall(m, line)
    if len(res):
        last_pre = res[0]
        pass
    else:
        m = at_tst
        res = re.findall(m, line)
        if len(res):
            break
        else:
            pass
        pass
    pass

if last_pre:
    print('==> [%s] : Find tst tst precondition in run.cfg : \n %s' % ('PASS', last_pre))
    case['precondition'].append(last_pre)
    pass
else:
    print('==> [%s] : Find tst tst precondition in run.cfg' % ('FAIL'))
    pass

print('--' * 16)
print('\n\n')
print('==> [%s] : Load tst file(%s) contains at case(%s) ' % ('TODO', at_tst, at_case) )

fd = open(case['fn_at_tst'], 'r')
lines = []
if fd:
    lines = fd.readlines()
    fd.close()
    pass

before_case = True
before_nextcase = True
overwrite_pre = True
for linenum, line in enumerate(lines):

    if line.startswith('#'):
        continue

    # precondition
    m = r'-f .*/pre_(.*)\.tst'
    res = re.findall(m, line)
    if len(res):
        if overwrite_pre:
            overwrite_pre = False
            print('--> empty precondition')
            case['precondition'] = []
        z = case['precondition']
        if not before_case:
            z = case['postcondition']
            continue
            #pass
        #

        if not line.startswith('#'):
            if line not in z:
                z.append(line)
                print('==> add precondition (%d : %s)' % (linenum, res[0]))
        continue
    else:
        pass

    #pre-jobs
    m = '-tc.*%s.*' % at_case
    res = re.findall(m, line)
    if len(res):
        case['jobs'].append(line)
        before_case = False
        print('==> Find case (%d : %s)' % (linenum, line))
        #break
        continue
    else:
        pass

    #
    m = '-nc.*'
    res = re.findall(m, line)
    if len(res):
        z = case['pre_jobs']
        if not before_case:
            z = case['after_jobs']
            if not before_nextcase:
                continue
            pass

        if len(z):
            last = z[-1]
            if last == line:
                continue
            pass
        z.append(line)
        continue
    else:
        pass

    #
    m = '-tc.*'
    res = re.findall(m, line)
    if len(res):
        if before_case:
            #case['precondition'] = []
            pass
        else:
            before_nextcase = False
            #case['after_jobs'].append(res[0])
            pass
            #break
        continue
    else:
        pass

    if line.startswith('-pre_cmdline'):
        case['pre_check'].append(line.strip())
        continue
    else:
        pass

    if len(line.strip()) and not line.startswith('#'):
        if before_case:
            case['pre_jobs'].append(line)
            pass
        else:
            if before_nextcase:
                case['after_jobs'].append(line)
            else:
                if line.startswith('-label'):
                    case['after_jobs'].append(line)
            pass

pprint(case)

### process raw data
print('--' * 16)
print('\n\n')
print('==> Process Raw Data' )

#precondition
prec = case['precondition']
d = []
prec.reverse()
for v in prec:
    if v not in d:
        d.append(v)
        if v.find('pre_tr') > 0:
            pass
        else:
            break

d.reverse()
case['precondition'] = d

# pre_jobs
prej = case['pre_jobs']
d = []
prej.reverse()

vlist = []

vlist_uniq = []
vlist_duplicate = []
for v in prej:
    m = r'(\w*)\s*=(.*)'
    res = re.findall(m, v)
    if len(res):
        key, val = res[0]
        if key not in vlist:
            vlist.append(key)
            vlist_uniq.append(key)
            d.append(v)
            pass
        else:
            vlist_duplicate.append(key)
            if key in vlist_uniq:
                vlist_uniq.remove(key)

            continue

    if v not in d:
        d.append(v)
        pass

d.reverse()
case['pre_jobs'] = d
print('==>Duplicate variables : %s ' % str(vlist_duplicate) )
print('==>Uniq variables : %s ' % str(vlist_uniq) )


#
# after_jobs
prej = case['after_jobs']
d = []
prej.reverse()

vlist = []
for v in prej:
    m = r'(\w*)\s*=(.*)'
    res = re.findall(m, v)
    if len(res):
        key, val = res[0]
        if key not in vlist:
            vlist.append(key)
            d.append(v)
            pass
        else:
            continue

    if v not in d:
        d.append(v)
        pass

d.reverse()
case['after_jobs'] = d

pprint(case)



# save to file
#
"""
case = {
    'fn_tl_case' : '',
    'fn_at_run_cfg' : '',
    'fn_at_tst' : '',
    #
    'precondition' : [],
    'pre_jobs' : [],
    'premise' : [],
    'jobs' : [],
    'after_jobs' : [],
    'postcondition' : [],
}


"""
print('--' * 16)
print('\n\n')
print('==> case content' )
comment = """
#
# The data is collecting from file : %s
#
""" % (case['fn_at_tst'])
postfiles = ''
rpcfiles = ''

pre = '-SUITE_PRECONDITION_BEGIN\n%s\n-SUITE_PRECONDITION_END\n\n' % ('\n'.join(case['precondition']) )
pre_jobs = '-SUITE_PRE_JOBS_BEGIN\n%s\n-SUITE_PRE_JOBS_END\n\n' % ('\n'.join(case['pre_jobs']) )
pre_check = '-CASE_PRE_CHECK_BEGIN\n%s\n-CASE_PRE_CHECK_END\n\n' % ('\n'.join(case['pre_check']) )

premise = '-CASE_DEPENDENT_BEGIN\n%s\n-CASE_DEPENDENT_END\n\n' % ('\n'.join(case['premise']) )

jobs = '-CASE_BEGIN\n%s\n-CASE_END\n\n' % ('\n'.join(case['jobs']) )
after_jobs = '-CASE_AFTER_JOBS_BEGIN\n%s\n-CASE_AFTER_JOBS_END\n\n' % ('\n'.join(case['after_jobs']) )
postcondition = '-SUITE_POSTCONDITION_BEGIN\n%s\n-SUITE_POSTCONDITION_END\n\n' % ('\n'.join(case['postcondition']) )

pre_jobs = '-CASE_PRE_JOBS_BEGIN\n\n\n-CASE_PRE_JOBS_END\n\n'

z = [comment, postfiles, rpcfiles, pre, pre_jobs, pre_check, premise, jobs, after_jobs, postcondition]

o = "\n\n###############################\n".join(z)

fmt = """
#
#Import from file : %s
#

################################################################################
-SUITE_PRECONDITION_BEGIN
%s
-SUITE_PRECONDITION_END

################################################################################
-SUITE_PRE_JOBS_BEGIN
%s
-SUITE_PRE_JOBS_END

################################################################################
-CASE_PRE_JOBS_BEGIN
%s
-CASE_PRE_JOBS_END

################################################################################
-SUITE_PRE_CHECK_BEGIN
%s
-SUITE_PRE_CHECK_END

################################################################################
-CASE_PRE_CHECK_BEGIN
%s
-CASE_PRE_CHECK_END

################################################################################
-CASE_POST_FILES_BEGIN
%s
-CASE_POST_FILES_END

################################################################################
-CASE_TR69RPC_FILES_BEGIN
%s
-CASE_TR69RPC_FILES_END

################################################################################
-CASE_DEPENDENT_BEGIN
%s
-CASE_DEPENDENT_END

################################################################################
-CASE_BEGIN
%s
-CASE_END

################################################################################
-CASE_AFTER_JOBS_BEGIN
%s
-CASE_AFTER_JOBS_END

################################################################################
-SUITE_POSTCONDITION_BEGIN
%s
-SUITE_POSTCONDITION_END

"""

o = fmt % (case['fn_at_tst'],
           '\n'.join(case['precondition']),
           '\n'.join(case['pre_jobs']),
           '',
           '\n'.join(case['pre_check']),
           '',
           '',
           '',
           '\n'.join(case['premise']),
           '\n'.join(case['jobs']),
           '\n'.join(case['after_jobs']),
           '\n'.join(case['postcondition']),
)


#print(o)


# save to file
fn = case['fn_tl_case']
fd = open(fn, 'w')
if fd:
    fd.write(o)
    fd.close()
    print('==> [DONE] update testlink case(%s)' % fn)


