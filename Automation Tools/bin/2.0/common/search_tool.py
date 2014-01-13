#!/usr/bin/env python
# coding=utf-8

from optparse import OptionParser
from pprint import pprint
from pprint import pformat
import re
import xlrd


class AT_script_search:
    AT_Scripts_f = '/root/automation/docs/Manual/AT_Scripts.xlsx'
    with_vars = False
    
    def __init__(self, with_vars, file=None):
        if file:
            self.AT_Scripts_f = file
        self.with_vars = with_vars
            
        
    def search_by_kw(self, kw):
        def inred(s):
            # echo -e "\033[43;34m something here \033[0m"
            return"%s[43;34m%s%s[0m" % (chr(27), s, chr(27))
        
        def blockit(stri):
            strBuilder = """
"""
            
            for line in stri.split('\n'):
                strBuilder += "\t" + line + '\n'
                
            return strBuilder
        
        """
        0  u'ID', 
        1  u'Category', 
        2  u'Tool', 
        3  u'Invoked count', 
        4  u'Description', 
        5  u'Script Samples', 
        6  u'Keyword Samples', 
        7  u'Keyword Lists', 
        8  u'Keywords Number', 
        9  u'Implement Time (Hour)', 
        10 u'Developer', 
        11 u'subtools and variable'
        
        #                     print '\n' + '*' * 50 + '\n'
        # cell_A1 = table.cell(0,0).value
        # cell_C4 = table.cell(2,3).value
        # cell_A1 = table.row(0)[0].value
        # cell_A2 = table.col(1)[0].value
        #         # ncols = table.ncols
        #         print table.row_values(0)
         
        # print table.col_values(0)
        """
        
        print 'to search [%s] in [%s]' % (kw, self.AT_Scripts_f)
        data = xlrd.open_workbook(self.AT_Scripts_f)
        table = data.sheet_by_index(0)
         
        nrows = table.nrows

        for i in range(nrows):
            rowi = table.row_values(i)
            
            ID, Category, Tool, \
            Invoked_count, Description, Invoked_variable, Script_Samples, \
            Keyword_Samples, Keyword_Lists, Keywords_Number, \
            Implement_Time, Developer, subtools_and_variable\
 = rowi[0], rowi[1], rowi[2], rowi[3], rowi[4], rowi[5], rowi[6], rowi[7], rowi[8], rowi[9], rowi[10], rowi[11], rowi[12]

            match_count = 0
            
            for k in kw:
                for s in ID, Category, Tool, \
                Invoked_count, Description, Invoked_variable, Script_Samples, \
                Keyword_Samples, Keyword_Lists, Keywords_Number, \
                Implement_Time, Developer:
               
                    if  pformat(s).lower().find(k.lower()) > -1:
                        match_count += 1
                        break
                        
            if match_count == len(kw) :
                print '\n' + inred(' ' * 450) + '\n'
                        
#                 print '%s : %s' % (inred('ID'), ID)
#                 print '%s : %s' % (inred('Category'), Category)
                print '%s : %s\n' % (inred('Tool'), blockit(Tool))
                
#                 print '%s : %s' % (inred('Invoked_count'), Invoked_count)
                print '%s : \n%s\n' % (inred('Description'), blockit(Description))
                print '%s : \n%s\n' % (inred('Invoked_variable'), blockit(Invoked_variable))
                print '%s : \n%s\n' % (inred('Script_Samples'), blockit(Script_Samples))
                
                print '%s : \n%s\n' % (inred('Keyword_Samples'), blockit(Keyword_Samples))
                print '%s : \n%s\n' % (inred('Keyword_Lists'), blockit(Keyword_Lists))
#                 print '%s : %s\n' % (inred('Keywords_Number'), blockit(Keywords_Number))
                
#                 print '%s : %s\n' % (inred('Implement_Time'), blockit(Implement_Time))
                print '%s : %s\n' % (inred('Developer'), blockit(Developer))
                if self.with_vars:
                    print '%s : \n%s\n' % (inred('subtools_and_variable'), blockit(subtools_and_variable))

        pass
    
def main():
    usage = "too young too simple , sometime naive \n"

    parser = OptionParser(usage=usage)

    parser.add_option("-k", "--keyword", dest="keyword", action="append", help="the keyword to be searched in at_script excel")
    parser.add_option("-f", "--file", dest="file", help="the file to be searched in ")
    parser.add_option("-v", "--with_vars", dest="with_vars", action='store_true', default=False, help="output with vars")

    (options, args) = parser.parse_args()

    if not len(args) == 0:
        print args
    
    keyword = None
    with_vars = False
    
    if options.keyword:
        keyword = options.keyword
        
    if options.with_vars:
        with_vars = options.with_vars
        
    print 'keyword : %s' % (keyword)
    
    if options.file:
        ass = AT_script_search(with_vars=with_vars, file=options.file)
    else:
        ass = AT_script_search(with_vars=with_vars)
        
    ass.search_by_kw(keyword)
    
    pass

if __name__ == '__main__':
    main()
