optionList = ['deauth', 'preauth', 'disassociate', 'dwellTime', \
              'pmkid', 'learningFlowFlag','reassoc', 'flowPacketSize',  \
              'flowRate', 'durationUnits', 'learningPacketRate',\
              'repeatValue', 'repeatType', 'renewDHCP','renewDHCPonConn','powerProfileFlag' ]

#Computes the time for which a group will have to wait at the start and end points of its 
#roam sequence.     
    
def computeWaitTimes(roamInterval, roamBenchDict, clientGroupNumsDict):
    global optionList
    cgWaitTimes = {}
    lastLoopEndWaitTime = {}
    oneCycleTime ={}
    roamGroupLists = [[]]
    roamRate = roamBenchDict['roamRate']
    finalRoundFractionTime = {}
    cgNames = []
    dictKeys = roamBenchDict.keys()
    for key in  dictKeys:
        if key not in ['roamRate', 'backgroundTraffic' , 'roamTraffic',
                       'callTrafficOptions', 'MediumCapacity','AcceptableRoamFailures','AcceptableRoamDelay'] and key not in optionList :
            cgNames.append(key)
    #Make sure we do not shuffle the starttime of the clientgroups, we call CGGenclients, Generateclients in sorted order
    cgNames.sort()
        
    #Compute oneCycleTime (the total time a group is in action), 
    repeatCount = {}
    repeatType = roamBenchDict['repeatType']
    testTypeVal =  roamBenchDict['repeatValue']
    durationUnits = roamBenchDict['durationUnits']
    allGroupsOneCycleTime = 0    #Used when the test type is 'Duration'
    groupTestTime = {}            #Used when the test type is 'Duration
    for cgName in  cgNames:
        roamList = roamBenchDict[cgName]['portNameList']
        oneCycleTime[cgName] = roamInterval * ((clientGroupNumsDict[cgName]) * (len(roamList)))
        allGroupsOneCycleTime += oneCycleTime[cgName]
        repeatCount[cgName] = 0
    #If the test type is 'Duration' , Compute the total test time in seconds.
    if repeatType == 1:
        if durationUnits == 1: #minutes
            testTypeVal *= 60
        elif durationUnits == 2: #hours
            testTypeVal *= 3600 
        totalTime = testTypeVal
        #Deduct the base call duration value, if the test is 'VoIP Roam Quality'
        if 'callTrafficOptions' in roamBenchDict:
            baseCallDurationUnits = roamBenchDict['callTrafficOptions']['baseCallDurationUnits']
            baseCallDurationVal = int(roamBenchDict['callTrafficOptions']['baseCallDurationVal'])
            if int(baseCallDurationUnits) == 1: #minutes
                baseCallDurationVal *= 60
            elif int(baseCallDurationUnits) == 2: #hours
                baseCallDurationVal *= 3600
            totalTime -= baseCallDurationVal
        commonRounds = int(totalTime/allGroupsOneCycleTime)#Number of times all groups completes an entire sequence
        if commonRounds >= 1:
            for cgName in cgNames:
                repeatCount[cgName] = commonRounds
        # % operator doesn't work properly when we have decimal as dividor
        fractRoundTime = totalTime - (commonRounds * allGroupsOneCycleTime)    
        remainingTime = fractRoundTime
        while remainingTime >= roamInterval:
            for cgName in cgNames:
                if remainingTime > oneCycleTime[cgName]:
                    repeatCount[cgName] += 1
                    remainingTime -= oneCycleTime[cgName]
                else:
                    finalRoundFractionTime[cgName] = remainingTime
                    repeatCount[cgName] += 1   #Even if we have a fraction of oneCycleTime, it means it is involved in another round
                    remainingTime = 0

        #We calculate the time each group gets in the total duration, this is required by 
        #scheduler
        for cgName in cgNames:
            if cgName not in finalRoundFractionTime.keys():
                groupTestTime[cgName] = repeatCount[cgName] * oneCycleTime[cgName]
            else:
                groupTestTime[cgName] = ((repeatCount[cgName]-1) * oneCycleTime[cgName]) +\
                                        finalRoundFractionTime[cgName]

    if repeatType == 2:
        for cgName in cgNames:
            repeatCount[cgName] = testTypeVal

     ###
    #Compute the roamGroupList
    #Create a list of lists containing the groups roaming at each iteration
    #The list could be like [[Group_1, Group_2], [Group_2]] where Group_2 roams
    #through 2 cycles and Group_1 roams only once. Initialise a dictionary
    #{GroupName:{'startWait':[]}
    for cgName in  cgNames:
        for j in range(repeatCount[cgName]):    
            if j > len(roamGroupLists)-1:
                roamGroupLists.append([])
            roamGroupLists[j].append(cgName)
        cgWaitTimes[cgName] = {"startWait": []}    #Initialisation
        lastLoopEndWaitTime[cgName] = 0
    
    currTime = 0.0
    for j in range(len(roamGroupLists)):
        CGnameList  = roamGroupLists[j]
        for cgName in CGnameList: 
            i = 0
            currTime = 0.0
            while i < len(CGnameList):
                if cgName == CGnameList[i]:
                    thisLoopStartWait = currTime + lastLoopEndWaitTime[cgName]
                    cgWaitTimes[cgName]["startWait"].append(thisLoopStartWait)
                    currTime = 0.0            #Later used for calculating lastLoopEndWaitTime
                    i += 1
                    
                else:
                    currTime += oneCycleTime[CGnameList[i]]
                    i += 1
            lastLoopEndWaitTime[cgName] = currTime
    return (cgWaitTimes, groupTestTime)

