#!/usr/bin/python
import re, os, sys
from pprint import pprint
from pprint import pformat

# main_dir = '$SQAROOT/main'
# sys.path.append(os.path.expandvars(main_dir))

from GUI_validator.GUI_validator import GUI_validator

def main():
    print 'setting tr069 via selenium'
    
    try:
        gv = GUI_validator(local=True, debug=True)
        rc = gv.tr_setting()
        
        if rc:
            print 'setting passed'
            sys.exit(0)
        else:
            print 'setting failed'
            sys.exit(1)
            
    except Exception, e:
        print str(e)
        sys.exit(1)

if __name__ == '__main__':
#     os.environ.update({
#                        'U_CUSTOM_CURRENT_CASE_ID':'00000000',
#                        'U_CUSTOM_CURRENT_FW_VER':'aaaa',
#                        })
#     
#     os.environ.update({
#                        'U_DUT_HTTP_USER':'admin',
#                        'U_DUT_HTTP_PWD':'1',
#                        'G_PROD_IP_BR0_0_0':'192.168.0.1',
#                        'U_DUT_TYPE':'CTLC2KA',
#                        })
    main()
