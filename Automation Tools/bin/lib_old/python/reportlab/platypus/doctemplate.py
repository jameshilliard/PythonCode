#Copyright ReportLab Europe Ltd. 2000-2004
#see license.txt for license details
#history http://www.reportlab.co.uk/cgi-bin/viewcvs.cgi/public/reportlab/trunk/reportlab/platypus/doctemplate.py

__version__=''' $Id: doctemplate.py,v 1.1.1.1 2006/03/20 16:48:33 wpoxon Exp $ '''

__doc__="""
This module contains the core structure of platypus.

Platypus constructs documents.  Document styles are determined by DocumentTemplates.

Each DocumentTemplate contains one or more PageTemplates which defines the look of the
pages of the document.

Each PageTemplate has a procedure for drawing the "non-flowing" part of the page
(for example the header, footer, page number, fixed logo graphic, watermark, etcetera) and
a set of Frames which enclose the flowing part of the page (for example the paragraphs,
tables, or non-fixed diagrams of the text).

A document is built when a DocumentTemplate is fed a sequence of Flowables.
The action of the build consumes the flowables in order and places them onto
frames on pages as space allows.  When a frame runs out of space the next frame
of the page is used.  If no frame remains a new page is created.  A new page
can also be created if a page break is forced.

The special invisible flowable NextPageTemplate can be used to specify
the page template for the next page (which by default is the one being used
for the current frame).
"""

from reportlab.platypus.flowables import *
from reportlab.platypus.paragraph import Paragraph
from reportlab.platypus.frames import Frame
from reportlab.rl_config import defaultPageSize, verbose
import reportlab.lib.sequencer

from types import *
import sys

class LayoutError(Exception):
    pass

def _doNothing(canvas, doc):
    "Dummy callback for onPage"
    pass


class IndexingFlowable(Flowable):
    """Abstract interface definition for flowables which might
    hold references to other pages or themselves be targets
    of cross-references.  XRefStart, XRefDest, Table of Contents,
    Indexes etc."""
    def isIndexing(self):
        return 1

    def isSatisfied(self):
        return 1

    def notify(self, kind, stuff):
        """This will be called by the framework wherever 'stuff' happens.
        'kind' will be a value that can be used to decide whether to
        pay attention or not."""
        pass

    def beforeBuild(self):
        """Called by multiBuild before it starts; use this to clear
        old contents"""
        pass

    def afterBuild(self):
        """Called after build ends but before isSatisfied"""
        pass


class ActionFlowable(Flowable):
    '''This Flowable is never drawn, it can be used for data driven controls
       For example to change a page template (from one column to two, for example)
       use NextPageTemplate which creates an ActionFlowable.
    '''
    def __init__(self,action=()):
        if type(action) not in (ListType, TupleType):
            action = (action,)
        self.action = tuple(action)

    def wrap(self, availWidth, availHeight):
        '''Should never be called.'''
        raise NotImplementedError

    def draw(self):
        '''Should never be called.'''
        raise NotImplementedError

    def apply(self,doc):
        '''
        This is called by the doc.build processing to allow the instance to
        implement its behaviour
        '''
        action = self.action[0]
        args = tuple(self.action[1:])
        arn = 'handle_'+action
        try:
            apply(getattr(doc,arn), args)
        except AttributeError, aerr:
            if aerr.args[0]==arn:
                raise NotImplementedError, "Can't handle ActionFlowable(%s)" % action
            else:
                raise
        except "bogus":
            t, v, unused = sys.exc_info()
            raise t, "%s\n   handle_%s args=%s"%(v,action,args)

    def __call__(self):
        return self

    def identity(self, maxLen=None):
        return "ActionFlowable: %s" % str(self.action)

class NextFrameFlowable(ActionFlowable):
    def __init__(self,ix,resume=0):
        ActionFlowable.__init__(self,('nextFrame',ix,resume))

