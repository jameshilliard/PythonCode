import copy
import math

#Graph libraries
from basetest import FlowableGraph
from basetest import VeriwaveBlue, VeriwaveYellow, VeriwaveGreen, VeriwaveLtBlue
from reportlab.graphics.charts.axes import XValueAxis
from reportlab.graphics.shapes import Drawing, Line, String, Rect, STATE_DEFAULTS
from reportlab.graphics.charts.linecharts import HorizontalLineChart
from reportlab.graphics.charts.linecharts import makeMarker
from reportlab.graphics import renderPDF
from reportlab.graphics.charts.barcharts import VerticalBarChart
from reportlab.lib import colors
from reportlab.graphics.charts.legends import Legend, LineLegend
from reportlab.graphics.charts.textlabels import Label
from reportlab.lib.units import inch
from reportlab.graphics.charts.axes import XCategoryAxis,YValueAxis
from reportlab.graphics.charts.utils import nextRoundNumber
from reportlab.graphics.charts.piecharts import Pie, LegendedPie

#we define 51 colors to be used in graphs with multiple y vals. add more
#if necessary
colorList = [colors.green, colors.red, colors.blue, colors.yellow, 
             colors.violet, colors.orange, colors.navy, colors.maroon,
             colors.lightblue, colors.khaki, colors.oldlace, colors.crimson, 
             colors.darkgray, colors.aliceblue, colors.azure, colors.bisque,
             colors.forestgreen, colors.gold, colors.hotpink, colors.indianred,
             colors.lightgoldenrodyellow, colors.mistyrose, colors.paleturquoise, 
             colors.papayawhip, colors.chartreuse, colors.thistle, colors.sienna,
             colors.gray, colors.purple, colors.cyan, colors.darkkhaki, 
             colors.gainsboro, colors.indigo, colors.olive, colors.plum, 
             colors.seashell, colors.wheat, colors.yellowgreen, colors.silver,
             colors.orchid, colors.palegoldenrod, colors.magenta, colors.beige,
             colors.cornsilk, colors.lavender, colors.linen, colors.peru,
             colors.salmon, colors.springgreen, colors.steelblue, colors.teal]

distinctColorList = [colors.black, colors.green, colors.red, 
                     colors.blue, colors.gray, colors.yellow,
                     colors.darkorange, colors.darkolivegreen, 
                     colors.burlywood, colors.blueviolet, colors.brown, 
                     colors.darkseagreen, colors.hotpink, colors.lime, 
                     colors.thistle, colors.steelblue, colors.rosybrown, 
                     colors.cyan, colors.chocolate,colors.slateblue]

