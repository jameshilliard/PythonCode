#Copyright ReportLab Europe Ltd. 2000-2004
#see license.txt for license details
#history http://www.reportlab.co.uk/cgi-bin/viewcvs.cgi/public/reportlab/trunk/reportlab/platypus/__init__.py
__version__=''' $Id: __init__.py,v 1.1.1.1 2006/03/20 16:48:34 wpoxon Exp $ '''
__doc__=''
from reportlab.platypus.flowables import Flowable, Image, Macro, PageBreak, Preformatted, Spacer, XBox, \
                        CondPageBreak, KeepTogether, TraceInfo, FailOnWrap, FailOnDraw, PTOContainer
from reportlab.platypus.paragraph import Paragraph, cleanBlockQuotedText, ParaLines
from reportlab.platypus.paraparser import ParaFrag
from reportlab.platypus.tables import Table, TableStyle, CellStyle, LongTable
from reportlab.platypus.frames import Frame
from reportlab.platypus.doctemplate import BaseDocTemplate, NextPageTemplate, PageTemplate, ActionFlowable, \
                        SimpleDocTemplate, FrameBreak, PageBegin, Indenter
from xpreformatted import XPreformatted