class CurrentFrameFlowable(ActionFlowable):
    def __init__(self,ix,resume=0):
        ActionFlowable.__init__(self,('currentFrame',ix,resume))

class _FrameBreak(ActionFlowable):
    '''
    A special ActionFlowable that allows setting doc._nextFrameIndex

    eg story.append(FrameBreak('mySpecialFrame'))
    '''
    def __call__(self,ix=None,resume=0):
        r = self.__class__(self.action+(resume,))
        r._ix = ix
        return r

    def apply(self,doc):
        if getattr(self,'_ix',None): doc._nextFrameIndex = self._ix
        ActionFlowable.apply(self,doc)

FrameBreak = _FrameBreak('frameEnd')
PageBegin = ActionFlowable('pageBegin')

def _evalMeasurement(n):
    if type(n) is type(''):
        from paraparser import _num
        n = _num(n)
        if type(n) is type(()): n = n[1]
    return n

class Indenter(ActionFlowable):
    """Increases or decreases left and right margins of frame.

    This allows one to have a 'context-sensitive' indentation
    and makes nested lists way easier.
    """

    def __init__(self, left=0, right=0):
        self.left = _evalMeasurement(left)
        self.right = _evalMeasurement(right)

    def apply(self, doc):
        doc.frame._leftExtraIndent = doc.frame._leftExtraIndent + self.left
        doc.frame._rightExtraIndent = doc.frame._rightExtraIndent + self.right


class NextPageTemplate(ActionFlowable):
    """When you get to the next page, use the template specified (change to two column, for example)  """
    def __init__(self,pt):
        ActionFlowable.__init__(self,('nextPageTemplate',pt))


class PageTemplate:
    """
    essentially a list of Frames and an onPage routine to call at the start
    of a page when this is selected. onPageEnd gets called at the end.
    derived classes can also implement beforeDrawPage and afterDrawPage if they want
    """
    def __init__(self,id=None,frames=[],onPage=_doNothing, onPageEnd=_doNothing,
                 pagesize=None):
        if type(frames) not in (ListType,TupleType): frames = [frames]
        assert filter(lambda x: not isinstance(x,Frame), frames)==[], "frames argument error"
        self.id = id
        self.frames = frames
        self.onPage = onPage
        self.onPageEnd = onPageEnd
        self.pagesize = pagesize

    def beforeDrawPage(self,canv,doc):
        """Override this if you want additional functionality or prefer
        a class based page routine.  Called before any flowables for
        this page are processed."""
        pass

    def checkPageSize(self,canv,doc):
        '''This gets called by the template framework
        If canv size != template size then the canv size is set to
        the template size or if that's not available to the
        doc size.
        '''
        #### NEVER EVER EVER COMPARE FLOATS FOR EQUALITY
        #RGB converting pagesizes to ints means we are accurate to one point
        #RGB I suggest we should be aiming a little better
        cp = None
        dp = None
        sp = None
        if canv._pagesize: cp = map(int, canv._pagesize)
        if self.pagesize: sp = map(int, self.pagesize)
        if doc.pagesize: dp = map(int, doc.pagesize)
        if cp!=sp:
            if sp:
                canv.setPageSize(self.pagesize)
            elif cp!=dp:
                canv.setPageSize(doc.pagesize)

    def afterDrawPage(self, canv, doc):
        """This is called after the last flowable for the page has
        been processed.  You might use this if the page header or
        footer needed knowledge of what flowables were drawn on
        this page."""
        pass


