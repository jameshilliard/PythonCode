#!/bin/env python
#Copyright ReportLab Europe Ltd. 2000-2004
#see license.txt for license details
#history http://www.reportlab.co.uk/cgi-bin/viewcvs.cgi/public/reportlab/trunk/reportlab/demos/tests/testdemos.py
__version__=''' $Id: testdemos.py,v 1.1.1.1 2006/03/20 16:48:25 wpoxon Exp $ '''
__doc__='Test all demos'
_globals=globals().copy()
import os, sys
from reportlab import pdfgen

for p in ('pythonpoint/pythonpoint.py','stdfonts/stdfonts.py','odyssey/odyssey.py', 'gadflypaper/gfe.py'):
    fn = os.path.normcase(os.path.normpath(os.path.join(os.path.dirname(pdfgen.__file__),'..','demos',p)))
    os.chdir(os.path.dirname(fn))
    execfile(fn,_globals.copy())