class BasicGraph:
    """
    This is a base class with methods common among graphs in this module
    """
    def drawLegends(self, chartObj, x, y, legendHeight):
        legendX = x + 5
        legendY = y + legendHeight - 2
        line2Fval = False
        indx = 0
        for legend in self.legendList:
            if len(legend) == 0:
                continue
            String = legend[0]
            Type   = 'Rect'
            #Default color.
            (R,G,B) = VeriwaveYellow
            Color = colors.Color(R,G,B)
            if isinstance(chartObj, VerticalBarChart):
                Color = chartObj.bars[indx].fillColor
            if isinstance(chartObj, HorizontalLineChart):
                Color = chartObj.lines[indx].strokeColor
            if len(legend) == 2:
                Type   = legend[1]
            if len(legend) == 3:
                Color  = legend[2]
            indx += 1
            (deltax, moveToline2F) = self.drawLegend(legendX, legendY,
                    Type, Color, String, line2F = line2Fval, startX = x + 5)
            if moveToline2F:
                #To fit more possible legends, we start writing legends at some points 
                #above max Y val, and we allow max of 2 (5 size) lines, when we reach
                #end of line 1, drawLegend() return the moveToline2F as True, 
                #so next time drawLegend is called, we should pass proper x, y values. 
                legendY -= 7
                legendX = x + 5 + deltax
                line2Fval = True
            elif deltax != -1:
                legendX += deltax
        #Add the legend for additional line, if present
        if  self.additionalLineF:
            Type = 'Line'
            Color = colors.brown
            if len(self.additionalLine) < 5:
                return -1
            String = self.additionalLine[4]
            self.drawLegend(legendX, legendY, Type, Color, String, line2F = line2Fval, startX = x + 5)
    
    def drawLegend(self, x, y, Ltype, Color, String, line2F = False, startX = 0):
        if Ltype == 'Line':
            legend = LineLegend()
            legend.strokeWidth = 0.1
        elif Ltype == 'Rect':
            legend = Legend()
            legend.dx = 5
            legend.dy = 5
        else:
            return -1
        legend.alignment = 'right'
        legend.x = x
        legend.y = y
        legend.fontName = 'Helvetica'
        legend.fontSize = 7
        legend.dxTextSpace = 4
        legend.colorNamePairs = [(Color, String)]
        #We use private functions to calculate the width. Bad?
        maxWidth = legend._calculateMaxWidth(legend.colorNamePairs)
        maxWidth += legend.dx + legend.dxTextSpace + legend.autoXPadding
        #To fit more possible legends, we start writing legends at some points above 
        #max Y val, and we allow max of 2 (5 size) lines, when we reach end of line 1,
        #pass the moveToline2F (True) to drawLegends, so next time it calls drawLegend
        #it passes proper x, y values. 
        moveToline2F = False
        cantDrawF = False
        if (maxWidth + x) > self.width:
            if line2F != True:
                moveToline2F = True
                legend.y -= 7
                if startX != 0:
                    legend.x = startX
                else:
                    cantDrawF = True
            else:
                cantDrawF = True

        if cantDrawF:
                print("Legend list too long. %s doesn't fit in graph" % String)
                maxWidth = -1
        else:
            self.drawing.add(legend)
            
        return (maxWidth, moveToline2F)        
        
                
    def drawLine(self, graphObj, lineEndPoints):
        x1, y1, x2, y2, _ = lineEndPoints
        if isinstance(self.x_vals[0], str):
            xValsAreCategories = True
        else:
            xValsAreCategories = False
            
        if  xValsAreCategories and (x1 != 0 or x2 != 'END'):
            print("X-Axis values are categories, not numerical points but given x1, x2 are valid values, Line can't be drawn")
            return -1

        graphWidth = graphObj.width
        if xValsAreCategories:
            lnX1 = graphObj.x
            lnX2 = graphObj.x + graphWidth
        else:
            xMax = max(self.x_vals)
            xMin = min(self.x_vals)
            perUnitWidth = graphWidth/( xMax - xMin)
            lnX1 = graphObj.x + (perUnitWidth * (x1 - xMin) )
            lnX2 = graphObj.x + (perUnitWidth * (x2 - xMin) )
            
        graphHeight = graphObj.height
        yMax = graphObj.valueAxis.valueMax 
        yMin = graphObj.valueAxis.valueMin
        perUnitHeight = graphHeight/ (yMax - yMin) 
        lnY1 = graphObj.y + (perUnitHeight * (y1 - yMin) )
        lnY2 = graphObj.y + (perUnitHeight * (y2 - yMin) )
        dashArray = [2,2]
        ln = Line(lnX1, lnY1, lnX2, lnY2, strokeColor = colors.brown, strokeWidth= 0.5)

        self.drawing.add(ln)
        
        
