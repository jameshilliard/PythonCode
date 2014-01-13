#!/usr/bin/python
from optparse import OptionParser    
import os,re
from pprint import pprint

def env2str(s) :
    """
    """
    m = r'\${\w*}'
    
    rc = re.findall(m, s)
    
    if len(rc) != 0 :
        for i in range(len(rc)):
            s=s.replace(rc[i],os.popen('echo "' + rc[i] + '"').read().strip())
    
    return os.popen('echo "' + s + '"').read().strip()

def str2raw(s) :
    """
    """
    s = str(s)
    if s.startswith('"') and s.endswith('"') :
        return s[1:-1]
    if s.startswith("'") and s.endswith("'") :
        return s[1:-1]
    return s

def safe2Int(s) :
    """
    """
    rc = None
    try :
        rc = int(s)
    except :
        rc = None
    return rc

def safe2Float(s) :
    """
    """
    rc = None
    try :
        rc = float(s)
    except :
        rc = None
    return rc


def parseArr(s) :
    """
    ['1','10'] => ['1','10']
    [1,10] => ['1','10']
    [1..3] => ['1','2','3']


    """

    rc = []
    if s.startswith('[') and s.endswith(']') :
        s = s[1:-1]
        z = s.split(',')
        for p in z :
            if p.find('..') >= 0 :
                zz = p.split('..')
                if len(zz)==2 :
                    b = str2raw(zz[0])
                    e = str2raw(zz[1])
                    b = safe2Int(b)
                    e = safe2Int(e)
                    if not b==None and not e==None and (e >= e):
                        for i in range(b,e+1) :
                            rc.append(str(i))

            else :
                p = str2raw(p)
                rc.append(str(p))
    pass
    return rc

#print parseArr("['6','1'..'10',100..102,abc,aaa..bbb]")


def matchEqual(rule) :
    """
    """
    rc = False
    z = ['<','=','>']
    opr = rule['operation']
    key = rule['object']
    val = rule['parameter']

    reverse = False
    if opr :
        if opr.startswith('!') :
            opr = opr[1:]
            reverse = True
        if '=='==opr or '='==opr :
            rc = (key==val)
            pass
        elif '~='==opr :
            key = env2str(str2raw(key))
            val = env2str(str2raw(val))
            
            key=key.lower()
            val=val.lower()
            #if key and val :
            rc = (key==val)
            pass

        key = safe2Int(key)
        val = safe2Int(val)
        if not key==None and not val==None :
            if '>'==opr :
                rc = (key > val)
                pass
            elif '<'==opr :
                rc = (key < val)
                pass
            elif '>='==opr :
                rc = (key >= val)
                pass
            elif '<='==opr :
                rc = (key <= val)
                pass
    pass

    if reverse : rc = not rc

    return rc

def matchLenIn(rule) :
    """
    """
    rc = False
    opr = rule['operation']
    key = rule['object']
    val = rule['parameter']

    reverse = False
    if opr :
        if opr.startswith('!') :
            opr = opr[1:]
            reverse = True

    key = len(key)
    if 'len_eq' == opr :
        val = safe2Int(val)
        if val != None:
            rc = (key==val)
        pass
    elif 'len_more' == opr:
        val = safe2Int(val)
        if val != None:
            rc = (key>val)
        pass
    else :
        z = parseArr(val)
        if z : rc = (str(key) in z)

    if reverse : rc = not rc
    return rc


def matchIn(rule) :
    """
    """
    rc = False
    opr = rule['operation']
    key = rule['object']
    val = rule['parameter']

    reverse = False
    if opr :
        if opr.startswith('!') :
            opr = opr[1:]
            reverse = True
    z = parseArr(val)
    if z : rc = (key in z)

    if reverse : rc = not rc
    return rc

def matchSubIn(rule) :
    """
    """
    rc = False
    opr = rule['operation']
    key = rule['object']
    val = rule['parameter']

    reverse = False
    if opr :
        if opr.startswith('!') :
            opr = opr[1:]
            reverse = True
    #
    z1 = key.split(',')
    
    for z1_index in range(len(z1)):
        z1[z1_index]=z1[z1_index].strip()

    #print 'key:'
    #pprint(z1)

    z2 = parseArr(val)

    for z2_index in range(len(z2)):
        z2[z2_index]=z2[z2_index].strip()
    #print 'value:'
    #pprint(z2)

    d1 = list(set(z1) - set(z2))

    if len(d1)==0 : rc = True
    if reverse : rc = not rc
    return rc