class BaseDocTemplate:
    """
    First attempt at defining a document template class.

    The basic idea is simple.
    0)  The document has a list of data associated with it
        this data should derive from flowables. We'll have
        special classes like PageBreak, FrameBreak to do things
        like forcing a page end etc.

    1)  The document has one or more page templates.

    2)  Each page template has one or more frames.

    3)  The document class provides base methods for handling the
        story events and some reasonable methods for getting the
        story flowables into the frames.

    4)  The document instances can override the base handler routines.

    Most of the methods for this class are not called directly by the user,
    but in some advanced usages they may need to be overridden via subclassing.

    EXCEPTION: doctemplate.build(...) must be called for most reasonable uses
    since it builds a document using the page template.

    Each document template builds exactly one document into a file specified
    by the filename argument on initialization.

    Possible keyword arguments for the initialization:

    pageTemplates: A list of templates.  Must be nonempty.  Names
      assigned to the templates are used for referring to them so no two used
      templates should have the same name.  For example you might want one template
      for a title page, one for a section first page, one for a first page of
      a chapter and two more for the interior of a chapter on odd and even pages.
      If this argument is omitted then at least one pageTemplate should be provided
      using the addPageTemplates method before the document is built.
    pageSize: a 2-tuple or a size constant from reportlab/lib/pagesizes.pu.
     Used by the SimpleDocTemplate subclass which does NOT accept a list of
     pageTemplates but makes one for you; ignored when using pageTemplates.

    showBoundary: if set draw a box around the frame boundaries.
    leftMargin:
    rightMargin:
    topMargin:
    bottomMargin:  Margin sizes in points (default 1 inch)
      These margins may be overridden by the pageTemplates.  They are primarily of interest
      for the SimpleDocumentTemplate subclass.
    allowSplitting:  If set flowables (eg, paragraphs) may be split across frames or pages
      (default: 1)
    title: Internal title for document (does not automatically display on any page)
    author: Internal author for document (does not automatically display on any page)
    """
    _initArgs = {   'pagesize':defaultPageSize,
                    'pageTemplates':[],
                    'showBoundary':0,
                    'leftMargin':inch,
                    'rightMargin':inch,
                    'topMargin':inch,
                    'bottomMargin':inch,
                    'allowSplitting':1,
                    'title':None,
                    'author':None,
                    'invariant':None,
                    '_pageBreakQuick':1}
    _invalidInitArgs = ()
    _firstPageTemplateIndex = 0

    def __init__(self, filename, **kw):
        """create a document template bound to a filename (see class documentation for keyword arguments)"""
        self.filename = filename

        for k in self._initArgs.keys():
            if not kw.has_key(k):
                v = self._initArgs[k]
            else:
                if k in self._invalidInitArgs:
                    raise ValueError, "Invalid argument %s" % k
                v = kw[k]
            setattr(self,k,v)
        #print "pagesize is", self.pagesize

        p = self.pageTemplates
        self.pageTemplates = []
        self.addPageTemplates(p)

        # facility to assist multi-build and cross-referencing.
        # various hooks can put things into here - key is what
        # you want, value is a page number.  This can then be
        # passed to indexing flowables.
        self._pageRefs = {}
        self._indexingFlowables = []


        #callback facility for progress monitoring
        self._onPage = None
        self._onProgress = None
        self._flowableCount = 0  # so we know how far to go


        #infinite loop detection if we start doing lots of empty pages
        self._curPageFlowableCount = 0
        self._emptyPages = 0
        self._emptyPagesAllowed = 10

        #context sensitive margins - set by story, not from outside
        self._leftExtraIndent = 0.0
        self._rightExtraIndent = 0.0

        self._calc()
        self.afterInit()

    def _calc(self):
        self._rightMargin = self.pagesize[0] - self.rightMargin
        self._topMargin = self.pagesize[1] - self.topMargin
        self.width = self._rightMargin - self.leftMargin
        self.height = self._topMargin - self.bottomMargin

    def setPageCallBack(self, func):
        'Simple progress monitor - func(pageNo) called on each new page'
        self._onPage = func

    def setProgressCallBack(self, func):
        '''Cleverer progress monitor - func(typ, value) called regularly'''
        self._onProgress = func

    def clean_hanging(self):
        'handle internal postponed actions'
        while len(self._hanging):
            self.handle_flowable(self._hanging)

    def addPageTemplates(self,pageTemplates):
        'add one or a sequence of pageTemplates'
        if type(pageTemplates) not in (ListType,TupleType):
            pageTemplates = [pageTemplates]
        #this test below fails due to inconsistent imports!
        #assert filter(lambda x: not isinstance(x,PageTemplate), pageTemplates)==[], "pageTemplates argument error"
        for t in pageTemplates:
            self.pageTemplates.append(t)

    def handle_documentBegin(self):
        '''implement actions at beginning of document'''
        self._hanging = [PageBegin]
        self.pageTemplate = self.pageTemplates[self._firstPageTemplateIndex]
        self.page = 0
        self.beforeDocument()

    def handle_pageBegin(self):
        '''Perform actions required at beginning of page.
        shouldn't normally be called directly'''
        self.page = self.page + 1
        self.pageTemplate.beforeDrawPage(self.canv,self)
        self.pageTemplate.checkPageSize(self.canv,self)
        self.pageTemplate.onPage(self.canv,self)
        for f in self.pageTemplate.frames: f._reset()
        self.beforePage()
        #keep a count of flowables added to this page.  zero indicates bad stuff
        self._curPageFlowableCount = 0
        if hasattr(self,'_nextFrameIndex'):
            del self._nextFrameIndex
        self.frame = self.pageTemplate.frames[0]
        self.handle_frameBegin()

    def handle_pageEnd(self):
        ''' show the current page
            check the next page template
            hang a page begin
        '''
        #detect infinite loops...
        if self._curPageFlowableCount == 0:
            self._emptyPages = self._emptyPages + 1
        else:
            self._emptyPages = 0
        if self._emptyPages >= self._emptyPagesAllowed:
            if 1:
                raise LayoutError("More than %d pages generated without content - halting layout.  Likely that a flowable is too large for any frame." % self._emptyPagesAllowed)
            else:
                pass    #attempt to restore to good state
        else:
            if self._onProgress:
                self._onProgress('PAGE', self.canv.getPageNumber())
            self.pageTemplate.afterDrawPage(self.canv, self)
            self.pageTemplate.onPageEnd(self.canv, self)
            self.afterPage()
            self.canv.showPage()
            if hasattr(self,'_nextPageTemplateIndex'):
                self.pageTemplate = self.pageTemplates[self._nextPageTemplateIndex]
                del self._nextPageTemplateIndex
            if self._emptyPages==0:
                pass    #store good state here
        self._hanging.append(PageBegin)

    def handle_pageBreak(self,slow=None):
        '''some might choose not to end all the frames'''
        if self._pageBreakQuick and not slow:
            self.handle_pageEnd()
        else:
            n = len(self._hanging)
            while len(self._hanging)==n:
                self.handle_frameEnd()

    def handle_frameBegin(self,resume=0):
        '''What to do at the beginning of a frame'''
        f = self.frame
        if f._atTop:
            if self.showBoundary or self.frame.showBoundary:
                self.frame.drawBoundary(self.canv)
        f._leftExtraIndent = self._leftExtraIndent
        f._rightExtraIndent = self._rightExtraIndent

    def handle_frameEnd(self,resume=0):
        ''' Handles the semantics of the end of a frame. This includes the selection of
            the next frame or if this is the last frame then invoke pageEnd.
        '''

        self._leftExtraIndent = self.frame._leftExtraIndent
        self._rightExtraIndent = self.frame._rightExtraIndent

        if hasattr(self,'_nextFrameIndex'):
            frame = self.pageTemplate.frames[self._nextFrameIndex]
            del self._nextFrameIndex
            self.handle_frameBegin(resume)
        elif hasattr(self.frame,'lastFrame') or self.frame is self.pageTemplate.frames[-1]:
            self.handle_pageEnd()
            self.frame = None
        else:
            f = self.frame
            self.frame = self.pageTemplate.frames[self.pageTemplate.frames.index(f) + 1]
            self.handle_frameBegin()

    def handle_nextPageTemplate(self,pt):
        '''On endPage chenge to the page template with name or index pt'''
        if type(pt) is StringType:
            for t in self.pageTemplates:
                if t.id == pt:
                    self._nextPageTemplateIndex = self.pageTemplates.index(t)
                    return
            raise ValueError, "can't find template('%s')"%pt
        elif type(pt) is IntType:
            self._nextPageTemplateIndex = pt
        else:
            raise TypeError, "argument pt should be string or integer"

    def handle_nextFrame(self,fx):
        '''On endFrame chenge to the frame with name or index fx'''
        if type(fx) is StringType:
            for f in self.pageTemplate.frames:
                if f.id == fx:
                    self._nextFrameIndex = self.pageTemplate.frames.index(f)
                    return
            raise ValueError, "can't find frame('%s')"%fx
        elif type(fx) is IntType:
            self._nextFrameIndex = fx
        else:
            raise TypeError, "argument fx should be string or integer"

    def handle_currentFrame(self,fx):
        '''chenge to the frame with name or index fx'''
        if type(fx) is StringType:
            for f in self.pageTemplate.frames:
                if f.id == fx:
                    self._nextFrameIndex = self.pageTemplate.frames.index(f)
                    return
            raise ValueError, "can't find frame('%s')"%fx
        elif type(fx) is IntType:
            self._nextFrameIndex = fx
        else:
            raise TypeError, "argument fx should be string or integer"

    def handle_breakBefore(self, flowables):
        '''preprocessing step to allow pageBreakBefore and frameBreakBefore attributes'''
        first = flowables[0]
        # if we insert a page break before, we'll process that, see it again,
        # and go in an infinite loop.  So we need to set a flag on the object
        # saying 'skip me'.  This should be unset on the next pass
        if hasattr(first, '_skipMeNextTime'):
            delattr(first, '_skipMeNextTime')
            return
        # this could all be made much quicker by putting the attributes
        # in to the flowables with a defult value of 0
        if hasattr(first,'pageBreakBefore') and first.pageBreakBefore == 1:
            first._skipMeNextTime = 1
            first.insert(0, PageBreak())
            return
        if hasattr(first,'style') and hasattr(first.style, 'pageBreakBefore') and first.style.pageBreakBefore == 1:
            first._skipMeNextTime = 1
            flowables.insert(0, PageBreak())
            return
        if hasattr(first,'frameBreakBefore') and first.frameBreakBefore == 1:
            first._skipMeNextTime = 1
            flowables.insert(0, FrameBreak())
            return
        if hasattr(first,'style') and hasattr(first.style, 'frameBreakBefore') and first.style.frameBreakBefore == 1:
            first._skipMeNextTime = 1
            flowables.insert(0, FrameBreak())
            return


    def handle_keepWithNext(self, flowables):
        "implements keepWithNext"
        i = 0
        n = len(flowables)
        while i<n and flowables[i].getKeepWithNext(): i = i + 1
        if i:
            i = i + 1
            K = KeepTogether(flowables[:i])
            for f in K._flowables:
                f.keepWithNext = 0
            del flowables[:i]
            flowables.insert(0,K)

    def handle_flowable(self,flowables):
        '''try to handle one flowable from the front of list flowables.'''

        #allow document a chance to look at, modify or ignore
        #the object(s) about to be processed
        self.filterFlowables(flowables)

        self.handle_breakBefore(flowables)
        self.handle_keepWithNext(flowables)
        f = flowables[0]
        #print 'handling flowable %s' % f.identity()
        del flowables[0]
        if f is None:
            return

        if isinstance(f,PageBreak):
            if isinstance(f,SlowPageBreak):
                self.handle_pageBreak(slow=1)
            else:
                self.handle_pageBreak()
            self.afterFlowable(f)
        elif isinstance(f,ActionFlowable):
            f.apply(self)
            self.afterFlowable(f)
        else:
            #try to fit it then draw it
            if self.frame.add(f, self.canv, trySplit=self.allowSplitting):
                self._curPageFlowableCount = self._curPageFlowableCount + 1
                self.afterFlowable(f)
            else:
                #if isinstance(f, KeepTogether): print 'could not add it to frame'
                if self.allowSplitting:
                    # see if this is a splittable thing
                    S = self.frame.split(f,self.canv)
                    #print '%d parts to sequence on page %d' % (len(S), self.page)
                    n = len(S)
                else:
                    n = 0
                #if isinstance(f, KeepTogether): print 'n=%d' % n
                if n:
                    if self.frame.add(S[0], self.canv, trySplit=0):
                        self._curPageFlowableCount = self._curPageFlowableCount + 1
                        self.afterFlowable(S[0])
                    else:
                        raise LayoutError("Splitting error(n==%d) on page %d in\n%s" % (n,self.page,f.identity(30)))
                    del S[0]
                    for f in xrange(n-1):
                        flowables.insert(f,S[f])    # put split flowables back on the list
                else:
                    if hasattr(f,'_postponed'):
                        raise LayoutError("Flowable %s too large on page %d" % (f.identity(30), self.page))
                    # this ought to be cleared when they are finally drawn!
                    f._postponed = 1
                    flowables.insert(0,f)           # put the flowable back
                    self.handle_frameEnd()

    #these are provided so that deriving classes can refer to them
    _handle_documentBegin = handle_documentBegin
    _handle_pageBegin = handle_pageBegin
    _handle_pageEnd = handle_pageEnd
    _handle_frameBegin = handle_frameBegin
    _handle_frameEnd = handle_frameEnd
    _handle_flowable = handle_flowable
    _handle_nextPageTemplate = handle_nextPageTemplate
    _handle_currentFrame = handle_currentFrame
    _handle_nextFrame = handle_nextFrame

    def _startBuild(self, filename=None, canvasmaker=canvas.Canvas):
        self._calc()
        self.canv = canvasmaker(filename or self.filename,
                                pagesize=self.pagesize,
                                invariant=self.invariant)
        if self._onPage:
            self.canv.setPageCallBack(self._onPage)
        self.handle_documentBegin()

    def _endBuild(self):
        if self._hanging!=[] and self._hanging[-1] is PageBegin:
            del self._hanging[-1]
            self.clean_hanging()
        else:
            self.clean_hanging()
            self.handle_pageBreak()

        if getattr(self,'_doSave',1): self.canv.save()
        if self._onPage: self.canv.setPageCallBack(None)

    def build(self, flowables, filename=None, canvasmaker=canvas.Canvas):
        """Build the document from a list of flowables.
           If the filename argument is provided then that filename is used
           rather than the one provided upon initialization.
           If the canvasmaker argument is provided then it will be used
           instead of the default.  For example a slideshow might use
           an alternate canvas which places 6 slides on a page (by
           doing translations, scalings and redefining the page break
           operations).
        """
        #assert filter(lambda x: not isinstance(x,Flowable), flowables)==[], "flowables argument error"
        flowableCount = len(flowables)
        if self._onProgress:
            self._onProgress('STARTED',0)
            self._onProgress('SIZE_EST', len(flowables))
        self._startBuild(filename,canvasmaker)

        while len(flowables):
            self.clean_hanging()
            try:
                first = flowables[0]
                self.handle_flowable(flowables)
            except:
                #if it has trace info, add it to the traceback message.
                if hasattr(first, '_traceInfo') and first._traceInfo:
                    exc = sys.exc_info()[1]
                    args = list(exc.args)
                    tr = first._traceInfo
                    args[0] = args[0] + '\n(srcFile %s, line %d char %d to line %d char %d)' % (
                        tr.srcFile,
                        tr.startLineNo,
                        tr.startLinePos,
                        tr.endLineNo,
                        tr.endLinePos
                        )
                    exc.args = tuple(args)
                raise
            if self._onProgress:
                self._onProgress('PROGRESS',flowableCount - len(flowables))

        self._endBuild()
        if self._onProgress:
            self._onProgress('FINISHED',0)

    def _allSatisfied(self):
        """Called by multi-build - are all cross-references resolved?"""
        allHappy = 1
        for f in self._indexingFlowables:
            if not f.isSatisfied():
                allHappy = 0
                break
        return allHappy

    def notify(self, kind, stuff):
        """"Forward to any listeners"""
        for l in self._indexingFlowables:
            l.notify(kind, stuff)

    def pageRef(self, label):
        """hook to register a page number"""
        if verbose: print "pageRef called with label '%s' on page %d" % (
            label, self.page)
        self._pageRefs[label] = self.page

    def multiBuild(self, story,
                   filename=None,
                   canvasmaker=canvas.Canvas,
                   maxPasses = 10):
        """Makes multiple passes until all indexing flowables
        are happy."""
        self._indexingFlowables = []
        #scan the story and keep a copy
        for thing in story:
            if thing.isIndexing():
                self._indexingFlowables.append(thing)
        #print 'scanned story, found these indexing flowables:\n'
        #print self._indexingFlowables

        #better fix for filename is a 'file' problem
        self._doSave = 0
        passes = 0
        while 1:
            passes = passes + 1
            if self._onProgress:
                self.onProgress('PASS', passes)
            if verbose: print 'building pass '+str(passes) + '...',

            for fl in self._indexingFlowables:
                fl.beforeBuild()

            # work with a copy of the story, since it is consumed
            tempStory = story[:]
            self.build(tempStory, filename, canvasmaker)
            #self.notify('debug',None)

            #clean up so multi-build does not go wrong - the frame
            #packer might have tacked an attribute onto some flowables
            for elem in story:
                if hasattr(elem, '_postponed'):
                    del elem._postponed

            for fl in self._indexingFlowables:
                fl.afterBuild()

            happy = self._allSatisfied()

            if happy:
                self._doSave = 0
                self.canv.save()
                break
            if passes > maxPasses:
                raise IndexError, "Index entries not resolved after %d passes" % maxPasses

        if verbose: print 'saved'

    #these are pure virtuals override in derived classes
    #NB these get called at suitable places by the base class
    #so if you derive and override the handle_xxx methods
    #it's up to you to ensure that they maintain the needed consistency
    def afterInit(self):
        """This is called after initialisation of the base class."""
        pass

    def beforeDocument(self):
        """This is called before any processing is
        done on the document."""
        pass

    def beforePage(self):
        """This is called at the beginning of page
        processing, and immediately before the
        beforeDrawPage method of the current page
        template."""
        pass

    def afterPage(self):
        """This is called after page processing, and
        immediately after the afterDrawPage method
        of the current page template."""
        pass

    def filterFlowables(self,flowables):
        '''called to filter flowables at the start of the main handle_flowable method.
        Upon return if flowables[0] has been set to None it is discarded and the main
        method returns.
        '''
        pass

    def afterFlowable(self, flowable):
        '''called after a flowable has been rendered'''
        pass


