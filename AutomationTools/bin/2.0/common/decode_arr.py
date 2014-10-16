#!/usr/bin/python
#import re
from pprint import pprint
from optparse import OptionParser
import  re

class decode_arr():
    def extend_arr(self, array):
        '''
        '''
    
        folded_arr = array
        
        extracted_arr = []
        
        for elem in folded_arr:
            elems = elem.split('-')
            if len(elems) == 1:
                extracted_arr.append(int(elems[0]))
            elif len(elems) == 2:
                start_p = elems[0]
                end_p = elems[1]
                for e in range(int(start_p), int(end_p) + 1):
                    extracted_arr.append(int(e))
        extracted_arr.sort() 
        return extracted_arr
    
    def load_ports(self, input_file, p_type):
        '''
        '''
        #print 'in function py->load_ports from ', input_file
        loaded_arr = []
        
        if p_type.find('|') > 0:
            #    294/udp  open|filtered
            p_type = p_type.replace('|', '\|')
            m_str = r'(\d*)/\w* *' + p_type
        else:
            m_str = r'Discovered *' + p_type + ' *port *(\d*)\/'
        #print m_str
        #m = rm_str
        fn = open(input_file, 'r')
        lines = fn.readlines()
        fn.close()
        
        for line in lines:
            rc = re.findall(m_str, line)
            if len(rc) > 0:
                #print 'MATCHED !'
                c_p = rc[0]
                #print 'c_p', c_p
                loaded_arr.append(int(c_p))
            #else:
                #print line
                
        loaded_arr.sort()
        return loaded_arr
    
    def load_filtered_ports(self, input_file):
        '''
        '''
        m_total_ports = r'(\d*) *total *ports'
        
        fn = open(input_file, 'r')
        lines = fn.readlines()
        fn.close()
        
        total_count = 65535
        
        for line in lines:
            rc_count = re.findall(m_total_ports, line)
        
            if len(rc_count) > 0:
                total_count = rc_count[0]
            
        open_ports = self.load_ports(input_file, 'open')
        
        closed_ports = self.load_ports(input_file, 'closed')    
        
        all_range = '1-' + str(total_count)
        
        all_ports = self.extend_arr([all_range])
        
        for i in open_ports:
            all_ports.remove(i)
            
        for i in closed_ports:
            all_ports.remove(i)
                
        all_ports.sort()
        
        return all_ports
    
    def pprint_arr(self, array):
        '''
        '''
        pretty_arr = []
        ugly_arr = array
        
        pretty_idx = 0
        
        for idx in range(len(ugly_arr)):
            if idx == 0:
                pretty_idx = 0
                pretty_arr.append(ugly_arr[idx])
            elif idx > 0 and idx <= len(ugly_arr) - 1:
                ''
                if ugly_arr[idx] - ugly_arr[idx - 1] > 1:
                    ''
                    pretty_idx += 1
                    pretty_arr.append(str(ugly_arr[idx]))
                elif ugly_arr[idx] - ugly_arr[idx - 1] == 1:
                    ''
                    m = r'(-\d*)'
                    
                    rc = re.findall(m, str(pretty_arr[pretty_idx]))
                    
                    if len(rc) > 0:
                        pretty_arr[pretty_idx] = str(pretty_arr[pretty_idx]).replace(rc[0], '-' + str(ugly_arr[idx]))
                    else:
                        pretty_arr[pretty_idx] = str(pretty_arr[pretty_idx]) + '-' + str(ugly_arr[idx])
            
        return pretty_arr
    
    def println_arr(self, array):
        """
        to print an array in one line
        """
        s = ''
        for e in array:
            s += ' ' + str(e)
            
        print 'array in line |' + s
        
    def all_filtered_except(self, open, close, arr_filtered, filtered, snbf=False):
        """
        open_ports closed_ports only contains those ports in arr_filtered
        """
        
        arr_sbfbn = []
        
        if not snbf:
            open.extend(close)        
            
            for i in open:
                if i not in arr_filtered:
                    arr_sbfbn.append(int(i))
        else:
            open.extend(close)        
            
            for i in filtered:
                if i  in arr_filtered:
                    arr_sbfbn.append(int(i))
        
        arr_sbfbn.sort()
        return arr_sbfbn
    
    def all_not_filtered_except(self, open, close, arr_filtered, filtered, snbf=False):
        """
        the ones in arr_filtered should not be in open_ports or closed_ports
        """
        arr_sbfbn = []
        
        if not snbf:
            open.extend(close)        
            
            for i in arr_filtered:
                if i in open:
                    arr_sbfbn.append(int(i))
        else:
            open.extend(close)        
            