def matchEqInRange(rule) :
    """
    """
    rc = False
    opr = rule['operation']
    key = rule['object']
    val = rule['parameter']
    reverse = False
    if opr :
        if opr.startswith('!') :
            opr = opr[1:]
            reverse = True

    val = safe2Float(val)
    key = safe2Float(key)
    if not key==None and not val==None :
        #
        m = r'\((.*)\)'
        res = re.findall(m,opr)
        delta = 0
        #print res
        if len(res) :
            rg = res[0]
            if rg.endswith('%') :
                rg = rg[:-1]
                rg = safe2Float(rg)
                if rg :
                    delta = val * (0.01*rg)
            else :
                rg = safe2Float(rg)
                delta = rg

        d = abs(key - val)
        print d,delta
        if d <= delta : rc = True


    if reverse : rc = not rc
    return rc

def matchRex(rule) :
    """
    """
    rc = False
    opr = rule['operation']
    key = rule['object']
    val = rule['parameter']

    reverse = False
    val = str2raw(val)
    if opr :
        if opr.startswith('!') :
            opr = opr[1:]
            reverse = True

        if opr == 'match' :
            m = val
            res = re.match(m,key)
            if res : rc = True
        elif opr == 'find' :
            m = val
            res = re.findall(m,key)
            if len(res) > 0 : rc = True

    if reverse : rc = not rc
    return rc

def pickRules(rules,rule_given,rule_index):
    #print rule_index
    rule_got=[]
    for r_given in rule_given:
        is_exist=False
        for r in rules:
            if r_given == r['object'] and r['index'] == int(rule_index):
                #print 'r index is %d ' % (r['index'])
                #print 'rule_index is %d ' % (int(rule_index))
                is_exist=True
                rule_return={}
                
                if os.getenv(r['object'][1:]) == None:
                    print '-| AT_ERROR : ' + r['object'] + ' not defined !'
                    exit(1)
                if r['parameter'].startswith('$'):
                    if os.getenv(r['parameter'][1:]) == None:
                        print '-| AT_ERROR : ' + r['parameter'] + ' not defined !'
                        exit(1)
                    
                rule_return['object'] =env2str(r['object'])
                rule_return['operation']=env2str(r['operation'])
                rule_return['parameter']=env2str(r['parameter'])
                rule_return['object_ori'] =r_given
                rule_return['parameter_ori']=r['parameter']
                rule_got.append(rule_return)
        #print 'is there a rule matched ? : %s' % (str(is_exist))
        if not is_exist:
            print 'warning : rule %s not found ! ' % (r_given)
            rule_return={}
            rule_return['object'] ='NONE'
            rule_return['operation']='NONE'
            #rule_return['parameter']=env2str(r['parameter'])
            rule_return['object_ori'] =r_given
            #rule_return['parameter_ori']=r['parameter']
            rule_got.append(rule_return)
    return rule_got

def loadRulesFromFile(ruleFile , rule_given):
    rules=[]
    ruleContainer=open(ruleFile)
    
    for line in ruleContainer.readlines():
        for r_given in rule_given :
            line = line.strip()
            if len(line) and not line.startswith('#'):
                if line.find(r_given) != -1:
                    print 'found rule : %s' % (line)
                    
                    k_opr_v = line.split()
                    
                    k=k_opr_v[0]
                    
                    opr=k_opr_v[1]
                    
                    v=' '.join(k_opr_v[2:])
                    
                    if not k : k = ''
                    if not opr : opr = ''
                    if not v : v = ''
            
                    index = 1
                    for existingRule in rules:
                        if k == existingRule['object']:
                            index = index + 1
                    rule = {}
                    rule['object'] = k
                    rule['operation'] = opr
                    rule['parameter'] = v
                    rule['index'] = index

                    rules.append(rule)
                #else:
                #    print ''
                #    pass
                    
                
               
    ruleContainer.close()
    #print '-------function out---------------'
    return rules

def getResults(rule_got):
    results=[]
    
    for r_got in rule_got :
        opr = r_got['operation']
        opr = str2raw(opr)
        
        reverse = False
        if opr and opr != 'NONE':
            if opr.startswith('!') : opr = opr[1:] 
            if opr.find('eq_in_range') >= 0 : opr = 'eq_in_range'
            #r_got['key'] = '1'

            method = hdlrs.get(opr)
                    #print 'find method : ',method,opr
            if method :
                r_got['result'] = None
                rc = method(r_got)
                r_got['result'] = rc
                
                rule_result={}      
                        #if rc:
                rule_result['object'] = r_got['object_ori'] +'('+r_got['object']+')'
                rule_result['operation'] = r_got['operation']
                rule_result['parameter'] = r_got['parameter_ori'] +'('+r_got['parameter']+')'
                rule_result['result'] = str(r_got['result'])
                        
                results.append(rule_result)
                #pprint(r_got)
        else:
            #print 'this rule is not found ------------------------------------------------------------------------------'   
            rule_result={}      
                        #if rc:
            rule_result['object'] = r_got['object_ori']
            rule_result['operation'] = r_got['operation']
            #rule_result['parameter'] = r_got['parameter_ori'] +'('+r_got['parameter']+')'
            rule_result['result'] = 'NONE'  
            results.append(rule_result)  
    return results