class GenericGraph(FlowableGraph, BasicGraph):
    def __init__(self, x_vals, x_label, y_vals, y_label,
            title, graphtypeList, legends = [], splitgraph = False,
            xAxisDigits = 3, yAxisDigits = 3, dataLblDigits = 3, displayDataLbls = True,
            dataLabelAngle = 0, xValsDisplayAngle = 0,  strictYbounds = {}, 
            additionalLine = []):
        #x_vals - list of integers represented as strings. Ex: ['1', '2', '10']
        #x_label - X axis title as string. Ex: "Time"
        #y_vals - list of list of values. Ex: [[200, 300, 50], [1, 10, 12]]
        #y_label - Y axis title as string. Ex: "FrameRate"
        #title  - Title for the graph as string. Ex: "Latency Measurement"
        #graphtypeList - list of graph types as strings. Only 'Bar' and 'Line'
        #                supported for now. Ex: ['Line'] or ['Line', 'Bar']
        #legends - List of legendLists. Each legendList should have a mandatory
        #          legend Name followed by optional type and color. Types
        #          supported now are 'Line' or 'Rect'. Color needs to be
        #          specified as an index pointing to one of the colors of
        #          colorList.
        #          Ex: [['Min', 'Line', colorList[1]], ['Max'], ['Avg', 'Rect']]
        #splitGraph - Draws (tries to..) separate graphs for each set of 
        #             y_val in the same chart area.
        #xAxisDigits - number of digits after the decimal point for x axis 
        #yAxisDigits - number of digits after the decimal point for y axis 
        #dataLblDigits - number of digits after the decimal point for data label 
        #displayDataLbls - Flag indicating whether data labels are to be displayed
        #dataLabelAngle - The angle at which the data label is to be displayed (so that we minimize the
        #                    probability of one data label over running on the adjacent data label
        #xValsDisplayAngle - The angle at which the x-axis ticks' names (categorys names) are to be displayed
        #                to aviod each over running onto the adjacent one
        #strictYbounds- A dict containing the lower and upper bounds values, if any
        #            { 'lower': lowerBoundValue], 'upper': upperBoundValue}
        #additionalLine- [x1, y1, x2, y2, String]. Allows a line to be drawn between points (x1, y1),
        #         (x2, y2) where (x1, x2), (y1, y2) are the points in the XValueAxis, 
        #         YValueAxis respectively. 'String' is the string to be used for the l
        #         drawn for this line. 
        #         This line is useful in such cases where a theoritical line needs to
        #         be drawn
        width       = 7.0 * inch
        height      = 3.5 * inch
        FlowableGraph.__init__(self, width, height)

        self.x_vals  = x_vals
        self.x_label = x_label
        self.y_vals  = y_vals
        self.y_label = y_label
        self.title   = title
        self.graphList = graphtypeList
        self.splitgraph =  splitgraph
        self.betweenSplitsF = False
        self.numSplits = 0
        self.tmpYVal = 0
        self.legendList = legends
        self.legendsDrawnF = False
        self.labelsDrawnF = False
        self.xAxisDigits = xAxisDigits
        self.yAxisDigits = yAxisDigits
        self.dataLblDigits = dataLblDigits        
        self.displayDataLbls = displayDataLbls
        self.dataLabelAngle = dataLabelAngle
        self.xValsDisplayAngle = xValsDisplayAngle
        self.additionalLine = additionalLine
        self.strictYbounds = strictYbounds
        #When a lower bound is give for self.y_vals, the assumption is one doesn't care 
        #about the plots below this lower value, so make all the values which are lower
        #than the given lowest value (self.strictYbounds['lower']), as the lowest value
        #Yes, this is a hack
        if 'lower' in self.strictYbounds:
            for i, eachPlot in enumerate(self.y_vals[:]):    #Iterate over copy, as we change the actual values
                for j, eachPoint in enumerate(eachPlot):
                    if eachPoint < self.strictYbounds['lower']:
                        self.y_vals[i][j] = self.strictYbounds['lower']
        
        self.additionalLineF = False
        if self.additionalLine:
            self.additionalLineF = True
            
    def _drawLabels(self, Title, xAxis, yAxis):
        self.graphCenterX = self.width/2
        self.graphCenterY = self.height/2
        Label_Xaxis = Label()
        Label_Xaxis.fontSize = 7
        Label_Xaxis.angle = 0
        Label_Xaxis.dx = self.graphCenterX - 50
        Label_Xaxis.dy = 0
        Label_Xaxis.boxAnchor = 's'
        Label_Xaxis.setText(xAxis)
        self.drawing.add(Label_Xaxis)

        Label_Yaxis = Label()
        Label_Yaxis.fontSize = 7
        Label_Yaxis.angle = 90
        Label_Yaxis.boxAnchor = 'n'
        Label_Yaxis.dx = -5
        Label_Yaxis.dy = self.graphCenterY
        Label_Yaxis.setText(yAxis)
        self.drawing.add(Label_Yaxis)

        Label_Graph = Label()
        Label_Graph.fontSize = 10
        Label_Graph.angle = 0
        Label_Graph.boxAnchor = 'n'
        Label_Graph.dx = self.graphCenterX - 50
        Label_Graph.dy = self.height
        Label_Graph.setText(Title)
        self.drawing.add(Label_Graph)


    def getValueAxisScale(self, AxisObj, data):
        #Set scale only for Value Axes.
        valueMax = 0.0
        valueMin = 10000000.0
        axis = ''
        strictYminF = False
        strictYmaxF = False
        if (not isinstance(AxisObj, XValueAxis) and
                not isinstance(AxisObj, YValueAxis)):
            print("Axis should be X/Y Value Axis\n", 'ERR')
            return (-1, -1, -1)
        if isinstance(AxisObj, XValueAxis):
            axis = 'x-axis'
            maxlimit = self.width
            for eachValue in data:
                if eachValue > valueMax:
                    valueMax = eachValue
                if eachValue < valueMin:
                    valueMin = eachValue
        else: #YValueAxis
            axis = 'y-axis'
            if 'lower' in self.strictYbounds:
                strictYminF = True
            if 'upper' in self.strictYbounds:
                strictYmaxF = True
            maxlimit = self.height
            if not (strictYminF and strictYmaxF):
                for eachSeries in data:
                    for eachLine in eachSeries:
                        for eachValue in eachLine:
                            self.validData = True
                            if eachValue > valueMax:
                                valueMax = eachValue
                            if eachValue < valueMin:
                                valueMin = eachValue
        if strictYminF:
            valueMin = self.strictYbounds['lower']
        if strictYmaxF:
            valueMax = self.strictYbounds['upper']
        valueMinCopy = valueMin
        if valueMax == valueMin:
            if axis == 'y-axis':
                valueStep = valueMin + 0.001
                valueMax  = valueMin + 0.001
                tmp = valueStep * int(valueMin/valueStep)
                if (valueMin - tmp) > valueStep:
                    valueMin = tmp + valueStep
                else:
                    valueMin = tmp
            else:
                valueMin = 0
                valueStep = valueMax
        else:
            rawInterval = ((valueMax - valueMin) /
                               min(float(AxisObj.maximumTicks - 1),
                                   (float(maxlimit)/AxisObj.minimumTickSpacing)))
            valueStep = nextRoundNumber(rawInterval)
            if axis == 'y-axis':
                if strictYmaxF:
                    valueMax  = valueStep * (int(valueMax/valueStep) )
                else:
                    valueMax  = valueStep * (1 + int(valueMax/valueStep) )
            if (axis == 'x-axis') or (axis == 'y-axis' and not strictYminF): 
                tmp = valueStep * int(valueMin/valueStep)
                if (valueMin - tmp) > valueStep:
                    valueMin = tmp + valueStep
                else:
                    valueMin = tmp
        if (axis == 'x-axis') or (axis == 'y-axis' and not strictYminF):
            if valueMinCopy == valueMin and valueMin != 0:
                valueMin = valueMin - valueStep
                if valueMin < 0:
                    valueMin = 0    
        return (valueMin, valueMax, valueStep)

    def getSizes(self):
        SizeXaxis = 14
        SizeYaxis = 0.0
        countSteps = int(self.valueMax / self.valueStep)
        for n in range(countSteps + 1):
            eachValue = self.valueMin + n * self.valueStep
            SizeYaxis = max(SizeYaxis, self._stringWidth(str(eachValue),
                STATE_DEFAULTS['fontName'], STATE_DEFAULTS['fontSize']) )
        SizeXaxis = 10
        for eachName in self.x_vals:
            SizeXaxis = max(SizeXaxis, self._stringWidth(str(eachName),
                STATE_DEFAULTS['fontName'], STATE_DEFAULTS['fontSize']) )
        return (SizeXaxis, SizeYaxis)

    def drawGraph(self, graphObj, x, y, width, height, drawLabelF,
                  drawLegendF, legendHeight = 0):
        graphObj.x = x
        graphObj.y = y
        graphObj.width = width
        graphObj.height = height
        graphObj.data = self.y_vals
        if isinstance(graphObj, VerticalBarChart):
            for i in range(len(self.y_vals)):
                #add more colors to the colorList if there are more
                #than len(colorList) y_vals
                graphObj.bars[i].fillColor = colorList[i]
                i += 1
            for i in range(len(self.legendList)):
                if len(self.legendList[i]) >= 3:
                    graphObj.bars[i].fillColor = self.legendList[i][2]
            if drawLabelF == True:
                graphObj.barLabels.fontName = 'Helvetica'
                graphObj.barLabels.fontSize = 7
                graphObj.barLabels.nudge = 12 
                graphObj.barLabels.angle = self.dataLabelAngle              
                graphObj.barLabelFormat = '%0.' + '%d' % self.dataLblDigits + 'f'
                self.labelsDrawnF = True
        if isinstance(graphObj, HorizontalLineChart):
            for i in range(len(self.y_vals)):
                graphObj.lines[i].strokeColor = colorList[i]
            for i in range(len(self.legendList)):
                if len(self.legendList[i]) >= 3:
                    graphObj.lines[i].strokeColor = self.legendList[i][2]
            if drawLabelF == True:
                graphObj.lines.symbol = makeMarker('FilledDiamond')
                graphObj.lineLabelFormat = '%0.' + '%d' % self.dataLblDigits + 'f'
                graphObj.lineLabels.fontName = 'Helvetica'
                graphObj.lineLabels.fontSize = 7
                graphObj.lineLabelNudge = 7
                self.labelsDrawnF = True
        graphObj.valueAxis.visible = 1
        graphObj.categoryAxis.visible = 0
        if drawLegendF == True:
            self.drawLegends(graphObj, x, y, legendHeight)
            self.legendsDrawnF = True
        if  self.additionalLineF:    
            self.drawLine(graphObj, self.additionalLine)
        self.drawing.add(graphObj)

    def generateGraphs(self, x, y):
        (x1, y1, Width, Height) = self._getGraphRegion(x, y)
        #Draw Axes
        yVAxis = YValueAxis()
        #If we got numeric X vals, we use a ValueAxis, otherwise CategoryAxis.
        if len(self.x_vals) > 0:
            if isinstance(self.x_vals[0], str):
                xVAxis = XCategoryAxis()
            else:
                xVAxis = XValueAxis()
        else:
            return -1
        
        (y_min, y_max, y_step) = self.getValueAxisScale(yVAxis, [self.y_vals])

        if y_min == -1 and y_min == -1 and y_step == -1:
            return -1
        
        (self.valueMin, self.valueMax, self.valueStep) = (y_min, y_max, y_step)
        
        (SizeXaxis, SizeYaxis) = self.getSizes()
        #lot of ugliness in here to get the split chart working :|
        if self.betweenSplitsF == True:
            if self.numSplits == 0:
                self.tmpYVal = SizeYaxis
            else:
                SizeYaxis = self.tmpYVal
        if self.numSplits > 0:
            xVAxis.visibleLabels = False
            xVAxis.visibleTicks = False
        X_start_pos = x1 - x + SizeYaxis
        X_width = Width - SizeYaxis - 10
        if self.betweenSplitsF == True:
            if self.numSplits > 0:
                Y_start_pos = y1 - y + SizeXaxis + (self.numSplits *
                        self.height) - (self.numSplits * 15)
            else:
                Y_start_pos = y1 - y + SizeXaxis + (self.numSplits *
                        self.height)
            Y_height = Height - SizeXaxis + 40
        else:
            Y_start_pos = y1 - y + SizeXaxis + (self.numSplits *
                    self.height)
            Y_height = Height - SizeXaxis
        xVAxis.setPosition(X_start_pos, Y_start_pos, X_width)
        if isinstance(xVAxis, XValueAxis):
            dataList = []
            dataTuple =  reduce(lambda a,b: a + (b,), self.x_vals, ())
            dataList.append(dataTuple)
            xVAxis.configure(dataList)
            xVAxis.labelTextFormat = '%0.' + '%d' % self.xAxisDigits + 'f'
        else:
            dataList = []
            zerodata = [0 for val in self.x_vals]
            dataTuple =  reduce(lambda a,b: a + (b,), zerodata, ())
            dataList.append(dataTuple)
            xVAxis.configure(dataList)
            xVAxis.categoryNames = self.x_vals
            #Ugly hack for setting the labels.dy. Empirical: If there are more than 5 
            #chars, dy = -35 fits fine (assuming the angle would be > 75,when we have 
            #so long val)
            maxLen = 0
            for val in self.x_vals:
                valLen = len(val)
                if valLen > maxLen:
                    maxLen = valLen
            if maxLen > 5:
                xVAxis.labels.dy = -35
                           
        xVAxis.labels.fontName = 'Helvetica'
        xVAxis.labels.fontSize = 7
        xVAxis.labels.angle = self.xValsDisplayAngle
        drawLegendF = False
        if len(self.legendList) > 0:
            drawLegendF = True
        drawLabelF = False
        lblCounts = len(self.x_vals) * len(self.y_vals)
        if lblCounts <= 30 and self.displayDataLbls == True:
            drawLabelF = True
        if len(self.x_vals) == 1:
            drawLabelF = True            
        #hack to increase chart height to include legend and labels
        total_height = 0
        legendHeight = 0
        if drawLegendF == True:
            #Kludge: We enchroach the space needed for legends by bringing down the 
            #y value by 28 (in drawOn()), we use that space here
            legendHeight = Y_height + 28
        graph_height = Y_height
        yVAxis.setPosition(X_start_pos, Y_start_pos, Y_height)
        yVAxis.valueMin = y_min
        yVAxis.valueMax = y_max    
        yVAxis.valueStep = y_step
        yVAxis.labels.fontName = 'Helvetica'
        yVAxis.labels.fontSize = 7
        yVAxis.labelTextFormat = '%0.' + '%d' % self.yAxisDigits + 'f'
        yVAxis.configure(self.y_vals)
        #will later sync the yVAxis as the ValueAxis of the graph
        self.drawing.add(xVAxis)
        if self.numSplits == 0:
            tmp = self.height
            self.height = self.origHeight
            self._drawLabels(self.title, self.x_label, self.y_label)
            self.height = tmp
        for graphtype in self.graphList:
            #Draw only one set of Legends/Labels for any dataset,
            #even if there are multiple charts drawn for the same dataset
            if self.labelsDrawnF == True and self.numSplits == 0:
                drawLabelF = False
            if self.legendsDrawnF == True and self.numSplits == 0:
                drawLegendF = False
            if graphtype == 'Bar':
                GraphObj = VerticalBarChart()
                GraphObj.valueAxis = yVAxis
                self.drawGraph(GraphObj, X_start_pos, Y_start_pos, X_width,
                        graph_height, drawLabelF, drawLegendF, legendHeight)
            if graphtype == 'Line':
                GraphObj = HorizontalLineChart()
                GraphObj.valueAxis = yVAxis
                self.drawGraph(GraphObj, X_start_pos, Y_start_pos, X_width,
                        graph_height, drawLabelF, drawLegendF, legendHeight)

    def _rawDraw(self, x, y):
        self.legendsDrawnF = False
        self.labelsDrawnF = False
        self.numSplits = 0
        self.tmpYVal = 0
        self.drawing = Drawing(self.width, self.height)
        self.origHeight = origHeight = self.height
        if (self.splitgraph == True and len(self.y_vals) > 1 and
                len(self.y_vals) * len(self.x_vals) > 30):
            origXval = x
            origYval = y
            origYvals = copy.deepcopy(self.y_vals)
            numSets = len(self.y_vals)
            origLegends = self.legendList[:]
            heightincr = origHeight/numSets
            self.numSplits = 0
            self.betweenSplitsF = True
            for i in range(numSets):
                self.y_vals = []
                self.y_vals.append(origYvals[i])
                self.height = heightincr
                y = y + (i * heightincr)
                self.legendList = []
                if len(origLegends) > i:
                    self.legendList.append(origLegends[i])
                self.generateGraphs(x, y)
                self.numSplits += 1
            self.betweenSplitsF = False
            self.y_vals = copy.deepcopy(origYvals)
            self.legendList = origLegends[:]
            self.height = self.origHeight
            x = origXval
            y = origYval
        else:
            self.generateGraphs(x, y)

    def drawOn(self, canvas, x, y, _sW=0):
        #There is basic support for drawing Barchart, Linechart for
        #the same dataset. This could be extended for more chart types
        #There is also basic support for including Legends in the chart
        #A list of Legends can be optionally specified. Legend config is
        #[String, Type,Color]. The last two are optional.
        #The charts are drawn in the order as specified in the config.
        #So, if the config is ['Line', 'Bar'], Linechart is drawn first
        #and then Barchart. Thus some parts of Line gets overdrawn by Bars.
        #To display both line and bar cleanly, it is suggested that the
        #config be ['Bar', 'Line']. There is also a minimum support to
        #split a chart. Separate charts are drawn in the same area for
        #each set of [y_vals].
        self.canvas = canvas
        self.canvas.saveState()
        self.drawing = Drawing(self.width, self.height)
        self.origHeight = origHeight = self.height
        if len(self.legendList) > 1:
            #Kludge: We encroach the space needed for legends by bringing down the 
            #y value by 28 below (y -= 28), so, the height is increased by 28
            self.origHeight += 28
        if (self.splitgraph == True and len(self.y_vals) > 1 and
                len(self.y_vals) * len(self.x_vals) > 30):
            origXval = x
            origYval = y
            origYvals = copy.deepcopy(self.y_vals)
            numSets = len(self.y_vals)
            origLegends = self.legendList[:]
            heightincr = origHeight/numSets
            self.numSplits = 0
            self.betweenSplitsF = True
            for i in range(numSets):
                self.y_vals = []
                self.y_vals.append(origYvals[i])
                self.height = heightincr
                y = y + (i * heightincr)
                self.legendList = []
                if len(origLegends) > i:
                    self.legendList.append(origLegends[i])
                    #Kludge: Bring the graph down by 28 points, as we add 28 points
                    #when we have legends 
                    y -= 28
                self.generateGraphs(x, y)
                self.numSplits += 1
            self.betweenSplitsF = False
            self.y_vals = copy.deepcopy(origYvals)
            self.legendList = origLegends[:]
            self.height = self.origHeight
            x = origXval
            y = origYval
        else:
            if len(self.legendList) > 0:
                #Kludge: Bring the graph down by 28 points, as we add 28 points
                #when we have legends 
                y -= 28
            self.generateGraphs(x, y)
        renderPDF.draw(self.drawing, self.canvas, x, y)
        self.canvas.restoreState()