class SimpleDocTemplate(BaseDocTemplate):
    """A special case document template that will handle many simple documents.
       See documentation for BaseDocTemplate.  No pageTemplates are required
       for this special case.   A page templates are inferred from the
       margin information and the onFirstPage, onLaterPages arguments to the build method.

       A document which has all pages with the same look except for the first
       page may can be built using this special approach.
    """
    _invalidInitArgs = ('pageTemplates',)

    def handle_pageBegin(self):
        '''override base method to add a change of page template after the firstpage.
        '''
        self._handle_pageBegin()
        self._handle_nextPageTemplate('Later')

    def build(self,flowables,onFirstPage=_doNothing, onLaterPages=_doNothing):
        """build the document using the flowables.  Annotate the first page using the onFirstPage
               function and later pages using the onLaterPages function.  The onXXX pages should follow
               the signature

                  def myOnFirstPage(canvas, document):
                      # do annotations and modify the document
                      ...

               The functions can do things like draw logos, page numbers,
               footers, etcetera. They can use external variables to vary
               the look (for example providing page numbering or section names).
        """
        self._calc()    #in case we changed margins sizes etc
        frameT = Frame(self.leftMargin, self.bottomMargin, self.width, self.height, id='normal')
        self.addPageTemplates([PageTemplate(id='First',frames=frameT, onPage=onFirstPage,pagesize=self.pagesize),
                        PageTemplate(id='Later',frames=frameT, onPage=onLaterPages,pagesize=self.pagesize)])
        if onFirstPage is _doNothing and hasattr(self,'onFirstPage'):
            self.pageTemplates[0].beforeDrawPage = self.onFirstPage
        if onLaterPages is _doNothing and hasattr(self,'onLaterPages'):
            self.pageTemplates[1].beforeDrawPage = self.onLaterPages
        BaseDocTemplate.build(self,flowables)