def createLog(log,results):
    '''
    '''
    final_result='TRUE'
    if os.path.exists(log):
        if os.path.isfile(log):
            #print 'delete existing log : ' + log
            os.popen('rm -f "' + log + '"')
            #pass
        else:
            if os.path.isdir(log):
                print '-|AT_ERROR : the given rule file is actually a Directory'
                exit(1)
    else:
        #head,tail=os.path.split('/')
        #print 'head is %s and tail is %s' % (head,tail)
        print 'creating new log file : ' + log
        #exit(1)
        
#        [{'object': '$U_TR069_WANDEVICE_INDEX(1)',
#          'operation': '!=',
#          'parameter': '2',
#          'result': 'True'}]
    for result in results:
        if result['result'] == 'NONE':
            final_result = 'NONE'
            break
        elif result['result'] == 'False':
            final_result = 'FALSE'
            break
        
    print 'final result : %s ' % (final_result)
       
    output=open(log,'a')
    output.write(final_result)
    output.write('\n')
    output.close()   
    
    for result in results:
        output=open(log,'a')
        if result['result'] != 'NONE':
            output.write(result['result'] + '    ' + result['object'] + '    ' + result['operation'] + '    ' + result['parameter'])
            output.write('\n')
        else:
            output.write(result['result'] + '    ' + result['object'] )
            output.write('\n')
        output.close()

hdlrs = {
'~=' : matchEqual,
'==' : matchEqual,
'=' : matchEqual,
'>' : matchEqual,
'<' : matchEqual,
'>=' : matchEqual,
'<=' : matchEqual,
'in' : matchIn,
'subin' : matchSubIn,
'eq_in_range' : matchEqInRange,
'len_eq' : matchLenIn,
'len_in' : matchLenIn,
'len_more' : matchLenIn,
'match' : matchRex,
'find' : matchRex,
}

def main() :
    """
    """
    print 'now we are in python ...'
    usage = "usage: %prog -f/--file rule_file -r/--rule rule -o/--output output_file\n"
    
    usage += "Arguments :\n"
    usage += "-f/--file              : the rule file , contains all the rules using in tr test \n"
    usage += "-r/--rule              : the rule currently to be search from the rule file \n"
    usage += "-i/--index             : the index of the rule ,starting from 1 \n"
    usage += "-o/--output            : the output log file \n"
    
    rule_given=[]
    rule_index=1
    
    parser=OptionParser(usage=usage)
    parser.add_option("-f", "--file", dest="file_path",help="the file that contains all the rules" )
    parser.add_option("-r", "--rule", action="append", dest="rule_given",help="the rule currently being searched from the rule file" )
    parser.add_option("-o", "--output", dest="log_path",help="the out put file path" )
    parser.add_option("-i", "--index", dest="rule_index",help="the index of rule you want it to match" )

    (options, args) = parser.parse_args()

    rule_index_env=os.getenv('TMP_COMPARE_RULE_INDEX')

    if rule_index_env != None:
        print 'TMP_COMPARE_RULE_INDEX defined in os env '
        rule_index=rule_index_env
    else:
        print 'TMP_COMPARE_RULE_INDEX not defined in os env  '

    if options.rule_index:
        rule_index=options.rule_index
        
    if options.file_path and options.rule_given and options.log_path :
        rule_file = options.file_path
        
        log_file = options.log_path
        
        for r in range(len(options.rule_given)):
            rule_given.append(options.rule_given[r])
            
        print 'the given rules' + '*'*25
        pprint(rule_given)
        print '\n'
    else:
        print 'AT_ERROR : there must be a rule file , a given rule and a output log file !'
        print usage
        exit(1)
        
    if os.path.exists(rule_file):
        if os.path.isfile(rule_file):
            pass
        else:
            if os.path.isdir(rule_file):
                print '-|AT_ERROR : the given rule file is actually a Directory'
                exit(1)
    else:
        print '-|AT_ERROR : no such file or Directory :' + rule_file
        exit(1)

    #os.putenv("U_TR069_WANDEVICE_INDEX","1")
    #os.putenv("U_TR069_LANDEVICE_INDEX","1")
    #os.putenv("U_TR069_WANDEVICE_INDEX_VALUE","1")
    #os.putenv("U_TR069_RATE","15")
    
    
    #result='TRUE'
    
    
    rules = loadRulesFromFile(rule_file,rule_given)
    
    print 'the rules          ' + '*-'*25
    pprint(rules)
    print '\n'
    # handle rules
    rule_got=pickRules(rules,rule_given,rule_index)
    
    print 'the rules got      ' + '*-'*25
    pprint(rule_got)
    print '\n'
    
    results=getResults(rule_got)
    
    print 'the results        ' + '*-'*25
    pprint(results)
    print '\n'
    
    createLog(log_file,results)
    
main()