#            for i in open:
#                if i in arr_filtered:
#                    arr_sbfbn.append(int(i))
                    
            for i in filtered:
                if not i in arr_filtered:
                    arr_sbfbn.append(int(i))
        
        arr_sbfbn.sort()
        return arr_sbfbn
        
def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    
    parser = OptionParser(usage=usage)

    parser.add_option("-a", "--array", dest="arr",
                            help="The array to operate on")
    parser.add_option("-f", "--file", dest="file",
                            help="The file that contains array elems")
    parser.add_option("--open_ports", dest="open_ports",
                            help="The file that contains open_ports")
    parser.add_option("--closed_ports", dest="closed_ports",
                            help="The file that contains closed_ports")
    parser.add_option("--filtered_ports", dest="filtered_ports",
                            help="The file that contains filtered_ports")
    parser.add_option("--arr_filtered", dest="arr_filtered",
                            help="The file that contains arr_filtered")
    parser.add_option("--snbf", dest="snbf", action="store_true",
                            help="The file that contains arr_filtered")
    parser.add_option("-t", "--type", dest="type",
                            help="decode type")

    (options, args) = parser.parse_args()

    return options, args
    
def main():
    opts, args = parseCommandLine()
    
    #pprint(args)
    
    arr = ['0', '1-5', '7', '8', '11', '41-44', '2000-60055', '3000-4000', '1200-1204']
    open_ports = []
    closed_ports = []
    filtered_ports = []
    arr_filtered = []
    snbf = False
    
    if opts.snbf:
        snbf = True
    
    if opts.arr:
        arr = []
        for i in opts.arr.split():
            arr.append(i)
            
    if opts.type:
        type = opts.type
            
    if opts.file:
        #print 'read array items from : ', opts.file
        arr = []
        
        fn = opts.file
        fd = open(fn, 'r')
        lines = fd.readlines()
        fd.close()
        
        for line in lines:
            for i in line.split():
                arr.append(i)
                
    if opts.open_ports:
        #
        arr = []
        
        fn = opts.open_ports
        fd = open(fn, 'r')
        lines = fd.readlines()
        fd.close()
        
        for line in lines:
            for i in line.split():
                open_ports.append(i)
                
    if opts.closed_ports:
        #
        arr = []
        
        fn = opts.closed_ports
        fd = open(fn, 'r')
        lines = fd.readlines()
        fd.close()
        
        for line in lines:
            for i in line.split():
                closed_ports.append(i)
                
    if opts.arr_filtered:
        #
        arr = []
        
        fn = opts.arr_filtered
        fd = open(fn, 'r')
        lines = fd.readlines()
        fd.close()
        
        for line in lines:
            for i in line.split():
                arr_filtered.append(i)
                
    if opts.filtered_ports:
        #
        arr = []
        
        fn = opts.filtered_ports
        fd = open(fn, 'r')
        lines = fd.readlines()
        fd.close()
        
        for line in lines:
            for i in line.split():
                filtered_ports.append(i)
    
    
    arr_decoder = decode_arr()
    
    if type == 'extend':
        arr = arr_decoder.extend_arr(arr)
    
        pprint(arr)
    elif type == 'load':
        p_type = args[0]
        
        if not p_type == 'filtered':
            loaded_arr = arr_decoder.load_ports(fn, p_type)
        else:
            loaded_arr = arr_decoder.load_filtered_ports(fn)
        
        arr_decoder.println_arr(loaded_arr)
        
    elif type == 'pprint':
        arr = arr_decoder.extend_arr(arr)
        arr = arr_decoder.pprint_arr(arr)
    
        for index, i in enumerate(arr):
            print i,
            if (index + 1) % 18 == 0:
                print
        
    elif type == 'all_filtered_except':
        
        if snbf:
        
            arr_sbfbn = arr_decoder.all_filtered_except(open_ports, closed_ports, arr_filtered, filtered_ports, snbf=True)
        else:
            arr_sbfbn = arr_decoder.all_filtered_except(open_ports, closed_ports, arr_filtered, filtered_ports)
        arr_sbfbn = arr_decoder.pprint_arr(arr_sbfbn)
    
        arr_decoder.println_arr(arr_sbfbn)
        
    elif type == 'all_not_filtered_except':
        
        if snbf:
            arr_sbfbn = arr_decoder.all_not_filtered_except(open_ports, closed_ports, arr_filtered, filtered_ports, snbf=True)
        else:
            arr_sbfbn = arr_decoder.all_not_filtered_except(open_ports, closed_ports, arr_filtered, filtered_ports)
        arr_sbfbn = arr_decoder.pprint_arr(arr_sbfbn)
    
        arr_decoder.println_arr(arr_sbfbn)

if __name__ == '__main__':
    """
    main entrance
    """
    main()