def progressCB(typ, value):
    """Example prototype for progress monitoring.

    This aims to provide info about what is going on
    during a big job.  It should enable, for example, a reasonably
    smooth progress bar to be drawn.  We design the argument
    signature to be predictable and conducive to programming in
    other (type safe) languages.  If set, this will be called
    repeatedly with pairs of values.  The first is a string
    indicating the type of call; the second is a numeric value.

    typ 'STARTING', value = 0
    typ 'SIZE_EST', value = numeric estimate of job size
    typ 'PASS', value = number of this rendering pass
    typ 'PROGRESS', value = number between 0 and SIZE_EST
    typ 'PAGE', value = page number of page
    type 'FINISHED', value = 0

    The sequence is
        STARTING - always called once
        SIZE_EST - always called once
        PROGRESS - called often
        PAGE - called often when page is emitted
        FINISHED - called when really, really finished

    some juggling is needed to accurately estimate numbers of
    pages in pageDrawing mode.

    NOTE: the SIZE_EST is a guess.  It is possible that the
    PROGRESS value may slightly exceed it, or may even step
    back a little on rare occasions.  The only way to be
    really accurate would be to do two passes, and I don't
    want to take that performance hit.
    """
    print 'PROGRESS MONITOR:  %-10s   %d' % (typ, value)