class Chart(FlowableGraph, BasicGraph):
    def __init__(self, graphType = 'Pie', data = [ [[],[]] ]):
        """
        Draw pieChart.
        
        def __init__(self, graphType = 'Pie', data = [[dataList , dataLabels,
                                                       graphTitle, graphHeight, 
                                                       graphWidth],...])
        'dataList' contains the list of list of proportionate amounts of the slices
        x1, x2, x3,..xn, the pie chart would have slices of percentages 
        (x1/sum) * 100, (x2/sum) * 100, ... (xn/sum) * 100, where 
        sum = x1 + x2 + x3 + ...+ xn
        
        'dataLabels' are the corresponding list of list labels of the data given in 
        'dataList', so, it is expected that len(dataLabels) == len(dataList)
        
        'graphTitle' is the title of the graph. 
        
        'graphHeight', 'graphWidth' are height and width of the graph, so the pie chart
        can be elliptical. The values default to 2*inch, 2*inch. 
        
        One list [graphTitle, dataList ,dataLabels, graphHeight, graphWidth ] corresponds
        to one chart.  'dataLabels', 'graphTitle', 'graphHeight', and 'graphWidth' are
        optional
        
        When more than one Pie Chart is to be drawn, i.e., len(data) > 1, we draw as many 
        charts aside to each other as possible (based on the height, width of the graph)

        Extensions can be made to include other attributes such as label angle, slice 
        colors etc
        
        """
        
        #Each chart is surrounded by self.chartSideCushion space on both the sides
        #Each row is preceeded and succeeded by a cusion of self.interRowSpace
        self.chartSideCushion = 7
        self.interRowSpace = 21
        #We fix the width assuming the pdf generated is either A4 of US Letter
        flowableWidth       = 7.5 * inch
        data = self._setDefaults(data) 
        flowableHeight, self.rowBasedData = self._computeFlowableHeightAndRowBasedData(flowableWidth,
                                                                                       data)

        FlowableGraph.__init__(self, flowableWidth, flowableHeight)

        self.graphType = graphType
        
        #'self.minChartAreaWidth' minimum width of a chart, this affects the total number
        #of charts that can fit into a row
        self.minChartAreaWidth = 3*inch
        
    def _setDefaults(self, data):
        """
        Synopsis:
        
        Set the default optional parameters, if needed
        """
        for chartData in data:
            while len(chartData) < 5:
                chartData.append(None)
        
        formattedData = []        
        for chartData in data:
            dataList, dataLabels, chartTitle, chartHeight, chartWidth = chartData
            
            if not chartTitle:
                chartTitle = ''
                
            if not chartWidth or chartWidth <= 0:
                chartWidth = 1.5*inch
            if not chartHeight or chartHeight <= 0:
                chartHeight = 1.5*inch
                
            if chartWidth > 3.0*inch:
                print ("Given pie chart width is too high. \
                        It can't be greater than 3.0 inches\
                        Ignoring the chart'")
                continue
            
            if dataLabels and (len(dataLabels) != len(dataList)):
                print('The number of Data Labels and Data Values do not match.\
                       Ignoring the chart')
                continue
            
            formattedData.append([dataList, dataLabels, chartTitle, 
                                  chartHeight, chartWidth])
        return formattedData
    
    def _computeFlowableHeightAndRowBasedData(self, flowableWidth, data):
        """
        Assuming a list of pieCharts, we try to fit as many as possible (actually, this is
        also affected by 'self.minChartAreaWidth') in a row.
        If we are crossing the y boundary, we move to next row. Compute the total height
        of the graph. Each pieChart can have its own height, a rows height is the maximum
        height of any pieChart in that row
        """
        totalGraphWidth = 0.0
        x = 0
        thisRowHeight = 0
        totalHeight = 0
        firstInThisRowF = True
        rowCount = 1
        #dx = dy = 0
        thisRowCharts = []
        rowBasedData = []
        for chartData in data:
            _, _, _, charthHeight, chartWidth = chartData
            
            totalGraphWidth += ((2*self.chartSideCushion) + (2 * chartWidth))
                
            if totalGraphWidth > flowableWidth:
                rowCount += 1
                rowBasedData.append([thisRowHeight, thisRowCharts])
                totalHeight += thisRowHeight
                #We are onto a new row
                totalGraphWidth = ((2*self.chartSideCushion) + (2 * chartWidth))
                thisRowCharts = [chartData]
                thisRowHeight = charthHeight
            else:
                if thisRowHeight < charthHeight:
                    thisRowHeight = charthHeight
                thisRowCharts.append(chartData)
                firstInThisRowF = False
        #Handle the last row case 
        rowBasedData.append([thisRowHeight, thisRowCharts])
        totalHeight += thisRowHeight
            
        #Every row is preceeded and succeeded by interRowSpace
        totalHeight += ((2*self.interRowSpace) * rowCount)
            
        return totalHeight, rowBasedData

               
    def drawOn(self, canvas, x, y, _sW=0):
        """
        drawOn is the method of a flowable called when the pdf is printed
        """
        self.canvas = canvas
        self.canvas.saveState()
        self.drawing = Drawing(self.width, self.height)
        self._drawGraphs(x, y)
        renderPDF.draw(self.drawing, self.canvas, x, y)
        self.canvas.restoreState()
        
    def _drawGraphs(self, x, y):
        """
        Given x, y. We move to the top left of the graph area (using height of the graph)
        and then draw each row of charts, coming down with every row
        """
        #prevRowY holds the value of 'y' for the previous row's chart, we measure the 
        #current rows 'y' based on that y value
        prevRowY = self.height
        #For the first row, we place the label at the top of the flowable, since there is
        #no previous row, the space above this first row's label is 0
        #for subsequent rows labelSpaceCushion = self.interRowSpace
        firstRowF = True
        labelSpaceCushion = 0
        for rowData in self.rowBasedData:
            
            rowHeight, rowCharts = rowData

            labelY = prevRowY - labelSpaceCushion
            if firstRowF:
                labelSpaceCushion = self.interRowSpace
                cushionAbove = self.interRowSpace
                firstRowF = False
            else:
                cushionAbove = 2 * self.interRowSpace
            #We have a fixed  y coordinate for each row
            currentRowY = prevRowY - (cushionAbove + (rowHeight))
            
            #At the start of each row x-coordinate is reset
            currentChartX = 0
            #This is start of the row, so previous chart width is nill
            prevChartBoundary = 0
            chartAreaWidth = 0

            for chart in rowCharts:
                chartWidth = chart[4]
                #chartAreaWidth is the space within which we draw the label, this space
                #is the sum of chart diameter and 2* chartSideCushion
                chartAreaWidth = (2 * self.chartSideCushion) + (2 * chartWidth)
                
                #Keep chartAreaWidth at least 3 inches to keep the report eye appealing
                if chartAreaWidth < self.minChartAreaWidth:
                    chartAreaWidth = self.minChartAreaWidth
                    
                #chart x changes with each chart in every row
                #prevChartBoundary is the reference point, from which the current chart 
                #should be centered in an area of width chartAreaWidth, go to the 
                #center point of that chartArea and move back by the chart width (radius)
                #to get the x coordinate for the current chart
                currentChartX = ( prevChartBoundary + ((chartAreaWidth/2) - chartWidth))
                
                #Label is positioned such a way that the center of the label is 
                #chart's center point. labelX is evaluated accordingly
                labelCenter = currentChartX + chartWidth
                self._drawLabels(chart[2], labelCenter, labelY, chartAreaWidth)

                self._drawGraph(currentChartX, currentRowY, chart)
                prevChartBoundary += chartAreaWidth
            
            prevRowY = currentRowY
            
    def _drawGraph(self, x, y, chart):
        if self.graphType == 'Pie':
            chartHeight = chart[3]
            chartWidth = chart[4]
            chartData = chart[0]
            chartLabels = chart[1]
            legendOffset = 17
            pieChart = LegendedPie()
            pieChart.x = x
            pieChart.y = y
            pieChart.height = chartHeight
            pieChart.width = chartWidth
            pieChart.data = chartData
            pieChart.legend_data = chartData
            pieChart.drawLegend = 1
            pieChart.legendNumberFormat = '%.1f%%'
            pieChart.legend1.x = pieChart.x + pieChart.width + legendOffset
            pieChart.legend1.y = pieChart.height

            #pieChart.checkLabelOverlap = 0
            if len(chartLabels) != 0:
                pieChart.legend_names = chartLabels
                pieChart.pieAndLegend_colors = distinctColorList[:len(chartLabels)]

            """
            for i in range(len(chartData)):
                pieChart.slices[i].popout = ((i) * 10) % 25    #Don't need to popout first slice (i == 0)
                #pieChart.slices[i].labelRadius = 
            """
            self.drawing.add(pieChart)
            
    def _drawLabels(self, label, labelCenter, y, width):
        """
        Draw the label given in a given area originating at (x,y) with width 'width'
        """
        fontName = 'Times-Roman'
        fontSize = 10
        #Limit the length of the label to the boundaries of the chartAreaWidth
        
        strWidth = self._stringWidth(label, fontName, fontSize)
        #Calculate the area taken by one character
        oneCharWidth = self._stringWidth(label[0], fontName, fontSize)
        #If the given string needs more size, reduce the string to a length which fits
        #in the given area
        if strWidth > width:
            maxPossibleLen = int(width/oneCharWidth)
            label = label[:maxPossibleLen]
            strWidth = self._stringWidth(label, fontName, fontSize)
            
        x = (labelCenter - ((strWidth)/2))
        Label_Graph = Label()
        Label_Graph.fontName = fontName
        Label_Graph.fontSize = fontSize
        #Label_Graph.angle = 0
        Label_Graph.boxAnchor = 'n'
        Label_Graph.x = x
        Label_Graph.y = y
        Label_Graph.setText(label)
        self.drawing.add(Label_Graph)