if __name__ == '__main__':

    def myFirstPage(canvas, doc):
        canvas.saveState()
        canvas.setStrokeColor(red)
        canvas.setLineWidth(5)
        canvas.line(66,72,66,PAGE_HEIGHT-72)
        canvas.setFont('Times-Bold',24)
        canvas.drawString(108, PAGE_HEIGHT-108, "TABLE OF CONTENTS DEMO")
        canvas.setFont('Times-Roman',12)
        canvas.drawString(4 * inch, 0.75 * inch, "First Page")
        canvas.restoreState()

    def myLaterPages(canvas, doc):
        canvas.saveState()
        canvas.setStrokeColor(red)
        canvas.setLineWidth(5)
        canvas.line(66,72,66,PAGE_HEIGHT-72)
        canvas.setFont('Times-Roman',12)
        canvas.drawString(4 * inch, 0.75 * inch, "Page %d" % doc.page)
        canvas.restoreState()

    def run():
        objects_to_draw = []
        from reportlab.lib.styles import ParagraphStyle
        #from paragraph import Paragraph
        from doctemplate import SimpleDocTemplate

        #need a style
        normal = ParagraphStyle('normal')
        normal.firstLineIndent = 18
        normal.spaceBefore = 6
        from reportlab.lib.randomtext import randomText
        import random
        for i in range(15):
            height = 0.5 + (2*random.random())
            box = XBox(6 * inch, height * inch, 'Box Number %d' % i)
            objects_to_draw.append(box)
            para = Paragraph(randomText(), normal)
            objects_to_draw.append(para)

        SimpleDocTemplate('doctemplate.pdf').build(objects_to_draw,
            onFirstPage=myFirstPage,onLaterPages=myLaterPages)

    run()
