# This file was created automatically by SWIG.
# Don't modify this file, modify the SWIG interface instead.
# This file is compatible with both classic and new-style classes.

import _vclapi

def _swig_setattr(self,class_type,name,value):
    if (name == "this"):
        if isinstance(value, class_type):
            self.__dict__[name] = value.this
            if hasattr(value,"thisown"): self.__dict__["thisown"] = value.thisown
            del value.thisown
            return
    method = class_type.__swig_setmethods__.get(name,None)
    if method: return method(self,value)
    self.__dict__[name] = value

def _swig_getattr(self,class_type,name):
    method = class_type.__swig_getmethods__.get(name,None)
    if method: return method(self)
    raise AttributeError,name

import types
try:
    _object = types.ObjectType
    _newclass = 1
except AttributeError:
    class _object : pass
    _newclass = 0
del types


class IntList(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, IntList, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, IntList, name)
    def __repr__(self):
        return "<C std::vector<(int)> instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, IntList, 'this', _vclapi.new_IntList(*args))
        _swig_setattr(self, IntList, 'thisown', 1)
    def __len__(*args): return _vclapi.IntList___len__(*args)
    def __nonzero__(*args): return _vclapi.IntList___nonzero__(*args)
    def clear(*args): return _vclapi.IntList_clear(*args)
    def append(*args): return _vclapi.IntList_append(*args)
    def pop(*args): return _vclapi.IntList_pop(*args)
    def __getitem__(*args): return _vclapi.IntList___getitem__(*args)
    def __getslice__(*args): return _vclapi.IntList___getslice__(*args)
    def __setitem__(*args): return _vclapi.IntList___setitem__(*args)
    def __setslice__(*args): return _vclapi.IntList___setslice__(*args)
    def __delitem__(*args): return _vclapi.IntList___delitem__(*args)
    def __delslice__(*args): return _vclapi.IntList___delslice__(*args)
    def __del__(self, destroy=_vclapi.delete_IntList):
        try:
            if self.thisown: destroy(self)
        except: pass

class IntListPtr(IntList):
    def __init__(self, this):
        _swig_setattr(self, IntList, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, IntList, 'thisown', 0)
        _swig_setattr(self, IntList,self.__class__,IntList)
_vclapi.IntList_swigregister(IntListPtr)

class StringList(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, StringList, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, StringList, name)
    def __repr__(self):
        return "<C std::vector<(std::string)> instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, StringList, 'this', _vclapi.new_StringList(*args))
        _swig_setattr(self, StringList, 'thisown', 1)
    def __len__(*args): return _vclapi.StringList___len__(*args)
    def __nonzero__(*args): return _vclapi.StringList___nonzero__(*args)
    def clear(*args): return _vclapi.StringList_clear(*args)
    def append(*args): return _vclapi.StringList_append(*args)
    def pop(*args): return _vclapi.StringList_pop(*args)
    def __getitem__(*args): return _vclapi.StringList___getitem__(*args)
    def __getslice__(*args): return _vclapi.StringList___getslice__(*args)
    def __setitem__(*args): return _vclapi.StringList___setitem__(*args)
    def __setslice__(*args): return _vclapi.StringList___setslice__(*args)
    def __delitem__(*args): return _vclapi.StringList___delitem__(*args)
    def __delslice__(*args): return _vclapi.StringList___delslice__(*args)
    def __del__(self, destroy=_vclapi.delete_StringList):
        try:
            if self.thisown: destroy(self)
        except: pass

class StringListPtr(StringList):
    def __init__(self, this):
        _swig_setattr(self, StringList, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, StringList, 'thisown', 0)
        _swig_setattr(self, StringList,self.__class__,StringList)
_vclapi.StringList_swigregister(StringListPtr)

class ULongLongList(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, ULongLongList, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, ULongLongList, name)
    def __repr__(self):
        return "<C std::vector<(vu64_t)> instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, ULongLongList, 'this', _vclapi.new_ULongLongList(*args))
        _swig_setattr(self, ULongLongList, 'thisown', 1)
    def __len__(*args): return _vclapi.ULongLongList___len__(*args)
    def __nonzero__(*args): return _vclapi.ULongLongList___nonzero__(*args)
    def clear(*args): return _vclapi.ULongLongList_clear(*args)
    def append(*args): return _vclapi.ULongLongList_append(*args)
    def pop(*args): return _vclapi.ULongLongList_pop(*args)
    def __getitem__(*args): return _vclapi.ULongLongList___getitem__(*args)
    def __getslice__(*args): return _vclapi.ULongLongList___getslice__(*args)
    def __setitem__(*args): return _vclapi.ULongLongList___setitem__(*args)
    def __setslice__(*args): return _vclapi.ULongLongList___setslice__(*args)
    def __delitem__(*args): return _vclapi.ULongLongList___delitem__(*args)
    def __delslice__(*args): return _vclapi.ULongLongList___delslice__(*args)
    def __del__(self, destroy=_vclapi.delete_ULongLongList):
        try:
            if self.thisown: destroy(self)
        except: pass

class ULongLongListPtr(ULongLongList):
    def __init__(self, this):
        _swig_setattr(self, ULongLongList, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, ULongLongList, 'thisown', 0)
        _swig_setattr(self, ULongLongList,self.__class__,ULongLongList)
_vclapi.ULongLongList_swigregister(ULongLongListPtr)

class VclChassis(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclChassis, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclChassis, name)
    def __repr__(self):
        return "<C VclChassis instance at %s>" % (self.this,)
    def connect(*args): return _vclapi.VclChassis_connect(*args)
    def disconnect(*args): return _vclapi.VclChassis_disconnect(*args)
    def closeConnection(*args): return _vclapi.VclChassis_closeConnection(*args)
    def disconnectAll(*args): return _vclapi.VclChassis_disconnectAll(*args)
    def read(*args): return _vclapi.VclChassis_read(*args)
    def scan(*args): return _vclapi.VclChassis_scan(*args)
    def getNames(*args): return _vclapi.VclChassis_getNames(*args)
    def getHostname(*args): return _vclapi.VclChassis_getHostname(*args)
    def getIpAddress(*args): return _vclapi.VclChassis_getIpAddress(*args)
    def getMacAddress(*args): return _vclapi.VclChassis_getMacAddress(*args)
    def getVersion(*args): return _vclapi.VclChassis_getVersion(*args)
    def getUserId(*args): return _vclapi.VclChassis_getUserId(*args)
    def getCardInfo(*args): return _vclapi.VclChassis_getCardInfo(*args)
    def getSchema(*args): return _vclapi.VclChassis_getSchema(*args)
    def getSchemaMin(*args): return _vclapi.VclChassis_getSchemaMin(*args)
    def getModelName(*args): return _vclapi.VclChassis_getModelName(*args)
    def getUid(*args): return _vclapi.VclChassis_getUid(*args)
    def getGid(*args): return _vclapi.VclChassis_getGid(*args)
    def setDefaults(*args): return _vclapi.VclChassis_setDefaults(*args)
    def setUserId(*args): return _vclapi.VclChassis_setUserId(*args)
    __swig_getmethods__["hostname"] = _vclapi.VclChassis_hostname_get
    if _newclass:hostname = property(_vclapi.VclChassis_hostname_get)
    __swig_getmethods__["ipAddress"] = _vclapi.VclChassis_ipAddress_get
    if _newclass:ipAddress = property(_vclapi.VclChassis_ipAddress_get)
    __swig_getmethods__["macAddress"] = _vclapi.VclChassis_macAddress_get
    if _newclass:macAddress = property(_vclapi.VclChassis_macAddress_get)
    __swig_getmethods__["version"] = _vclapi.VclChassis_version_get
    if _newclass:version = property(_vclapi.VclChassis_version_get)
    __swig_getmethods__["cardInfo"] = _vclapi.VclChassis_cardInfo_get
    if _newclass:cardInfo = property(_vclapi.VclChassis_cardInfo_get)
    __swig_getmethods__["userId"] = _vclapi.VclChassis_userId_get
    if _newclass:userId = property(_vclapi.VclChassis_userId_get)
    __swig_getmethods__["modelName"] = _vclapi.VclChassis_modelName_get
    if _newclass:modelName = property(_vclapi.VclChassis_modelName_get)
    __swig_getmethods__["uid"] = _vclapi.VclChassis_uid_get
    if _newclass:uid = property(_vclapi.VclChassis_uid_get)
    __swig_getmethods__["gid"] = _vclapi.VclChassis_gid_get
    if _newclass:gid = property(_vclapi.VclChassis_gid_get)
    def __init__(self, *args):
        _swig_setattr(self, VclChassis, 'this', _vclapi.new_VclChassis(*args))
        _swig_setattr(self, VclChassis, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclChassis):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclChassisPtr(VclChassis):
    def __init__(self, this):
        _swig_setattr(self, VclChassis, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclChassis, 'thisown', 0)
        _swig_setattr(self, VclChassis,self.__class__,VclChassis)
_vclapi.VclChassis_swigregister(VclChassisPtr)

class VclCard(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclCard, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclCard, name)
    def __repr__(self):
        return "<C VclCard instance at %s>" % (self.this,)
    def read(*args): return _vclapi.VclCard_read(*args)
    def getType(*args): return _vclapi.VclCard_getType(*args)
    def getNumPorts(*args): return _vclapi.VclCard_getNumPorts(*args)
    def getVersion(*args): return _vclapi.VclCard_getVersion(*args)
    def getPortInfo(*args): return _vclapi.VclCard_getPortInfo(*args)
    def getModelName(*args): return _vclapi.VclCard_getModelName(*args)
    __swig_getmethods__["type"] = _vclapi.VclCard_type_get
    if _newclass:type = property(_vclapi.VclCard_type_get)
    __swig_getmethods__["numPorts"] = _vclapi.VclCard_numPorts_get
    if _newclass:numPorts = property(_vclapi.VclCard_numPorts_get)
    __swig_getmethods__["version"] = _vclapi.VclCard_version_get
    if _newclass:version = property(_vclapi.VclCard_version_get)
    __swig_getmethods__["portInfo"] = _vclapi.VclCard_portInfo_get
    if _newclass:portInfo = property(_vclapi.VclCard_portInfo_get)
    __swig_getmethods__["modelName"] = _vclapi.VclCard_modelName_get
    if _newclass:modelName = property(_vclapi.VclCard_modelName_get)
    def __init__(self, *args):
        _swig_setattr(self, VclCard, 'this', _vclapi.new_VclCard(*args))
        _swig_setattr(self, VclCard, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclCard):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclCardPtr(VclCard):
    def __init__(self, this):
        _swig_setattr(self, VclCard, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclCard, 'thisown', 0)
        _swig_setattr(self, VclCard,self.__class__,VclCard)
_vclapi.VclCard_swigregister(VclCardPtr)

class VclPort(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclPort, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclPort, name)
    def __repr__(self):
        return "<C VclPort instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclPort_create(*args)
    def destroy(*args): return _vclapi.VclPort_destroy(*args)
    def releaseBinding(*args): return _vclapi.VclPort_releaseBinding(*args)
    def bind(*args): return _vclapi.VclPort_bind(*args)
    def unbind(*args): return _vclapi.VclPort_unbind(*args)
    def unbindAll(*args): return _vclapi.VclPort_unbindAll(*args)
    def alias(*args): return _vclapi.VclPort_alias(*args)
    def unalias(*args): return _vclapi.VclPort_unalias(*args)
    def read(*args): return _vclapi.VclPort_read(*args)
    def write(*args): return _vclapi.VclPort_write(*args)
    def reset(*args): return _vclapi.VclPort_reset(*args)
    def scanBssid(*args): return _vclapi.VclPort_scanBssid(*args)
    def scanBssidWithMac(*args): return _vclapi.VclPort_scanBssidWithMac(*args)
    def enableFeature(*args): return _vclapi.VclPort_enableFeature(*args)
    def sendFrame(*args): return _vclapi.VclPort_sendFrame(*args)
    def getNames(*args): return _vclapi.VclPort_getNames(*args)
    def getName(*args): return _vclapi.VclPort_getName(*args)
    def getType(*args): return _vclapi.VclPort_getType(*args)
    def getOwnerId(*args): return _vclapi.VclPort_getOwnerId(*args)
    def getBindingTag(*args): return _vclapi.VclPort_getBindingTag(*args)
    def getSchema(*args): return _vclapi.VclPort_getSchema(*args)
    def getSchemaMin(*args): return _vclapi.VclPort_getSchemaMin(*args)
    def getAutonegotiation(*args): return _vclapi.VclPort_getAutonegotiation(*args)
    def getDuplex(*args): return _vclapi.VclPort_getDuplex(*args)
    def getSpeed(*args): return _vclapi.VclPort_getSpeed(*args)
    def getLink(*args): return _vclapi.VclPort_getLink(*args)
    def getChannel(*args): return _vclapi.VclPort_getChannel(*args)
    def getBssidList(*args): return _vclapi.VclPort_getBssidList(*args)
    def getRadio(*args): return _vclapi.VclPort_getRadio(*args)
    def getNumTxFlows(*args): return _vclapi.VclPort_getNumTxFlows(*args)
    def getNumRxFlows(*args): return _vclapi.VclPort_getNumRxFlows(*args)
    def getMaxFlows(*args): return _vclapi.VclPort_getMaxFlows(*args)
    def getNumClients(*args): return _vclapi.VclPort_getNumClients(*args)
    def getMaxClients(*args): return _vclapi.VclPort_getMaxClients(*args)
    def getBssidFlags(*args): return _vclapi.VclPort_getBssidFlags(*args)
    def getBssidRsneIe(*args): return _vclapi.VclPort_getBssidRsneIe(*args)
    def getBssidSsid(*args): return _vclapi.VclPort_getBssidSsid(*args)
    def getBssidWpaIe(*args): return _vclapi.VclPort_getBssidWpaIe(*args)
    def getBssidHtiIe(*args): return _vclapi.VclPort_getBssidHtiIe(*args)
    def getBssidHtcIe(*args): return _vclapi.VclPort_getBssidHtcIe(*args)
    def getBssidSupportedRates(*args): return _vclapi.VclPort_getBssidSupportedRates(*args)
    def getBssidCapabilities(*args): return _vclapi.VclPort_getBssidCapabilities(*args)
    def getBssidQbssStaCount(*args): return _vclapi.VclPort_getBssidQbssStaCount(*args)
    def getBssidQbssAdmitCap(*args): return _vclapi.VclPort_getBssidQbssAdmitCap(*args)
    def getBssidQbssChanUtil(*args): return _vclapi.VclPort_getBssidQbssChanUtil(*args)
    def getBssidQosInfo(*args): return _vclapi.VclPort_getBssidQosInfo(*args)
    def getBssidQosFlags(*args): return _vclapi.VclPort_getBssidQosFlags(*args)
    def getBssidQosBeAci(*args): return _vclapi.VclPort_getBssidQosBeAci(*args)
    def getBssidQosBeAifsn(*args): return _vclapi.VclPort_getBssidQosBeAifsn(*args)
    def getBssidQosBeCwmin(*args): return _vclapi.VclPort_getBssidQosBeCwmin(*args)
    def getBssidQosBeCwmax(*args): return _vclapi.VclPort_getBssidQosBeCwmax(*args)
    def getBssidQosBeTxopLimit(*args): return _vclapi.VclPort_getBssidQosBeTxopLimit(*args)
    def getBssidQosBkAci(*args): return _vclapi.VclPort_getBssidQosBkAci(*args)
    def getBssidQosBkAifsn(*args): return _vclapi.VclPort_getBssidQosBkAifsn(*args)
    def getBssidQosBkCwmin(*args): return _vclapi.VclPort_getBssidQosBkCwmin(*args)
    def getBssidQosBkCwmax(*args): return _vclapi.VclPort_getBssidQosBkCwmax(*args)
    def getBssidQosBkTxopLimit(*args): return _vclapi.VclPort_getBssidQosBkTxopLimit(*args)
    def getBssidQosViAci(*args): return _vclapi.VclPort_getBssidQosViAci(*args)
    def getBssidQosViAifsn(*args): return _vclapi.VclPort_getBssidQosViAifsn(*args)
    def getBssidQosViCwmin(*args): return _vclapi.VclPort_getBssidQosViCwmin(*args)
    def getBssidQosViCwmax(*args): return _vclapi.VclPort_getBssidQosViCwmax(*args)
    def getBssidQosViTxopLimit(*args): return _vclapi.VclPort_getBssidQosViTxopLimit(*args)
    def getBssidQosVoAci(*args): return _vclapi.VclPort_getBssidQosVoAci(*args)
    def getBssidQosVoAifsn(*args): return _vclapi.VclPort_getBssidQosVoAifsn(*args)
    def getBssidQosVoCwmin(*args): return _vclapi.VclPort_getBssidQosVoCwmin(*args)
    def getBssidQosVoCwmax(*args): return _vclapi.VclPort_getBssidQosVoCwmax(*args)
    def getBssidQosVoTxopLimit(*args): return _vclapi.VclPort_getBssidQosVoTxopLimit(*args)
    def getBssidRssi(*args): return _vclapi.VclPort_getBssidRssi(*args)
    def getBssidCurrentChannel(*args): return _vclapi.VclPort_getBssidCurrentChannel(*args)
    def getBssidNonERPPresent(*args): return _vclapi.VclPort_getBssidNonERPPresent(*args)
    def getBssidUseProtect(*args): return _vclapi.VclPort_getBssidUseProtect(*args)
    def getBssidAllowShortPre(*args): return _vclapi.VclPort_getBssidAllowShortPre(*args)
    def getLatencyBoundariesEth(*args): return _vclapi.VclPort_getLatencyBoundariesEth(*args)
    def getLatencyBoundariesTxAc(*args): return _vclapi.VclPort_getLatencyBoundariesTxAc(*args)
    def getLatencyBoundariesTxTid(*args): return _vclapi.VclPort_getLatencyBoundariesTxTid(*args)
    def getLatencyBoundariesRxTid(*args): return _vclapi.VclPort_getLatencyBoundariesRxTid(*args)
    def getLatencyBoundariesRxFlow(*args): return _vclapi.VclPort_getLatencyBoundariesRxFlow(*args)
    def getRfcsTxEnabled(*args): return _vclapi.VclPort_getRfcsTxEnabled(*args)
    def getRfcsTxWeight(*args): return _vclapi.VclPort_getRfcsTxWeight(*args)
    def getContentionProbability(*args): return _vclapi.VclPort_getContentionProbability(*args)
    def getOperationalMode(*args): return _vclapi.VclPort_getOperationalMode(*args)
    def getOgBin1Low(*args): return _vclapi.VclPort_getOgBin1Low(*args)
    def getOgBin1High(*args): return _vclapi.VclPort_getOgBin1High(*args)
    def getOgBin1Probability(*args): return _vclapi.VclPort_getOgBin1Probability(*args)
    def getOgBin2Low(*args): return _vclapi.VclPort_getOgBin2Low(*args)
    def getOgBin2High(*args): return _vclapi.VclPort_getOgBin2High(*args)
    def getOgBin2Probability(*args): return _vclapi.VclPort_getOgBin2Probability(*args)
    def getOgBin3Low(*args): return _vclapi.VclPort_getOgBin3Low(*args)
    def getOgBin3High(*args): return _vclapi.VclPort_getOgBin3High(*args)
    def getOgBin3Probability(*args): return _vclapi.VclPort_getOgBin3Probability(*args)
    def getOgBin4Low(*args): return _vclapi.VclPort_getOgBin4Low(*args)
    def getOgBin4High(*args): return _vclapi.VclPort_getOgBin4High(*args)
    def getOgBin4Probability(*args): return _vclapi.VclPort_getOgBin4Probability(*args)
    def getSignatureOffset(*args): return _vclapi.VclPort_getSignatureOffset(*args)
    def getNumActiveClients(*args): return _vclapi.VclPort_getNumActiveClients(*args)
    def getNumActiveFlows(*args): return _vclapi.VclPort_getNumActiveFlows(*args)
    def getBssidSuppRatesMask(*args): return _vclapi.VclPort_getBssidSuppRatesMask(*args)
    def getBssidBasicSuppRatesMask(*args): return _vclapi.VclPort_getBssidBasicSuppRatesMask(*args)
    def getBssidRxMcsBitMask(*args): return _vclapi.VclPort_getBssidRxMcsBitMask(*args)
    def getRadioChannel(*args): return _vclapi.VclPort_getRadioChannel(*args)
    def getRadioBand(*args): return _vclapi.VclPort_getRadioBand(*args)
    def getSecondaryChannelPlacement(*args): return _vclapi.VclPort_getSecondaryChannelPlacement(*args)
    def getEnableRxAttenuation(*args): return _vclapi.VclPort_getEnableRxAttenuation(*args)
    def getEnableBackoff(*args): return _vclapi.VclPort_getEnableBackoff(*args)
    def getModelName(*args): return _vclapi.VclPort_getModelName(*args)
    def getPartCode(*args): return _vclapi.VclPort_getPartCode(*args)
    def getRadioMaxPower(*args): return _vclapi.VclPort_getRadioMaxPower(*args)
    def setDefaults(*args): return _vclapi.VclPort_setDefaults(*args)
    def setAutonegotiation(*args): return _vclapi.VclPort_setAutonegotiation(*args)
    def setDuplex(*args): return _vclapi.VclPort_setDuplex(*args)
    def setSpeed(*args): return _vclapi.VclPort_setSpeed(*args)
    def setChannel(*args): return _vclapi.VclPort_setChannel(*args)
    def setBssidList(*args): return _vclapi.VclPort_setBssidList(*args)
    def setRadio(*args): return _vclapi.VclPort_setRadio(*args)
    def setLatencyBoundaries(*args): return _vclapi.VclPort_setLatencyBoundaries(*args)
    def setLatencyBoundariesEth(*args): return _vclapi.VclPort_setLatencyBoundariesEth(*args)
    def setLatencyBoundariesTxAc(*args): return _vclapi.VclPort_setLatencyBoundariesTxAc(*args)
    def setLatencyBoundariesTxTid(*args): return _vclapi.VclPort_setLatencyBoundariesTxTid(*args)
    def setLatencyBoundariesRxTid(*args): return _vclapi.VclPort_setLatencyBoundariesRxTid(*args)
    def setLatencyBoundariesRxFlow(*args): return _vclapi.VclPort_setLatencyBoundariesRxFlow(*args)
    def setRfcsTxEnabled(*args): return _vclapi.VclPort_setRfcsTxEnabled(*args)
    def setRfcsTxWeight(*args): return _vclapi.VclPort_setRfcsTxWeight(*args)
    def setContentionProbability(*args): return _vclapi.VclPort_setContentionProbability(*args)
    def setOperationalMode(*args): return _vclapi.VclPort_setOperationalMode(*args)
    def setOgBin1Low(*args): return _vclapi.VclPort_setOgBin1Low(*args)
    def setOgBin1High(*args): return _vclapi.VclPort_setOgBin1High(*args)
    def setOgBin1Probability(*args): return _vclapi.VclPort_setOgBin1Probability(*args)
    def setOgBin2Low(*args): return _vclapi.VclPort_setOgBin2Low(*args)
    def setOgBin2High(*args): return _vclapi.VclPort_setOgBin2High(*args)
    def setOgBin2Probability(*args): return _vclapi.VclPort_setOgBin2Probability(*args)
    def setOgBin3Low(*args): return _vclapi.VclPort_setOgBin3Low(*args)
    def setOgBin3High(*args): return _vclapi.VclPort_setOgBin3High(*args)
    def setOgBin3Probability(*args): return _vclapi.VclPort_setOgBin3Probability(*args)
    def setOgBin4Low(*args): return _vclapi.VclPort_setOgBin4Low(*args)
    def setOgBin4High(*args): return _vclapi.VclPort_setOgBin4High(*args)
    def setOgBin4Probability(*args): return _vclapi.VclPort_setOgBin4Probability(*args)
    def setSignatureOffset(*args): return _vclapi.VclPort_setSignatureOffset(*args)
    def setRadioChannel(*args): return _vclapi.VclPort_setRadioChannel(*args)
    def setRadioBand(*args): return _vclapi.VclPort_setRadioBand(*args)
    def setSecondaryChannelPlacement(*args): return _vclapi.VclPort_setSecondaryChannelPlacement(*args)
    def setEnableRxAttenuation(*args): return _vclapi.VclPort_setEnableRxAttenuation(*args)
    def setEnableBackoff(*args): return _vclapi.VclPort_setEnableBackoff(*args)
    __swig_setmethods__["name"] = _vclapi.VclPort_name_set
    __swig_getmethods__["name"] = _vclapi.VclPort_name_get
    if _newclass:name = property(_vclapi.VclPort_name_get, _vclapi.VclPort_name_set)
    __swig_getmethods__["type"] = _vclapi.VclPort_type_get
    if _newclass:type = property(_vclapi.VclPort_type_get)
    __swig_getmethods__["ownerId"] = _vclapi.VclPort_ownerId_get
    if _newclass:ownerId = property(_vclapi.VclPort_ownerId_get)
    __swig_getmethods__["bindingTag"] = _vclapi.VclPort_bindingTag_get
    if _newclass:bindingTag = property(_vclapi.VclPort_bindingTag_get)
    __swig_setmethods__["autoneg"] = _vclapi.VclPort_autoneg_set
    __swig_getmethods__["autoneg"] = _vclapi.VclPort_autoneg_get
    if _newclass:autoneg = property(_vclapi.VclPort_autoneg_get, _vclapi.VclPort_autoneg_set)
    __swig_setmethods__["duplex"] = _vclapi.VclPort_duplex_set
    __swig_getmethods__["duplex"] = _vclapi.VclPort_duplex_get
    if _newclass:duplex = property(_vclapi.VclPort_duplex_get, _vclapi.VclPort_duplex_set)
    __swig_setmethods__["speed"] = _vclapi.VclPort_speed_set
    __swig_getmethods__["speed"] = _vclapi.VclPort_speed_get
    if _newclass:speed = property(_vclapi.VclPort_speed_get, _vclapi.VclPort_speed_set)
    __swig_getmethods__["link"] = _vclapi.VclPort_link_get
    if _newclass:link = property(_vclapi.VclPort_link_get)
    __swig_setmethods__["channel"] = _vclapi.VclPort_channel_set
    __swig_getmethods__["channel"] = _vclapi.VclPort_channel_get
    if _newclass:channel = property(_vclapi.VclPort_channel_get, _vclapi.VclPort_channel_set)
    __swig_setmethods__["bssidList"] = _vclapi.VclPort_bssidList_set
    __swig_getmethods__["bssidList"] = _vclapi.VclPort_bssidList_get
    if _newclass:bssidList = property(_vclapi.VclPort_bssidList_get, _vclapi.VclPort_bssidList_set)
    __swig_setmethods__["radio"] = _vclapi.VclPort_radio_set
    __swig_getmethods__["radio"] = _vclapi.VclPort_radio_get
    if _newclass:radio = property(_vclapi.VclPort_radio_get, _vclapi.VclPort_radio_set)
    __swig_setmethods__["latencyBoundariesEth"] = _vclapi.VclPort_latencyBoundariesEth_set
    __swig_getmethods__["latencyBoundariesEth"] = _vclapi.VclPort_latencyBoundariesEth_get
    if _newclass:latencyBoundariesEth = property(_vclapi.VclPort_latencyBoundariesEth_get, _vclapi.VclPort_latencyBoundariesEth_set)
    __swig_setmethods__["latencyBoundariesTxAc"] = _vclapi.VclPort_latencyBoundariesTxAc_set
    __swig_getmethods__["latencyBoundariesTxAc"] = _vclapi.VclPort_latencyBoundariesTxAc_get
    if _newclass:latencyBoundariesTxAc = property(_vclapi.VclPort_latencyBoundariesTxAc_get, _vclapi.VclPort_latencyBoundariesTxAc_set)
    __swig_setmethods__["latencyBoundariesTxTid"] = _vclapi.VclPort_latencyBoundariesTxTid_set
    __swig_getmethods__["latencyBoundariesTxTid"] = _vclapi.VclPort_latencyBoundariesTxTid_get
    if _newclass:latencyBoundariesTxTid = property(_vclapi.VclPort_latencyBoundariesTxTid_get, _vclapi.VclPort_latencyBoundariesTxTid_set)
    __swig_setmethods__["latencyBoundariesRxTid"] = _vclapi.VclPort_latencyBoundariesRxTid_set
    __swig_getmethods__["latencyBoundariesRxTid"] = _vclapi.VclPort_latencyBoundariesRxTid_get
    if _newclass:latencyBoundariesRxTid = property(_vclapi.VclPort_latencyBoundariesRxTid_get, _vclapi.VclPort_latencyBoundariesRxTid_set)
    __swig_setmethods__["latencyBoundariesRxFlow"] = _vclapi.VclPort_latencyBoundariesRxFlow_set
    __swig_getmethods__["latencyBoundariesRxFlow"] = _vclapi.VclPort_latencyBoundariesRxFlow_get
    if _newclass:latencyBoundariesRxFlow = property(_vclapi.VclPort_latencyBoundariesRxFlow_get, _vclapi.VclPort_latencyBoundariesRxFlow_set)
    __swig_getmethods__["numTxFlows"] = _vclapi.VclPort_numTxFlows_get
    if _newclass:numTxFlows = property(_vclapi.VclPort_numTxFlows_get)
    __swig_getmethods__["numRxFlows"] = _vclapi.VclPort_numRxFlows_get
    if _newclass:numRxFlows = property(_vclapi.VclPort_numRxFlows_get)
    __swig_getmethods__["maxFlows"] = _vclapi.VclPort_maxFlows_get
    if _newclass:maxFlows = property(_vclapi.VclPort_maxFlows_get)
    __swig_getmethods__["numClients"] = _vclapi.VclPort_numClients_get
    if _newclass:numClients = property(_vclapi.VclPort_numClients_get)
    __swig_getmethods__["maxClients"] = _vclapi.VclPort_maxClients_get
    if _newclass:maxClients = property(_vclapi.VclPort_maxClients_get)
    __swig_getmethods__["numActiveClients"] = _vclapi.VclPort_numActiveClients_get
    if _newclass:numActiveClients = property(_vclapi.VclPort_numActiveClients_get)
    __swig_getmethods__["numActiveFlows"] = _vclapi.VclPort_numActiveFlows_get
    if _newclass:numActiveFlows = property(_vclapi.VclPort_numActiveFlows_get)
    __swig_setmethods__["rfcsTxEnabled"] = _vclapi.VclPort_rfcsTxEnabled_set
    __swig_getmethods__["rfcsTxEnabled"] = _vclapi.VclPort_rfcsTxEnabled_get
    if _newclass:rfcsTxEnabled = property(_vclapi.VclPort_rfcsTxEnabled_get, _vclapi.VclPort_rfcsTxEnabled_set)
    __swig_setmethods__["rfcsTxWeight"] = _vclapi.VclPort_rfcsTxWeight_set
    __swig_getmethods__["rfcsTxWeight"] = _vclapi.VclPort_rfcsTxWeight_get
    if _newclass:rfcsTxWeight = property(_vclapi.VclPort_rfcsTxWeight_get, _vclapi.VclPort_rfcsTxWeight_set)
    __swig_setmethods__["operationalMode"] = _vclapi.VclPort_operationalMode_set
    __swig_getmethods__["operationalMode"] = _vclapi.VclPort_operationalMode_get
    if _newclass:operationalMode = property(_vclapi.VclPort_operationalMode_get, _vclapi.VclPort_operationalMode_set)
    __swig_setmethods__["ogBin1Low"] = _vclapi.VclPort_ogBin1Low_set
    __swig_getmethods__["ogBin1Low"] = _vclapi.VclPort_ogBin1Low_get
    if _newclass:ogBin1Low = property(_vclapi.VclPort_ogBin1Low_get, _vclapi.VclPort_ogBin1Low_set)
    __swig_setmethods__["ogBin1High"] = _vclapi.VclPort_ogBin1High_set
    __swig_getmethods__["ogBin1High"] = _vclapi.VclPort_ogBin1High_get
    if _newclass:ogBin1High = property(_vclapi.VclPort_ogBin1High_get, _vclapi.VclPort_ogBin1High_set)
    __swig_setmethods__["ogBin1Probability"] = _vclapi.VclPort_ogBin1Probability_set
    __swig_getmethods__["ogBin1Probability"] = _vclapi.VclPort_ogBin1Probability_get
    if _newclass:ogBin1Probability = property(_vclapi.VclPort_ogBin1Probability_get, _vclapi.VclPort_ogBin1Probability_set)
    __swig_setmethods__["ogBin2Low"] = _vclapi.VclPort_ogBin2Low_set
    __swig_getmethods__["ogBin2Low"] = _vclapi.VclPort_ogBin2Low_get
    if _newclass:ogBin2Low = property(_vclapi.VclPort_ogBin2Low_get, _vclapi.VclPort_ogBin2Low_set)
    __swig_setmethods__["ogBin2High"] = _vclapi.VclPort_ogBin2High_set
    __swig_getmethods__["ogBin2High"] = _vclapi.VclPort_ogBin2High_get
    if _newclass:ogBin2High = property(_vclapi.VclPort_ogBin2High_get, _vclapi.VclPort_ogBin2High_set)
    __swig_setmethods__["ogBin2Probability"] = _vclapi.VclPort_ogBin2Probability_set
    __swig_getmethods__["ogBin2Probability"] = _vclapi.VclPort_ogBin2Probability_get
    if _newclass:ogBin2Probability = property(_vclapi.VclPort_ogBin2Probability_get, _vclapi.VclPort_ogBin2Probability_set)
    __swig_setmethods__["ogBin3Low"] = _vclapi.VclPort_ogBin3Low_set
    __swig_getmethods__["ogBin3Low"] = _vclapi.VclPort_ogBin3Low_get
    if _newclass:ogBin3Low = property(_vclapi.VclPort_ogBin3Low_get, _vclapi.VclPort_ogBin3Low_set)
    __swig_setmethods__["ogBin3High"] = _vclapi.VclPort_ogBin3High_set
    __swig_getmethods__["ogBin3High"] = _vclapi.VclPort_ogBin3High_get
    if _newclass:ogBin3High = property(_vclapi.VclPort_ogBin3High_get, _vclapi.VclPort_ogBin3High_set)
    __swig_setmethods__["ogBin3Probability"] = _vclapi.VclPort_ogBin3Probability_set
    __swig_getmethods__["ogBin3Probability"] = _vclapi.VclPort_ogBin3Probability_get
    if _newclass:ogBin3Probability = property(_vclapi.VclPort_ogBin3Probability_get, _vclapi.VclPort_ogBin3Probability_set)
    __swig_setmethods__["ogBin4Low"] = _vclapi.VclPort_ogBin4Low_set
    __swig_getmethods__["ogBin4Low"] = _vclapi.VclPort_ogBin4Low_get
    if _newclass:ogBin4Low = property(_vclapi.VclPort_ogBin4Low_get, _vclapi.VclPort_ogBin4Low_set)
    __swig_setmethods__["ogBin4High"] = _vclapi.VclPort_ogBin4High_set
    __swig_getmethods__["ogBin4High"] = _vclapi.VclPort_ogBin4High_get
    if _newclass:ogBin4High = property(_vclapi.VclPort_ogBin4High_get, _vclapi.VclPort_ogBin4High_set)
    __swig_setmethods__["ogBin4Probability"] = _vclapi.VclPort_ogBin4Probability_set
    __swig_getmethods__["ogBin4Probability"] = _vclapi.VclPort_ogBin4Probability_get
    if _newclass:ogBin4Probability = property(_vclapi.VclPort_ogBin4Probability_get, _vclapi.VclPort_ogBin4Probability_set)
    __swig_setmethods__["signatureOffset"] = _vclapi.VclPort_signatureOffset_set
    __swig_getmethods__["signatureOffset"] = _vclapi.VclPort_signatureOffset_get
    if _newclass:signatureOffset = property(_vclapi.VclPort_signatureOffset_get, _vclapi.VclPort_signatureOffset_set)
    __swig_setmethods__["radioChannel"] = _vclapi.VclPort_radioChannel_set
    __swig_getmethods__["radioChannel"] = _vclapi.VclPort_radioChannel_get
    if _newclass:radioChannel = property(_vclapi.VclPort_radioChannel_get, _vclapi.VclPort_radioChannel_set)
    __swig_setmethods__["radioBand"] = _vclapi.VclPort_radioBand_set
    __swig_getmethods__["radioBand"] = _vclapi.VclPort_radioBand_get
    if _newclass:radioBand = property(_vclapi.VclPort_radioBand_get, _vclapi.VclPort_radioBand_set)
    __swig_setmethods__["secondaryChannelPlacement"] = _vclapi.VclPort_secondaryChannelPlacement_set
    __swig_getmethods__["secondaryChannelPlacement"] = _vclapi.VclPort_secondaryChannelPlacement_get
    if _newclass:secondaryChannelPlacement = property(_vclapi.VclPort_secondaryChannelPlacement_get, _vclapi.VclPort_secondaryChannelPlacement_set)
    __swig_setmethods__["enableRxAttenuation"] = _vclapi.VclPort_enableRxAttenuation_set
    __swig_getmethods__["enableRxAttenuation"] = _vclapi.VclPort_enableRxAttenuation_get
    if _newclass:enableRxAttenuation = property(_vclapi.VclPort_enableRxAttenuation_get, _vclapi.VclPort_enableRxAttenuation_set)
    __swig_setmethods__["enableBackoff"] = _vclapi.VclPort_enableBackoff_set
    __swig_getmethods__["enableBackoff"] = _vclapi.VclPort_enableBackoff_get
    if _newclass:enableBackoff = property(_vclapi.VclPort_enableBackoff_get, _vclapi.VclPort_enableBackoff_set)
    __swig_getmethods__["modelName"] = _vclapi.VclPort_modelName_get
    if _newclass:modelName = property(_vclapi.VclPort_modelName_get)
    __swig_getmethods__["partCode"] = _vclapi.VclPort_partCode_get
    if _newclass:partCode = property(_vclapi.VclPort_partCode_get)
    __swig_getmethods__["radioMaxPower"] = _vclapi.VclPort_radioMaxPower_get
    if _newclass:radioMaxPower = property(_vclapi.VclPort_radioMaxPower_get)
    def __init__(self, *args):
        _swig_setattr(self, VclPort, 'this', _vclapi.new_VclPort(*args))
        _swig_setattr(self, VclPort, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclPort):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclPortPtr(VclPort):
    def __init__(self, this):
        _swig_setattr(self, VclPort, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclPort, 'thisown', 0)
        _swig_setattr(self, VclPort,self.__class__,VclPort)
_vclapi.VclPort_swigregister(VclPortPtr)

class VclClientGroup(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclClientGroup, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclClientGroup, name)
    def __repr__(self):
        return "<C VclClientGroup instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclClientGroup_create(*args)
    def destroy(*args): return _vclapi.VclClientGroup_destroy(*args)
    def write(*args): return _vclapi.VclClientGroup_write(*args)
    def read(*args): return _vclapi.VclClientGroup_read(*args)
    def add(*args): return _vclapi.VclClientGroup_add(*args)
    def remove(*args): return _vclapi.VclClientGroup_remove(*args)
    def validate(*args): return _vclapi.VclClientGroup_validate(*args)
    def doConnectToAP(*args): return _vclapi.VclClientGroup_doConnectToAP(*args)
    def doAuthentication(*args): return _vclapi.VclClientGroup_doAuthentication(*args)
    def doDeauthentication(*args): return _vclapi.VclClientGroup_doDeauthentication(*args)
    def doAssociation(*args): return _vclapi.VclClientGroup_doAssociation(*args)
    def doReassociation(*args): return _vclapi.VclClientGroup_doReassociation(*args)
    def doDisassociation(*args): return _vclapi.VclClientGroup_doDisassociation(*args)
    def doDhcpExchange(*args): return _vclapi.VclClientGroup_doDhcpExchange(*args)
    def doGratuitousArp(*args): return _vclapi.VclClientGroup_doGratuitousArp(*args)
    def checkStatus(*args): return _vclapi.VclClientGroup_checkStatus(*args)
    def getNames(*args): return _vclapi.VclClientGroup_getNames(*args)
    def getClientNames(*args): return _vclapi.VclClientGroup_getClientNames(*args)
    def getSecurity(*args): return _vclapi.VclClientGroup_getSecurity(*args)
    def getConnectionInterval(*args): return _vclapi.VclClientGroup_getConnectionInterval(*args)
    def setDefaults(*args): return _vclapi.VclClientGroup_setDefaults(*args)
    def setSecurity(*args): return _vclapi.VclClientGroup_setSecurity(*args)
    def setConnectionInterval(*args): return _vclapi.VclClientGroup_setConnectionInterval(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclClientGroup, 'this', _vclapi.new_VclClientGroup(*args))
        _swig_setattr(self, VclClientGroup, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclClientGroup):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclClientGroupPtr(VclClientGroup):
    def __init__(self, this):
        _swig_setattr(self, VclClientGroup, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclClientGroup, 'thisown', 0)
        _swig_setattr(self, VclClientGroup,self.__class__,VclClientGroup)
_vclapi.VclClientGroup_swigregister(VclClientGroupPtr)

class VclEthernetClient(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclEthernetClient, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclEthernetClient, name)
    def __repr__(self):
        return "<C VclEthernetClient instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclEthernetClient_create(*args)
    def destroy(*args): return _vclapi.VclEthernetClient_destroy(*args)
    def read(*args): return _vclapi.VclEthernetClient_read(*args)
    def write(*args): return _vclapi.VclEthernetClient_write(*args)
    def getClientType(*args): return _vclapi.VclEthernetClient_getClientType(*args)
    def doDhcpExchange(*args): return _vclapi.VclEthernetClient_doDhcpExchange(*args)
    def doEapolHandshake(*args): return _vclapi.VclEthernetClient_doEapolHandshake(*args)
    def checkStatus(*args): return _vclapi.VclEthernetClient_checkStatus(*args)
    def enableNetworkInterface(*args): return _vclapi.VclEthernetClient_enableNetworkInterface(*args)
    def getNames(*args): return _vclapi.VclEthernetClient_getNames(*args)
    def sendFrame(*args): return _vclapi.VclEthernetClient_sendFrame(*args)
    def updateSecurity(*args): return _vclapi.VclEthernetClient_updateSecurity(*args)
    def doConnectEc(*args): return _vclapi.VclEthernetClient_doConnectEc(*args)
    def disconnectEc(*args): return _vclapi.VclEthernetClient_disconnectEc(*args)
    def getConnectionHandshakeTime(*args): return _vclapi.VclEthernetClient_getConnectionHandshakeTime(*args)
    def getName(*args): return _vclapi.VclEthernetClient_getName(*args)
    def getState(*args): return _vclapi.VclEthernetClient_getState(*args)
    def getProtocolType(*args): return _vclapi.VclEthernetClient_getProtocolType(*args)
    def getIpAddress(*args): return _vclapi.VclEthernetClient_getIpAddress(*args)
    def getIpAddressMode(*args): return _vclapi.VclEthernetClient_getIpAddressMode(*args)
    def getGateway(*args): return _vclapi.VclEthernetClient_getGateway(*args)
    def getMacAddress(*args): return _vclapi.VclEthernetClient_getMacAddress(*args)
    def getArpResponse(*args): return _vclapi.VclEthernetClient_getArpResponse(*args)
    def getSubnetMask(*args): return _vclapi.VclEthernetClient_getSubnetMask(*args)
    def getPort(*args): return _vclapi.VclEthernetClient_getPort(*args)
    def getVlanTag(*args): return _vclapi.VclEthernetClient_getVlanTag(*args)
    def getArpTimeout(*args): return _vclapi.VclEthernetClient_getArpTimeout(*args)
    def getRetryProt(*args): return _vclapi.VclEthernetClient_getRetryProt(*args)
    def getSecurity(*args): return _vclapi.VclEthernetClient_getSecurity(*args)
    def getNetworkAuthMethod(*args): return _vclapi.VclEthernetClient_getNetworkAuthMethod(*args)
    def getIdentity(*args): return _vclapi.VclEthernetClient_getIdentity(*args)
    def getAnonymousIdentity(*args): return _vclapi.VclEthernetClient_getAnonymousIdentity(*args)
    def getPassword(*args): return _vclapi.VclEthernetClient_getPassword(*args)
    def getRootCertificate(*args): return _vclapi.VclEthernetClient_getRootCertificate(*args)
    def getClientCertificate(*args): return _vclapi.VclEthernetClient_getClientCertificate(*args)
    def getPrivateKeyFile(*args): return _vclapi.VclEthernetClient_getPrivateKeyFile(*args)
    def getEnableValidateCertificate(*args): return _vclapi.VclEthernetClient_getEnableValidateCertificate(*args)
    def getEnableVcReconnect(*args): return _vclapi.VclEthernetClient_getEnableVcReconnect(*args)
    def getInitNextVc(*args): return _vclapi.VclEthernetClient_getInitNextVc(*args)
    def getChainedConnectionInterval(*args): return _vclapi.VclEthernetClient_getChainedConnectionInterval(*args)
    def getVcConnectionInterval(*args): return _vclapi.VclEthernetClient_getVcConnectionInterval(*args)
    def getNextVc(*args): return _vclapi.VclEthernetClient_getNextVc(*args)
    def getDhcpTimeout(*args): return _vclapi.VclEthernetClient_getDhcpTimeout(*args)
    def setDefaults(*args): return _vclapi.VclEthernetClient_setDefaults(*args)
    def setIpAddress(*args): return _vclapi.VclEthernetClient_setIpAddress(*args)
    def setIpAddressMode(*args): return _vclapi.VclEthernetClient_setIpAddressMode(*args)
    def setGateway(*args): return _vclapi.VclEthernetClient_setGateway(*args)
    def setMacAddress(*args): return _vclapi.VclEthernetClient_setMacAddress(*args)
    def setArpResponse(*args): return _vclapi.VclEthernetClient_setArpResponse(*args)
    def setSubnetMask(*args): return _vclapi.VclEthernetClient_setSubnetMask(*args)
    def setPort(*args): return _vclapi.VclEthernetClient_setPort(*args)
    def setVlanTag(*args): return _vclapi.VclEthernetClient_setVlanTag(*args)
    def setArpTimeout(*args): return _vclapi.VclEthernetClient_setArpTimeout(*args)
    def setRetryProt(*args): return _vclapi.VclEthernetClient_setRetryProt(*args)
    def setSecurity(*args): return _vclapi.VclEthernetClient_setSecurity(*args)
    def setNetworkAuthMethod(*args): return _vclapi.VclEthernetClient_setNetworkAuthMethod(*args)
    def setIdentity(*args): return _vclapi.VclEthernetClient_setIdentity(*args)
    def setAnonymousIdentity(*args): return _vclapi.VclEthernetClient_setAnonymousIdentity(*args)
    def setPassword(*args): return _vclapi.VclEthernetClient_setPassword(*args)
    def setRootCertificate(*args): return _vclapi.VclEthernetClient_setRootCertificate(*args)
    def setClientCertificate(*args): return _vclapi.VclEthernetClient_setClientCertificate(*args)
    def setPrivateKeyFile(*args): return _vclapi.VclEthernetClient_setPrivateKeyFile(*args)
    def setEnableValidateCertificate(*args): return _vclapi.VclEthernetClient_setEnableValidateCertificate(*args)
    def setEnableVcReconnect(*args): return _vclapi.VclEthernetClient_setEnableVcReconnect(*args)
    def setInitNextVc(*args): return _vclapi.VclEthernetClient_setInitNextVc(*args)
    def setChainedConnectionInterval(*args): return _vclapi.VclEthernetClient_setChainedConnectionInterval(*args)
    def setVcConnectionInterval(*args): return _vclapi.VclEthernetClient_setVcConnectionInterval(*args)
    def setNextVc(*args): return _vclapi.VclEthernetClient_setNextVc(*args)
    def setDhcpTimeout(*args): return _vclapi.VclEthernetClient_setDhcpTimeout(*args)
    __swig_getmethods__["name"] = _vclapi.VclEthernetClient_name_get
    if _newclass:name = property(_vclapi.VclEthernetClient_name_get)
    __swig_setmethods__["protocolType"] = _vclapi.VclEthernetClient_protocolType_set
    __swig_getmethods__["protocolType"] = _vclapi.VclEthernetClient_protocolType_get
    if _newclass:protocolType = property(_vclapi.VclEthernetClient_protocolType_get, _vclapi.VclEthernetClient_protocolType_set)
    __swig_setmethods__["port"] = _vclapi.VclEthernetClient_port_set
    __swig_getmethods__["port"] = _vclapi.VclEthernetClient_port_get
    if _newclass:port = property(_vclapi.VclEthernetClient_port_get, _vclapi.VclEthernetClient_port_set)
    __swig_setmethods__["ipAddress"] = _vclapi.VclEthernetClient_ipAddress_set
    __swig_getmethods__["ipAddress"] = _vclapi.VclEthernetClient_ipAddress_get
    if _newclass:ipAddress = property(_vclapi.VclEthernetClient_ipAddress_get, _vclapi.VclEthernetClient_ipAddress_set)
    __swig_setmethods__["ipAddressMode"] = _vclapi.VclEthernetClient_ipAddressMode_set
    __swig_getmethods__["ipAddressMode"] = _vclapi.VclEthernetClient_ipAddressMode_get
    if _newclass:ipAddressMode = property(_vclapi.VclEthernetClient_ipAddressMode_get, _vclapi.VclEthernetClient_ipAddressMode_set)
    __swig_setmethods__["subnetMask"] = _vclapi.VclEthernetClient_subnetMask_set
    __swig_getmethods__["subnetMask"] = _vclapi.VclEthernetClient_subnetMask_get
    if _newclass:subnetMask = property(_vclapi.VclEthernetClient_subnetMask_get, _vclapi.VclEthernetClient_subnetMask_set)
    __swig_setmethods__["gateway"] = _vclapi.VclEthernetClient_gateway_set
    __swig_getmethods__["gateway"] = _vclapi.VclEthernetClient_gateway_get
    if _newclass:gateway = property(_vclapi.VclEthernetClient_gateway_get, _vclapi.VclEthernetClient_gateway_set)
    __swig_setmethods__["macAddress"] = _vclapi.VclEthernetClient_macAddress_set
    __swig_getmethods__["macAddress"] = _vclapi.VclEthernetClient_macAddress_get
    if _newclass:macAddress = property(_vclapi.VclEthernetClient_macAddress_get, _vclapi.VclEthernetClient_macAddress_set)
    __swig_setmethods__["arpResponse"] = _vclapi.VclEthernetClient_arpResponse_set
    __swig_getmethods__["arpResponse"] = _vclapi.VclEthernetClient_arpResponse_get
    if _newclass:arpResponse = property(_vclapi.VclEthernetClient_arpResponse_get, _vclapi.VclEthernetClient_arpResponse_set)
    __swig_setmethods__["vlanTag"] = _vclapi.VclEthernetClient_vlanTag_set
    __swig_getmethods__["vlanTag"] = _vclapi.VclEthernetClient_vlanTag_get
    if _newclass:vlanTag = property(_vclapi.VclEthernetClient_vlanTag_get, _vclapi.VclEthernetClient_vlanTag_set)
    __swig_getmethods__["state"] = _vclapi.VclEthernetClient_state_get
    if _newclass:state = property(_vclapi.VclEthernetClient_state_get)
    __swig_setmethods__["arpTimeout"] = _vclapi.VclEthernetClient_arpTimeout_set
    __swig_getmethods__["arpTimeout"] = _vclapi.VclEthernetClient_arpTimeout_get
    if _newclass:arpTimeout = property(_vclapi.VclEthernetClient_arpTimeout_get, _vclapi.VclEthernetClient_arpTimeout_set)
    __swig_setmethods__["retryProt"] = _vclapi.VclEthernetClient_retryProt_set
    __swig_getmethods__["retryProt"] = _vclapi.VclEthernetClient_retryProt_get
    if _newclass:retryProt = property(_vclapi.VclEthernetClient_retryProt_get, _vclapi.VclEthernetClient_retryProt_set)
    __swig_setmethods__["security"] = _vclapi.VclEthernetClient_security_set
    __swig_getmethods__["security"] = _vclapi.VclEthernetClient_security_get
    if _newclass:security = property(_vclapi.VclEthernetClient_security_get, _vclapi.VclEthernetClient_security_set)
    __swig_setmethods__["networkAuthMethod"] = _vclapi.VclEthernetClient_networkAuthMethod_set
    __swig_getmethods__["networkAuthMethod"] = _vclapi.VclEthernetClient_networkAuthMethod_get
    if _newclass:networkAuthMethod = property(_vclapi.VclEthernetClient_networkAuthMethod_get, _vclapi.VclEthernetClient_networkAuthMethod_set)
    __swig_setmethods__["identity"] = _vclapi.VclEthernetClient_identity_set
    __swig_getmethods__["identity"] = _vclapi.VclEthernetClient_identity_get
    if _newclass:identity = property(_vclapi.VclEthernetClient_identity_get, _vclapi.VclEthernetClient_identity_set)
    __swig_setmethods__["anonymousIdentity"] = _vclapi.VclEthernetClient_anonymousIdentity_set
    __swig_getmethods__["anonymousIdentity"] = _vclapi.VclEthernetClient_anonymousIdentity_get
    if _newclass:anonymousIdentity = property(_vclapi.VclEthernetClient_anonymousIdentity_get, _vclapi.VclEthernetClient_anonymousIdentity_set)
    __swig_setmethods__["password"] = _vclapi.VclEthernetClient_password_set
    __swig_getmethods__["password"] = _vclapi.VclEthernetClient_password_get
    if _newclass:password = property(_vclapi.VclEthernetClient_password_get, _vclapi.VclEthernetClient_password_set)
    __swig_setmethods__["rootCertificate"] = _vclapi.VclEthernetClient_rootCertificate_set
    __swig_getmethods__["rootCertificate"] = _vclapi.VclEthernetClient_rootCertificate_get
    if _newclass:rootCertificate = property(_vclapi.VclEthernetClient_rootCertificate_get, _vclapi.VclEthernetClient_rootCertificate_set)
    __swig_setmethods__["clientCertificate"] = _vclapi.VclEthernetClient_clientCertificate_set
    __swig_getmethods__["clientCertificate"] = _vclapi.VclEthernetClient_clientCertificate_get
    if _newclass:clientCertificate = property(_vclapi.VclEthernetClient_clientCertificate_get, _vclapi.VclEthernetClient_clientCertificate_set)
    __swig_setmethods__["privateKeyFile"] = _vclapi.VclEthernetClient_privateKeyFile_set
    __swig_getmethods__["privateKeyFile"] = _vclapi.VclEthernetClient_privateKeyFile_get
    if _newclass:privateKeyFile = property(_vclapi.VclEthernetClient_privateKeyFile_get, _vclapi.VclEthernetClient_privateKeyFile_set)
    __swig_setmethods__["enableValidateCertificate"] = _vclapi.VclEthernetClient_enableValidateCertificate_set
    __swig_getmethods__["enableValidateCertificate"] = _vclapi.VclEthernetClient_enableValidateCertificate_get
    if _newclass:enableValidateCertificate = property(_vclapi.VclEthernetClient_enableValidateCertificate_get, _vclapi.VclEthernetClient_enableValidateCertificate_set)
    __swig_setmethods__["dhcpTimeout"] = _vclapi.VclEthernetClient_dhcpTimeout_set
    __swig_getmethods__["dhcpTimeout"] = _vclapi.VclEthernetClient_dhcpTimeout_get
    if _newclass:dhcpTimeout = property(_vclapi.VclEthernetClient_dhcpTimeout_get, _vclapi.VclEthernetClient_dhcpTimeout_set)
    __swig_setmethods__["enableVcReconnect"] = _vclapi.VclEthernetClient_enableVcReconnect_set
    __swig_getmethods__["enableVcReconnect"] = _vclapi.VclEthernetClient_enableVcReconnect_get
    if _newclass:enableVcReconnect = property(_vclapi.VclEthernetClient_enableVcReconnect_get, _vclapi.VclEthernetClient_enableVcReconnect_set)
    __swig_setmethods__["initNextVc"] = _vclapi.VclEthernetClient_initNextVc_set
    __swig_getmethods__["initNextVc"] = _vclapi.VclEthernetClient_initNextVc_get
    if _newclass:initNextVc = property(_vclapi.VclEthernetClient_initNextVc_get, _vclapi.VclEthernetClient_initNextVc_set)
    __swig_setmethods__["chainedConnectionInterval"] = _vclapi.VclEthernetClient_chainedConnectionInterval_set
    __swig_getmethods__["chainedConnectionInterval"] = _vclapi.VclEthernetClient_chainedConnectionInterval_get
    if _newclass:chainedConnectionInterval = property(_vclapi.VclEthernetClient_chainedConnectionInterval_get, _vclapi.VclEthernetClient_chainedConnectionInterval_set)
    __swig_setmethods__["vcConnectionInterval"] = _vclapi.VclEthernetClient_vcConnectionInterval_set
    __swig_getmethods__["vcConnectionInterval"] = _vclapi.VclEthernetClient_vcConnectionInterval_get
    if _newclass:vcConnectionInterval = property(_vclapi.VclEthernetClient_vcConnectionInterval_get, _vclapi.VclEthernetClient_vcConnectionInterval_set)
    __swig_setmethods__["nextVc"] = _vclapi.VclEthernetClient_nextVc_set
    __swig_getmethods__["nextVc"] = _vclapi.VclEthernetClient_nextVc_get
    if _newclass:nextVc = property(_vclapi.VclEthernetClient_nextVc_get, _vclapi.VclEthernetClient_nextVc_set)
    def __init__(self, *args):
        _swig_setattr(self, VclEthernetClient, 'this', _vclapi.new_VclEthernetClient(*args))
        _swig_setattr(self, VclEthernetClient, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclEthernetClient):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclEthernetClientPtr(VclEthernetClient):
    def __init__(self, this):
        _swig_setattr(self, VclEthernetClient, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclEthernetClient, 'thisown', 0)
        _swig_setattr(self, VclEthernetClient,self.__class__,VclEthernetClient)
_vclapi.VclEthernetClient_swigregister(VclEthernetClientPtr)

class VclDns(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclDns, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclDns, name)
    def __repr__(self):
        return "<C VclDns instance at %s>" % (self.this,)
    def clear(*args): return _vclapi.VclDns_clear(*args)
    def addEntry(*args): return _vclapi.VclDns_addEntry(*args)
    def removeEntry(*args): return _vclapi.VclDns_removeEntry(*args)
    def write(*args): return _vclapi.VclDns_write(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclDns, 'this', _vclapi.new_VclDns(*args))
        _swig_setattr(self, VclDns, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclDns):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclDnsPtr(VclDns):
    def __init__(self, this):
        _swig_setattr(self, VclDns, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclDns, 'thisown', 0)
        _swig_setattr(self, VclDns,self.__class__,VclDns)
_vclapi.VclDns_swigregister(VclDnsPtr)

class VclCurl(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclCurl, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclCurl, name)
    def __repr__(self):
        return "<C VclCurl instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclCurl_setDefaults(*args)
    def create(*args): return _vclapi.VclCurl_create(*args)
    def destroy(*args): return _vclapi.VclCurl_destroy(*args)
    def read(*args): return _vclapi.VclCurl_read(*args)
    def write(*args): return _vclapi.VclCurl_write(*args)
    def perform(*args): return _vclapi.VclCurl_perform(*args)
    def performAsync(*args): return _vclapi.VclCurl_performAsync(*args)
    def setClient(*args): return _vclapi.VclCurl_setClient(*args)
    def setUrl(*args): return _vclapi.VclCurl_setUrl(*args)
    def setOutputFileName(*args): return _vclapi.VclCurl_setOutputFileName(*args)
    def addFormField(*args): return _vclapi.VclCurl_addFormField(*args)
    def addFormMultipart(*args): return _vclapi.VclCurl_addFormMultipart(*args)
    def get(*args): return _vclapi.VclCurl_get(*args)
    def set(*args): return _vclapi.VclCurl_set(*args)
    def reflect(*args): return _vclapi.VclCurl_reflect(*args)
    def getNames(*args): return _vclapi.VclCurl_getNames(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclCurl, 'this', _vclapi.new_VclCurl(*args))
        _swig_setattr(self, VclCurl, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclCurl):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclCurlPtr(VclCurl):
    def __init__(self, this):
        _swig_setattr(self, VclCurl, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclCurl, 'thisown', 0)
        _swig_setattr(self, VclCurl,self.__class__,VclCurl)
_vclapi.VclCurl_swigregister(VclCurlPtr)

class VclForwarder(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclForwarder, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclForwarder, name)
    def __repr__(self):
        return "<C VclForwarder instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclForwarder_setDefaults(*args)
    def create(*args): return _vclapi.VclForwarder_create(*args)
    def destroy(*args): return _vclapi.VclForwarder_destroy(*args)
    def read(*args): return _vclapi.VclForwarder_read(*args)
    def write(*args): return _vclapi.VclForwarder_write(*args)
    def setClient(*args): return _vclapi.VclForwarder_setClient(*args)
    def setListeningPort(*args): return _vclapi.VclForwarder_setListeningPort(*args)
    def setTerminationPoint(*args): return _vclapi.VclForwarder_setTerminationPoint(*args)
    def setType(*args): return _vclapi.VclForwarder_setType(*args)
    def getType(*args): return _vclapi.VclForwarder_getType(*args)
    def get(*args): return _vclapi.VclForwarder_get(*args)
    def getStatus(*args): return _vclapi.VclForwarder_getStatus(*args)
    def set(*args): return _vclapi.VclForwarder_set(*args)
    def reflect(*args): return _vclapi.VclForwarder_reflect(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclForwarder, 'this', _vclapi.new_VclForwarder(*args))
        _swig_setattr(self, VclForwarder, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclForwarder):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclForwarderPtr(VclForwarder):
    def __init__(self, this):
        _swig_setattr(self, VclForwarder, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclForwarder, 'thisown', 0)
        _swig_setattr(self, VclForwarder,self.__class__,VclForwarder)
_vclapi.VclForwarder_swigregister(VclForwarderPtr)

class VclUpgrade(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclUpgrade, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclUpgrade, name)
    def __repr__(self):
        return "<C VclUpgrade instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclUpgrade_setDefaults(*args)
    def startUpgrade(*args): return _vclapi.VclUpgrade_startUpgrade(*args)
    def monitorUpgrade(*args): return _vclapi.VclUpgrade_monitorUpgrade(*args)
    def chassisReset(*args): return _vclapi.VclUpgrade_chassisReset(*args)
    def query(*args): return _vclapi.VclUpgrade_query(*args)
    def getCardVersions(*args): return _vclapi.VclUpgrade_getCardVersions(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclUpgrade, 'this', _vclapi.new_VclUpgrade(*args))
        _swig_setattr(self, VclUpgrade, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclUpgrade):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclUpgradePtr(VclUpgrade):
    def __init__(self, this):
        _swig_setattr(self, VclUpgrade, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclUpgrade, 'thisown', 0)
        _swig_setattr(self, VclUpgrade,self.__class__,VclUpgrade)
_vclapi.VclUpgrade_swigregister(VclUpgradePtr)

class VclMobileClient(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclMobileClient, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclMobileClient, name)
    def __repr__(self):
        return "<C VclMobileClient instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclMobileClient_create(*args)
    def destroy(*args): return _vclapi.VclMobileClient_destroy(*args)
    def read(*args): return _vclapi.VclMobileClient_read(*args)
    def write(*args): return _vclapi.VclMobileClient_write(*args)
    def update(*args): return _vclapi.VclMobileClient_update(*args)
    def updateTxPowerModulation(*args): return _vclapi.VclMobileClient_updateTxPowerModulation(*args)
    def updateMacParams(*args): return _vclapi.VclMobileClient_updateMacParams(*args)
    def updateTimeout(*args): return _vclapi.VclMobileClient_updateTimeout(*args)
    def updateFerLevel(*args): return _vclapi.VclMobileClient_updateFerLevel(*args)
    def updatePowerSaveMode(*args): return _vclapi.VclMobileClient_updatePowerSaveMode(*args)
    def updateSecurity(*args): return _vclapi.VclMobileClient_updateSecurity(*args)
    def updateClientDelays(*args): return _vclapi.VclMobileClient_updateClientDelays(*args)
    def updateBssid(*args): return _vclapi.VclMobileClient_updateBssid(*args)
    def addNetworkMap(*args): return _vclapi.VclMobileClient_addNetworkMap(*args)
    def setActiveBssid(*args): return _vclapi.VclMobileClient_setActiveBssid(*args)
    def doPreauthBssid(*args): return _vclapi.VclMobileClient_doPreauthBssid(*args)
    def doConnectToAP(*args): return _vclapi.VclMobileClient_doConnectToAP(*args)
    def disassociate(*args): return _vclapi.VclMobileClient_disassociate(*args)
    def deauthenticate(*args): return _vclapi.VclMobileClient_deauthenticate(*args)
    def checkReasonCode(*args): return _vclapi.VclMobileClient_checkReasonCode(*args)
    def checkStatus(*args): return _vclapi.VclMobileClient_checkStatus(*args)
    def checkStatusCode(*args): return _vclapi.VclMobileClient_checkStatusCode(*args)
    def enableNetworkInterface(*args): return _vclapi.VclMobileClient_enableNetworkInterface(*args)
    def getClientType(*args): return _vclapi.VclMobileClient_getClientType(*args)
    def getNames(*args): return _vclapi.VclMobileClient_getNames(*args)
    def sendFrame(*args): return _vclapi.VclMobileClient_sendFrame(*args)
    def doEapolHandshake(*args): return _vclapi.VclMobileClient_doEapolHandshake(*args)
    def doQosHandshake(*args): return _vclapi.VclMobileClient_doQosHandshake(*args)
    def teardownQosHandshake(*args): return _vclapi.VclMobileClient_teardownQosHandshake(*args)
    def doConnectToIP(*args): return _vclapi.VclMobileClient_doConnectToIP(*args)
    def getName(*args): return _vclapi.VclMobileClient_getName(*args)
    def getProtocolType(*args): return _vclapi.VclMobileClient_getProtocolType(*args)
    def getIpAddress(*args): return _vclapi.VclMobileClient_getIpAddress(*args)
    def getIpAddressMode(*args): return _vclapi.VclMobileClient_getIpAddressMode(*args)
    def getGateway(*args): return _vclapi.VclMobileClient_getGateway(*args)
    def getMacAddress(*args): return _vclapi.VclMobileClient_getMacAddress(*args)
    def getArpResponse(*args): return _vclapi.VclMobileClient_getArpResponse(*args)
    def getSubnetMask(*args): return _vclapi.VclMobileClient_getSubnetMask(*args)
    def getNumFlows(*args): return _vclapi.VclMobileClient_getNumFlows(*args)
    def getState(*args): return _vclapi.VclMobileClient_getState(*args)
    def getCurrentPort(*args): return _vclapi.VclMobileClient_getCurrentPort(*args)
    def getCurrentBssid(*args): return _vclapi.VclMobileClient_getCurrentBssid(*args)
    def getListenInterval(*args): return _vclapi.VclMobileClient_getListenInterval(*args)
    def getPhyRate(*args): return _vclapi.VclMobileClient_getPhyRate(*args)
    def getBssidList(*args): return _vclapi.VclMobileClient_getBssidList(*args)
    def getPortList(*args): return _vclapi.VclMobileClient_getPortList(*args)
    def getSsid(*args): return _vclapi.VclMobileClient_getSsid(*args)
    def getFragmentThreshold(*args): return _vclapi.VclMobileClient_getFragmentThreshold(*args)
    def getRtsThreshold(*args): return _vclapi.VclMobileClient_getRtsThreshold(*args)
    def getCtsToSelf(*args): return _vclapi.VclMobileClient_getCtsToSelf(*args)
    def getShortPreamble(*args): return _vclapi.VclMobileClient_getShortPreamble(*args)
    def getPowerSave(*args): return _vclapi.VclMobileClient_getPowerSave(*args)
    def getWmeUapsd(*args): return _vclapi.VclMobileClient_getWmeUapsd(*args)
    def getWmeUapsdAcFlags(*args): return _vclapi.VclMobileClient_getWmeUapsdAcFlags(*args)
    def getWmeUapsdSpLength(*args): return _vclapi.VclMobileClient_getWmeUapsdSpLength(*args)
    def getProbeBeforeAssoc(*args): return _vclapi.VclMobileClient_getProbeBeforeAssoc(*args)
    def getGratuitousArp(*args): return _vclapi.VclMobileClient_getGratuitousArp(*args)
    def getUseReassociation(*args): return _vclapi.VclMobileClient_getUseReassociation(*args)
    def getLeaseDhcpOnRoam(*args): return _vclapi.VclMobileClient_getLeaseDhcpOnRoam(*args)
    def getLeaseDhcpReconnection(*args): return _vclapi.VclMobileClient_getLeaseDhcpReconnection(*args)
    def getPersistentReauth(*args): return _vclapi.VclMobileClient_getPersistentReauth(*args)
    def getWmeEnabled(*args): return _vclapi.VclMobileClient_getWmeEnabled(*args)
    def getSnifferEnabled(*args): return _vclapi.VclMobileClient_getSnifferEnabled(*args)
    def getFerLevel(*args): return _vclapi.VclMobileClient_getFerLevel(*args)
    def getEnableTxPowerModulation(*args): return _vclapi.VclMobileClient_getEnableTxPowerModulation(*args)
    def getTxPower(*args): return _vclapi.VclMobileClient_getTxPower(*args)
    def getTxPowerLimit(*args): return _vclapi.VclMobileClient_getTxPowerLimit(*args)
    def getTxPowerStep(*args): return _vclapi.VclMobileClient_getTxPowerStep(*args)
    def getTxPowerInterval(*args): return _vclapi.VclMobileClient_getTxPowerInterval(*args)
    def getTxPowerHoldoff(*args): return _vclapi.VclMobileClient_getTxPowerHoldoff(*args)
    def getSlotTime(*args): return _vclapi.VclMobileClient_getSlotTime(*args)
    def getSifs(*args): return _vclapi.VclMobileClient_getSifs(*args)
    def getAifs(*args): return _vclapi.VclMobileClient_getAifs(*args)
    def getCwMin(*args): return _vclapi.VclMobileClient_getCwMin(*args)
    def getCwMax(*args): return _vclapi.VclMobileClient_getCwMax(*args)
    def getTxDeference(*args): return _vclapi.VclMobileClient_getTxDeference(*args)
    def getBOnlyMode(*args): return _vclapi.VclMobileClient_getBOnlyMode(*args)
    def getAckTimeout(*args): return _vclapi.VclMobileClient_getAckTimeout(*args)
    def getCtsTimeout(*args): return _vclapi.VclMobileClient_getCtsTimeout(*args)
    def getArpTimeout(*args): return _vclapi.VclMobileClient_getArpTimeout(*args)
    def getProbeTimeout(*args): return _vclapi.VclMobileClient_getProbeTimeout(*args)
    def getAuthTimeout(*args): return _vclapi.VclMobileClient_getAuthTimeout(*args)
    def getAssocTimeout(*args): return _vclapi.VclMobileClient_getAssocTimeout(*args)
    def getEapolTimeout(*args): return _vclapi.VclMobileClient_getEapolTimeout(*args)
    def getDhcpTimeout(*args): return _vclapi.VclMobileClient_getDhcpTimeout(*args)
    def getApAuthMethod(*args): return _vclapi.VclMobileClient_getApAuthMethod(*args)
    def getSecurity(*args): return _vclapi.VclMobileClient_getSecurity(*args)
    def getSecurityProtocol(*args): return _vclapi.VclMobileClient_getSecurityProtocol(*args)
    def getKeyMethod(*args): return _vclapi.VclMobileClient_getKeyMethod(*args)
    def getNetworkAuthMethod(*args): return _vclapi.VclMobileClient_getNetworkAuthMethod(*args)
    def getEncryptionMethod(*args): return _vclapi.VclMobileClient_getEncryptionMethod(*args)
    def getNetworkKey(*args): return _vclapi.VclMobileClient_getNetworkKey(*args)
    def getKeyId(*args): return _vclapi.VclMobileClient_getKeyId(*args)
    def getKeyType(*args): return _vclapi.VclMobileClient_getKeyType(*args)
    def getIdentity(*args): return _vclapi.VclMobileClient_getIdentity(*args)
    def getAnonymousIdentity(*args): return _vclapi.VclMobileClient_getAnonymousIdentity(*args)
    def getPassword(*args): return _vclapi.VclMobileClient_getPassword(*args)
    def getRootCertificate(*args): return _vclapi.VclMobileClient_getRootCertificate(*args)
    def getClientCertificate(*args): return _vclapi.VclMobileClient_getClientCertificate(*args)
    def getPrivateKeyFile(*args): return _vclapi.VclMobileClient_getPrivateKeyFile(*args)
    def getEnableValidateCertificate(*args): return _vclapi.VclMobileClient_getEnableValidateCertificate(*args)
    def getRetryMgmt(*args): return _vclapi.VclMobileClient_getRetryMgmt(*args)
    def getRetryProt(*args): return _vclapi.VclMobileClient_getRetryProt(*args)
    def getRetryData(*args): return _vclapi.VclMobileClient_getRetryData(*args)
    def getClientLearning(*args): return _vclapi.VclMobileClient_getClientLearning(*args)
    def getLearningIpAddress(*args): return _vclapi.VclMobileClient_getLearningIpAddress(*args)
    def getLearningMacAddress(*args): return _vclapi.VclMobileClient_getLearningMacAddress(*args)
    def getLearningRate(*args): return _vclapi.VclMobileClient_getLearningRate(*args)
    def getProbeDelay(*args): return _vclapi.VclMobileClient_getProbeDelay(*args)
    def getAuthDelay(*args): return _vclapi.VclMobileClient_getAuthDelay(*args)
    def getAssocDelay(*args): return _vclapi.VclMobileClient_getAssocDelay(*args)
    def getEapolDelay(*args): return _vclapi.VclMobileClient_getEapolDelay(*args)
    def getGratArpDelay(*args): return _vclapi.VclMobileClient_getGratArpDelay(*args)
    def getTrafficDelay(*args): return _vclapi.VclMobileClient_getTrafficDelay(*args)
    def getProactiveKeyCaching(*args): return _vclapi.VclMobileClient_getProactiveKeyCaching(*args)
    def getAutoMaxPhyRate(*args): return _vclapi.VclMobileClient_getAutoMaxPhyRate(*args)
    def getConnectMode(*args): return _vclapi.VclMobileClient_getConnectMode(*args)
    def getSsidInBcstProbe(*args): return _vclapi.VclMobileClient_getSsidInBcstProbe(*args)
    def getChannelModel(*args): return _vclapi.VclMobileClient_getChannelModel(*args)
    def getPhyType(*args): return _vclapi.VclMobileClient_getPhyType(*args)
    def getPlcpConfiguration(*args): return _vclapi.VclMobileClient_getPlcpConfiguration(*args)
    def getChannelBandwidth(*args): return _vclapi.VclMobileClient_getChannelBandwidth(*args)
    def getMgmtMcsIndex(*args): return _vclapi.VclMobileClient_getMgmtMcsIndex(*args)
    def getDataMcsIndex(*args): return _vclapi.VclMobileClient_getDataMcsIndex(*args)
    def getGuardInterval(*args): return _vclapi.VclMobileClient_getGuardInterval(*args)
    def getAddTsTimeout(*args): return _vclapi.VclMobileClient_getAddTsTimeout(*args)
    def getAddBaTimeout(*args): return _vclapi.VclMobileClient_getAddBaTimeout(*args)
    def getMaxSuppRate(*args): return _vclapi.VclMobileClient_getMaxSuppRate(*args)
    def getAmpduLength(*args): return _vclapi.VclMobileClient_getAmpduLength(*args)
    def getAmpduDensity(*args): return _vclapi.VclMobileClient_getAmpduDensity(*args)
    def getSuppRxMcs(*args): return _vclapi.VclMobileClient_getSuppRxMcs(*args)
    def getRxParamFromBss(*args): return _vclapi.VclMobileClient_getRxParamFromBss(*args)
    def getAggregationEnabled(*args): return _vclapi.VclMobileClient_getAggregationEnabled(*args)
    def getRxMcsBitMask(*args): return _vclapi.VclMobileClient_getRxMcsBitMask(*args)
    def getSuppRatesMask(*args): return _vclapi.VclMobileClient_getSuppRatesMask(*args)
    def getBasicSuppRatesMask(*args): return _vclapi.VclMobileClient_getBasicSuppRatesMask(*args)
    def getTargetConnectionState(*args): return _vclapi.VclMobileClient_getTargetConnectionState(*args)
    def getFullConnectionState(*args): return _vclapi.VclMobileClient_getFullConnectionState(*args)
    def setRoamingArea(*args): return _vclapi.VclMobileClient_setRoamingArea(*args)
    def getRoamingArea(*args): return _vclapi.VclMobileClient_getRoamingArea(*args)
    def setRoamingCircuit(*args): return _vclapi.VclMobileClient_setRoamingCircuit(*args)
    def getRoamingCircuit(*args): return _vclapi.VclMobileClient_getRoamingCircuit(*args)
    def setDefaults(*args): return _vclapi.VclMobileClient_setDefaults(*args)
    def setIpAddress(*args): return _vclapi.VclMobileClient_setIpAddress(*args)
    def setIpAddressMode(*args): return _vclapi.VclMobileClient_setIpAddressMode(*args)
    def setGateway(*args): return _vclapi.VclMobileClient_setGateway(*args)
    def setMacAddress(*args): return _vclapi.VclMobileClient_setMacAddress(*args)
    def setArpResponse(*args): return _vclapi.VclMobileClient_setArpResponse(*args)
    def setSubnetMask(*args): return _vclapi.VclMobileClient_setSubnetMask(*args)
    def setListenInterval(*args): return _vclapi.VclMobileClient_setListenInterval(*args)
    def setPhyRate(*args): return _vclapi.VclMobileClient_setPhyRate(*args)
    def setBssidList(*args): return _vclapi.VclMobileClient_setBssidList(*args)
    def setPortList(*args): return _vclapi.VclMobileClient_setPortList(*args)
    def setSsid(*args): return _vclapi.VclMobileClient_setSsid(*args)
    def setFragmentThreshold(*args): return _vclapi.VclMobileClient_setFragmentThreshold(*args)
    def setRtsThreshold(*args): return _vclapi.VclMobileClient_setRtsThreshold(*args)
    def setCtsToSelf(*args): return _vclapi.VclMobileClient_setCtsToSelf(*args)
    def setShortPreamble(*args): return _vclapi.VclMobileClient_setShortPreamble(*args)
    def setPowerSave(*args): return _vclapi.VclMobileClient_setPowerSave(*args)
    def setWmeUapsd(*args): return _vclapi.VclMobileClient_setWmeUapsd(*args)
    def setWmeUapsdAcFlags(*args): return _vclapi.VclMobileClient_setWmeUapsdAcFlags(*args)
    def setWmeUapsdSpLength(*args): return _vclapi.VclMobileClient_setWmeUapsdSpLength(*args)
    def setProbeBeforeAssoc(*args): return _vclapi.VclMobileClient_setProbeBeforeAssoc(*args)
    def setGratuitousArp(*args): return _vclapi.VclMobileClient_setGratuitousArp(*args)
    def setUseReassociation(*args): return _vclapi.VclMobileClient_setUseReassociation(*args)
    def setPersistentReauth(*args): return _vclapi.VclMobileClient_setPersistentReauth(*args)
    def setWmeEnabled(*args): return _vclapi.VclMobileClient_setWmeEnabled(*args)
    def setSnifferEnabled(*args): return _vclapi.VclMobileClient_setSnifferEnabled(*args)
    def setEnableTxPowerModulation(*args): return _vclapi.VclMobileClient_setEnableTxPowerModulation(*args)
    def setLeaseDhcpOnRoam(*args): return _vclapi.VclMobileClient_setLeaseDhcpOnRoam(*args)
    def setLeaseDhcpReconnection(*args): return _vclapi.VclMobileClient_setLeaseDhcpReconnection(*args)
    def setFerLevel(*args): return _vclapi.VclMobileClient_setFerLevel(*args)
    def setTxPower(*args): return _vclapi.VclMobileClient_setTxPower(*args)
    def setTxPowerLimit(*args): return _vclapi.VclMobileClient_setTxPowerLimit(*args)
    def setTxPowerStep(*args): return _vclapi.VclMobileClient_setTxPowerStep(*args)
    def setTxPowerInterval(*args): return _vclapi.VclMobileClient_setTxPowerInterval(*args)
    def setTxPowerHoldoff(*args): return _vclapi.VclMobileClient_setTxPowerHoldoff(*args)
    def setSlotTime(*args): return _vclapi.VclMobileClient_setSlotTime(*args)
    def setSifs(*args): return _vclapi.VclMobileClient_setSifs(*args)
    def setAifs(*args): return _vclapi.VclMobileClient_setAifs(*args)
    def setCwMin(*args): return _vclapi.VclMobileClient_setCwMin(*args)
    def setCwMax(*args): return _vclapi.VclMobileClient_setCwMax(*args)
    def setTxDeference(*args): return _vclapi.VclMobileClient_setTxDeference(*args)
    def setBOnlyMode(*args): return _vclapi.VclMobileClient_setBOnlyMode(*args)
    def setAckTimeout(*args): return _vclapi.VclMobileClient_setAckTimeout(*args)
    def setCtsTimeout(*args): return _vclapi.VclMobileClient_setCtsTimeout(*args)
    def setArpTimeout(*args): return _vclapi.VclMobileClient_setArpTimeout(*args)
    def setProbeTimeout(*args): return _vclapi.VclMobileClient_setProbeTimeout(*args)
    def setAuthTimeout(*args): return _vclapi.VclMobileClient_setAuthTimeout(*args)
    def setAssocTimeout(*args): return _vclapi.VclMobileClient_setAssocTimeout(*args)
    def setEapolTimeout(*args): return _vclapi.VclMobileClient_setEapolTimeout(*args)
    def setDhcpTimeout(*args): return _vclapi.VclMobileClient_setDhcpTimeout(*args)
    def setApAuthMethod(*args): return _vclapi.VclMobileClient_setApAuthMethod(*args)
    def setSecurity(*args): return _vclapi.VclMobileClient_setSecurity(*args)
    def setKeyMethod(*args): return _vclapi.VclMobileClient_setKeyMethod(*args)
    def setNetworkAuthMethod(*args): return _vclapi.VclMobileClient_setNetworkAuthMethod(*args)
    def setEncryptionMethod(*args): return _vclapi.VclMobileClient_setEncryptionMethod(*args)
    def setNetworkKey(*args): return _vclapi.VclMobileClient_setNetworkKey(*args)
    def setIdentity(*args): return _vclapi.VclMobileClient_setIdentity(*args)
    def setAnonymousIdentity(*args): return _vclapi.VclMobileClient_setAnonymousIdentity(*args)
    def setPassword(*args): return _vclapi.VclMobileClient_setPassword(*args)
    def setRootCertificate(*args): return _vclapi.VclMobileClient_setRootCertificate(*args)
    def setClientCertificate(*args): return _vclapi.VclMobileClient_setClientCertificate(*args)
    def setPrivateKeyFile(*args): return _vclapi.VclMobileClient_setPrivateKeyFile(*args)
    def setEnableValidateCertificate(*args): return _vclapi.VclMobileClient_setEnableValidateCertificate(*args)
    def setKeyId(*args): return _vclapi.VclMobileClient_setKeyId(*args)
    def setKeyType(*args): return _vclapi.VclMobileClient_setKeyType(*args)
    def setRetryMgmt(*args): return _vclapi.VclMobileClient_setRetryMgmt(*args)
    def setRetryProt(*args): return _vclapi.VclMobileClient_setRetryProt(*args)
    def setRetryData(*args): return _vclapi.VclMobileClient_setRetryData(*args)
    def setClientLearning(*args): return _vclapi.VclMobileClient_setClientLearning(*args)
    def setLearningIpAddress(*args): return _vclapi.VclMobileClient_setLearningIpAddress(*args)
    def setLearningMacAddress(*args): return _vclapi.VclMobileClient_setLearningMacAddress(*args)
    def setLearningRate(*args): return _vclapi.VclMobileClient_setLearningRate(*args)
    def setProbeDelay(*args): return _vclapi.VclMobileClient_setProbeDelay(*args)
    def setAuthDelay(*args): return _vclapi.VclMobileClient_setAuthDelay(*args)
    def setAssocDelay(*args): return _vclapi.VclMobileClient_setAssocDelay(*args)
    def setEapolDelay(*args): return _vclapi.VclMobileClient_setEapolDelay(*args)
    def setGratArpDelay(*args): return _vclapi.VclMobileClient_setGratArpDelay(*args)
    def setTrafficDelay(*args): return _vclapi.VclMobileClient_setTrafficDelay(*args)
    def setProactiveKeyCaching(*args): return _vclapi.VclMobileClient_setProactiveKeyCaching(*args)
    def setAutoMaxPhyRate(*args): return _vclapi.VclMobileClient_setAutoMaxPhyRate(*args)
    def setConnectMode(*args): return _vclapi.VclMobileClient_setConnectMode(*args)
    def setSsidInBcstProbe(*args): return _vclapi.VclMobileClient_setSsidInBcstProbe(*args)
    def setPhyType(*args): return _vclapi.VclMobileClient_setPhyType(*args)
    def setMgmtMcsIndex(*args): return _vclapi.VclMobileClient_setMgmtMcsIndex(*args)
    def setDataMcsIndex(*args): return _vclapi.VclMobileClient_setDataMcsIndex(*args)
    def setGuardInterval(*args): return _vclapi.VclMobileClient_setGuardInterval(*args)
    def setChannelBandwidth(*args): return _vclapi.VclMobileClient_setChannelBandwidth(*args)
    def setPlcpConfiguration(*args): return _vclapi.VclMobileClient_setPlcpConfiguration(*args)
    def setChannelModel(*args): return _vclapi.VclMobileClient_setChannelModel(*args)
    def setAddTsTimeout(*args): return _vclapi.VclMobileClient_setAddTsTimeout(*args)
    def setAddBaTimeout(*args): return _vclapi.VclMobileClient_setAddBaTimeout(*args)
    def setMaxSuppRate(*args): return _vclapi.VclMobileClient_setMaxSuppRate(*args)
    def setAmpduLength(*args): return _vclapi.VclMobileClient_setAmpduLength(*args)
    def setAmpduDensity(*args): return _vclapi.VclMobileClient_setAmpduDensity(*args)
    def setSuppRxMcs(*args): return _vclapi.VclMobileClient_setSuppRxMcs(*args)
    def setRxMcsBitMask(*args): return _vclapi.VclMobileClient_setRxMcsBitMask(*args)
    def setSuppRatesMask(*args): return _vclapi.VclMobileClient_setSuppRatesMask(*args)
    def setBasicSuppRatesMask(*args): return _vclapi.VclMobileClient_setBasicSuppRatesMask(*args)
    def setRxParamFromBss(*args): return _vclapi.VclMobileClient_setRxParamFromBss(*args)
    def setAggregationEnabled(*args): return _vclapi.VclMobileClient_setAggregationEnabled(*args)
    def setTargetConnectionState(*args): return _vclapi.VclMobileClient_setTargetConnectionState(*args)
    __swig_getmethods__["name"] = _vclapi.VclMobileClient_name_get
    if _newclass:name = property(_vclapi.VclMobileClient_name_get)
    __swig_setmethods__["protocolType"] = _vclapi.VclMobileClient_protocolType_set
    __swig_getmethods__["protocolType"] = _vclapi.VclMobileClient_protocolType_get
    if _newclass:protocolType = property(_vclapi.VclMobileClient_protocolType_get, _vclapi.VclMobileClient_protocolType_set)
    __swig_getmethods__["numFlows"] = _vclapi.VclMobileClient_numFlows_get
    if _newclass:numFlows = property(_vclapi.VclMobileClient_numFlows_get)
    __swig_getmethods__["state"] = _vclapi.VclMobileClient_state_get
    if _newclass:state = property(_vclapi.VclMobileClient_state_get)
    __swig_getmethods__["currentPort"] = _vclapi.VclMobileClient_currentPort_get
    if _newclass:currentPort = property(_vclapi.VclMobileClient_currentPort_get)
    __swig_getmethods__["currentBssid"] = _vclapi.VclMobileClient_currentBssid_get
    if _newclass:currentBssid = property(_vclapi.VclMobileClient_currentBssid_get)
    __swig_getmethods__["suppRatesMask"] = _vclapi.VclMobileClient_suppRatesMask_get
    if _newclass:suppRatesMask = property(_vclapi.VclMobileClient_suppRatesMask_get)
    __swig_getmethods__["basicSuppRatesMask"] = _vclapi.VclMobileClient_basicSuppRatesMask_get
    if _newclass:basicSuppRatesMask = property(_vclapi.VclMobileClient_basicSuppRatesMask_get)
    __swig_setmethods__["ipAddress"] = _vclapi.VclMobileClient_ipAddress_set
    __swig_getmethods__["ipAddress"] = _vclapi.VclMobileClient_ipAddress_get
    if _newclass:ipAddress = property(_vclapi.VclMobileClient_ipAddress_get, _vclapi.VclMobileClient_ipAddress_set)
    __swig_setmethods__["ipAddressMode"] = _vclapi.VclMobileClient_ipAddressMode_set
    __swig_getmethods__["ipAddressMode"] = _vclapi.VclMobileClient_ipAddressMode_get
    if _newclass:ipAddressMode = property(_vclapi.VclMobileClient_ipAddressMode_get, _vclapi.VclMobileClient_ipAddressMode_set)
    __swig_setmethods__["subnetMask"] = _vclapi.VclMobileClient_subnetMask_set
    __swig_getmethods__["subnetMask"] = _vclapi.VclMobileClient_subnetMask_get
    if _newclass:subnetMask = property(_vclapi.VclMobileClient_subnetMask_get, _vclapi.VclMobileClient_subnetMask_set)
    __swig_setmethods__["gateway"] = _vclapi.VclMobileClient_gateway_set
    __swig_getmethods__["gateway"] = _vclapi.VclMobileClient_gateway_get
    if _newclass:gateway = property(_vclapi.VclMobileClient_gateway_get, _vclapi.VclMobileClient_gateway_set)
    __swig_setmethods__["macAddress"] = _vclapi.VclMobileClient_macAddress_set
    __swig_getmethods__["macAddress"] = _vclapi.VclMobileClient_macAddress_get
    if _newclass:macAddress = property(_vclapi.VclMobileClient_macAddress_get, _vclapi.VclMobileClient_macAddress_set)
    __swig_setmethods__["arpResponse"] = _vclapi.VclMobileClient_arpResponse_set
    __swig_getmethods__["arpResponse"] = _vclapi.VclMobileClient_arpResponse_get
    if _newclass:arpResponse = property(_vclapi.VclMobileClient_arpResponse_get, _vclapi.VclMobileClient_arpResponse_set)
    __swig_setmethods__["listenInterval"] = _vclapi.VclMobileClient_listenInterval_set
    __swig_getmethods__["listenInterval"] = _vclapi.VclMobileClient_listenInterval_get
    if _newclass:listenInterval = property(_vclapi.VclMobileClient_listenInterval_get, _vclapi.VclMobileClient_listenInterval_set)
    __swig_setmethods__["phyRate"] = _vclapi.VclMobileClient_phyRate_set
    __swig_getmethods__["phyRate"] = _vclapi.VclMobileClient_phyRate_get
    if _newclass:phyRate = property(_vclapi.VclMobileClient_phyRate_get, _vclapi.VclMobileClient_phyRate_set)
    __swig_setmethods__["bssidList"] = _vclapi.VclMobileClient_bssidList_set
    __swig_getmethods__["bssidList"] = _vclapi.VclMobileClient_bssidList_get
    if _newclass:bssidList = property(_vclapi.VclMobileClient_bssidList_get, _vclapi.VclMobileClient_bssidList_set)
    __swig_setmethods__["portList"] = _vclapi.VclMobileClient_portList_set
    __swig_getmethods__["portList"] = _vclapi.VclMobileClient_portList_get
    if _newclass:portList = property(_vclapi.VclMobileClient_portList_get, _vclapi.VclMobileClient_portList_set)
    __swig_setmethods__["fragmentThreshold"] = _vclapi.VclMobileClient_fragmentThreshold_set
    __swig_getmethods__["fragmentThreshold"] = _vclapi.VclMobileClient_fragmentThreshold_get
    if _newclass:fragmentThreshold = property(_vclapi.VclMobileClient_fragmentThreshold_get, _vclapi.VclMobileClient_fragmentThreshold_set)
    __swig_setmethods__["rtsThreshold"] = _vclapi.VclMobileClient_rtsThreshold_set
    __swig_getmethods__["rtsThreshold"] = _vclapi.VclMobileClient_rtsThreshold_get
    if _newclass:rtsThreshold = property(_vclapi.VclMobileClient_rtsThreshold_get, _vclapi.VclMobileClient_rtsThreshold_set)
    __swig_setmethods__["ctsToSelf"] = _vclapi.VclMobileClient_ctsToSelf_set
    __swig_getmethods__["ctsToSelf"] = _vclapi.VclMobileClient_ctsToSelf_get
    if _newclass:ctsToSelf = property(_vclapi.VclMobileClient_ctsToSelf_get, _vclapi.VclMobileClient_ctsToSelf_set)
    __swig_setmethods__["shortPreamble"] = _vclapi.VclMobileClient_shortPreamble_set
    __swig_getmethods__["shortPreamble"] = _vclapi.VclMobileClient_shortPreamble_get
    if _newclass:shortPreamble = property(_vclapi.VclMobileClient_shortPreamble_get, _vclapi.VclMobileClient_shortPreamble_set)
    __swig_setmethods__["powerSave"] = _vclapi.VclMobileClient_powerSave_set
    __swig_getmethods__["powerSave"] = _vclapi.VclMobileClient_powerSave_get
    if _newclass:powerSave = property(_vclapi.VclMobileClient_powerSave_get, _vclapi.VclMobileClient_powerSave_set)
    __swig_setmethods__["wmeUapsd"] = _vclapi.VclMobileClient_wmeUapsd_set
    __swig_getmethods__["wmeUapsd"] = _vclapi.VclMobileClient_wmeUapsd_get
    if _newclass:wmeUapsd = property(_vclapi.VclMobileClient_wmeUapsd_get, _vclapi.VclMobileClient_wmeUapsd_set)
    __swig_setmethods__["wmeUapsdAcFlags"] = _vclapi.VclMobileClient_wmeUapsdAcFlags_set
    __swig_getmethods__["wmeUapsdAcFlags"] = _vclapi.VclMobileClient_wmeUapsdAcFlags_get
    if _newclass:wmeUapsdAcFlags = property(_vclapi.VclMobileClient_wmeUapsdAcFlags_get, _vclapi.VclMobileClient_wmeUapsdAcFlags_set)
    __swig_setmethods__["wmeUapsdSpLength"] = _vclapi.VclMobileClient_wmeUapsdSpLength_set
    __swig_getmethods__["wmeUapsdSpLength"] = _vclapi.VclMobileClient_wmeUapsdSpLength_get
    if _newclass:wmeUapsdSpLength = property(_vclapi.VclMobileClient_wmeUapsdSpLength_get, _vclapi.VclMobileClient_wmeUapsdSpLength_set)
    __swig_setmethods__["probeBeforeAssoc"] = _vclapi.VclMobileClient_probeBeforeAssoc_set
    __swig_getmethods__["probeBeforeAssoc"] = _vclapi.VclMobileClient_probeBeforeAssoc_get
    if _newclass:probeBeforeAssoc = property(_vclapi.VclMobileClient_probeBeforeAssoc_get, _vclapi.VclMobileClient_probeBeforeAssoc_set)
    __swig_setmethods__["gratuitousArp"] = _vclapi.VclMobileClient_gratuitousArp_set
    __swig_getmethods__["gratuitousArp"] = _vclapi.VclMobileClient_gratuitousArp_get
    if _newclass:gratuitousArp = property(_vclapi.VclMobileClient_gratuitousArp_get, _vclapi.VclMobileClient_gratuitousArp_set)
    __swig_setmethods__["useReassociation"] = _vclapi.VclMobileClient_useReassociation_set
    __swig_getmethods__["useReassociation"] = _vclapi.VclMobileClient_useReassociation_get
    if _newclass:useReassociation = property(_vclapi.VclMobileClient_useReassociation_get, _vclapi.VclMobileClient_useReassociation_set)
    __swig_setmethods__["leaseDhcpOnRoam"] = _vclapi.VclMobileClient_leaseDhcpOnRoam_set
    __swig_getmethods__["leaseDhcpOnRoam"] = _vclapi.VclMobileClient_leaseDhcpOnRoam_get
    if _newclass:leaseDhcpOnRoam = property(_vclapi.VclMobileClient_leaseDhcpOnRoam_get, _vclapi.VclMobileClient_leaseDhcpOnRoam_set)
    __swig_setmethods__["leaseDhcpReconnection"] = _vclapi.VclMobileClient_leaseDhcpReconnection_set
    __swig_getmethods__["leaseDhcpReconnection"] = _vclapi.VclMobileClient_leaseDhcpReconnection_get
    if _newclass:leaseDhcpReconnection = property(_vclapi.VclMobileClient_leaseDhcpReconnection_get, _vclapi.VclMobileClient_leaseDhcpReconnection_set)
    __swig_setmethods__["persistentReauth"] = _vclapi.VclMobileClient_persistentReauth_set
    __swig_getmethods__["persistentReauth"] = _vclapi.VclMobileClient_persistentReauth_get
    if _newclass:persistentReauth = property(_vclapi.VclMobileClient_persistentReauth_get, _vclapi.VclMobileClient_persistentReauth_set)
    __swig_setmethods__["wmeEnabled"] = _vclapi.VclMobileClient_wmeEnabled_set
    __swig_getmethods__["wmeEnabled"] = _vclapi.VclMobileClient_wmeEnabled_get
    if _newclass:wmeEnabled = property(_vclapi.VclMobileClient_wmeEnabled_get, _vclapi.VclMobileClient_wmeEnabled_set)
    __swig_setmethods__["snifferEnabled"] = _vclapi.VclMobileClient_snifferEnabled_set
    __swig_getmethods__["snifferEnabled"] = _vclapi.VclMobileClient_snifferEnabled_get
    if _newclass:snifferEnabled = property(_vclapi.VclMobileClient_snifferEnabled_get, _vclapi.VclMobileClient_snifferEnabled_set)
    __swig_setmethods__["ferLevel"] = _vclapi.VclMobileClient_ferLevel_set
    __swig_getmethods__["ferLevel"] = _vclapi.VclMobileClient_ferLevel_get
    if _newclass:ferLevel = property(_vclapi.VclMobileClient_ferLevel_get, _vclapi.VclMobileClient_ferLevel_set)
    __swig_setmethods__["txPower"] = _vclapi.VclMobileClient_txPower_set
    __swig_getmethods__["txPower"] = _vclapi.VclMobileClient_txPower_get
    if _newclass:txPower = property(_vclapi.VclMobileClient_txPower_get, _vclapi.VclMobileClient_txPower_set)
    __swig_setmethods__["enableTxPowerModulation"] = _vclapi.VclMobileClient_enableTxPowerModulation_set
    __swig_getmethods__["enableTxPowerModulation"] = _vclapi.VclMobileClient_enableTxPowerModulation_get
    if _newclass:enableTxPowerModulation = property(_vclapi.VclMobileClient_enableTxPowerModulation_get, _vclapi.VclMobileClient_enableTxPowerModulation_set)
    __swig_setmethods__["txPowerLimit"] = _vclapi.VclMobileClient_txPowerLimit_set
    __swig_getmethods__["txPowerLimit"] = _vclapi.VclMobileClient_txPowerLimit_get
    if _newclass:txPowerLimit = property(_vclapi.VclMobileClient_txPowerLimit_get, _vclapi.VclMobileClient_txPowerLimit_set)
    __swig_setmethods__["txPowerStep"] = _vclapi.VclMobileClient_txPowerStep_set
    __swig_getmethods__["txPowerStep"] = _vclapi.VclMobileClient_txPowerStep_get
    if _newclass:txPowerStep = property(_vclapi.VclMobileClient_txPowerStep_get, _vclapi.VclMobileClient_txPowerStep_set)
    __swig_setmethods__["txPowerInterval"] = _vclapi.VclMobileClient_txPowerInterval_set
    __swig_getmethods__["txPowerInterval"] = _vclapi.VclMobileClient_txPowerInterval_get
    if _newclass:txPowerInterval = property(_vclapi.VclMobileClient_txPowerInterval_get, _vclapi.VclMobileClient_txPowerInterval_set)
    __swig_setmethods__["txPowerHoldoff"] = _vclapi.VclMobileClient_txPowerHoldoff_set
    __swig_getmethods__["txPowerHoldoff"] = _vclapi.VclMobileClient_txPowerHoldoff_get
    if _newclass:txPowerHoldoff = property(_vclapi.VclMobileClient_txPowerHoldoff_get, _vclapi.VclMobileClient_txPowerHoldoff_set)
    __swig_setmethods__["slotTime"] = _vclapi.VclMobileClient_slotTime_set
    __swig_getmethods__["slotTime"] = _vclapi.VclMobileClient_slotTime_get
    if _newclass:slotTime = property(_vclapi.VclMobileClient_slotTime_get, _vclapi.VclMobileClient_slotTime_set)
    __swig_setmethods__["slotTimeCck"] = _vclapi.VclMobileClient_slotTimeCck_set
    __swig_getmethods__["slotTimeCck"] = _vclapi.VclMobileClient_slotTimeCck_get
    if _newclass:slotTimeCck = property(_vclapi.VclMobileClient_slotTimeCck_get, _vclapi.VclMobileClient_slotTimeCck_set)
    __swig_setmethods__["slotTimeOfdm"] = _vclapi.VclMobileClient_slotTimeOfdm_set
    __swig_getmethods__["slotTimeOfdm"] = _vclapi.VclMobileClient_slotTimeOfdm_get
    if _newclass:slotTimeOfdm = property(_vclapi.VclMobileClient_slotTimeOfdm_get, _vclapi.VclMobileClient_slotTimeOfdm_set)
    __swig_setmethods__["sifs"] = _vclapi.VclMobileClient_sifs_set
    __swig_getmethods__["sifs"] = _vclapi.VclMobileClient_sifs_get
    if _newclass:sifs = property(_vclapi.VclMobileClient_sifs_get, _vclapi.VclMobileClient_sifs_set)
    __swig_setmethods__["sifsCck"] = _vclapi.VclMobileClient_sifsCck_set
    __swig_getmethods__["sifsCck"] = _vclapi.VclMobileClient_sifsCck_get
    if _newclass:sifsCck = property(_vclapi.VclMobileClient_sifsCck_get, _vclapi.VclMobileClient_sifsCck_set)
    __swig_setmethods__["sifsOfdm"] = _vclapi.VclMobileClient_sifsOfdm_set
    __swig_getmethods__["sifsOfdm"] = _vclapi.VclMobileClient_sifsOfdm_get
    if _newclass:sifsOfdm = property(_vclapi.VclMobileClient_sifsOfdm_get, _vclapi.VclMobileClient_sifsOfdm_set)
    __swig_setmethods__["aifs"] = _vclapi.VclMobileClient_aifs_set
    __swig_getmethods__["aifs"] = _vclapi.VclMobileClient_aifs_get
    if _newclass:aifs = property(_vclapi.VclMobileClient_aifs_get, _vclapi.VclMobileClient_aifs_set)
    __swig_setmethods__["cwMin"] = _vclapi.VclMobileClient_cwMin_set
    __swig_getmethods__["cwMin"] = _vclapi.VclMobileClient_cwMin_get
    if _newclass:cwMin = property(_vclapi.VclMobileClient_cwMin_get, _vclapi.VclMobileClient_cwMin_set)
    __swig_setmethods__["cwMax"] = _vclapi.VclMobileClient_cwMax_set
    __swig_getmethods__["cwMax"] = _vclapi.VclMobileClient_cwMax_get
    if _newclass:cwMax = property(_vclapi.VclMobileClient_cwMax_get, _vclapi.VclMobileClient_cwMax_set)
    __swig_setmethods__["txDeference"] = _vclapi.VclMobileClient_txDeference_set
    __swig_getmethods__["txDeference"] = _vclapi.VclMobileClient_txDeference_get
    if _newclass:txDeference = property(_vclapi.VclMobileClient_txDeference_get, _vclapi.VclMobileClient_txDeference_set)
    __swig_setmethods__["bOnlyMode"] = _vclapi.VclMobileClient_bOnlyMode_set
    __swig_getmethods__["bOnlyMode"] = _vclapi.VclMobileClient_bOnlyMode_get
    if _newclass:bOnlyMode = property(_vclapi.VclMobileClient_bOnlyMode_get, _vclapi.VclMobileClient_bOnlyMode_set)
    __swig_setmethods__["ackTimeout"] = _vclapi.VclMobileClient_ackTimeout_set
    __swig_getmethods__["ackTimeout"] = _vclapi.VclMobileClient_ackTimeout_get
    if _newclass:ackTimeout = property(_vclapi.VclMobileClient_ackTimeout_get, _vclapi.VclMobileClient_ackTimeout_set)
    __swig_setmethods__["ctsTimeout"] = _vclapi.VclMobileClient_ctsTimeout_set
    __swig_getmethods__["ctsTimeout"] = _vclapi.VclMobileClient_ctsTimeout_get
    if _newclass:ctsTimeout = property(_vclapi.VclMobileClient_ctsTimeout_get, _vclapi.VclMobileClient_ctsTimeout_set)
    __swig_setmethods__["probeTimeout"] = _vclapi.VclMobileClient_probeTimeout_set
    __swig_getmethods__["probeTimeout"] = _vclapi.VclMobileClient_probeTimeout_get
    if _newclass:probeTimeout = property(_vclapi.VclMobileClient_probeTimeout_get, _vclapi.VclMobileClient_probeTimeout_set)
    __swig_setmethods__["authTimeout"] = _vclapi.VclMobileClient_authTimeout_set
    __swig_getmethods__["authTimeout"] = _vclapi.VclMobileClient_authTimeout_get
    if _newclass:authTimeout = property(_vclapi.VclMobileClient_authTimeout_get, _vclapi.VclMobileClient_authTimeout_set)
    __swig_setmethods__["assocTimeout"] = _vclapi.VclMobileClient_assocTimeout_set
    __swig_getmethods__["assocTimeout"] = _vclapi.VclMobileClient_assocTimeout_get
    if _newclass:assocTimeout = property(_vclapi.VclMobileClient_assocTimeout_get, _vclapi.VclMobileClient_assocTimeout_set)
    __swig_setmethods__["eapolTimeout"] = _vclapi.VclMobileClient_eapolTimeout_set
    __swig_getmethods__["eapolTimeout"] = _vclapi.VclMobileClient_eapolTimeout_get
    if _newclass:eapolTimeout = property(_vclapi.VclMobileClient_eapolTimeout_get, _vclapi.VclMobileClient_eapolTimeout_set)
    __swig_setmethods__["dhcpTimeout"] = _vclapi.VclMobileClient_dhcpTimeout_set
    __swig_getmethods__["dhcpTimeout"] = _vclapi.VclMobileClient_dhcpTimeout_get
    if _newclass:dhcpTimeout = property(_vclapi.VclMobileClient_dhcpTimeout_get, _vclapi.VclMobileClient_dhcpTimeout_set)
    __swig_setmethods__["arpTimeout"] = _vclapi.VclMobileClient_arpTimeout_set
    __swig_getmethods__["arpTimeout"] = _vclapi.VclMobileClient_arpTimeout_get
    if _newclass:arpTimeout = property(_vclapi.VclMobileClient_arpTimeout_get, _vclapi.VclMobileClient_arpTimeout_set)
    __swig_setmethods__["probeDelay"] = _vclapi.VclMobileClient_probeDelay_set
    __swig_getmethods__["probeDelay"] = _vclapi.VclMobileClient_probeDelay_get
    if _newclass:probeDelay = property(_vclapi.VclMobileClient_probeDelay_get, _vclapi.VclMobileClient_probeDelay_set)
    __swig_setmethods__["authDelay"] = _vclapi.VclMobileClient_authDelay_set
    __swig_getmethods__["authDelay"] = _vclapi.VclMobileClient_authDelay_get
    if _newclass:authDelay = property(_vclapi.VclMobileClient_authDelay_get, _vclapi.VclMobileClient_authDelay_set)
    __swig_setmethods__["assocDelay"] = _vclapi.VclMobileClient_assocDelay_set
    __swig_getmethods__["assocDelay"] = _vclapi.VclMobileClient_assocDelay_get
    if _newclass:assocDelay = property(_vclapi.VclMobileClient_assocDelay_get, _vclapi.VclMobileClient_assocDelay_set)
    __swig_setmethods__["eapolDelay"] = _vclapi.VclMobileClient_eapolDelay_set
    __swig_getmethods__["eapolDelay"] = _vclapi.VclMobileClient_eapolDelay_get
    if _newclass:eapolDelay = property(_vclapi.VclMobileClient_eapolDelay_get, _vclapi.VclMobileClient_eapolDelay_set)
    __swig_setmethods__["gratArpDelay"] = _vclapi.VclMobileClient_gratArpDelay_set
    __swig_getmethods__["gratArpDelay"] = _vclapi.VclMobileClient_gratArpDelay_get
    if _newclass:gratArpDelay = property(_vclapi.VclMobileClient_gratArpDelay_get, _vclapi.VclMobileClient_gratArpDelay_set)
    __swig_setmethods__["trafficDelay"] = _vclapi.VclMobileClient_trafficDelay_set
    __swig_getmethods__["trafficDelay"] = _vclapi.VclMobileClient_trafficDelay_get
    if _newclass:trafficDelay = property(_vclapi.VclMobileClient_trafficDelay_get, _vclapi.VclMobileClient_trafficDelay_set)
    __swig_setmethods__["apAuthMethod"] = _vclapi.VclMobileClient_apAuthMethod_set
    __swig_getmethods__["apAuthMethod"] = _vclapi.VclMobileClient_apAuthMethod_get
    if _newclass:apAuthMethod = property(_vclapi.VclMobileClient_apAuthMethod_get, _vclapi.VclMobileClient_apAuthMethod_set)
    __swig_setmethods__["security"] = _vclapi.VclMobileClient_security_set
    __swig_getmethods__["security"] = _vclapi.VclMobileClient_security_get
    if _newclass:security = property(_vclapi.VclMobileClient_security_get, _vclapi.VclMobileClient_security_set)
    __swig_getmethods__["securityProtocol"] = _vclapi.VclMobileClient_securityProtocol_get
    if _newclass:securityProtocol = property(_vclapi.VclMobileClient_securityProtocol_get)
    __swig_setmethods__["keyMethod"] = _vclapi.VclMobileClient_keyMethod_set
    __swig_getmethods__["keyMethod"] = _vclapi.VclMobileClient_keyMethod_get
    if _newclass:keyMethod = property(_vclapi.VclMobileClient_keyMethod_get, _vclapi.VclMobileClient_keyMethod_set)
    __swig_setmethods__["networkAuthMethod"] = _vclapi.VclMobileClient_networkAuthMethod_set
    __swig_getmethods__["networkAuthMethod"] = _vclapi.VclMobileClient_networkAuthMethod_get
    if _newclass:networkAuthMethod = property(_vclapi.VclMobileClient_networkAuthMethod_get, _vclapi.VclMobileClient_networkAuthMethod_set)
    __swig_setmethods__["encryptionMethod"] = _vclapi.VclMobileClient_encryptionMethod_set
    __swig_getmethods__["encryptionMethod"] = _vclapi.VclMobileClient_encryptionMethod_get
    if _newclass:encryptionMethod = property(_vclapi.VclMobileClient_encryptionMethod_get, _vclapi.VclMobileClient_encryptionMethod_set)
    __swig_setmethods__["networkKey"] = _vclapi.VclMobileClient_networkKey_set
    __swig_getmethods__["networkKey"] = _vclapi.VclMobileClient_networkKey_get
    if _newclass:networkKey = property(_vclapi.VclMobileClient_networkKey_get, _vclapi.VclMobileClient_networkKey_set)
    __swig_setmethods__["keyId"] = _vclapi.VclMobileClient_keyId_set
    __swig_getmethods__["keyId"] = _vclapi.VclMobileClient_keyId_get
    if _newclass:keyId = property(_vclapi.VclMobileClient_keyId_get, _vclapi.VclMobileClient_keyId_set)
    __swig_setmethods__["keyType"] = _vclapi.VclMobileClient_keyType_set
    __swig_getmethods__["keyType"] = _vclapi.VclMobileClient_keyType_get
    if _newclass:keyType = property(_vclapi.VclMobileClient_keyType_get, _vclapi.VclMobileClient_keyType_set)
    __swig_setmethods__["identity"] = _vclapi.VclMobileClient_identity_set
    __swig_getmethods__["identity"] = _vclapi.VclMobileClient_identity_get
    if _newclass:identity = property(_vclapi.VclMobileClient_identity_get, _vclapi.VclMobileClient_identity_set)
    __swig_setmethods__["anonymousIdentity"] = _vclapi.VclMobileClient_anonymousIdentity_set
    __swig_getmethods__["anonymousIdentity"] = _vclapi.VclMobileClient_anonymousIdentity_get
    if _newclass:anonymousIdentity = property(_vclapi.VclMobileClient_anonymousIdentity_get, _vclapi.VclMobileClient_anonymousIdentity_set)
    __swig_setmethods__["password"] = _vclapi.VclMobileClient_password_set
    __swig_getmethods__["password"] = _vclapi.VclMobileClient_password_get
    if _newclass:password = property(_vclapi.VclMobileClient_password_get, _vclapi.VclMobileClient_password_set)
    __swig_setmethods__["rootCertificate"] = _vclapi.VclMobileClient_rootCertificate_set
    __swig_getmethods__["rootCertificate"] = _vclapi.VclMobileClient_rootCertificate_get
    if _newclass:rootCertificate = property(_vclapi.VclMobileClient_rootCertificate_get, _vclapi.VclMobileClient_rootCertificate_set)
    __swig_setmethods__["clientCertificate"] = _vclapi.VclMobileClient_clientCertificate_set
    __swig_getmethods__["clientCertificate"] = _vclapi.VclMobileClient_clientCertificate_get
    if _newclass:clientCertificate = property(_vclapi.VclMobileClient_clientCertificate_get, _vclapi.VclMobileClient_clientCertificate_set)
    __swig_setmethods__["privateKeyFile"] = _vclapi.VclMobileClient_privateKeyFile_set
    __swig_getmethods__["privateKeyFile"] = _vclapi.VclMobileClient_privateKeyFile_get
    if _newclass:privateKeyFile = property(_vclapi.VclMobileClient_privateKeyFile_get, _vclapi.VclMobileClient_privateKeyFile_set)
    __swig_setmethods__["enableValidateCertificate"] = _vclapi.VclMobileClient_enableValidateCertificate_set
    __swig_getmethods__["enableValidateCertificate"] = _vclapi.VclMobileClient_enableValidateCertificate_get
    if _newclass:enableValidateCertificate = property(_vclapi.VclMobileClient_enableValidateCertificate_get, _vclapi.VclMobileClient_enableValidateCertificate_set)
    __swig_setmethods__["retryMgmt"] = _vclapi.VclMobileClient_retryMgmt_set
    __swig_getmethods__["retryMgmt"] = _vclapi.VclMobileClient_retryMgmt_get
    if _newclass:retryMgmt = property(_vclapi.VclMobileClient_retryMgmt_get, _vclapi.VclMobileClient_retryMgmt_set)
    __swig_setmethods__["retryProt"] = _vclapi.VclMobileClient_retryProt_set
    __swig_getmethods__["retryProt"] = _vclapi.VclMobileClient_retryProt_get
    if _newclass:retryProt = property(_vclapi.VclMobileClient_retryProt_get, _vclapi.VclMobileClient_retryProt_set)
    __swig_setmethods__["retryData"] = _vclapi.VclMobileClient_retryData_set
    __swig_getmethods__["retryData"] = _vclapi.VclMobileClient_retryData_get
    if _newclass:retryData = property(_vclapi.VclMobileClient_retryData_get, _vclapi.VclMobileClient_retryData_set)
    __swig_setmethods__["clientLearning"] = _vclapi.VclMobileClient_clientLearning_set
    __swig_getmethods__["clientLearning"] = _vclapi.VclMobileClient_clientLearning_get
    if _newclass:clientLearning = property(_vclapi.VclMobileClient_clientLearning_get, _vclapi.VclMobileClient_clientLearning_set)
    __swig_setmethods__["learningIpAddress"] = _vclapi.VclMobileClient_learningIpAddress_set
    __swig_getmethods__["learningIpAddress"] = _vclapi.VclMobileClient_learningIpAddress_get
    if _newclass:learningIpAddress = property(_vclapi.VclMobileClient_learningIpAddress_get, _vclapi.VclMobileClient_learningIpAddress_set)
    __swig_setmethods__["learningMacAddress"] = _vclapi.VclMobileClient_learningMacAddress_set
    __swig_getmethods__["learningMacAddress"] = _vclapi.VclMobileClient_learningMacAddress_get
    if _newclass:learningMacAddress = property(_vclapi.VclMobileClient_learningMacAddress_get, _vclapi.VclMobileClient_learningMacAddress_set)
    __swig_setmethods__["learningRate"] = _vclapi.VclMobileClient_learningRate_set
    __swig_getmethods__["learningRate"] = _vclapi.VclMobileClient_learningRate_get
    if _newclass:learningRate = property(_vclapi.VclMobileClient_learningRate_get, _vclapi.VclMobileClient_learningRate_set)
    __swig_setmethods__["proactiveKeyCaching"] = _vclapi.VclMobileClient_proactiveKeyCaching_set
    __swig_getmethods__["proactiveKeyCaching"] = _vclapi.VclMobileClient_proactiveKeyCaching_get
    if _newclass:proactiveKeyCaching = property(_vclapi.VclMobileClient_proactiveKeyCaching_get, _vclapi.VclMobileClient_proactiveKeyCaching_set)
    __swig_setmethods__["autoMaxPhyRate"] = _vclapi.VclMobileClient_autoMaxPhyRate_set
    __swig_getmethods__["autoMaxPhyRate"] = _vclapi.VclMobileClient_autoMaxPhyRate_get
    if _newclass:autoMaxPhyRate = property(_vclapi.VclMobileClient_autoMaxPhyRate_get, _vclapi.VclMobileClient_autoMaxPhyRate_set)
    __swig_setmethods__["connectMode"] = _vclapi.VclMobileClient_connectMode_set
    __swig_getmethods__["connectMode"] = _vclapi.VclMobileClient_connectMode_get
    if _newclass:connectMode = property(_vclapi.VclMobileClient_connectMode_get, _vclapi.VclMobileClient_connectMode_set)
    __swig_setmethods__["ssidInBcstProbe"] = _vclapi.VclMobileClient_ssidInBcstProbe_set
    __swig_getmethods__["ssidInBcstProbe"] = _vclapi.VclMobileClient_ssidInBcstProbe_get
    if _newclass:ssidInBcstProbe = property(_vclapi.VclMobileClient_ssidInBcstProbe_get, _vclapi.VclMobileClient_ssidInBcstProbe_set)
    __swig_getmethods__["phyType"] = _vclapi.VclMobileClient_phyType_get
    if _newclass:phyType = property(_vclapi.VclMobileClient_phyType_get)
    __swig_setmethods__["mgmtMcsIndex"] = _vclapi.VclMobileClient_mgmtMcsIndex_set
    __swig_getmethods__["mgmtMcsIndex"] = _vclapi.VclMobileClient_mgmtMcsIndex_get
    if _newclass:mgmtMcsIndex = property(_vclapi.VclMobileClient_mgmtMcsIndex_get, _vclapi.VclMobileClient_mgmtMcsIndex_set)
    __swig_setmethods__["dataMcsIndex"] = _vclapi.VclMobileClient_dataMcsIndex_set
    __swig_getmethods__["dataMcsIndex"] = _vclapi.VclMobileClient_dataMcsIndex_get
    if _newclass:dataMcsIndex = property(_vclapi.VclMobileClient_dataMcsIndex_get, _vclapi.VclMobileClient_dataMcsIndex_set)
    __swig_setmethods__["guardInterval"] = _vclapi.VclMobileClient_guardInterval_set
    __swig_getmethods__["guardInterval"] = _vclapi.VclMobileClient_guardInterval_get
    if _newclass:guardInterval = property(_vclapi.VclMobileClient_guardInterval_get, _vclapi.VclMobileClient_guardInterval_set)
    __swig_setmethods__["channelBandwidth"] = _vclapi.VclMobileClient_channelBandwidth_set
    __swig_getmethods__["channelBandwidth"] = _vclapi.VclMobileClient_channelBandwidth_get
    if _newclass:channelBandwidth = property(_vclapi.VclMobileClient_channelBandwidth_get, _vclapi.VclMobileClient_channelBandwidth_set)
    __swig_setmethods__["plcpConfiguration"] = _vclapi.VclMobileClient_plcpConfiguration_set
    __swig_getmethods__["plcpConfiguration"] = _vclapi.VclMobileClient_plcpConfiguration_get
    if _newclass:plcpConfiguration = property(_vclapi.VclMobileClient_plcpConfiguration_get, _vclapi.VclMobileClient_plcpConfiguration_set)
    __swig_setmethods__["channelModel"] = _vclapi.VclMobileClient_channelModel_set
    __swig_getmethods__["channelModel"] = _vclapi.VclMobileClient_channelModel_get
    if _newclass:channelModel = property(_vclapi.VclMobileClient_channelModel_get, _vclapi.VclMobileClient_channelModel_set)
    __swig_setmethods__["addTsTimeout"] = _vclapi.VclMobileClient_addTsTimeout_set
    __swig_getmethods__["addTsTimeout"] = _vclapi.VclMobileClient_addTsTimeout_get
    if _newclass:addTsTimeout = property(_vclapi.VclMobileClient_addTsTimeout_get, _vclapi.VclMobileClient_addTsTimeout_set)
    __swig_setmethods__["addBaTimeout"] = _vclapi.VclMobileClient_addBaTimeout_set
    __swig_getmethods__["addBaTimeout"] = _vclapi.VclMobileClient_addBaTimeout_get
    if _newclass:addBaTimeout = property(_vclapi.VclMobileClient_addBaTimeout_get, _vclapi.VclMobileClient_addBaTimeout_set)
    __swig_setmethods__["maxSuppRate"] = _vclapi.VclMobileClient_maxSuppRate_set
    __swig_getmethods__["maxSuppRate"] = _vclapi.VclMobileClient_maxSuppRate_get
    if _newclass:maxSuppRate = property(_vclapi.VclMobileClient_maxSuppRate_get, _vclapi.VclMobileClient_maxSuppRate_set)
    __swig_setmethods__["ampduLength"] = _vclapi.VclMobileClient_ampduLength_set
    __swig_getmethods__["ampduLength"] = _vclapi.VclMobileClient_ampduLength_get
    if _newclass:ampduLength = property(_vclapi.VclMobileClient_ampduLength_get, _vclapi.VclMobileClient_ampduLength_set)
    __swig_setmethods__["ampduDensity"] = _vclapi.VclMobileClient_ampduDensity_set
    __swig_getmethods__["ampduDensity"] = _vclapi.VclMobileClient_ampduDensity_get
    if _newclass:ampduDensity = property(_vclapi.VclMobileClient_ampduDensity_get, _vclapi.VclMobileClient_ampduDensity_set)
    __swig_setmethods__["suppRxMcs"] = _vclapi.VclMobileClient_suppRxMcs_set
    __swig_getmethods__["suppRxMcs"] = _vclapi.VclMobileClient_suppRxMcs_get
    if _newclass:suppRxMcs = property(_vclapi.VclMobileClient_suppRxMcs_get, _vclapi.VclMobileClient_suppRxMcs_set)
    __swig_setmethods__["rxParamFromBss"] = _vclapi.VclMobileClient_rxParamFromBss_set
    __swig_getmethods__["rxParamFromBss"] = _vclapi.VclMobileClient_rxParamFromBss_get
    if _newclass:rxParamFromBss = property(_vclapi.VclMobileClient_rxParamFromBss_get, _vclapi.VclMobileClient_rxParamFromBss_set)
    __swig_setmethods__["aggregationEnabled"] = _vclapi.VclMobileClient_aggregationEnabled_set
    __swig_getmethods__["aggregationEnabled"] = _vclapi.VclMobileClient_aggregationEnabled_get
    if _newclass:aggregationEnabled = property(_vclapi.VclMobileClient_aggregationEnabled_get, _vclapi.VclMobileClient_aggregationEnabled_set)
    __swig_setmethods__["targetConnectionState"] = _vclapi.VclMobileClient_targetConnectionState_set
    __swig_getmethods__["targetConnectionState"] = _vclapi.VclMobileClient_targetConnectionState_get
    if _newclass:targetConnectionState = property(_vclapi.VclMobileClient_targetConnectionState_get, _vclapi.VclMobileClient_targetConnectionState_set)
    __swig_getmethods__["fullConnectionState"] = _vclapi.VclMobileClient_fullConnectionState_get
    if _newclass:fullConnectionState = property(_vclapi.VclMobileClient_fullConnectionState_get)
    __swig_setmethods__["roamingArea"] = _vclapi.VclMobileClient_roamingArea_set
    __swig_getmethods__["roamingArea"] = _vclapi.VclMobileClient_roamingArea_get
    if _newclass:roamingArea = property(_vclapi.VclMobileClient_roamingArea_get, _vclapi.VclMobileClient_roamingArea_set)
    __swig_setmethods__["roamingCircuit"] = _vclapi.VclMobileClient_roamingCircuit_set
    __swig_getmethods__["roamingCircuit"] = _vclapi.VclMobileClient_roamingCircuit_get
    if _newclass:roamingCircuit = property(_vclapi.VclMobileClient_roamingCircuit_get, _vclapi.VclMobileClient_roamingCircuit_set)
    def __init__(self, *args):
        _swig_setattr(self, VclMobileClient, 'this', _vclapi.new_VclMobileClient(*args))
        _swig_setattr(self, VclMobileClient, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclMobileClient):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclMobileClientPtr(VclMobileClient):
    def __init__(self, this):
        _swig_setattr(self, VclMobileClient, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclMobileClient, 'thisown', 0)
        _swig_setattr(self, VclMobileClient,self.__class__,VclMobileClient)
_vclapi.VclMobileClient_swigregister(VclMobileClientPtr)

class VclBiflow(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclBiflow, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclBiflow, name)
    def __repr__(self):
        return "<C VclBiflow instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclBiflow_create(*args)
    def destroy(*args): return _vclapi.VclBiflow_destroy(*args)
    def getNames(*args): return _vclapi.VclBiflow_getNames(*args)
    def read(*args): return _vclapi.VclBiflow_read(*args)
    def write(*args): return _vclapi.VclBiflow_write(*args)
    def connect(*args): return _vclapi.VclBiflow_connect(*args)
    def disconnect(*args): return _vclapi.VclBiflow_disconnect(*args)
    def resetConnection(*args): return _vclapi.VclBiflow_resetConnection(*args)
    def checkStatus(*args): return _vclapi.VclBiflow_checkStatus(*args)
    def get(*args): return _vclapi.VclBiflow_get(*args)
    def reflect(*args): return _vclapi.VclBiflow_reflect(*args)
    def getName(*args): return _vclapi.VclBiflow_getName(*args)
    def getEnable(*args): return _vclapi.VclBiflow_getEnable(*args)
    def getSrcClient(*args): return _vclapi.VclBiflow_getSrcClient(*args)
    def getDestClient(*args): return _vclapi.VclBiflow_getDestClient(*args)
    def getInsertSignature(*args): return _vclapi.VclBiflow_getInsertSignature(*args)
    def getNumFrames(*args): return _vclapi.VclBiflow_getNumFrames(*args)
    def getAutoReconnect(*args): return _vclapi.VclBiflow_getAutoReconnect(*args)
    def getRateMode(*args): return _vclapi.VclBiflow_getRateMode(*args)
    def getIntendedRate(*args): return _vclapi.VclBiflow_getIntendedRate(*args)
    def getIfg(*args): return _vclapi.VclBiflow_getIfg(*args)
    def getPriority(*args): return _vclapi.VclBiflow_getPriority(*args)
    def getFrameSize(*args): return _vclapi.VclBiflow_getFrameSize(*args)
    def getPayloadMode(*args): return _vclapi.VclBiflow_getPayloadMode(*args)
    def getPayload(*args): return _vclapi.VclBiflow_getPayload(*args)
    def getRetryLimit(*args): return _vclapi.VclBiflow_getRetryLimit(*args)
    def getAifs(*args): return _vclapi.VclBiflow_getAifs(*args)
    def getCwMin(*args): return _vclapi.VclBiflow_getCwMin(*args)
    def getCwMax(*args): return _vclapi.VclBiflow_getCwMax(*args)
    def getPhyRate(*args): return _vclapi.VclBiflow_getPhyRate(*args)
    def getAutoMaxPhyRate(*args): return _vclapi.VclBiflow_getAutoMaxPhyRate(*args)
    def getFlowLearning(*args): return _vclapi.VclBiflow_getFlowLearning(*args)
    def getLearningRate(*args): return _vclapi.VclBiflow_getLearningRate(*args)
    def getState(*args): return _vclapi.VclBiflow_getState(*args)
    def getSignatureOffset(*args): return _vclapi.VclBiflow_getSignatureOffset(*args)
    def getPayloadChecksumEnabled(*args): return _vclapi.VclBiflow_getPayloadChecksumEnabled(*args)
    def getPayloadChecksumOffset(*args): return _vclapi.VclBiflow_getPayloadChecksumOffset(*args)
    def setDefaults(*args): return _vclapi.VclBiflow_setDefaults(*args)
    def set(*args): return _vclapi.VclBiflow_set(*args)
    def setEnable(*args): return _vclapi.VclBiflow_setEnable(*args)
    def setSrcClient(*args): return _vclapi.VclBiflow_setSrcClient(*args)
    def setDestClient(*args): return _vclapi.VclBiflow_setDestClient(*args)
    def setInsertSignature(*args): return _vclapi.VclBiflow_setInsertSignature(*args)
    def setNumFrames(*args): return _vclapi.VclBiflow_setNumFrames(*args)
    def setAutoReconnect(*args): return _vclapi.VclBiflow_setAutoReconnect(*args)
    def setRateMode(*args): return _vclapi.VclBiflow_setRateMode(*args)
    def setIntendedRate(*args): return _vclapi.VclBiflow_setIntendedRate(*args)
    def setIfg(*args): return _vclapi.VclBiflow_setIfg(*args)
    def setPriority(*args): return _vclapi.VclBiflow_setPriority(*args)
    def setFrameSize(*args): return _vclapi.VclBiflow_setFrameSize(*args)
    def setPayloadMode(*args): return _vclapi.VclBiflow_setPayloadMode(*args)
    def setPayload(*args): return _vclapi.VclBiflow_setPayload(*args)
    def setRetryLimit(*args): return _vclapi.VclBiflow_setRetryLimit(*args)
    def setAifs(*args): return _vclapi.VclBiflow_setAifs(*args)
    def setCwMin(*args): return _vclapi.VclBiflow_setCwMin(*args)
    def setCwMax(*args): return _vclapi.VclBiflow_setCwMax(*args)
    def setPhyRate(*args): return _vclapi.VclBiflow_setPhyRate(*args)
    def setAutoMaxPhyRate(*args): return _vclapi.VclBiflow_setAutoMaxPhyRate(*args)
    def setFlowLearning(*args): return _vclapi.VclBiflow_setFlowLearning(*args)
    def setLearningRate(*args): return _vclapi.VclBiflow_setLearningRate(*args)
    def setSignatureOffset(*args): return _vclapi.VclBiflow_setSignatureOffset(*args)
    def setPayloadChecksumEnabled(*args): return _vclapi.VclBiflow_setPayloadChecksumEnabled(*args)
    def setPayloadChecksumOffset(*args): return _vclapi.VclBiflow_setPayloadChecksumOffset(*args)
    __swig_getmethods__["name"] = _vclapi.VclBiflow_name_get
    if _newclass:name = property(_vclapi.VclBiflow_name_get)
    __swig_setmethods__["enable"] = _vclapi.VclBiflow_enable_set
    __swig_getmethods__["enable"] = _vclapi.VclBiflow_enable_get
    if _newclass:enable = property(_vclapi.VclBiflow_enable_get, _vclapi.VclBiflow_enable_set)
    __swig_setmethods__["srcClient"] = _vclapi.VclBiflow_srcClient_set
    __swig_getmethods__["srcClient"] = _vclapi.VclBiflow_srcClient_get
    if _newclass:srcClient = property(_vclapi.VclBiflow_srcClient_get, _vclapi.VclBiflow_srcClient_set)
    __swig_setmethods__["destClient"] = _vclapi.VclBiflow_destClient_set
    __swig_getmethods__["destClient"] = _vclapi.VclBiflow_destClient_get
    if _newclass:destClient = property(_vclapi.VclBiflow_destClient_get, _vclapi.VclBiflow_destClient_set)
    __swig_setmethods__["insertSignature"] = _vclapi.VclBiflow_insertSignature_set
    __swig_getmethods__["insertSignature"] = _vclapi.VclBiflow_insertSignature_get
    if _newclass:insertSignature = property(_vclapi.VclBiflow_insertSignature_get, _vclapi.VclBiflow_insertSignature_set)
    __swig_setmethods__["numFrames"] = _vclapi.VclBiflow_numFrames_set
    __swig_getmethods__["numFrames"] = _vclapi.VclBiflow_numFrames_get
    if _newclass:numFrames = property(_vclapi.VclBiflow_numFrames_get, _vclapi.VclBiflow_numFrames_set)
    __swig_setmethods__["autoReconnect"] = _vclapi.VclBiflow_autoReconnect_set
    __swig_getmethods__["autoReconnect"] = _vclapi.VclBiflow_autoReconnect_get
    if _newclass:autoReconnect = property(_vclapi.VclBiflow_autoReconnect_get, _vclapi.VclBiflow_autoReconnect_set)
    __swig_setmethods__["rateMode"] = _vclapi.VclBiflow_rateMode_set
    __swig_getmethods__["rateMode"] = _vclapi.VclBiflow_rateMode_get
    if _newclass:rateMode = property(_vclapi.VclBiflow_rateMode_get, _vclapi.VclBiflow_rateMode_set)
    __swig_setmethods__["intendedRate"] = _vclapi.VclBiflow_intendedRate_set
    __swig_getmethods__["intendedRate"] = _vclapi.VclBiflow_intendedRate_get
    if _newclass:intendedRate = property(_vclapi.VclBiflow_intendedRate_get, _vclapi.VclBiflow_intendedRate_set)
    __swig_setmethods__["ifg"] = _vclapi.VclBiflow_ifg_set
    __swig_getmethods__["ifg"] = _vclapi.VclBiflow_ifg_get
    if _newclass:ifg = property(_vclapi.VclBiflow_ifg_get, _vclapi.VclBiflow_ifg_set)
    __swig_setmethods__["priority"] = _vclapi.VclBiflow_priority_set
    __swig_getmethods__["priority"] = _vclapi.VclBiflow_priority_get
    if _newclass:priority = property(_vclapi.VclBiflow_priority_get, _vclapi.VclBiflow_priority_set)
    __swig_setmethods__["frameSize"] = _vclapi.VclBiflow_frameSize_set
    __swig_getmethods__["frameSize"] = _vclapi.VclBiflow_frameSize_get
    if _newclass:frameSize = property(_vclapi.VclBiflow_frameSize_get, _vclapi.VclBiflow_frameSize_set)
    __swig_setmethods__["payloadMode"] = _vclapi.VclBiflow_payloadMode_set
    __swig_getmethods__["payloadMode"] = _vclapi.VclBiflow_payloadMode_get
    if _newclass:payloadMode = property(_vclapi.VclBiflow_payloadMode_get, _vclapi.VclBiflow_payloadMode_set)
    __swig_setmethods__["payload"] = _vclapi.VclBiflow_payload_set
    __swig_getmethods__["payload"] = _vclapi.VclBiflow_payload_get
    if _newclass:payload = property(_vclapi.VclBiflow_payload_get, _vclapi.VclBiflow_payload_set)
    __swig_setmethods__["retryLimit"] = _vclapi.VclBiflow_retryLimit_set
    __swig_getmethods__["retryLimit"] = _vclapi.VclBiflow_retryLimit_get
    if _newclass:retryLimit = property(_vclapi.VclBiflow_retryLimit_get, _vclapi.VclBiflow_retryLimit_set)
    __swig_setmethods__["aifs"] = _vclapi.VclBiflow_aifs_set
    __swig_getmethods__["aifs"] = _vclapi.VclBiflow_aifs_get
    if _newclass:aifs = property(_vclapi.VclBiflow_aifs_get, _vclapi.VclBiflow_aifs_set)
    __swig_setmethods__["cwMin"] = _vclapi.VclBiflow_cwMin_set
    __swig_getmethods__["cwMin"] = _vclapi.VclBiflow_cwMin_get
    if _newclass:cwMin = property(_vclapi.VclBiflow_cwMin_get, _vclapi.VclBiflow_cwMin_set)
    __swig_setmethods__["cwMax"] = _vclapi.VclBiflow_cwMax_set
    __swig_getmethods__["cwMax"] = _vclapi.VclBiflow_cwMax_get
    if _newclass:cwMax = property(_vclapi.VclBiflow_cwMax_get, _vclapi.VclBiflow_cwMax_set)
    __swig_setmethods__["phyRate"] = _vclapi.VclBiflow_phyRate_set
    __swig_getmethods__["phyRate"] = _vclapi.VclBiflow_phyRate_get
    if _newclass:phyRate = property(_vclapi.VclBiflow_phyRate_get, _vclapi.VclBiflow_phyRate_set)
    __swig_setmethods__["autoMaxPhyRate"] = _vclapi.VclBiflow_autoMaxPhyRate_set
    __swig_getmethods__["autoMaxPhyRate"] = _vclapi.VclBiflow_autoMaxPhyRate_get
    if _newclass:autoMaxPhyRate = property(_vclapi.VclBiflow_autoMaxPhyRate_get, _vclapi.VclBiflow_autoMaxPhyRate_set)
    __swig_setmethods__["flowLearning"] = _vclapi.VclBiflow_flowLearning_set
    __swig_getmethods__["flowLearning"] = _vclapi.VclBiflow_flowLearning_get
    if _newclass:flowLearning = property(_vclapi.VclBiflow_flowLearning_get, _vclapi.VclBiflow_flowLearning_set)
    __swig_setmethods__["learningRate"] = _vclapi.VclBiflow_learningRate_set
    __swig_getmethods__["learningRate"] = _vclapi.VclBiflow_learningRate_get
    if _newclass:learningRate = property(_vclapi.VclBiflow_learningRate_get, _vclapi.VclBiflow_learningRate_set)
    __swig_getmethods__["state"] = _vclapi.VclBiflow_state_get
    if _newclass:state = property(_vclapi.VclBiflow_state_get)
    __swig_setmethods__["signatureOffset"] = _vclapi.VclBiflow_signatureOffset_set
    __swig_getmethods__["signatureOffset"] = _vclapi.VclBiflow_signatureOffset_get
    if _newclass:signatureOffset = property(_vclapi.VclBiflow_signatureOffset_get, _vclapi.VclBiflow_signatureOffset_set)
    __swig_setmethods__["payloadChecksumEnabled"] = _vclapi.VclBiflow_payloadChecksumEnabled_set
    __swig_getmethods__["payloadChecksumEnabled"] = _vclapi.VclBiflow_payloadChecksumEnabled_get
    if _newclass:payloadChecksumEnabled = property(_vclapi.VclBiflow_payloadChecksumEnabled_get, _vclapi.VclBiflow_payloadChecksumEnabled_set)
    __swig_setmethods__["payloadChecksumOffset"] = _vclapi.VclBiflow_payloadChecksumOffset_set
    __swig_getmethods__["payloadChecksumOffset"] = _vclapi.VclBiflow_payloadChecksumOffset_get
    if _newclass:payloadChecksumOffset = property(_vclapi.VclBiflow_payloadChecksumOffset_get, _vclapi.VclBiflow_payloadChecksumOffset_set)
    def __init__(self, *args):
        _swig_setattr(self, VclBiflow, 'this', _vclapi.new_VclBiflow(*args))
        _swig_setattr(self, VclBiflow, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclBiflow):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclBiflowPtr(VclBiflow):
    def __init__(self, this):
        _swig_setattr(self, VclBiflow, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclBiflow, 'thisown', 0)
        _swig_setattr(self, VclBiflow,self.__class__,VclBiflow)
_vclapi.VclBiflow_swigregister(VclBiflowPtr)

class VclFlow(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlow, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlow, name)
    def __repr__(self):
        return "<C VclFlow instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclFlow_create(*args)
    def destroy(*args): return _vclapi.VclFlow_destroy(*args)
    def read(*args): return _vclapi.VclFlow_read(*args)
    def write(*args): return _vclapi.VclFlow_write(*args)
    def validate(*args): return _vclapi.VclFlow_validate(*args)
    def doArpExchange(*args): return _vclapi.VclFlow_doArpExchange(*args)
    def doArpStatus(*args): return _vclapi.VclFlow_doArpStatus(*args)
    def getNames(*args): return _vclapi.VclFlow_getNames(*args)
    def getFrame(*args): return _vclapi.VclFlow_getFrame(*args)
    def getMacHeader(*args): return _vclapi.VclFlow_getMacHeader(*args)
    def getName(*args): return _vclapi.VclFlow_getName(*args)
    def getType(*args): return _vclapi.VclFlow_getType(*args)
    def getEnable(*args): return _vclapi.VclFlow_getEnable(*args)
    def getProtocolHeaderLen(*args): return _vclapi.VclFlow_getProtocolHeaderLen(*args)
    def getProtocolHeader(*args): return _vclapi.VclFlow_getProtocolHeader(*args)
    def getPayloadLen(*args): return _vclapi.VclFlow_getPayloadLen(*args)
    def getPayloadMode(*args): return _vclapi.VclFlow_getPayloadMode(*args)
    def getPayload(*args): return _vclapi.VclFlow_getPayload(*args)
    def getPayloadPattern(*args): return _vclapi.VclFlow_getPayloadPattern(*args)
    def getPayloadChecksum(*args): return _vclapi.VclFlow_getPayloadChecksum(*args)
    def getSignature(*args): return _vclapi.VclFlow_getSignature(*args)
    def getUpdateType1(*args): return _vclapi.VclFlow_getUpdateType1(*args)
    def getUpdateTarget1(*args): return _vclapi.VclFlow_getUpdateTarget1(*args)
    def getUpdateOffset1(*args): return _vclapi.VclFlow_getUpdateOffset1(*args)
    def getUpdateData1(*args): return _vclapi.VclFlow_getUpdateData1(*args)
    def getUpdateType2(*args): return _vclapi.VclFlow_getUpdateType2(*args)
    def getUpdateTarget2(*args): return _vclapi.VclFlow_getUpdateTarget2(*args)
    def getUpdateOffset2(*args): return _vclapi.VclFlow_getUpdateOffset2(*args)
    def getUpdateData2(*args): return _vclapi.VclFlow_getUpdateData2(*args)
    def getSysUpdateProtocol(*args): return _vclapi.VclFlow_getSysUpdateProtocol(*args)
    def getSysUpdateType(*args): return _vclapi.VclFlow_getSysUpdateType(*args)
    def getSysUpdateTarget(*args): return _vclapi.VclFlow_getSysUpdateTarget(*args)
    def getSysUpdateOffset(*args): return _vclapi.VclFlow_getSysUpdateOffset(*args)
    def getSysUpdateData(*args): return _vclapi.VclFlow_getSysUpdateData(*args)
    def getSignatureOffset(*args): return _vclapi.VclFlow_getSignatureOffset(*args)
    def getPayloadChecksumEnabled(*args): return _vclapi.VclFlow_getPayloadChecksumEnabled(*args)
    def getPayloadChecksumOffset(*args): return _vclapi.VclFlow_getPayloadChecksumOffset(*args)
    def getMinFrameSizebyType(*args): return _vclapi.VclFlow_getMinFrameSizebyType(*args)
    def findSysUpdate(*args): return _vclapi.VclFlow_findSysUpdate(*args)
    def setSysUpdateProtocol(*args): return _vclapi.VclFlow_setSysUpdateProtocol(*args)
    def setSysUpdateType(*args): return _vclapi.VclFlow_setSysUpdateType(*args)
    def setSysUpdateTarget(*args): return _vclapi.VclFlow_setSysUpdateTarget(*args)
    def setSysUpdateOffset(*args): return _vclapi.VclFlow_setSysUpdateOffset(*args)
    def setSysUpdateData(*args): return _vclapi.VclFlow_setSysUpdateData(*args)
    def setSysUpdate(*args): return _vclapi.VclFlow_setSysUpdate(*args)
    def getSrcClient(*args): return _vclapi.VclFlow_getSrcClient(*args)
    def getDestClient(*args): return _vclapi.VclFlow_getDestClient(*args)
    def getRateMode(*args): return _vclapi.VclFlow_getRateMode(*args)
    def getIntendedRate(*args): return _vclapi.VclFlow_getIntendedRate(*args)
    def getIfg(*args): return _vclapi.VclFlow_getIfg(*args)
    def getPriority(*args): return _vclapi.VclFlow_getPriority(*args)
    def getNumFrames(*args): return _vclapi.VclFlow_getNumFrames(*args)
    def getFrameSize(*args): return _vclapi.VclFlow_getFrameSize(*args)
    def getRetryLimit(*args): return _vclapi.VclFlow_getRetryLimit(*args)
    def getInsertSignature(*args): return _vclapi.VclFlow_getInsertSignature(*args)
    def getPhyRate(*args): return _vclapi.VclFlow_getPhyRate(*args)
    def getAifs(*args): return _vclapi.VclFlow_getAifs(*args)
    def getCwMin(*args): return _vclapi.VclFlow_getCwMin(*args)
    def getCwMax(*args): return _vclapi.VclFlow_getCwMax(*args)
    def getFlowLearning(*args): return _vclapi.VclFlow_getFlowLearning(*args)
    def getLearningRate(*args): return _vclapi.VclFlow_getLearningRate(*args)
    def getNatEnable(*args): return _vclapi.VclFlow_getNatEnable(*args)
    def getTransmitState(*args): return _vclapi.VclFlow_getTransmitState(*args)
    def setDefaults(*args): return _vclapi.VclFlow_setDefaults(*args)
    def setEnable(*args): return _vclapi.VclFlow_setEnable(*args)
    def setType(*args): return _vclapi.VclFlow_setType(*args)
    def setFrame(*args): return _vclapi.VclFlow_setFrame(*args)
    def setProtocolHeaderLen(*args): return _vclapi.VclFlow_setProtocolHeaderLen(*args)
    def setProtocolHeader(*args): return _vclapi.VclFlow_setProtocolHeader(*args)
    def setPayloadLen(*args): return _vclapi.VclFlow_setPayloadLen(*args)
    def setPayloadMode(*args): return _vclapi.VclFlow_setPayloadMode(*args)
    def setPayload(*args): return _vclapi.VclFlow_setPayload(*args)
    def setPayloadPattern(*args): return _vclapi.VclFlow_setPayloadPattern(*args)
    def setUpdateType1(*args): return _vclapi.VclFlow_setUpdateType1(*args)
    def setUpdateTarget1(*args): return _vclapi.VclFlow_setUpdateTarget1(*args)
    def setUpdateOffset1(*args): return _vclapi.VclFlow_setUpdateOffset1(*args)
    def setUpdateData1(*args): return _vclapi.VclFlow_setUpdateData1(*args)
    def setUpdateType2(*args): return _vclapi.VclFlow_setUpdateType2(*args)
    def setUpdateTarget2(*args): return _vclapi.VclFlow_setUpdateTarget2(*args)
    def setUpdateOffset2(*args): return _vclapi.VclFlow_setUpdateOffset2(*args)
    def setUpdateData2(*args): return _vclapi.VclFlow_setUpdateData2(*args)
    def setSrcClient(*args): return _vclapi.VclFlow_setSrcClient(*args)
    def setDestClient(*args): return _vclapi.VclFlow_setDestClient(*args)
    def setRateMode(*args): return _vclapi.VclFlow_setRateMode(*args)
    def setIntendedRate(*args): return _vclapi.VclFlow_setIntendedRate(*args)
    def setIfg(*args): return _vclapi.VclFlow_setIfg(*args)
    def setPriority(*args): return _vclapi.VclFlow_setPriority(*args)
    def setNumFrames(*args): return _vclapi.VclFlow_setNumFrames(*args)
    def setFrameSize(*args): return _vclapi.VclFlow_setFrameSize(*args)
    def setRetryLimit(*args): return _vclapi.VclFlow_setRetryLimit(*args)
    def setInsertSignature(*args): return _vclapi.VclFlow_setInsertSignature(*args)
    def setPhyRate(*args): return _vclapi.VclFlow_setPhyRate(*args)
    def setAifs(*args): return _vclapi.VclFlow_setAifs(*args)
    def setCwMin(*args): return _vclapi.VclFlow_setCwMin(*args)
    def setCwMax(*args): return _vclapi.VclFlow_setCwMax(*args)
    def setFlowLearning(*args): return _vclapi.VclFlow_setFlowLearning(*args)
    def setLearningRate(*args): return _vclapi.VclFlow_setLearningRate(*args)
    def setNatEnable(*args): return _vclapi.VclFlow_setNatEnable(*args)
    def setSignatureOffset(*args): return _vclapi.VclFlow_setSignatureOffset(*args)
    def setPayloadChecksumEnabled(*args): return _vclapi.VclFlow_setPayloadChecksumEnabled(*args)
    def setPayloadChecksumOffset(*args): return _vclapi.VclFlow_setPayloadChecksumOffset(*args)
    __swig_getmethods__["name"] = _vclapi.VclFlow_name_get
    if _newclass:name = property(_vclapi.VclFlow_name_get)
    __swig_setmethods__["enable"] = _vclapi.VclFlow_enable_set
    __swig_getmethods__["enable"] = _vclapi.VclFlow_enable_get
    if _newclass:enable = property(_vclapi.VclFlow_enable_get, _vclapi.VclFlow_enable_set)
    __swig_getmethods__["protocolHeader"] = _vclapi.VclFlow_protocolHeader_get
    if _newclass:protocolHeader = property(_vclapi.VclFlow_protocolHeader_get)
    __swig_getmethods__["protocolHeaderLen"] = _vclapi.VclFlow_protocolHeaderLen_get
    if _newclass:protocolHeaderLen = property(_vclapi.VclFlow_protocolHeaderLen_get)
    __swig_setmethods__["payloadLen"] = _vclapi.VclFlow_payloadLen_set
    __swig_getmethods__["payloadLen"] = _vclapi.VclFlow_payloadLen_get
    if _newclass:payloadLen = property(_vclapi.VclFlow_payloadLen_get, _vclapi.VclFlow_payloadLen_set)
    __swig_setmethods__["payloadMode"] = _vclapi.VclFlow_payloadMode_set
    __swig_getmethods__["payloadMode"] = _vclapi.VclFlow_payloadMode_get
    if _newclass:payloadMode = property(_vclapi.VclFlow_payloadMode_get, _vclapi.VclFlow_payloadMode_set)
    __swig_setmethods__["payload"] = _vclapi.VclFlow_payload_set
    __swig_getmethods__["payload"] = _vclapi.VclFlow_payload_get
    if _newclass:payload = property(_vclapi.VclFlow_payload_get, _vclapi.VclFlow_payload_set)
    __swig_setmethods__["payloadPattern"] = _vclapi.VclFlow_payloadPattern_set
    __swig_getmethods__["payloadPattern"] = _vclapi.VclFlow_payloadPattern_get
    if _newclass:payloadPattern = property(_vclapi.VclFlow_payloadPattern_get, _vclapi.VclFlow_payloadPattern_set)
    __swig_getmethods__["signature"] = _vclapi.VclFlow_signature_get
    if _newclass:signature = property(_vclapi.VclFlow_signature_get)
    __swig_getmethods__["payloadChecksum"] = _vclapi.VclFlow_payloadChecksum_get
    if _newclass:payloadChecksum = property(_vclapi.VclFlow_payloadChecksum_get)
    __swig_getmethods__["transmitState"] = _vclapi.VclFlow_transmitState_get
    if _newclass:transmitState = property(_vclapi.VclFlow_transmitState_get)
    __swig_setmethods__["updateType1"] = _vclapi.VclFlow_updateType1_set
    __swig_getmethods__["updateType1"] = _vclapi.VclFlow_updateType1_get
    if _newclass:updateType1 = property(_vclapi.VclFlow_updateType1_get, _vclapi.VclFlow_updateType1_set)
    __swig_setmethods__["updateTarget1"] = _vclapi.VclFlow_updateTarget1_set
    __swig_getmethods__["updateTarget1"] = _vclapi.VclFlow_updateTarget1_get
    if _newclass:updateTarget1 = property(_vclapi.VclFlow_updateTarget1_get, _vclapi.VclFlow_updateTarget1_set)
    __swig_setmethods__["updateOffset1"] = _vclapi.VclFlow_updateOffset1_set
    __swig_getmethods__["updateOffset1"] = _vclapi.VclFlow_updateOffset1_get
    if _newclass:updateOffset1 = property(_vclapi.VclFlow_updateOffset1_get, _vclapi.VclFlow_updateOffset1_set)
    __swig_setmethods__["updateData1"] = _vclapi.VclFlow_updateData1_set
    __swig_getmethods__["updateData1"] = _vclapi.VclFlow_updateData1_get
    if _newclass:updateData1 = property(_vclapi.VclFlow_updateData1_get, _vclapi.VclFlow_updateData1_set)
    __swig_setmethods__["updateType2"] = _vclapi.VclFlow_updateType2_set
    __swig_getmethods__["updateType2"] = _vclapi.VclFlow_updateType2_get
    if _newclass:updateType2 = property(_vclapi.VclFlow_updateType2_get, _vclapi.VclFlow_updateType2_set)
    __swig_setmethods__["updateTarget2"] = _vclapi.VclFlow_updateTarget2_set
    __swig_getmethods__["updateTarget2"] = _vclapi.VclFlow_updateTarget2_get
    if _newclass:updateTarget2 = property(_vclapi.VclFlow_updateTarget2_get, _vclapi.VclFlow_updateTarget2_set)
    __swig_setmethods__["updateOffset2"] = _vclapi.VclFlow_updateOffset2_set
    __swig_getmethods__["updateOffset2"] = _vclapi.VclFlow_updateOffset2_get
    if _newclass:updateOffset2 = property(_vclapi.VclFlow_updateOffset2_get, _vclapi.VclFlow_updateOffset2_set)
    __swig_setmethods__["updateData2"] = _vclapi.VclFlow_updateData2_set
    __swig_getmethods__["updateData2"] = _vclapi.VclFlow_updateData2_get
    if _newclass:updateData2 = property(_vclapi.VclFlow_updateData2_get, _vclapi.VclFlow_updateData2_set)
    __swig_setmethods__["srcClient"] = _vclapi.VclFlow_srcClient_set
    __swig_getmethods__["srcClient"] = _vclapi.VclFlow_srcClient_get
    if _newclass:srcClient = property(_vclapi.VclFlow_srcClient_get, _vclapi.VclFlow_srcClient_set)
    __swig_setmethods__["destClient"] = _vclapi.VclFlow_destClient_set
    __swig_getmethods__["destClient"] = _vclapi.VclFlow_destClient_get
    if _newclass:destClient = property(_vclapi.VclFlow_destClient_get, _vclapi.VclFlow_destClient_set)
    __swig_setmethods__["rateMode"] = _vclapi.VclFlow_rateMode_set
    __swig_getmethods__["rateMode"] = _vclapi.VclFlow_rateMode_get
    if _newclass:rateMode = property(_vclapi.VclFlow_rateMode_get, _vclapi.VclFlow_rateMode_set)
    __swig_setmethods__["intendedRate"] = _vclapi.VclFlow_intendedRate_set
    __swig_getmethods__["intendedRate"] = _vclapi.VclFlow_intendedRate_get
    if _newclass:intendedRate = property(_vclapi.VclFlow_intendedRate_get, _vclapi.VclFlow_intendedRate_set)
    __swig_setmethods__["ifg"] = _vclapi.VclFlow_ifg_set
    __swig_getmethods__["ifg"] = _vclapi.VclFlow_ifg_get
    if _newclass:ifg = property(_vclapi.VclFlow_ifg_get, _vclapi.VclFlow_ifg_set)
    __swig_setmethods__["priority"] = _vclapi.VclFlow_priority_set
    __swig_getmethods__["priority"] = _vclapi.VclFlow_priority_get
    if _newclass:priority = property(_vclapi.VclFlow_priority_get, _vclapi.VclFlow_priority_set)
    __swig_setmethods__["numFrames"] = _vclapi.VclFlow_numFrames_set
    __swig_getmethods__["numFrames"] = _vclapi.VclFlow_numFrames_get
    if _newclass:numFrames = property(_vclapi.VclFlow_numFrames_get, _vclapi.VclFlow_numFrames_set)
    __swig_setmethods__["frameSize"] = _vclapi.VclFlow_frameSize_set
    __swig_getmethods__["frameSize"] = _vclapi.VclFlow_frameSize_get
    if _newclass:frameSize = property(_vclapi.VclFlow_frameSize_get, _vclapi.VclFlow_frameSize_set)
    __swig_setmethods__["retryLimit"] = _vclapi.VclFlow_retryLimit_set
    __swig_getmethods__["retryLimit"] = _vclapi.VclFlow_retryLimit_get
    if _newclass:retryLimit = property(_vclapi.VclFlow_retryLimit_get, _vclapi.VclFlow_retryLimit_set)
    __swig_setmethods__["insertSignature"] = _vclapi.VclFlow_insertSignature_set
    __swig_getmethods__["insertSignature"] = _vclapi.VclFlow_insertSignature_get
    if _newclass:insertSignature = property(_vclapi.VclFlow_insertSignature_get, _vclapi.VclFlow_insertSignature_set)
    __swig_setmethods__["phyRate"] = _vclapi.VclFlow_phyRate_set
    __swig_getmethods__["phyRate"] = _vclapi.VclFlow_phyRate_get
    if _newclass:phyRate = property(_vclapi.VclFlow_phyRate_get, _vclapi.VclFlow_phyRate_set)
    __swig_setmethods__["aifs"] = _vclapi.VclFlow_aifs_set
    __swig_getmethods__["aifs"] = _vclapi.VclFlow_aifs_get
    if _newclass:aifs = property(_vclapi.VclFlow_aifs_get, _vclapi.VclFlow_aifs_set)
    __swig_setmethods__["cwMin"] = _vclapi.VclFlow_cwMin_set
    __swig_getmethods__["cwMin"] = _vclapi.VclFlow_cwMin_get
    if _newclass:cwMin = property(_vclapi.VclFlow_cwMin_get, _vclapi.VclFlow_cwMin_set)
    __swig_setmethods__["cwMax"] = _vclapi.VclFlow_cwMax_set
    __swig_getmethods__["cwMax"] = _vclapi.VclFlow_cwMax_get
    if _newclass:cwMax = property(_vclapi.VclFlow_cwMax_get, _vclapi.VclFlow_cwMax_set)
    __swig_setmethods__["flowLearning"] = _vclapi.VclFlow_flowLearning_set
    __swig_getmethods__["flowLearning"] = _vclapi.VclFlow_flowLearning_get
    if _newclass:flowLearning = property(_vclapi.VclFlow_flowLearning_get, _vclapi.VclFlow_flowLearning_set)
    __swig_setmethods__["learningRate"] = _vclapi.VclFlow_learningRate_set
    __swig_getmethods__["learningRate"] = _vclapi.VclFlow_learningRate_get
    if _newclass:learningRate = property(_vclapi.VclFlow_learningRate_get, _vclapi.VclFlow_learningRate_set)
    __swig_setmethods__["natEnable"] = _vclapi.VclFlow_natEnable_set
    __swig_getmethods__["natEnable"] = _vclapi.VclFlow_natEnable_get
    if _newclass:natEnable = property(_vclapi.VclFlow_natEnable_get, _vclapi.VclFlow_natEnable_set)
    __swig_setmethods__["signatureOffset"] = _vclapi.VclFlow_signatureOffset_set
    __swig_getmethods__["signatureOffset"] = _vclapi.VclFlow_signatureOffset_get
    if _newclass:signatureOffset = property(_vclapi.VclFlow_signatureOffset_get, _vclapi.VclFlow_signatureOffset_set)
    __swig_setmethods__["payloadChecksumEnabled"] = _vclapi.VclFlow_payloadChecksumEnabled_set
    __swig_getmethods__["payloadChecksumEnabled"] = _vclapi.VclFlow_payloadChecksumEnabled_get
    if _newclass:payloadChecksumEnabled = property(_vclapi.VclFlow_payloadChecksumEnabled_get, _vclapi.VclFlow_payloadChecksumEnabled_set)
    __swig_setmethods__["payloadChecksumOffset"] = _vclapi.VclFlow_payloadChecksumOffset_set
    __swig_getmethods__["payloadChecksumOffset"] = _vclapi.VclFlow_payloadChecksumOffset_get
    if _newclass:payloadChecksumOffset = property(_vclapi.VclFlow_payloadChecksumOffset_get, _vclapi.VclFlow_payloadChecksumOffset_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFlow, 'this', _vclapi.new_VclFlow(*args))
        _swig_setattr(self, VclFlow, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlow):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowPtr(VclFlow):
    def __init__(self, this):
        _swig_setattr(self, VclFlow, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlow, 'thisown', 0)
        _swig_setattr(self, VclFlow,self.__class__,VclFlow)
_vclapi.VclFlow_swigregister(VclFlowPtr)

class VclFlowModMac(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowModMac, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowModMac, name)
    def __repr__(self):
        return "<C VclFlowModMac instance at %s>" % (self.this,)
    def readFlow(*args): return _vclapi.VclFlowModMac_readFlow(*args)
    def modifyFlow(*args): return _vclapi.VclFlowModMac_modifyFlow(*args)
    def read(*args): return _vclapi.VclFlowModMac_read(*args)
    def modify(*args): return _vclapi.VclFlowModMac_modify(*args)
    def setDefaultFlow(*args): return _vclapi.VclFlowModMac_setDefaultFlow(*args)
    def validate(*args): return _vclapi.VclFlowModMac_validate(*args)
    def getSrcAddr(*args): return _vclapi.VclFlowModMac_getSrcAddr(*args)
    def getDestAddr(*args): return _vclapi.VclFlowModMac_getDestAddr(*args)
    def getEtherType(*args): return _vclapi.VclFlowModMac_getEtherType(*args)
    def setDefaults(*args): return _vclapi.VclFlowModMac_setDefaults(*args)
    def setSrcAddr(*args): return _vclapi.VclFlowModMac_setSrcAddr(*args)
    def setDestAddr(*args): return _vclapi.VclFlowModMac_setDestAddr(*args)
    def setEtherType(*args): return _vclapi.VclFlowModMac_setEtherType(*args)
    __swig_setmethods__["srcAddr"] = _vclapi.VclFlowModMac_srcAddr_set
    __swig_getmethods__["srcAddr"] = _vclapi.VclFlowModMac_srcAddr_get
    if _newclass:srcAddr = property(_vclapi.VclFlowModMac_srcAddr_get, _vclapi.VclFlowModMac_srcAddr_set)
    __swig_setmethods__["destAddr"] = _vclapi.VclFlowModMac_destAddr_set
    __swig_getmethods__["destAddr"] = _vclapi.VclFlowModMac_destAddr_get
    if _newclass:destAddr = property(_vclapi.VclFlowModMac_destAddr_get, _vclapi.VclFlowModMac_destAddr_set)
    __swig_setmethods__["etherType"] = _vclapi.VclFlowModMac_etherType_set
    __swig_getmethods__["etherType"] = _vclapi.VclFlowModMac_etherType_get
    if _newclass:etherType = property(_vclapi.VclFlowModMac_etherType_get, _vclapi.VclFlowModMac_etherType_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowModMac, 'this', _vclapi.new_VclFlowModMac(*args))
        _swig_setattr(self, VclFlowModMac, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowModMac):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowModMacPtr(VclFlowModMac):
    def __init__(self, this):
        _swig_setattr(self, VclFlowModMac, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowModMac, 'thisown', 0)
        _swig_setattr(self, VclFlowModMac,self.__class__,VclFlowModMac)
_vclapi.VclFlowModMac_swigregister(VclFlowModMacPtr)

class VclFlowModUdp(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowModUdp, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowModUdp, name)
    def __repr__(self):
        return "<C VclFlowModUdp instance at %s>" % (self.this,)
    def readFlow(*args): return _vclapi.VclFlowModUdp_readFlow(*args)
    def modifyFlow(*args): return _vclapi.VclFlowModUdp_modifyFlow(*args)
    def read(*args): return _vclapi.VclFlowModUdp_read(*args)
    def modify(*args): return _vclapi.VclFlowModUdp_modify(*args)
    def setDefaultFlow(*args): return _vclapi.VclFlowModUdp_setDefaultFlow(*args)
    def getSrcPort(*args): return _vclapi.VclFlowModUdp_getSrcPort(*args)
    def getDestPort(*args): return _vclapi.VclFlowModUdp_getDestPort(*args)
    def getLen(*args): return _vclapi.VclFlowModUdp_getLen(*args)
    def getChecksum(*args): return _vclapi.VclFlowModUdp_getChecksum(*args)
    def getChecksumMode(*args): return _vclapi.VclFlowModUdp_getChecksumMode(*args)
    def setDefaults(*args): return _vclapi.VclFlowModUdp_setDefaults(*args)
    def setSrcPort(*args): return _vclapi.VclFlowModUdp_setSrcPort(*args)
    def setDestPort(*args): return _vclapi.VclFlowModUdp_setDestPort(*args)
    def setChecksum(*args): return _vclapi.VclFlowModUdp_setChecksum(*args)
    def setChecksumMode(*args): return _vclapi.VclFlowModUdp_setChecksumMode(*args)
    __swig_setmethods__["srcPort"] = _vclapi.VclFlowModUdp_srcPort_set
    __swig_getmethods__["srcPort"] = _vclapi.VclFlowModUdp_srcPort_get
    if _newclass:srcPort = property(_vclapi.VclFlowModUdp_srcPort_get, _vclapi.VclFlowModUdp_srcPort_set)
    __swig_setmethods__["destPort"] = _vclapi.VclFlowModUdp_destPort_set
    __swig_getmethods__["destPort"] = _vclapi.VclFlowModUdp_destPort_get
    if _newclass:destPort = property(_vclapi.VclFlowModUdp_destPort_get, _vclapi.VclFlowModUdp_destPort_set)
    __swig_getmethods__["len"] = _vclapi.VclFlowModUdp_len_get
    if _newclass:len = property(_vclapi.VclFlowModUdp_len_get)
    __swig_setmethods__["checksum"] = _vclapi.VclFlowModUdp_checksum_set
    __swig_getmethods__["checksum"] = _vclapi.VclFlowModUdp_checksum_get
    if _newclass:checksum = property(_vclapi.VclFlowModUdp_checksum_get, _vclapi.VclFlowModUdp_checksum_set)
    __swig_setmethods__["checksumMode"] = _vclapi.VclFlowModUdp_checksumMode_set
    __swig_getmethods__["checksumMode"] = _vclapi.VclFlowModUdp_checksumMode_get
    if _newclass:checksumMode = property(_vclapi.VclFlowModUdp_checksumMode_get, _vclapi.VclFlowModUdp_checksumMode_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowModUdp, 'this', _vclapi.new_VclFlowModUdp(*args))
        _swig_setattr(self, VclFlowModUdp, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowModUdp):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowModUdpPtr(VclFlowModUdp):
    def __init__(self, this):
        _swig_setattr(self, VclFlowModUdp, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowModUdp, 'thisown', 0)
        _swig_setattr(self, VclFlowModUdp,self.__class__,VclFlowModUdp)
_vclapi.VclFlowModUdp_swigregister(VclFlowModUdpPtr)

class VclFlowModIcmp(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowModIcmp, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowModIcmp, name)
    def __repr__(self):
        return "<C VclFlowModIcmp instance at %s>" % (self.this,)
    def readFlow(*args): return _vclapi.VclFlowModIcmp_readFlow(*args)
    def modifyFlow(*args): return _vclapi.VclFlowModIcmp_modifyFlow(*args)
    def read(*args): return _vclapi.VclFlowModIcmp_read(*args)
    def modify(*args): return _vclapi.VclFlowModIcmp_modify(*args)
    def setDefaultFlow(*args): return _vclapi.VclFlowModIcmp_setDefaultFlow(*args)
    def getType(*args): return _vclapi.VclFlowModIcmp_getType(*args)
    def getCode(*args): return _vclapi.VclFlowModIcmp_getCode(*args)
    def getData(*args): return _vclapi.VclFlowModIcmp_getData(*args)
    def getDataLen(*args): return _vclapi.VclFlowModIcmp_getDataLen(*args)
    def setDefaults(*args): return _vclapi.VclFlowModIcmp_setDefaults(*args)
    def setType(*args): return _vclapi.VclFlowModIcmp_setType(*args)
    def setCode(*args): return _vclapi.VclFlowModIcmp_setCode(*args)
    def setData(*args): return _vclapi.VclFlowModIcmp_setData(*args)
    def setDataLen(*args): return _vclapi.VclFlowModIcmp_setDataLen(*args)
    __swig_setmethods__["type"] = _vclapi.VclFlowModIcmp_type_set
    __swig_getmethods__["type"] = _vclapi.VclFlowModIcmp_type_get
    if _newclass:type = property(_vclapi.VclFlowModIcmp_type_get, _vclapi.VclFlowModIcmp_type_set)
    __swig_setmethods__["code"] = _vclapi.VclFlowModIcmp_code_set
    __swig_getmethods__["code"] = _vclapi.VclFlowModIcmp_code_get
    if _newclass:code = property(_vclapi.VclFlowModIcmp_code_get, _vclapi.VclFlowModIcmp_code_set)
    __swig_setmethods__["data"] = _vclapi.VclFlowModIcmp_data_set
    __swig_getmethods__["data"] = _vclapi.VclFlowModIcmp_data_get
    if _newclass:data = property(_vclapi.VclFlowModIcmp_data_get, _vclapi.VclFlowModIcmp_data_set)
    __swig_setmethods__["dataLen"] = _vclapi.VclFlowModIcmp_dataLen_set
    __swig_getmethods__["dataLen"] = _vclapi.VclFlowModIcmp_dataLen_get
    if _newclass:dataLen = property(_vclapi.VclFlowModIcmp_dataLen_get, _vclapi.VclFlowModIcmp_dataLen_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowModIcmp, 'this', _vclapi.new_VclFlowModIcmp(*args))
        _swig_setattr(self, VclFlowModIcmp, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowModIcmp):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowModIcmpPtr(VclFlowModIcmp):
    def __init__(self, this):
        _swig_setattr(self, VclFlowModIcmp, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowModIcmp, 'thisown', 0)
        _swig_setattr(self, VclFlowModIcmp,self.__class__,VclFlowModIcmp)
_vclapi.VclFlowModIcmp_swigregister(VclFlowModIcmpPtr)

class VclFlowModIpv4(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowModIpv4, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowModIpv4, name)
    def __repr__(self):
        return "<C VclFlowModIpv4 instance at %s>" % (self.this,)
    def readFlow(*args): return _vclapi.VclFlowModIpv4_readFlow(*args)
    def modifyFlow(*args): return _vclapi.VclFlowModIpv4_modifyFlow(*args)
    def read(*args): return _vclapi.VclFlowModIpv4_read(*args)
    def modify(*args): return _vclapi.VclFlowModIpv4_modify(*args)
    def setDefaultFlow(*args): return _vclapi.VclFlowModIpv4_setDefaultFlow(*args)
    def getPrecedence(*args): return _vclapi.VclFlowModIpv4_getPrecedence(*args)
    def getDscp(*args): return _vclapi.VclFlowModIpv4_getDscp(*args)
    def getDscpMode(*args): return _vclapi.VclFlowModIpv4_getDscpMode(*args)
    def getTos(*args): return _vclapi.VclFlowModIpv4_getTos(*args)
    def getTosField(*args): return _vclapi.VclFlowModIpv4_getTosField(*args)
    def getTotalLength(*args): return _vclapi.VclFlowModIpv4_getTotalLength(*args)
    def getIdentifier(*args): return _vclapi.VclFlowModIpv4_getIdentifier(*args)
    def getFragment(*args): return _vclapi.VclFlowModIpv4_getFragment(*args)
    def getFragmentOffset(*args): return _vclapi.VclFlowModIpv4_getFragmentOffset(*args)
    def getTtl(*args): return _vclapi.VclFlowModIpv4_getTtl(*args)
    def getProtocol(*args): return _vclapi.VclFlowModIpv4_getProtocol(*args)
    def getSrcAddr(*args): return _vclapi.VclFlowModIpv4_getSrcAddr(*args)
    def getDestAddr(*args): return _vclapi.VclFlowModIpv4_getDestAddr(*args)
    def setDefaults(*args): return _vclapi.VclFlowModIpv4_setDefaults(*args)
    def setPrecedence(*args): return _vclapi.VclFlowModIpv4_setPrecedence(*args)
    def setDscp(*args): return _vclapi.VclFlowModIpv4_setDscp(*args)
    def setDscpMode(*args): return _vclapi.VclFlowModIpv4_setDscpMode(*args)
    def setTos(*args): return _vclapi.VclFlowModIpv4_setTos(*args)
    def setTosField(*args): return _vclapi.VclFlowModIpv4_setTosField(*args)
    def setTotalLength(*args): return _vclapi.VclFlowModIpv4_setTotalLength(*args)
    def setIdentifier(*args): return _vclapi.VclFlowModIpv4_setIdentifier(*args)
    def setFragment(*args): return _vclapi.VclFlowModIpv4_setFragment(*args)
    def setFragmentOffset(*args): return _vclapi.VclFlowModIpv4_setFragmentOffset(*args)
    def setTtl(*args): return _vclapi.VclFlowModIpv4_setTtl(*args)
    def setProtocol(*args): return _vclapi.VclFlowModIpv4_setProtocol(*args)
    def setSrcAddr(*args): return _vclapi.VclFlowModIpv4_setSrcAddr(*args)
    def setDestAddr(*args): return _vclapi.VclFlowModIpv4_setDestAddr(*args)
    __swig_setmethods__["precedence"] = _vclapi.VclFlowModIpv4_precedence_set
    __swig_getmethods__["precedence"] = _vclapi.VclFlowModIpv4_precedence_get
    if _newclass:precedence = property(_vclapi.VclFlowModIpv4_precedence_get, _vclapi.VclFlowModIpv4_precedence_set)
    __swig_setmethods__["dscp"] = _vclapi.VclFlowModIpv4_dscp_set
    __swig_getmethods__["dscp"] = _vclapi.VclFlowModIpv4_dscp_get
    if _newclass:dscp = property(_vclapi.VclFlowModIpv4_dscp_get, _vclapi.VclFlowModIpv4_dscp_set)
    __swig_setmethods__["dscpMode"] = _vclapi.VclFlowModIpv4_dscpMode_set
    __swig_getmethods__["dscpMode"] = _vclapi.VclFlowModIpv4_dscpMode_get
    if _newclass:dscpMode = property(_vclapi.VclFlowModIpv4_dscpMode_get, _vclapi.VclFlowModIpv4_dscpMode_set)
    __swig_setmethods__["tos"] = _vclapi.VclFlowModIpv4_tos_set
    __swig_getmethods__["tos"] = _vclapi.VclFlowModIpv4_tos_get
    if _newclass:tos = property(_vclapi.VclFlowModIpv4_tos_get, _vclapi.VclFlowModIpv4_tos_set)
    __swig_setmethods__["tosField"] = _vclapi.VclFlowModIpv4_tosField_set
    __swig_getmethods__["tosField"] = _vclapi.VclFlowModIpv4_tosField_get
    if _newclass:tosField = property(_vclapi.VclFlowModIpv4_tosField_get, _vclapi.VclFlowModIpv4_tosField_set)
    __swig_setmethods__["totalLen"] = _vclapi.VclFlowModIpv4_totalLen_set
    __swig_getmethods__["totalLen"] = _vclapi.VclFlowModIpv4_totalLen_get
    if _newclass:totalLen = property(_vclapi.VclFlowModIpv4_totalLen_get, _vclapi.VclFlowModIpv4_totalLen_set)
    __swig_setmethods__["identifier"] = _vclapi.VclFlowModIpv4_identifier_set
    __swig_getmethods__["identifier"] = _vclapi.VclFlowModIpv4_identifier_get
    if _newclass:identifier = property(_vclapi.VclFlowModIpv4_identifier_get, _vclapi.VclFlowModIpv4_identifier_set)
    __swig_setmethods__["fragment"] = _vclapi.VclFlowModIpv4_fragment_set
    __swig_getmethods__["fragment"] = _vclapi.VclFlowModIpv4_fragment_get
    if _newclass:fragment = property(_vclapi.VclFlowModIpv4_fragment_get, _vclapi.VclFlowModIpv4_fragment_set)
    __swig_setmethods__["fragmentOffset"] = _vclapi.VclFlowModIpv4_fragmentOffset_set
    __swig_getmethods__["fragmentOffset"] = _vclapi.VclFlowModIpv4_fragmentOffset_get
    if _newclass:fragmentOffset = property(_vclapi.VclFlowModIpv4_fragmentOffset_get, _vclapi.VclFlowModIpv4_fragmentOffset_set)
    __swig_setmethods__["ttl"] = _vclapi.VclFlowModIpv4_ttl_set
    __swig_getmethods__["ttl"] = _vclapi.VclFlowModIpv4_ttl_get
    if _newclass:ttl = property(_vclapi.VclFlowModIpv4_ttl_get, _vclapi.VclFlowModIpv4_ttl_set)
    __swig_setmethods__["protocol"] = _vclapi.VclFlowModIpv4_protocol_set
    __swig_getmethods__["protocol"] = _vclapi.VclFlowModIpv4_protocol_get
    if _newclass:protocol = property(_vclapi.VclFlowModIpv4_protocol_get, _vclapi.VclFlowModIpv4_protocol_set)
    __swig_setmethods__["srcAddr"] = _vclapi.VclFlowModIpv4_srcAddr_set
    __swig_getmethods__["srcAddr"] = _vclapi.VclFlowModIpv4_srcAddr_get
    if _newclass:srcAddr = property(_vclapi.VclFlowModIpv4_srcAddr_get, _vclapi.VclFlowModIpv4_srcAddr_set)
    __swig_setmethods__["destAddr"] = _vclapi.VclFlowModIpv4_destAddr_set
    __swig_getmethods__["destAddr"] = _vclapi.VclFlowModIpv4_destAddr_get
    if _newclass:destAddr = property(_vclapi.VclFlowModIpv4_destAddr_get, _vclapi.VclFlowModIpv4_destAddr_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowModIpv4, 'this', _vclapi.new_VclFlowModIpv4(*args))
        _swig_setattr(self, VclFlowModIpv4, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowModIpv4):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowModIpv4Ptr(VclFlowModIpv4):
    def __init__(self, this):
        _swig_setattr(self, VclFlowModIpv4, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowModIpv4, 'thisown', 0)
        _swig_setattr(self, VclFlowModIpv4,self.__class__,VclFlowModIpv4)
_vclapi.VclFlowModIpv4_swigregister(VclFlowModIpv4Ptr)

class VclFlowModTcp(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowModTcp, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowModTcp, name)
    def __repr__(self):
        return "<C VclFlowModTcp instance at %s>" % (self.this,)
    def readFlow(*args): return _vclapi.VclFlowModTcp_readFlow(*args)
    def modifyFlow(*args): return _vclapi.VclFlowModTcp_modifyFlow(*args)
    def read(*args): return _vclapi.VclFlowModTcp_read(*args)
    def modify(*args): return _vclapi.VclFlowModTcp_modify(*args)
    def setDefaultFlow(*args): return _vclapi.VclFlowModTcp_setDefaultFlow(*args)
    def getSrcPort(*args): return _vclapi.VclFlowModTcp_getSrcPort(*args)
    def getDestPort(*args): return _vclapi.VclFlowModTcp_getDestPort(*args)
    def getSeq(*args): return _vclapi.VclFlowModTcp_getSeq(*args)
    def getAckNum(*args): return _vclapi.VclFlowModTcp_getAckNum(*args)
    def getWindow(*args): return _vclapi.VclFlowModTcp_getWindow(*args)
    def getUrgentPointer(*args): return _vclapi.VclFlowModTcp_getUrgentPointer(*args)
    def getControl(*args): return _vclapi.VclFlowModTcp_getControl(*args)
    def setDefaults(*args): return _vclapi.VclFlowModTcp_setDefaults(*args)
    def setSrcPort(*args): return _vclapi.VclFlowModTcp_setSrcPort(*args)
    def setDestPort(*args): return _vclapi.VclFlowModTcp_setDestPort(*args)
    def setSeq(*args): return _vclapi.VclFlowModTcp_setSeq(*args)
    def setAckNum(*args): return _vclapi.VclFlowModTcp_setAckNum(*args)
    def setWindow(*args): return _vclapi.VclFlowModTcp_setWindow(*args)
    def setUrgentPointer(*args): return _vclapi.VclFlowModTcp_setUrgentPointer(*args)
    def setControl(*args): return _vclapi.VclFlowModTcp_setControl(*args)
    __swig_setmethods__["srcPort"] = _vclapi.VclFlowModTcp_srcPort_set
    __swig_getmethods__["srcPort"] = _vclapi.VclFlowModTcp_srcPort_get
    if _newclass:srcPort = property(_vclapi.VclFlowModTcp_srcPort_get, _vclapi.VclFlowModTcp_srcPort_set)
    __swig_setmethods__["destPort"] = _vclapi.VclFlowModTcp_destPort_set
    __swig_getmethods__["destPort"] = _vclapi.VclFlowModTcp_destPort_get
    if _newclass:destPort = property(_vclapi.VclFlowModTcp_destPort_get, _vclapi.VclFlowModTcp_destPort_set)
    __swig_setmethods__["seq"] = _vclapi.VclFlowModTcp_seq_set
    __swig_getmethods__["seq"] = _vclapi.VclFlowModTcp_seq_get
    if _newclass:seq = property(_vclapi.VclFlowModTcp_seq_get, _vclapi.VclFlowModTcp_seq_set)
    __swig_setmethods__["ackNum"] = _vclapi.VclFlowModTcp_ackNum_set
    __swig_getmethods__["ackNum"] = _vclapi.VclFlowModTcp_ackNum_get
    if _newclass:ackNum = property(_vclapi.VclFlowModTcp_ackNum_get, _vclapi.VclFlowModTcp_ackNum_set)
    __swig_setmethods__["window"] = _vclapi.VclFlowModTcp_window_set
    __swig_getmethods__["window"] = _vclapi.VclFlowModTcp_window_get
    if _newclass:window = property(_vclapi.VclFlowModTcp_window_get, _vclapi.VclFlowModTcp_window_set)
    __swig_setmethods__["urgentPointer"] = _vclapi.VclFlowModTcp_urgentPointer_set
    __swig_getmethods__["urgentPointer"] = _vclapi.VclFlowModTcp_urgentPointer_get
    if _newclass:urgentPointer = property(_vclapi.VclFlowModTcp_urgentPointer_get, _vclapi.VclFlowModTcp_urgentPointer_set)
    __swig_setmethods__["control"] = _vclapi.VclFlowModTcp_control_set
    __swig_getmethods__["control"] = _vclapi.VclFlowModTcp_control_get
    if _newclass:control = property(_vclapi.VclFlowModTcp_control_get, _vclapi.VclFlowModTcp_control_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowModTcp, 'this', _vclapi.new_VclFlowModTcp(*args))
        _swig_setattr(self, VclFlowModTcp, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowModTcp):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowModTcpPtr(VclFlowModTcp):
    def __init__(self, this):
        _swig_setattr(self, VclFlowModTcp, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowModTcp, 'thisown', 0)
        _swig_setattr(self, VclFlowModTcp,self.__class__,VclFlowModTcp)
_vclapi.VclFlowModTcp_swigregister(VclFlowModTcpPtr)

class VclFlowModRtp(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowModRtp, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowModRtp, name)
    def __repr__(self):
        return "<C VclFlowModRtp instance at %s>" % (self.this,)
    def readFlow(*args): return _vclapi.VclFlowModRtp_readFlow(*args)
    def modifyFlow(*args): return _vclapi.VclFlowModRtp_modifyFlow(*args)
    def read(*args): return _vclapi.VclFlowModRtp_read(*args)
    def modify(*args): return _vclapi.VclFlowModRtp_modify(*args)
    def setDefaultFlow(*args): return _vclapi.VclFlowModRtp_setDefaultFlow(*args)
    def getPayloadType(*args): return _vclapi.VclFlowModRtp_getPayloadType(*args)
    def getInitialSeqNum(*args): return _vclapi.VclFlowModRtp_getInitialSeqNum(*args)
    def getInitialTimestamp(*args): return _vclapi.VclFlowModRtp_getInitialTimestamp(*args)
    def getTimestampInterval(*args): return _vclapi.VclFlowModRtp_getTimestampInterval(*args)
    def getSyncSource(*args): return _vclapi.VclFlowModRtp_getSyncSource(*args)
    def setDefaults(*args): return _vclapi.VclFlowModRtp_setDefaults(*args)
    def setPayloadType(*args): return _vclapi.VclFlowModRtp_setPayloadType(*args)
    def setInitialSeqNum(*args): return _vclapi.VclFlowModRtp_setInitialSeqNum(*args)
    def setInitialTimestamp(*args): return _vclapi.VclFlowModRtp_setInitialTimestamp(*args)
    def setTimestampInterval(*args): return _vclapi.VclFlowModRtp_setTimestampInterval(*args)
    def setSyncSource(*args): return _vclapi.VclFlowModRtp_setSyncSource(*args)
    __swig_setmethods__["payloadType"] = _vclapi.VclFlowModRtp_payloadType_set
    __swig_getmethods__["payloadType"] = _vclapi.VclFlowModRtp_payloadType_get
    if _newclass:payloadType = property(_vclapi.VclFlowModRtp_payloadType_get, _vclapi.VclFlowModRtp_payloadType_set)
    __swig_setmethods__["initialSeqNum"] = _vclapi.VclFlowModRtp_initialSeqNum_set
    __swig_getmethods__["initialSeqNum"] = _vclapi.VclFlowModRtp_initialSeqNum_get
    if _newclass:initialSeqNum = property(_vclapi.VclFlowModRtp_initialSeqNum_get, _vclapi.VclFlowModRtp_initialSeqNum_set)
    __swig_setmethods__["initialTimestamp"] = _vclapi.VclFlowModRtp_initialTimestamp_set
    __swig_getmethods__["initialTimestamp"] = _vclapi.VclFlowModRtp_initialTimestamp_get
    if _newclass:initialTimestamp = property(_vclapi.VclFlowModRtp_initialTimestamp_get, _vclapi.VclFlowModRtp_initialTimestamp_set)
    __swig_setmethods__["timestampInterval"] = _vclapi.VclFlowModRtp_timestampInterval_set
    __swig_getmethods__["timestampInterval"] = _vclapi.VclFlowModRtp_timestampInterval_get
    if _newclass:timestampInterval = property(_vclapi.VclFlowModRtp_timestampInterval_get, _vclapi.VclFlowModRtp_timestampInterval_set)
    __swig_setmethods__["syncSource"] = _vclapi.VclFlowModRtp_syncSource_set
    __swig_getmethods__["syncSource"] = _vclapi.VclFlowModRtp_syncSource_get
    if _newclass:syncSource = property(_vclapi.VclFlowModRtp_syncSource_get, _vclapi.VclFlowModRtp_syncSource_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowModRtp, 'this', _vclapi.new_VclFlowModRtp(*args))
        _swig_setattr(self, VclFlowModRtp, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowModRtp):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowModRtpPtr(VclFlowModRtp):
    def __init__(self, this):
        _swig_setattr(self, VclFlowModRtp, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowModRtp, 'thisown', 0)
        _swig_setattr(self, VclFlowModRtp,self.__class__,VclFlowModRtp)
_vclapi.VclFlowModRtp_swigregister(VclFlowModRtpPtr)

class VclFlowModWlanQos(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowModWlanQos, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowModWlanQos, name)
    def __repr__(self):
        return "<C VclFlowModWlanQos instance at %s>" % (self.this,)
    def readFlow(*args): return _vclapi.VclFlowModWlanQos_readFlow(*args)
    def modifyFlow(*args): return _vclapi.VclFlowModWlanQos_modifyFlow(*args)
    def read(*args): return _vclapi.VclFlowModWlanQos_read(*args)
    def modify(*args): return _vclapi.VclFlowModWlanQos_modify(*args)
    def setDefaultFlow(*args): return _vclapi.VclFlowModWlanQos_setDefaultFlow(*args)
    def getFlowState(*args): return _vclapi.VclFlowModWlanQos_getFlowState(*args)
    def getTgaPriority(*args): return _vclapi.VclFlowModWlanQos_getTgaPriority(*args)
    def getUserPriority(*args): return _vclapi.VclFlowModWlanQos_getUserPriority(*args)
    def getFragThreshold(*args): return _vclapi.VclFlowModWlanQos_getFragThreshold(*args)
    def getAifs(*args): return _vclapi.VclFlowModWlanQos_getAifs(*args)
    def getCwMin(*args): return _vclapi.VclFlowModWlanQos_getCwMin(*args)
    def getCwMax(*args): return _vclapi.VclFlowModWlanQos_getCwMax(*args)
    def getRetryLimit(*args): return _vclapi.VclFlowModWlanQos_getRetryLimit(*args)
    def getTid(*args): return _vclapi.VclFlowModWlanQos_getTid(*args)
    def getAc(*args): return _vclapi.VclFlowModWlanQos_getAc(*args)
    def getAckPolicy(*args): return _vclapi.VclFlowModWlanQos_getAckPolicy(*args)
    def getAckLimit(*args): return _vclapi.VclFlowModWlanQos_getAckLimit(*args)
    def getDirection(*args): return _vclapi.VclFlowModWlanQos_getDirection(*args)
    def getAckTimeout(*args): return _vclapi.VclFlowModWlanQos_getAckTimeout(*args)
    def getArpDelay(*args): return _vclapi.VclFlowModWlanQos_getArpDelay(*args)
    def getMsduSize(*args): return _vclapi.VclFlowModWlanQos_getMsduSize(*args)
    def getMinPhyRate(*args): return _vclapi.VclFlowModWlanQos_getMinPhyRate(*args)
    def getMeanDataRate(*args): return _vclapi.VclFlowModWlanQos_getMeanDataRate(*args)
    def getTxopLimit(*args): return _vclapi.VclFlowModWlanQos_getTxopLimit(*args)
    def getBandwidth(*args): return _vclapi.VclFlowModWlanQos_getBandwidth(*args)
    def getClassifier(*args): return _vclapi.VclFlowModWlanQos_getClassifier(*args)
    def getTclasIeIncluded(*args): return _vclapi.VclFlowModWlanQos_getTclasIeIncluded(*args)
    def getAcParamFromBss(*args): return _vclapi.VclFlowModWlanQos_getAcParamFromBss(*args)
    def getFragEnable(*args): return _vclapi.VclFlowModWlanQos_getFragEnable(*args)
    def getPerformHs(*args): return _vclapi.VclFlowModWlanQos_getPerformHs(*args)
    def getMPDUAggregationEnable(*args): return _vclapi.VclFlowModWlanQos_getMPDUAggregationEnable(*args)
    def getAggregationAutoMax(*args): return _vclapi.VclFlowModWlanQos_getAggregationAutoMax(*args)
    def getMPDUAggregationLimit(*args): return _vclapi.VclFlowModWlanQos_getMPDUAggregationLimit(*args)
    def getMinimumMpduStartSpacing(*args): return _vclapi.VclFlowModWlanQos_getMinimumMpduStartSpacing(*args)
    def setDefaults(*args): return _vclapi.VclFlowModWlanQos_setDefaults(*args)
    def setTgaPriority(*args): return _vclapi.VclFlowModWlanQos_setTgaPriority(*args)
    def setUserPriority(*args): return _vclapi.VclFlowModWlanQos_setUserPriority(*args)
    def setFragThreshold(*args): return _vclapi.VclFlowModWlanQos_setFragThreshold(*args)
    def setAifs(*args): return _vclapi.VclFlowModWlanQos_setAifs(*args)
    def setCwMin(*args): return _vclapi.VclFlowModWlanQos_setCwMin(*args)
    def setCwMax(*args): return _vclapi.VclFlowModWlanQos_setCwMax(*args)
    def setRetryLimit(*args): return _vclapi.VclFlowModWlanQos_setRetryLimit(*args)
    def setTid(*args): return _vclapi.VclFlowModWlanQos_setTid(*args)
    def setAc(*args): return _vclapi.VclFlowModWlanQos_setAc(*args)
    def setAckPolicy(*args): return _vclapi.VclFlowModWlanQos_setAckPolicy(*args)
    def setAckLimit(*args): return _vclapi.VclFlowModWlanQos_setAckLimit(*args)
    def setDirection(*args): return _vclapi.VclFlowModWlanQos_setDirection(*args)
    def setAckTimeout(*args): return _vclapi.VclFlowModWlanQos_setAckTimeout(*args)
    def setMinPhyRate(*args): return _vclapi.VclFlowModWlanQos_setMinPhyRate(*args)
    def setMsduSize(*args): return _vclapi.VclFlowModWlanQos_setMsduSize(*args)
    def setMeanDataRate(*args): return _vclapi.VclFlowModWlanQos_setMeanDataRate(*args)
    def setTxopLimit(*args): return _vclapi.VclFlowModWlanQos_setTxopLimit(*args)
    def setBandwidth(*args): return _vclapi.VclFlowModWlanQos_setBandwidth(*args)
    def setClassifier(*args): return _vclapi.VclFlowModWlanQos_setClassifier(*args)
    def setTclasIeIncluded(*args): return _vclapi.VclFlowModWlanQos_setTclasIeIncluded(*args)
    def setAcParamFromBss(*args): return _vclapi.VclFlowModWlanQos_setAcParamFromBss(*args)
    def setFragEnable(*args): return _vclapi.VclFlowModWlanQos_setFragEnable(*args)
    def setPerformHs(*args): return _vclapi.VclFlowModWlanQos_setPerformHs(*args)
    def setAdmissionControl(*args): return _vclapi.VclFlowModWlanQos_setAdmissionControl(*args)
    def setMPDUAggregationEnable(*args): return _vclapi.VclFlowModWlanQos_setMPDUAggregationEnable(*args)
    def setAggregationAutoMax(*args): return _vclapi.VclFlowModWlanQos_setAggregationAutoMax(*args)
    def setMPDUAggregationLimit(*args): return _vclapi.VclFlowModWlanQos_setMPDUAggregationLimit(*args)
    def setMinimumMpduStartSpacing(*args): return _vclapi.VclFlowModWlanQos_setMinimumMpduStartSpacing(*args)
    __swig_setmethods__["flowState"] = _vclapi.VclFlowModWlanQos_flowState_set
    __swig_getmethods__["flowState"] = _vclapi.VclFlowModWlanQos_flowState_get
    if _newclass:flowState = property(_vclapi.VclFlowModWlanQos_flowState_get, _vclapi.VclFlowModWlanQos_flowState_set)
    __swig_setmethods__["tgaPriority"] = _vclapi.VclFlowModWlanQos_tgaPriority_set
    __swig_getmethods__["tgaPriority"] = _vclapi.VclFlowModWlanQos_tgaPriority_get
    if _newclass:tgaPriority = property(_vclapi.VclFlowModWlanQos_tgaPriority_get, _vclapi.VclFlowModWlanQos_tgaPriority_set)
    __swig_setmethods__["userPriority"] = _vclapi.VclFlowModWlanQos_userPriority_set
    __swig_getmethods__["userPriority"] = _vclapi.VclFlowModWlanQos_userPriority_get
    if _newclass:userPriority = property(_vclapi.VclFlowModWlanQos_userPriority_get, _vclapi.VclFlowModWlanQos_userPriority_set)
    __swig_setmethods__["fragThreshold"] = _vclapi.VclFlowModWlanQos_fragThreshold_set
    __swig_getmethods__["fragThreshold"] = _vclapi.VclFlowModWlanQos_fragThreshold_get
    if _newclass:fragThreshold = property(_vclapi.VclFlowModWlanQos_fragThreshold_get, _vclapi.VclFlowModWlanQos_fragThreshold_set)
    __swig_setmethods__["aifs"] = _vclapi.VclFlowModWlanQos_aifs_set
    __swig_getmethods__["aifs"] = _vclapi.VclFlowModWlanQos_aifs_get
    if _newclass:aifs = property(_vclapi.VclFlowModWlanQos_aifs_get, _vclapi.VclFlowModWlanQos_aifs_set)
    __swig_setmethods__["cwMin"] = _vclapi.VclFlowModWlanQos_cwMin_set
    __swig_getmethods__["cwMin"] = _vclapi.VclFlowModWlanQos_cwMin_get
    if _newclass:cwMin = property(_vclapi.VclFlowModWlanQos_cwMin_get, _vclapi.VclFlowModWlanQos_cwMin_set)
    __swig_setmethods__["cwMax"] = _vclapi.VclFlowModWlanQos_cwMax_set
    __swig_getmethods__["cwMax"] = _vclapi.VclFlowModWlanQos_cwMax_get
    if _newclass:cwMax = property(_vclapi.VclFlowModWlanQos_cwMax_get, _vclapi.VclFlowModWlanQos_cwMax_set)
    __swig_setmethods__["retryLimit"] = _vclapi.VclFlowModWlanQos_retryLimit_set
    __swig_getmethods__["retryLimit"] = _vclapi.VclFlowModWlanQos_retryLimit_get
    if _newclass:retryLimit = property(_vclapi.VclFlowModWlanQos_retryLimit_get, _vclapi.VclFlowModWlanQos_retryLimit_set)
    __swig_setmethods__["tid"] = _vclapi.VclFlowModWlanQos_tid_set
    __swig_getmethods__["tid"] = _vclapi.VclFlowModWlanQos_tid_get
    if _newclass:tid = property(_vclapi.VclFlowModWlanQos_tid_get, _vclapi.VclFlowModWlanQos_tid_set)
    __swig_setmethods__["ac"] = _vclapi.VclFlowModWlanQos_ac_set
    __swig_getmethods__["ac"] = _vclapi.VclFlowModWlanQos_ac_get
    if _newclass:ac = property(_vclapi.VclFlowModWlanQos_ac_get, _vclapi.VclFlowModWlanQos_ac_set)
    __swig_setmethods__["ackPolicy"] = _vclapi.VclFlowModWlanQos_ackPolicy_set
    __swig_getmethods__["ackPolicy"] = _vclapi.VclFlowModWlanQos_ackPolicy_get
    if _newclass:ackPolicy = property(_vclapi.VclFlowModWlanQos_ackPolicy_get, _vclapi.VclFlowModWlanQos_ackPolicy_set)
    __swig_setmethods__["ackLimit"] = _vclapi.VclFlowModWlanQos_ackLimit_set
    __swig_getmethods__["ackLimit"] = _vclapi.VclFlowModWlanQos_ackLimit_get
    if _newclass:ackLimit = property(_vclapi.VclFlowModWlanQos_ackLimit_get, _vclapi.VclFlowModWlanQos_ackLimit_set)
    __swig_setmethods__["direction"] = _vclapi.VclFlowModWlanQos_direction_set
    __swig_getmethods__["direction"] = _vclapi.VclFlowModWlanQos_direction_get
    if _newclass:direction = property(_vclapi.VclFlowModWlanQos_direction_get, _vclapi.VclFlowModWlanQos_direction_set)
    __swig_setmethods__["ackTimeout"] = _vclapi.VclFlowModWlanQos_ackTimeout_set
    __swig_getmethods__["ackTimeout"] = _vclapi.VclFlowModWlanQos_ackTimeout_get
    if _newclass:ackTimeout = property(_vclapi.VclFlowModWlanQos_ackTimeout_get, _vclapi.VclFlowModWlanQos_ackTimeout_set)
    __swig_setmethods__["arpDelay"] = _vclapi.VclFlowModWlanQos_arpDelay_set
    __swig_getmethods__["arpDelay"] = _vclapi.VclFlowModWlanQos_arpDelay_get
    if _newclass:arpDelay = property(_vclapi.VclFlowModWlanQos_arpDelay_get, _vclapi.VclFlowModWlanQos_arpDelay_set)
    __swig_setmethods__["msduSize"] = _vclapi.VclFlowModWlanQos_msduSize_set
    __swig_getmethods__["msduSize"] = _vclapi.VclFlowModWlanQos_msduSize_get
    if _newclass:msduSize = property(_vclapi.VclFlowModWlanQos_msduSize_get, _vclapi.VclFlowModWlanQos_msduSize_set)
    __swig_setmethods__["minPhyRate"] = _vclapi.VclFlowModWlanQos_minPhyRate_set
    __swig_getmethods__["minPhyRate"] = _vclapi.VclFlowModWlanQos_minPhyRate_get
    if _newclass:minPhyRate = property(_vclapi.VclFlowModWlanQos_minPhyRate_get, _vclapi.VclFlowModWlanQos_minPhyRate_set)
    __swig_setmethods__["meanDataRate"] = _vclapi.VclFlowModWlanQos_meanDataRate_set
    __swig_getmethods__["meanDataRate"] = _vclapi.VclFlowModWlanQos_meanDataRate_get
    if _newclass:meanDataRate = property(_vclapi.VclFlowModWlanQos_meanDataRate_get, _vclapi.VclFlowModWlanQos_meanDataRate_set)
    __swig_setmethods__["txopLimit"] = _vclapi.VclFlowModWlanQos_txopLimit_set
    __swig_getmethods__["txopLimit"] = _vclapi.VclFlowModWlanQos_txopLimit_get
    if _newclass:txopLimit = property(_vclapi.VclFlowModWlanQos_txopLimit_get, _vclapi.VclFlowModWlanQos_txopLimit_set)
    __swig_setmethods__["bandwidth"] = _vclapi.VclFlowModWlanQos_bandwidth_set
    __swig_getmethods__["bandwidth"] = _vclapi.VclFlowModWlanQos_bandwidth_get
    if _newclass:bandwidth = property(_vclapi.VclFlowModWlanQos_bandwidth_get, _vclapi.VclFlowModWlanQos_bandwidth_set)
    __swig_setmethods__["classifier"] = _vclapi.VclFlowModWlanQos_classifier_set
    __swig_getmethods__["classifier"] = _vclapi.VclFlowModWlanQos_classifier_get
    if _newclass:classifier = property(_vclapi.VclFlowModWlanQos_classifier_get, _vclapi.VclFlowModWlanQos_classifier_set)
    __swig_setmethods__["tclasIeIncluded"] = _vclapi.VclFlowModWlanQos_tclasIeIncluded_set
    __swig_getmethods__["tclasIeIncluded"] = _vclapi.VclFlowModWlanQos_tclasIeIncluded_get
    if _newclass:tclasIeIncluded = property(_vclapi.VclFlowModWlanQos_tclasIeIncluded_get, _vclapi.VclFlowModWlanQos_tclasIeIncluded_set)
    __swig_setmethods__["acParamFromBss"] = _vclapi.VclFlowModWlanQos_acParamFromBss_set
    __swig_getmethods__["acParamFromBss"] = _vclapi.VclFlowModWlanQos_acParamFromBss_get
    if _newclass:acParamFromBss = property(_vclapi.VclFlowModWlanQos_acParamFromBss_get, _vclapi.VclFlowModWlanQos_acParamFromBss_set)
    __swig_setmethods__["fragEnable"] = _vclapi.VclFlowModWlanQos_fragEnable_set
    __swig_getmethods__["fragEnable"] = _vclapi.VclFlowModWlanQos_fragEnable_get
    if _newclass:fragEnable = property(_vclapi.VclFlowModWlanQos_fragEnable_get, _vclapi.VclFlowModWlanQos_fragEnable_set)
    __swig_setmethods__["performHs"] = _vclapi.VclFlowModWlanQos_performHs_set
    __swig_getmethods__["performHs"] = _vclapi.VclFlowModWlanQos_performHs_get
    if _newclass:performHs = property(_vclapi.VclFlowModWlanQos_performHs_get, _vclapi.VclFlowModWlanQos_performHs_set)
    __swig_setmethods__["uapsdEnable"] = _vclapi.VclFlowModWlanQos_uapsdEnable_set
    __swig_getmethods__["uapsdEnable"] = _vclapi.VclFlowModWlanQos_uapsdEnable_get
    if _newclass:uapsdEnable = property(_vclapi.VclFlowModWlanQos_uapsdEnable_get, _vclapi.VclFlowModWlanQos_uapsdEnable_set)
    __swig_setmethods__["aggregationEnable"] = _vclapi.VclFlowModWlanQos_aggregationEnable_set
    __swig_getmethods__["aggregationEnable"] = _vclapi.VclFlowModWlanQos_aggregationEnable_get
    if _newclass:aggregationEnable = property(_vclapi.VclFlowModWlanQos_aggregationEnable_get, _vclapi.VclFlowModWlanQos_aggregationEnable_set)
    __swig_setmethods__["aggregationAutoMax"] = _vclapi.VclFlowModWlanQos_aggregationAutoMax_set
    __swig_getmethods__["aggregationAutoMax"] = _vclapi.VclFlowModWlanQos_aggregationAutoMax_get
    if _newclass:aggregationAutoMax = property(_vclapi.VclFlowModWlanQos_aggregationAutoMax_get, _vclapi.VclFlowModWlanQos_aggregationAutoMax_set)
    __swig_setmethods__["aggregationLimit"] = _vclapi.VclFlowModWlanQos_aggregationLimit_set
    __swig_getmethods__["aggregationLimit"] = _vclapi.VclFlowModWlanQos_aggregationLimit_get
    if _newclass:aggregationLimit = property(_vclapi.VclFlowModWlanQos_aggregationLimit_get, _vclapi.VclFlowModWlanQos_aggregationLimit_set)
    __swig_setmethods__["minimumMpduStartSpacing"] = _vclapi.VclFlowModWlanQos_minimumMpduStartSpacing_set
    __swig_getmethods__["minimumMpduStartSpacing"] = _vclapi.VclFlowModWlanQos_minimumMpduStartSpacing_get
    if _newclass:minimumMpduStartSpacing = property(_vclapi.VclFlowModWlanQos_minimumMpduStartSpacing_get, _vclapi.VclFlowModWlanQos_minimumMpduStartSpacing_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowModWlanQos, 'this', _vclapi.new_VclFlowModWlanQos(*args))
        _swig_setattr(self, VclFlowModWlanQos, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowModWlanQos):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowModWlanQosPtr(VclFlowModWlanQos):
    def __init__(self, this):
        _swig_setattr(self, VclFlowModWlanQos, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowModWlanQos, 'thisown', 0)
        _swig_setattr(self, VclFlowModWlanQos,self.__class__,VclFlowModWlanQos)
_vclapi.VclFlowModWlanQos_swigregister(VclFlowModWlanQosPtr)

class VclFlowModEnetQos(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowModEnetQos, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowModEnetQos, name)
    def __repr__(self):
        return "<C VclFlowModEnetQos instance at %s>" % (self.this,)
    def readFlow(*args): return _vclapi.VclFlowModEnetQos_readFlow(*args)
    def modifyFlow(*args): return _vclapi.VclFlowModEnetQos_modifyFlow(*args)
    def read(*args): return _vclapi.VclFlowModEnetQos_read(*args)
    def modify(*args): return _vclapi.VclFlowModEnetQos_modify(*args)
    def setDefaultFlow(*args): return _vclapi.VclFlowModEnetQos_setDefaultFlow(*args)
    def getTgaPriority(*args): return _vclapi.VclFlowModEnetQos_getTgaPriority(*args)
    def getUserPriority(*args): return _vclapi.VclFlowModEnetQos_getUserPriority(*args)
    def getPriorityTag(*args): return _vclapi.VclFlowModEnetQos_getPriorityTag(*args)
    def setUserPriority(*args): return _vclapi.VclFlowModEnetQos_setUserPriority(*args)
    def setTgaPriority(*args): return _vclapi.VclFlowModEnetQos_setTgaPriority(*args)
    def setPriorityTag(*args): return _vclapi.VclFlowModEnetQos_setPriorityTag(*args)
    __swig_setmethods__["tgaPriority"] = _vclapi.VclFlowModEnetQos_tgaPriority_set
    __swig_getmethods__["tgaPriority"] = _vclapi.VclFlowModEnetQos_tgaPriority_get
    if _newclass:tgaPriority = property(_vclapi.VclFlowModEnetQos_tgaPriority_get, _vclapi.VclFlowModEnetQos_tgaPriority_set)
    __swig_setmethods__["userPriority"] = _vclapi.VclFlowModEnetQos_userPriority_set
    __swig_getmethods__["userPriority"] = _vclapi.VclFlowModEnetQos_userPriority_get
    if _newclass:userPriority = property(_vclapi.VclFlowModEnetQos_userPriority_get, _vclapi.VclFlowModEnetQos_userPriority_set)
    __swig_setmethods__["priorityTag"] = _vclapi.VclFlowModEnetQos_priorityTag_set
    __swig_getmethods__["priorityTag"] = _vclapi.VclFlowModEnetQos_priorityTag_get
    if _newclass:priorityTag = property(_vclapi.VclFlowModEnetQos_priorityTag_get, _vclapi.VclFlowModEnetQos_priorityTag_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowModEnetQos, 'this', _vclapi.new_VclFlowModEnetQos(*args))
        _swig_setattr(self, VclFlowModEnetQos, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowModEnetQos):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowModEnetQosPtr(VclFlowModEnetQos):
    def __init__(self, this):
        _swig_setattr(self, VclFlowModEnetQos, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowModEnetQos, 'thisown', 0)
        _swig_setattr(self, VclFlowModEnetQos,self.__class__,VclFlowModEnetQos)
_vclapi.VclFlowModEnetQos_swigregister(VclFlowModEnetQosPtr)

class VclFlowGroup(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowGroup, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowGroup, name)
    def __repr__(self):
        return "<C VclFlowGroup instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclFlowGroup_create(*args)
    def destroy(*args): return _vclapi.VclFlowGroup_destroy(*args)
    def read(*args): return _vclapi.VclFlowGroup_read(*args)
    def validate(*args): return _vclapi.VclFlowGroup_validate(*args)
    def write(*args): return _vclapi.VclFlowGroup_write(*args)
    def doArpExchange(*args): return _vclapi.VclFlowGroup_doArpExchange(*args)
    def doArpStatus(*args): return _vclapi.VclFlowGroup_doArpStatus(*args)
    def getNames(*args): return _vclapi.VclFlowGroup_getNames(*args)
    def getFlowNames(*args): return _vclapi.VclFlowGroup_getFlowNames(*args)
    def setDefaults(*args): return _vclapi.VclFlowGroup_setDefaults(*args)
    def add(*args): return _vclapi.VclFlowGroup_add(*args)
    def remove(*args): return _vclapi.VclFlowGroup_remove(*args)
    def move(*args): return _vclapi.VclFlowGroup_move(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowGroup, 'this', _vclapi.new_VclFlowGroup(*args))
        _swig_setattr(self, VclFlowGroup, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowGroup):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowGroupPtr(VclFlowGroup):
    def __init__(self, this):
        _swig_setattr(self, VclFlowGroup, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowGroup, 'thisown', 0)
        _swig_setattr(self, VclFlowGroup,self.__class__,VclFlowGroup)
_vclapi.VclFlowGroup_swigregister(VclFlowGroupPtr)

class VclFlowStats(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFlowStats, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFlowStats, name)
    def __repr__(self):
        return "<C VclFlowStats instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclFlowStats_setDefaults(*args)
    def read(*args): return _vclapi.VclFlowStats_read(*args)
    def calcCumulativeRValue(*args): return _vclapi.VclFlowStats_calcCumulativeRValue(*args)
    def calcInterimRValue(*args): return _vclapi.VclFlowStats_calcInterimRValue(*args)
    def getTxFlowFramesOk(*args): return _vclapi.VclFlowStats_getTxFlowFramesOk(*args)
    def getTxFlowOctetsOk(*args): return _vclapi.VclFlowStats_getTxFlowOctetsOk(*args)
    def getTxFlowIpPacketsOk(*args): return _vclapi.VclFlowStats_getTxFlowIpPacketsOk(*args)
    def getTxFlowIpOctetsOk(*args): return _vclapi.VclFlowStats_getTxFlowIpOctetsOk(*args)
    def getTxFlowSnap(*args): return _vclapi.VclFlowStats_getTxFlowSnap(*args)
    def getRxFlowFramesOk(*args): return _vclapi.VclFlowStats_getRxFlowFramesOk(*args)
    def getRxFlowOctetsOk(*args): return _vclapi.VclFlowStats_getRxFlowOctetsOk(*args)
    def getRxFlowIpPacketsOk(*args): return _vclapi.VclFlowStats_getRxFlowIpPacketsOk(*args)
    def getRxFlowIpOctetsOk(*args): return _vclapi.VclFlowStats_getRxFlowIpOctetsOk(*args)
    def getRxFlowLastSequenceNumber(*args): return _vclapi.VclFlowStats_getRxFlowLastSequenceNumber(*args)
    def getRxFlowOutOfSequenceFrames(*args): return _vclapi.VclFlowStats_getRxFlowOutOfSequenceFrames(*args)
    def getRxFlowBadPayloadChecksum(*args): return _vclapi.VclFlowStats_getRxFlowBadPayloadChecksum(*args)
    def getRxFlowLatencyBucket(*args): return _vclapi.VclFlowStats_getRxFlowLatencyBucket(*args)
    def getRxFlowMaxLatencyOverall(*args): return _vclapi.VclFlowStats_getRxFlowMaxLatencyOverall(*args)
    def getRxFlowSumLatencyOverall(*args): return _vclapi.VclFlowStats_getRxFlowSumLatencyOverall(*args)
    def getRxFlowLatencyCountOverall(*args): return _vclapi.VclFlowStats_getRxFlowLatencyCountOverall(*args)
    def getRxFlowSmoothedInterarrivalJitter(*args): return _vclapi.VclFlowStats_getRxFlowSmoothedInterarrivalJitter(*args)
    def getRxFlow2PacketLossNumber(*args): return _vclapi.VclFlowStats_getRxFlow2PacketLossNumber(*args)
    def getRxFlow3PacketLossNumber(*args): return _vclapi.VclFlowStats_getRxFlow3PacketLossNumber(*args)
    def getRxFlow4PacketLossNumber(*args): return _vclapi.VclFlowStats_getRxFlow4PacketLossNumber(*args)
    def getRxFlow5PacketLossNumber(*args): return _vclapi.VclFlowStats_getRxFlow5PacketLossNumber(*args)
    def getRxFlowLastLatency(*args): return _vclapi.VclFlowStats_getRxFlowLastLatency(*args)
    def getRxFlowSnap(*args): return _vclapi.VclFlowStats_getRxFlowSnap(*args)
    __swig_getmethods__["txFlowFramesOk"] = _vclapi.VclFlowStats_txFlowFramesOk_get
    if _newclass:txFlowFramesOk = property(_vclapi.VclFlowStats_txFlowFramesOk_get)
    __swig_getmethods__["txFlowOctetsOk"] = _vclapi.VclFlowStats_txFlowOctetsOk_get
    if _newclass:txFlowOctetsOk = property(_vclapi.VclFlowStats_txFlowOctetsOk_get)
    __swig_getmethods__["txFlowIpPacketsOk"] = _vclapi.VclFlowStats_txFlowIpPacketsOk_get
    if _newclass:txFlowIpPacketsOk = property(_vclapi.VclFlowStats_txFlowIpPacketsOk_get)
    __swig_getmethods__["txFlowIpOctetsOk"] = _vclapi.VclFlowStats_txFlowIpOctetsOk_get
    if _newclass:txFlowIpOctetsOk = property(_vclapi.VclFlowStats_txFlowIpOctetsOk_get)
    __swig_getmethods__["txFlowSnap"] = _vclapi.VclFlowStats_txFlowSnap_get
    if _newclass:txFlowSnap = property(_vclapi.VclFlowStats_txFlowSnap_get)
    __swig_getmethods__["rxFlowFramesOk"] = _vclapi.VclFlowStats_rxFlowFramesOk_get
    if _newclass:rxFlowFramesOk = property(_vclapi.VclFlowStats_rxFlowFramesOk_get)
    __swig_getmethods__["rxFlowOctetsOk"] = _vclapi.VclFlowStats_rxFlowOctetsOk_get
    if _newclass:rxFlowOctetsOk = property(_vclapi.VclFlowStats_rxFlowOctetsOk_get)
    __swig_getmethods__["rxFlowIpPacketsOk"] = _vclapi.VclFlowStats_rxFlowIpPacketsOk_get
    if _newclass:rxFlowIpPacketsOk = property(_vclapi.VclFlowStats_rxFlowIpPacketsOk_get)
    __swig_getmethods__["rxFlowIpOctetsOk"] = _vclapi.VclFlowStats_rxFlowIpOctetsOk_get
    if _newclass:rxFlowIpOctetsOk = property(_vclapi.VclFlowStats_rxFlowIpOctetsOk_get)
    __swig_getmethods__["rxFlowLastSequenceNumber"] = _vclapi.VclFlowStats_rxFlowLastSequenceNumber_get
    if _newclass:rxFlowLastSequenceNumber = property(_vclapi.VclFlowStats_rxFlowLastSequenceNumber_get)
    __swig_getmethods__["rxFlowOutOfSequenceFrames"] = _vclapi.VclFlowStats_rxFlowOutOfSequenceFrames_get
    if _newclass:rxFlowOutOfSequenceFrames = property(_vclapi.VclFlowStats_rxFlowOutOfSequenceFrames_get)
    __swig_getmethods__["rxFlowBadPayloadChecksum"] = _vclapi.VclFlowStats_rxFlowBadPayloadChecksum_get
    if _newclass:rxFlowBadPayloadChecksum = property(_vclapi.VclFlowStats_rxFlowBadPayloadChecksum_get)
    __swig_getmethods__["rxFlowLatencyBucket"] = _vclapi.VclFlowStats_rxFlowLatencyBucket_get
    if _newclass:rxFlowLatencyBucket = property(_vclapi.VclFlowStats_rxFlowLatencyBucket_get)
    __swig_getmethods__["rxFlowMaxLatencyOverall"] = _vclapi.VclFlowStats_rxFlowMaxLatencyOverall_get
    if _newclass:rxFlowMaxLatencyOverall = property(_vclapi.VclFlowStats_rxFlowMaxLatencyOverall_get)
    __swig_getmethods__["rxFlowSumLatencyOverall"] = _vclapi.VclFlowStats_rxFlowSumLatencyOverall_get
    if _newclass:rxFlowSumLatencyOverall = property(_vclapi.VclFlowStats_rxFlowSumLatencyOverall_get)
    __swig_getmethods__["rxFlowLatencyCountOverall"] = _vclapi.VclFlowStats_rxFlowLatencyCountOverall_get
    if _newclass:rxFlowLatencyCountOverall = property(_vclapi.VclFlowStats_rxFlowLatencyCountOverall_get)
    __swig_getmethods__["rxFlowSmoothedInterarrivalJitter"] = _vclapi.VclFlowStats_rxFlowSmoothedInterarrivalJitter_get
    if _newclass:rxFlowSmoothedInterarrivalJitter = property(_vclapi.VclFlowStats_rxFlowSmoothedInterarrivalJitter_get)
    __swig_getmethods__["rxFlow2PacketLossNumber"] = _vclapi.VclFlowStats_rxFlow2PacketLossNumber_get
    if _newclass:rxFlow2PacketLossNumber = property(_vclapi.VclFlowStats_rxFlow2PacketLossNumber_get)
    __swig_getmethods__["rxFlow3PacketLossNumber"] = _vclapi.VclFlowStats_rxFlow3PacketLossNumber_get
    if _newclass:rxFlow3PacketLossNumber = property(_vclapi.VclFlowStats_rxFlow3PacketLossNumber_get)
    __swig_getmethods__["rxFlow4PacketLossNumber"] = _vclapi.VclFlowStats_rxFlow4PacketLossNumber_get
    if _newclass:rxFlow4PacketLossNumber = property(_vclapi.VclFlowStats_rxFlow4PacketLossNumber_get)
    __swig_getmethods__["rxFlow5PacketLossNumber"] = _vclapi.VclFlowStats_rxFlow5PacketLossNumber_get
    if _newclass:rxFlow5PacketLossNumber = property(_vclapi.VclFlowStats_rxFlow5PacketLossNumber_get)
    __swig_getmethods__["rxFlowLastLatency"] = _vclapi.VclFlowStats_rxFlowLastLatency_get
    if _newclass:rxFlowLastLatency = property(_vclapi.VclFlowStats_rxFlowLastLatency_get)
    __swig_getmethods__["rxFlowSnap"] = _vclapi.VclFlowStats_rxFlowSnap_get
    if _newclass:rxFlowSnap = property(_vclapi.VclFlowStats_rxFlowSnap_get)
    def __init__(self, *args):
        _swig_setattr(self, VclFlowStats, 'this', _vclapi.new_VclFlowStats(*args))
        _swig_setattr(self, VclFlowStats, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFlowStats):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFlowStatsPtr(VclFlowStats):
    def __init__(self, this):
        _swig_setattr(self, VclFlowStats, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFlowStats, 'thisown', 0)
        _swig_setattr(self, VclFlowStats,self.__class__,VclFlowStats)
_vclapi.VclFlowStats_swigregister(VclFlowStatsPtr)

class VclCapture(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclCapture, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclCapture, name)
    def __repr__(self):
        return "<C VclCapture instance at %s>" % (self.this,)
    def read(*args): return _vclapi.VclCapture_read(*args)
    def write(*args): return _vclapi.VclCapture_write(*args)
    def enable(*args): return _vclapi.VclCapture_enable(*args)
    def disable(*args): return _vclapi.VclCapture_disable(*args)
    def clear(*args): return _vclapi.VclCapture_clear(*args)
    def save(*args): return _vclapi.VclCapture_save(*args)
    def grabLog(*args): return _vclapi.VclCapture_grabLog(*args)
    def getFileName(*args): return _vclapi.VclCapture_getFileName(*args)
    def getRadioInfoFlag(*args): return _vclapi.VclCapture_getRadioInfoFlag(*args)
    def getTimeResolution(*args): return _vclapi.VclCapture_getTimeResolution(*args)
    def getFcsFlag(*args): return _vclapi.VclCapture_getFcsFlag(*args)
    def getMode(*args): return _vclapi.VclCapture_getMode(*args)
    def getWindowPosition(*args): return _vclapi.VclCapture_getWindowPosition(*args)
    def getBestEffort(*args): return _vclapi.VclCapture_getBestEffort(*args)
    def getNumLogFrames(*args): return _vclapi.VclCapture_getNumLogFrames(*args)
    def getNumTxFrames(*args): return _vclapi.VclCapture_getNumTxFrames(*args)
    def getNumRxFrames(*args): return _vclapi.VclCapture_getNumRxFrames(*args)
    def getNumTotalFrames(*args): return _vclapi.VclCapture_getNumTotalFrames(*args)
    def getTriggerPacket(*args): return _vclapi.VclCapture_getTriggerPacket(*args)
    def getBufferOverFlow(*args): return _vclapi.VclCapture_getBufferOverFlow(*args)
    def setDefaults(*args): return _vclapi.VclCapture_setDefaults(*args)
    def setFileName(*args): return _vclapi.VclCapture_setFileName(*args)
    def setRadioInfoFlag(*args): return _vclapi.VclCapture_setRadioInfoFlag(*args)
    def setTimeResolution(*args): return _vclapi.VclCapture_setTimeResolution(*args)
    def setFcsFlag(*args): return _vclapi.VclCapture_setFcsFlag(*args)
    def setMode(*args): return _vclapi.VclCapture_setMode(*args)
    def setWindowPosition(*args): return _vclapi.VclCapture_setWindowPosition(*args)
    def setBestEffort(*args): return _vclapi.VclCapture_setBestEffort(*args)
    __swig_setmethods__["fileName"] = _vclapi.VclCapture_fileName_set
    __swig_getmethods__["fileName"] = _vclapi.VclCapture_fileName_get
    if _newclass:fileName = property(_vclapi.VclCapture_fileName_get, _vclapi.VclCapture_fileName_set)
    __swig_setmethods__["mode"] = _vclapi.VclCapture_mode_set
    __swig_getmethods__["mode"] = _vclapi.VclCapture_mode_get
    if _newclass:mode = property(_vclapi.VclCapture_mode_get, _vclapi.VclCapture_mode_set)
    __swig_setmethods__["radioInfoFlag"] = _vclapi.VclCapture_radioInfoFlag_set
    __swig_getmethods__["radioInfoFlag"] = _vclapi.VclCapture_radioInfoFlag_get
    if _newclass:radioInfoFlag = property(_vclapi.VclCapture_radioInfoFlag_get, _vclapi.VclCapture_radioInfoFlag_set)
    __swig_setmethods__["timeResolution"] = _vclapi.VclCapture_timeResolution_set
    __swig_getmethods__["timeResolution"] = _vclapi.VclCapture_timeResolution_get
    if _newclass:timeResolution = property(_vclapi.VclCapture_timeResolution_get, _vclapi.VclCapture_timeResolution_set)
    __swig_setmethods__["fcsFlag"] = _vclapi.VclCapture_fcsFlag_set
    __swig_getmethods__["fcsFlag"] = _vclapi.VclCapture_fcsFlag_get
    if _newclass:fcsFlag = property(_vclapi.VclCapture_fcsFlag_get, _vclapi.VclCapture_fcsFlag_set)
    __swig_setmethods__["windowPosition"] = _vclapi.VclCapture_windowPosition_set
    __swig_getmethods__["windowPosition"] = _vclapi.VclCapture_windowPosition_get
    if _newclass:windowPosition = property(_vclapi.VclCapture_windowPosition_get, _vclapi.VclCapture_windowPosition_set)
    __swig_setmethods__["bestEffort"] = _vclapi.VclCapture_bestEffort_set
    __swig_getmethods__["bestEffort"] = _vclapi.VclCapture_bestEffort_get
    if _newclass:bestEffort = property(_vclapi.VclCapture_bestEffort_get, _vclapi.VclCapture_bestEffort_set)
    __swig_getmethods__["numLogFrames"] = _vclapi.VclCapture_numLogFrames_get
    if _newclass:numLogFrames = property(_vclapi.VclCapture_numLogFrames_get)
    __swig_getmethods__["numTxFrames"] = _vclapi.VclCapture_numTxFrames_get
    if _newclass:numTxFrames = property(_vclapi.VclCapture_numTxFrames_get)
    __swig_getmethods__["numRxFrames"] = _vclapi.VclCapture_numRxFrames_get
    if _newclass:numRxFrames = property(_vclapi.VclCapture_numRxFrames_get)
    __swig_getmethods__["numTotalFrames"] = _vclapi.VclCapture_numTotalFrames_get
    if _newclass:numTotalFrames = property(_vclapi.VclCapture_numTotalFrames_get)
    __swig_getmethods__["triggerPacket"] = _vclapi.VclCapture_triggerPacket_get
    if _newclass:triggerPacket = property(_vclapi.VclCapture_triggerPacket_get)
    __swig_getmethods__["bufferOverFlow"] = _vclapi.VclCapture_bufferOverFlow_get
    if _newclass:bufferOverFlow = property(_vclapi.VclCapture_bufferOverFlow_get)
    def __init__(self, *args):
        _swig_setattr(self, VclCapture, 'this', _vclapi.new_VclCapture(*args))
        _swig_setattr(self, VclCapture, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclCapture):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclCapturePtr(VclCapture):
    def __init__(self, this):
        _swig_setattr(self, VclCapture, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclCapture, 'thisown', 0)
        _swig_setattr(self, VclCapture,self.__class__,VclCapture)
_vclapi.VclCapture_swigregister(VclCapturePtr)

class VclActions(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclActions, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclActions, name)
    def __repr__(self):
        return "<C VclActions instance at %s>" % (self.this,)
    def startPortTransmit(*args): return _vclapi.VclActions_startPortTransmit(*args)
    def stopPortTransmit(*args): return _vclapi.VclActions_stopPortTransmit(*args)
    def startClientTransmit(*args): return _vclapi.VclActions_startClientTransmit(*args)
    def stopClientTransmit(*args): return _vclapi.VclActions_stopClientTransmit(*args)
    def startFlowTransmit(*args): return _vclapi.VclActions_startFlowTransmit(*args)
    def stopFlowTransmit(*args): return _vclapi.VclActions_stopFlowTransmit(*args)
    def startClientGroup(*args): return _vclapi.VclActions_startClientGroup(*args)
    def stopClientGroup(*args): return _vclapi.VclActions_stopClientGroup(*args)
    def startFlowGroup(*args): return _vclapi.VclActions_startFlowGroup(*args)
    def stopFlowGroup(*args): return _vclapi.VclActions_stopFlowGroup(*args)
    def startCapture(*args): return _vclapi.VclActions_startCapture(*args)
    def stopCapture(*args): return _vclapi.VclActions_stopCapture(*args)
    def sendBroadcastProbes(*args): return _vclapi.VclActions_sendBroadcastProbes(*args)
    def sendDirectProbes(*args): return _vclapi.VclActions_sendDirectProbes(*args)
    def getVclVersionStr(*args): return _vclapi.VclActions_getVclVersionStr(*args)
    def getVersionStr(*args): return _vclapi.VclActions_getVersionStr(*args)
    def getBuildStr(*args): return _vclapi.VclActions_getBuildStr(*args)
    def getCopyrightStr(*args): return _vclapi.VclActions_getCopyrightStr(*args)
    def createVcalLog(*args): return _vclapi.VclActions_createVcalLog(*args)
    def closeVcalLog(*args): return _vclapi.VclActions_closeVcalLog(*args)
    def startVcalLogging(*args): return _vclapi.VclActions_startVcalLogging(*args)
    def stopVcalLogging(*args): return _vclapi.VclActions_stopVcalLogging(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclActions, 'this', _vclapi.new_VclActions(*args))
        _swig_setattr(self, VclActions, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclActions):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclActionsPtr(VclActions):
    def __init__(self, this):
        _swig_setattr(self, VclActions, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclActions, 'thisown', 0)
        _swig_setattr(self, VclActions,self.__class__,VclActions)
_vclapi.VclActions_swigregister(VclActionsPtr)

class VclUtilities(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclUtilities, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclUtilities, name)
    def __repr__(self):
        return "<C VclUtilities instance at %s>" % (self.this,)
    def getErrorString(*args): return _vclapi.VclUtilities_getErrorString(*args)
    def getAppErrorString(*args): return _vclapi.VclUtilities_getAppErrorString(*args)
    def getTime(*args): return _vclapi.VclUtilities_getTime(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclUtilities, 'this', _vclapi.new_VclUtilities(*args))
        _swig_setattr(self, VclUtilities, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclUtilities):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclUtilitiesPtr(VclUtilities):
    def __init__(self, this):
        _swig_setattr(self, VclUtilities, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclUtilities, 'thisown', 0)
        _swig_setattr(self, VclUtilities,self.__class__,VclUtilities)
_vclapi.VclUtilities_swigregister(VclUtilitiesPtr)

class VclStats(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclStats, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclStats, name)
    def __repr__(self):
        return "<C VclStats instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclStats_setDefaults(*args)
    def read(*args): return _vclapi.VclStats_read(*args)
    def write(*args): return _vclapi.VclStats_write(*args)
    def resetAll(*args): return _vclapi.VclStats_resetAll(*args)
    def getTxMacFrames(*args): return _vclapi.VclStats_getTxMacFrames(*args)
    def getTxMacManagementFrames(*args): return _vclapi.VclStats_getTxMacManagementFrames(*args)
    def getTxMacDataFrames(*args): return _vclapi.VclStats_getTxMacDataFrames(*args)
    def getTxMacFramesOk(*args): return _vclapi.VclStats_getTxMacFramesOk(*args)
    def getTxMacUnicastFrames(*args): return _vclapi.VclStats_getTxMacUnicastFrames(*args)
    def getTxMacMulticastFrames(*args): return _vclapi.VclStats_getTxMacMulticastFrames(*args)
    def getTxMacBroadcastFrames(*args): return _vclapi.VclStats_getTxMacBroadcastFrames(*args)
    def getTxMacFailedCount(*args): return _vclapi.VclStats_getTxMacFailedCount(*args)
    def getTxMacShortRetryCount(*args): return _vclapi.VclStats_getTxMacShortRetryCount(*args)
    def getTxMacLongRetryCount(*args): return _vclapi.VclStats_getTxMacLongRetryCount(*args)
    def getTxMacSingleRetryCount(*args): return _vclapi.VclStats_getTxMacSingleRetryCount(*args)
    def getTxMacMultipleRetryCount(*args): return _vclapi.VclStats_getTxMacMultipleRetryCount(*args)
    def getTxMacTotalRetransmissions(*args): return _vclapi.VclStats_getTxMacTotalRetransmissions(*args)
    def getTxMacRtsSuccessCount(*args): return _vclapi.VclStats_getTxMacRtsSuccessCount(*args)
    def getTxMacRtsFailureCount(*args): return _vclapi.VclStats_getTxMacRtsFailureCount(*args)
    def getTxMacAckFailureCount(*args): return _vclapi.VclStats_getTxMacAckFailureCount(*args)
    def getTxMacOctets(*args): return _vclapi.VclStats_getTxMacOctets(*args)
    def getTxMacDataOctets(*args): return _vclapi.VclStats_getTxMacDataOctets(*args)
    def getTxMacManagementOctets(*args): return _vclapi.VclStats_getTxMacManagementOctets(*args)
    def getTxMacDataOctetsOk(*args): return _vclapi.VclStats_getTxMacDataOctetsOk(*args)
    def getTxMacManagementOctetsOk(*args): return _vclapi.VclStats_getTxMacManagementOctetsOk(*args)
    def getTxMacFcsError(*args): return _vclapi.VclStats_getTxMacFcsError(*args)
    def getTxPortPerTidFrames(*args): return _vclapi.VclStats_getTxPortPerTidFrames(*args)
    def getTxPortPerTidOctets(*args): return _vclapi.VclStats_getTxPortPerTidOctets(*args)
    def getTxMacTotalBlockAckRetransmissions(*args): return _vclapi.VclStats_getTxMacTotalBlockAckRetransmissions(*args)
    def getTxCurrentMinMaxRssiValues(*args): return _vclapi.VclStats_getTxCurrentMinMaxRssiValues(*args)
    def getTxSignatureValidFrames(*args): return _vclapi.VclStats_getTxSignatureValidFrames(*args)
    def getRxMacFrames(*args): return _vclapi.VclStats_getRxMacFrames(*args)
    def getRxMacFramesOk(*args): return _vclapi.VclStats_getRxMacFramesOk(*args)
    def getRxMacUnicast(*args): return _vclapi.VclStats_getRxMacUnicast(*args)
    def getRxMacMulticast(*args): return _vclapi.VclStats_getRxMacMulticast(*args)
    def getRxMacBroadcast(*args): return _vclapi.VclStats_getRxMacBroadcast(*args)
    def getRxMacDuplicateFrameOk(*args): return _vclapi.VclStats_getRxMacDuplicateFrameOk(*args)
    def getRxMacFcsError(*args): return _vclapi.VclStats_getRxMacFcsError(*args)
    def getRxMacOctets(*args): return _vclapi.VclStats_getRxMacOctets(*args)
    def getRxMacDataOctetsOk(*args): return _vclapi.VclStats_getRxMacDataOctetsOk(*args)
    def getRxMacManagementOctetsOk(*args): return _vclapi.VclStats_getRxMacManagementOctetsOk(*args)
    def getRxMacControlOctetsOk(*args): return _vclapi.VclStats_getRxMacControlOctetsOk(*args)
    def getRxMacDuplicateOctetsOk(*args): return _vclapi.VclStats_getRxMacDuplicateOctetsOk(*args)
    def getRxMacAckError(*args): return _vclapi.VclStats_getRxMacAckError(*args)
    def getRxSignatureValidFrames(*args): return _vclapi.VclStats_getRxSignatureValidFrames(*args)
    def getRxSignatureErrorFrames(*args): return _vclapi.VclStats_getRxSignatureErrorFrames(*args)
    def getMinimumLatencyOverall(*args): return _vclapi.VclStats_getMinimumLatencyOverall(*args)
    def getMaximumLatencyOverall(*args): return _vclapi.VclStats_getMaximumLatencyOverall(*args)
    def getAverageLatencyOverall(*args): return _vclapi.VclStats_getAverageLatencyOverall(*args)
    def getSumLatencyOverall(*args): return _vclapi.VclStats_getSumLatencyOverall(*args)
    def getLatencyCountOverall(*args): return _vclapi.VclStats_getLatencyCountOverall(*args)
    def getRxMacBlockAckResponseRetries(*args): return _vclapi.VclStats_getRxMacBlockAckResponseRetries(*args)
    def getRxCurrentMinMaxRssiValues(*args): return _vclapi.VclStats_getRxCurrentMinMaxRssiValues(*args)
    def getRxPortPerTidFramesOk(*args): return _vclapi.VclStats_getRxPortPerTidFramesOk(*args)
    def getRxPortPerTidOctetsOk(*args): return _vclapi.VclStats_getRxPortPerTidOctetsOk(*args)
    def getRxPortTidMinLatencyOverall(*args): return _vclapi.VclStats_getRxPortTidMinLatencyOverall(*args)
    def getRxPortTidMaxLatencyOverall(*args): return _vclapi.VclStats_getRxPortTidMaxLatencyOverall(*args)
    def getRxPortTidMaxLatencySum(*args): return _vclapi.VclStats_getRxPortTidMaxLatencySum(*args)
    def getRxPortTidMaxLatencyTotal(*args): return _vclapi.VclStats_getRxPortTidMaxLatencyTotal(*args)
    def getTxPauseFrames(*args): return _vclapi.VclStats_getTxPauseFrames(*args)
    def getTxCollisions(*args): return _vclapi.VclStats_getTxCollisions(*args)
    def getTxFrames64Octets(*args): return _vclapi.VclStats_getTxFrames64Octets(*args)
    def getTxFrames65to127Octets(*args): return _vclapi.VclStats_getTxFrames65to127Octets(*args)
    def getTxFrames128to255Octets(*args): return _vclapi.VclStats_getTxFrames128to255Octets(*args)
    def getTxFrames256to511Octets(*args): return _vclapi.VclStats_getTxFrames256to511Octets(*args)
    def getTxFrames512to1023Octets(*args): return _vclapi.VclStats_getTxFrames512to1023Octets(*args)
    def getTxFrames1024to1522Octets(*args): return _vclapi.VclStats_getTxFrames1024to1522Octets(*args)
    def getTxFramesJumbos(*args): return _vclapi.VclStats_getTxFramesJumbos(*args)
    def getTxVlanFrames(*args): return _vclapi.VclStats_getTxVlanFrames(*args)
    def getTxPortPerUserPriFrames(*args): return _vclapi.VclStats_getTxPortPerUserPriFrames(*args)
    def getTxPortPerUserPriOctets(*args): return _vclapi.VclStats_getTxPortPerUserPriOctets(*args)
    def getTxSignatureValid(*args): return _vclapi.VclStats_getTxSignatureValid(*args)
    def getRxPauseFrames(*args): return _vclapi.VclStats_getRxPauseFrames(*args)
    def getRxFrames64Octets(*args): return _vclapi.VclStats_getRxFrames64Octets(*args)
    def getRxFrames65to127Octets(*args): return _vclapi.VclStats_getRxFrames65to127Octets(*args)
    def getRxFrames128to255Octets(*args): return _vclapi.VclStats_getRxFrames128to255Octets(*args)
    def getRxFrames256to511Octets(*args): return _vclapi.VclStats_getRxFrames256to511Octets(*args)
    def getRxFrames512to1023Octets(*args): return _vclapi.VclStats_getRxFrames512to1023Octets(*args)
    def getRxFrames1024to1522Octets(*args): return _vclapi.VclStats_getRxFrames1024to1522Octets(*args)
    def getRxFramesJumbos(*args): return _vclapi.VclStats_getRxFramesJumbos(*args)
    def getRxVlanFrames(*args): return _vclapi.VclStats_getRxVlanFrames(*args)
    def getRxUndersizeFrames(*args): return _vclapi.VclStats_getRxUndersizeFrames(*args)
    def getRxOversizeFrames(*args): return _vclapi.VclStats_getRxOversizeFrames(*args)
    def getRxFragmentFrames(*args): return _vclapi.VclStats_getRxFragmentFrames(*args)
    def getRxJabberFrames(*args): return _vclapi.VclStats_getRxJabberFrames(*args)
    def getRxLengthErrorFrames(*args): return _vclapi.VclStats_getRxLengthErrorFrames(*args)
    def getRxAlignmentErrorFrames(*args): return _vclapi.VclStats_getRxAlignmentErrorFrames(*args)
    def getRxMacUnicastFrames(*args): return _vclapi.VclStats_getRxMacUnicastFrames(*args)
    def getRxMacMulticastFrames(*args): return _vclapi.VclStats_getRxMacMulticastFrames(*args)
    def getRxMacBroadcastFrames(*args): return _vclapi.VclStats_getRxMacBroadcastFrames(*args)
    def getRxSignatureValid(*args): return _vclapi.VclStats_getRxSignatureValid(*args)
    def getRxSignatureError(*args): return _vclapi.VclStats_getRxSignatureError(*args)
    def getRxPortPerUserPriFramesOk(*args): return _vclapi.VclStats_getRxPortPerUserPriFramesOk(*args)
    def getRxPortPerUserPriOctetsOk(*args): return _vclapi.VclStats_getRxPortPerUserPriOctetsOk(*args)
    def getRxPortUserPriMinLatencyOverall(*args): return _vclapi.VclStats_getRxPortUserPriMinLatencyOverall(*args)
    def getRxPortUserPriMaxLatencyOverall(*args): return _vclapi.VclStats_getRxPortUserPriMaxLatencyOverall(*args)
    def getRxPortUserPriLatencySum(*args): return _vclapi.VclStats_getRxPortUserPriLatencySum(*args)
    def getRxPortUserPriLatencyTotal(*args): return _vclapi.VclStats_getRxPortUserPriLatencyTotal(*args)
    def getTxMacFramesRate(*args): return _vclapi.VclStats_getTxMacFramesRate(*args)
    def getTxMacManagementFramesRate(*args): return _vclapi.VclStats_getTxMacManagementFramesRate(*args)
    def getTxMacDataFramesRate(*args): return _vclapi.VclStats_getTxMacDataFramesRate(*args)
    def getTxMacFramesOkRate(*args): return _vclapi.VclStats_getTxMacFramesOkRate(*args)
    def getTxMacUnicastFramesRate(*args): return _vclapi.VclStats_getTxMacUnicastFramesRate(*args)
    def getTxMacMulticastFramesRate(*args): return _vclapi.VclStats_getTxMacMulticastFramesRate(*args)
    def getTxMacBroadcastFramesRate(*args): return _vclapi.VclStats_getTxMacBroadcastFramesRate(*args)
    def getTxMacFailedCountRate(*args): return _vclapi.VclStats_getTxMacFailedCountRate(*args)
    def getTxMacShortRetryCountRate(*args): return _vclapi.VclStats_getTxMacShortRetryCountRate(*args)
    def getTxMacLongRetryCountRate(*args): return _vclapi.VclStats_getTxMacLongRetryCountRate(*args)
    def getTxMacSingleRetryCountRate(*args): return _vclapi.VclStats_getTxMacSingleRetryCountRate(*args)
    def getTxMacMultipleRetryCountRate(*args): return _vclapi.VclStats_getTxMacMultipleRetryCountRate(*args)
    def getTxMacTotalRetransmissionsRate(*args): return _vclapi.VclStats_getTxMacTotalRetransmissionsRate(*args)
    def getTxMacRtsSuccessCountRate(*args): return _vclapi.VclStats_getTxMacRtsSuccessCountRate(*args)
    def getTxMacRtsFailureCountRate(*args): return _vclapi.VclStats_getTxMacRtsFailureCountRate(*args)
    def getTxMacAckFailureCountRate(*args): return _vclapi.VclStats_getTxMacAckFailureCountRate(*args)
    def getTxMacOctetsRate(*args): return _vclapi.VclStats_getTxMacOctetsRate(*args)
    def getTxMacDataOctetsRate(*args): return _vclapi.VclStats_getTxMacDataOctetsRate(*args)
    def getTxMacManagementOctetsRate(*args): return _vclapi.VclStats_getTxMacManagementOctetsRate(*args)
    def getTxMacDataOctetsOkRate(*args): return _vclapi.VclStats_getTxMacDataOctetsOkRate(*args)
    def getTxMacManagementOctetsOkRate(*args): return _vclapi.VclStats_getTxMacManagementOctetsOkRate(*args)
    def getTxMacFcsErrorRate(*args): return _vclapi.VclStats_getTxMacFcsErrorRate(*args)
    def getTxPortPerTidFramesRate(*args): return _vclapi.VclStats_getTxPortPerTidFramesRate(*args)
    def getTxPortPerTidOctetsRate(*args): return _vclapi.VclStats_getTxPortPerTidOctetsRate(*args)
    def getTxMacTotalBlockAckRetransmissionsRate(*args): return _vclapi.VclStats_getTxMacTotalBlockAckRetransmissionsRate(*args)
    def getTxCurrentMinMaxRssiValuesRate(*args): return _vclapi.VclStats_getTxCurrentMinMaxRssiValuesRate(*args)
    def getTxSignatureValidFramesRate(*args): return _vclapi.VclStats_getTxSignatureValidFramesRate(*args)
    def getRxMacFramesRate(*args): return _vclapi.VclStats_getRxMacFramesRate(*args)
    def getRxMacFramesOkRate(*args): return _vclapi.VclStats_getRxMacFramesOkRate(*args)
    def getRxMacUnicastRate(*args): return _vclapi.VclStats_getRxMacUnicastRate(*args)
    def getRxMacMulticastRate(*args): return _vclapi.VclStats_getRxMacMulticastRate(*args)
    def getRxMacBroadcastRate(*args): return _vclapi.VclStats_getRxMacBroadcastRate(*args)
    def getRxMacDuplicateFrameOkRate(*args): return _vclapi.VclStats_getRxMacDuplicateFrameOkRate(*args)
    def getRxMacFcsErrorRate(*args): return _vclapi.VclStats_getRxMacFcsErrorRate(*args)
    def getRxMacOctetsRate(*args): return _vclapi.VclStats_getRxMacOctetsRate(*args)
    def getRxMacDataOctetsOkRate(*args): return _vclapi.VclStats_getRxMacDataOctetsOkRate(*args)
    def getRxMacManagementOctetsOkRate(*args): return _vclapi.VclStats_getRxMacManagementOctetsOkRate(*args)
    def getRxMacControlOctetsOkRate(*args): return _vclapi.VclStats_getRxMacControlOctetsOkRate(*args)
    def getRxMacDuplicateOctetsOkRate(*args): return _vclapi.VclStats_getRxMacDuplicateOctetsOkRate(*args)
    def getRxMacAckErrorRate(*args): return _vclapi.VclStats_getRxMacAckErrorRate(*args)
    def getRxSignatureValidFramesRate(*args): return _vclapi.VclStats_getRxSignatureValidFramesRate(*args)
    def getRxSignatureErrorFramesRate(*args): return _vclapi.VclStats_getRxSignatureErrorFramesRate(*args)
    def getMinimumLatencyOverallRate(*args): return _vclapi.VclStats_getMinimumLatencyOverallRate(*args)
    def getMaximumLatencyOverallRate(*args): return _vclapi.VclStats_getMaximumLatencyOverallRate(*args)
    def getAverageLatencyOverallRate(*args): return _vclapi.VclStats_getAverageLatencyOverallRate(*args)
    def getSumLatencyOverallRate(*args): return _vclapi.VclStats_getSumLatencyOverallRate(*args)
    def getLatencyCountOverallRate(*args): return _vclapi.VclStats_getLatencyCountOverallRate(*args)
    def getRxMacBlockAckResponseRetriesRate(*args): return _vclapi.VclStats_getRxMacBlockAckResponseRetriesRate(*args)
    def getRxCurrentMinMaxRssiValuesRate(*args): return _vclapi.VclStats_getRxCurrentMinMaxRssiValuesRate(*args)
    def getRxPortPerTidFramesOkRate(*args): return _vclapi.VclStats_getRxPortPerTidFramesOkRate(*args)
    def getRxPortPerTidOctetsOkRate(*args): return _vclapi.VclStats_getRxPortPerTidOctetsOkRate(*args)
    def getRxPortTidMinLatencyOverallRate(*args): return _vclapi.VclStats_getRxPortTidMinLatencyOverallRate(*args)
    def getRxPortTidMaxLatencyOverallRate(*args): return _vclapi.VclStats_getRxPortTidMaxLatencyOverallRate(*args)
    def getRxPortTidMaxLatencySumRate(*args): return _vclapi.VclStats_getRxPortTidMaxLatencySumRate(*args)
    def getRxPortTidMaxLatencyTotalRate(*args): return _vclapi.VclStats_getRxPortTidMaxLatencyTotalRate(*args)
    def getTxPauseFramesRate(*args): return _vclapi.VclStats_getTxPauseFramesRate(*args)
    def getTxCollisionsRate(*args): return _vclapi.VclStats_getTxCollisionsRate(*args)
    def getTxFrames64OctetsRate(*args): return _vclapi.VclStats_getTxFrames64OctetsRate(*args)
    def getTxFrames65to127OctetsRate(*args): return _vclapi.VclStats_getTxFrames65to127OctetsRate(*args)
    def getTxFrames128to255OctetsRate(*args): return _vclapi.VclStats_getTxFrames128to255OctetsRate(*args)
    def getTxFrames256to511OctetsRate(*args): return _vclapi.VclStats_getTxFrames256to511OctetsRate(*args)
    def getTxFrames512to1023OctetsRate(*args): return _vclapi.VclStats_getTxFrames512to1023OctetsRate(*args)
    def getTxFrames1024to1522OctetsRate(*args): return _vclapi.VclStats_getTxFrames1024to1522OctetsRate(*args)
    def getTxFramesJumbosRate(*args): return _vclapi.VclStats_getTxFramesJumbosRate(*args)
    def getTxVlanFramesRate(*args): return _vclapi.VclStats_getTxVlanFramesRate(*args)
    def getTxSignatureValidRate(*args): return _vclapi.VclStats_getTxSignatureValidRate(*args)
    def getTxPortPerUserPriFramesRate(*args): return _vclapi.VclStats_getTxPortPerUserPriFramesRate(*args)
    def getTxPortPerUserPriOctetsRate(*args): return _vclapi.VclStats_getTxPortPerUserPriOctetsRate(*args)
    def getRxPauseFramesRate(*args): return _vclapi.VclStats_getRxPauseFramesRate(*args)
    def getRxFrames64OctetsRate(*args): return _vclapi.VclStats_getRxFrames64OctetsRate(*args)
    def getRxFrames65to127OctetsRate(*args): return _vclapi.VclStats_getRxFrames65to127OctetsRate(*args)
    def getRxFrames128to255OctetsRate(*args): return _vclapi.VclStats_getRxFrames128to255OctetsRate(*args)
    def getRxFrames256to511OctetsRate(*args): return _vclapi.VclStats_getRxFrames256to511OctetsRate(*args)
    def getRxFrames512to1023OctetsRate(*args): return _vclapi.VclStats_getRxFrames512to1023OctetsRate(*args)
    def getRxFrames1024to1522OctetsRate(*args): return _vclapi.VclStats_getRxFrames1024to1522OctetsRate(*args)
    def getRxFramesJumbosRate(*args): return _vclapi.VclStats_getRxFramesJumbosRate(*args)
    def getRxVlanFramesRate(*args): return _vclapi.VclStats_getRxVlanFramesRate(*args)
    def getRxUndersizeFramesRate(*args): return _vclapi.VclStats_getRxUndersizeFramesRate(*args)
    def getRxOversizeFramesRate(*args): return _vclapi.VclStats_getRxOversizeFramesRate(*args)
    def getRxFragmentFramesRate(*args): return _vclapi.VclStats_getRxFragmentFramesRate(*args)
    def getRxJabberFramesRate(*args): return _vclapi.VclStats_getRxJabberFramesRate(*args)
    def getRxLengthErrorFramesRate(*args): return _vclapi.VclStats_getRxLengthErrorFramesRate(*args)
    def getRxAlignmentErrorFramesRate(*args): return _vclapi.VclStats_getRxAlignmentErrorFramesRate(*args)
    def getRxMacUnicastFramesRate(*args): return _vclapi.VclStats_getRxMacUnicastFramesRate(*args)
    def getRxMacMulticastFramesRate(*args): return _vclapi.VclStats_getRxMacMulticastFramesRate(*args)
    def getRxMacBroadcastFramesRate(*args): return _vclapi.VclStats_getRxMacBroadcastFramesRate(*args)
    def getRxSignatureValidRate(*args): return _vclapi.VclStats_getRxSignatureValidRate(*args)
    def getRxSignatureErrorRate(*args): return _vclapi.VclStats_getRxSignatureErrorRate(*args)
    def getRxPortPerUserPriFramesOkRate(*args): return _vclapi.VclStats_getRxPortPerUserPriFramesOkRate(*args)
    def getRxPortPerUserPriOctetsOkRate(*args): return _vclapi.VclStats_getRxPortPerUserPriOctetsOkRate(*args)
    def getRxPortUserPriMinLatencyOverallRate(*args): return _vclapi.VclStats_getRxPortUserPriMinLatencyOverallRate(*args)
    def getRxPortUserPriMaxLatencyOverallRate(*args): return _vclapi.VclStats_getRxPortUserPriMaxLatencyOverallRate(*args)
    def getRxPortUserPriLatencySumRate(*args): return _vclapi.VclStats_getRxPortUserPriLatencySumRate(*args)
    def getRxPortUserPriLatencyTotalRate(*args): return _vclapi.VclStats_getRxPortUserPriLatencyTotalRate(*args)
    def getTxArpRequestOk(*args): return _vclapi.VclStats_getTxArpRequestOk(*args)
    def getTxArpResponseOk(*args): return _vclapi.VclStats_getTxArpResponseOk(*args)
    def getTxDhcpRequestOk(*args): return _vclapi.VclStats_getTxDhcpRequestOk(*args)
    def getTxPingResponseOk(*args): return _vclapi.VclStats_getTxPingResponseOk(*args)
    def getTxIpMulticastPackets(*args): return _vclapi.VclStats_getTxIpMulticastPackets(*args)
    def getTxIpPacketsOk(*args): return _vclapi.VclStats_getTxIpPacketsOk(*args)
    def getTxIpOctetsOk(*args): return _vclapi.VclStats_getTxIpOctetsOk(*args)
    def getTxIcmpFramesOk(*args): return _vclapi.VclStats_getTxIcmpFramesOk(*args)
    def getTxUdpFramesOk(*args): return _vclapi.VclStats_getTxUdpFramesOk(*args)
    def getTxTcpFramesOk(*args): return _vclapi.VclStats_getTxTcpFramesOk(*args)
    def getRxArpRequests(*args): return _vclapi.VclStats_getRxArpRequests(*args)
    def getRxArpResponses(*args): return _vclapi.VclStats_getRxArpResponses(*args)
    def getRxDhcpRequests(*args): return _vclapi.VclStats_getRxDhcpRequests(*args)
    def getRxIpPacketsOk(*args): return _vclapi.VclStats_getRxIpPacketsOk(*args)
    def getRxIpChecksumErrors(*args): return _vclapi.VclStats_getRxIpChecksumErrors(*args)
    def getRxIpOctetsOk(*args): return _vclapi.VclStats_getRxIpOctetsOk(*args)
    def getRxIcmpPacketsOk(*args): return _vclapi.VclStats_getRxIcmpPacketsOk(*args)
    def getRxIcmpChecksumErrors(*args): return _vclapi.VclStats_getRxIcmpChecksumErrors(*args)
    def getRxPingRequestsOk(*args): return _vclapi.VclStats_getRxPingRequestsOk(*args)
    def getRxPingResponsesOk(*args): return _vclapi.VclStats_getRxPingResponsesOk(*args)
    def getRxIpMulticastPackets(*args): return _vclapi.VclStats_getRxIpMulticastPackets(*args)
    def getRxUdpPacketsOk(*args): return _vclapi.VclStats_getRxUdpPacketsOk(*args)
    def getRxUdpChecksumErrors(*args): return _vclapi.VclStats_getRxUdpChecksumErrors(*args)
    def getRxTcpPacketsOk(*args): return _vclapi.VclStats_getRxTcpPacketsOk(*args)
    def getRxTcpChecksumErrors(*args): return _vclapi.VclStats_getRxTcpChecksumErrors(*args)
    def getTxArpRequestOkRate(*args): return _vclapi.VclStats_getTxArpRequestOkRate(*args)
    def getTxArpResponseOkRate(*args): return _vclapi.VclStats_getTxArpResponseOkRate(*args)
    def getTxDhcpRequestOkRate(*args): return _vclapi.VclStats_getTxDhcpRequestOkRate(*args)
    def getTxPingResponseOkRate(*args): return _vclapi.VclStats_getTxPingResponseOkRate(*args)
    def getTxIpMulticastPacketsRate(*args): return _vclapi.VclStats_getTxIpMulticastPacketsRate(*args)
    def getTxIpPacketsOkRate(*args): return _vclapi.VclStats_getTxIpPacketsOkRate(*args)
    def getTxIpOctetsOkRate(*args): return _vclapi.VclStats_getTxIpOctetsOkRate(*args)
    def getTxIcmpFramesOkRate(*args): return _vclapi.VclStats_getTxIcmpFramesOkRate(*args)
    def getTxUdpFramesOkRate(*args): return _vclapi.VclStats_getTxUdpFramesOkRate(*args)
    def getTxTcpFramesOkRate(*args): return _vclapi.VclStats_getTxTcpFramesOkRate(*args)
    def getRxArpRequestsRate(*args): return _vclapi.VclStats_getRxArpRequestsRate(*args)
    def getRxArpResponsesRate(*args): return _vclapi.VclStats_getRxArpResponsesRate(*args)
    def getRxDhcpRequestsRate(*args): return _vclapi.VclStats_getRxDhcpRequestsRate(*args)
    def getRxIpPacketsOkRate(*args): return _vclapi.VclStats_getRxIpPacketsOkRate(*args)
    def getRxIpChecksumErrorsRate(*args): return _vclapi.VclStats_getRxIpChecksumErrorsRate(*args)
    def getRxIpOctetsOkRate(*args): return _vclapi.VclStats_getRxIpOctetsOkRate(*args)
    def getRxIcmpPacketsOkRate(*args): return _vclapi.VclStats_getRxIcmpPacketsOkRate(*args)
    def getRxIcmpChecksumErrorsRate(*args): return _vclapi.VclStats_getRxIcmpChecksumErrorsRate(*args)
    def getRxPingRequestsOkRate(*args): return _vclapi.VclStats_getRxPingRequestsOkRate(*args)
    def getRxPingResponsesOkRate(*args): return _vclapi.VclStats_getRxPingResponsesOkRate(*args)
    def getRxIpMulticastPacketsRate(*args): return _vclapi.VclStats_getRxIpMulticastPacketsRate(*args)
    def getRxUdpPacketsOkRate(*args): return _vclapi.VclStats_getRxUdpPacketsOkRate(*args)
    def getRxUdpChecksumErrorsRate(*args): return _vclapi.VclStats_getRxUdpChecksumErrorsRate(*args)
    def getRxTcpPacketsOkRate(*args): return _vclapi.VclStats_getRxTcpPacketsOkRate(*args)
    def getRxTcpChecksumErrorsRate(*args): return _vclapi.VclStats_getRxTcpChecksumErrorsRate(*args)
    def getTxPatternMatchFrames(*args): return _vclapi.VclStats_getTxPatternMatchFrames(*args)
    def getTxPatternMatchOctets(*args): return _vclapi.VclStats_getTxPatternMatchOctets(*args)
    def getRxPatternMatchFrames(*args): return _vclapi.VclStats_getRxPatternMatchFrames(*args)
    def getRxPatternMatchOctets(*args): return _vclapi.VclStats_getRxPatternMatchOctets(*args)
    def getTxPatternMatchFramesRate(*args): return _vclapi.VclStats_getTxPatternMatchFramesRate(*args)
    def getTxPatternMatchOctetsRate(*args): return _vclapi.VclStats_getTxPatternMatchOctetsRate(*args)
    def getRxPatternMatchFramesRate(*args): return _vclapi.VclStats_getRxPatternMatchFramesRate(*args)
    def getRxPatternMatchOctetsRate(*args): return _vclapi.VclStats_getRxPatternMatchOctetsRate(*args)
    def getTxMacFrameType(*args): return _vclapi.VclStats_getTxMacFrameType(*args)
    def getRxMacFrameType(*args): return _vclapi.VclStats_getRxMacFrameType(*args)
    def getTxMacAssocRequests(*args): return _vclapi.VclStats_getTxMacAssocRequests(*args)
    def getTxMacAssocResponses(*args): return _vclapi.VclStats_getTxMacAssocResponses(*args)
    def getTxMacReassocRequests(*args): return _vclapi.VclStats_getTxMacReassocRequests(*args)
    def getTxMacReassocResponses(*args): return _vclapi.VclStats_getTxMacReassocResponses(*args)
    def getTxMacProbeRequests(*args): return _vclapi.VclStats_getTxMacProbeRequests(*args)
    def getTxMacProbeResponses(*args): return _vclapi.VclStats_getTxMacProbeResponses(*args)
    def getTxMacBeacon(*args): return _vclapi.VclStats_getTxMacBeacon(*args)
    def getTxMacAtim(*args): return _vclapi.VclStats_getTxMacAtim(*args)
    def getTxMacDisassoc(*args): return _vclapi.VclStats_getTxMacDisassoc(*args)
    def getTxMacAuth(*args): return _vclapi.VclStats_getTxMacAuth(*args)
    def getTxMacDeauth(*args): return _vclapi.VclStats_getTxMacDeauth(*args)
    def getTxMacPsPoll(*args): return _vclapi.VclStats_getTxMacPsPoll(*args)
    def getTxMacRts(*args): return _vclapi.VclStats_getTxMacRts(*args)
    def getTxMacCts(*args): return _vclapi.VclStats_getTxMacCts(*args)
    def getTxMacAck(*args): return _vclapi.VclStats_getTxMacAck(*args)
    def getTxMacCfEnd(*args): return _vclapi.VclStats_getTxMacCfEnd(*args)
    def getTxMacCfEndAck(*args): return _vclapi.VclStats_getTxMacCfEndAck(*args)
    def getTxMacData(*args): return _vclapi.VclStats_getTxMacData(*args)
    def getTxMacDataCfAck(*args): return _vclapi.VclStats_getTxMacDataCfAck(*args)
    def getTxMacDataCfPoll(*args): return _vclapi.VclStats_getTxMacDataCfPoll(*args)
    def getTxMacDataCfAckPoll(*args): return _vclapi.VclStats_getTxMacDataCfAckPoll(*args)
    def getTxMacDataNull(*args): return _vclapi.VclStats_getTxMacDataNull(*args)
    def getTxMacCfAckNull(*args): return _vclapi.VclStats_getTxMacCfAckNull(*args)
    def getTxMacCfPollNull(*args): return _vclapi.VclStats_getTxMacCfPollNull(*args)
    def getTxMacCfAckPollNull(*args): return _vclapi.VclStats_getTxMacCfAckPollNull(*args)
    def getRxMacAssocRequests(*args): return _vclapi.VclStats_getRxMacAssocRequests(*args)
    def getRxMacAssocResponses(*args): return _vclapi.VclStats_getRxMacAssocResponses(*args)
    def getRxMacReassocRequests(*args): return _vclapi.VclStats_getRxMacReassocRequests(*args)
    def getRxMacReassocResponses(*args): return _vclapi.VclStats_getRxMacReassocResponses(*args)
    def getRxMacProbeRequests(*args): return _vclapi.VclStats_getRxMacProbeRequests(*args)
    def getRxMacProbeResponses(*args): return _vclapi.VclStats_getRxMacProbeResponses(*args)
    def getRxMacBeacon(*args): return _vclapi.VclStats_getRxMacBeacon(*args)
    def getRxMacAtim(*args): return _vclapi.VclStats_getRxMacAtim(*args)
    def getRxMacDisassoc(*args): return _vclapi.VclStats_getRxMacDisassoc(*args)
    def getRxMacAuth(*args): return _vclapi.VclStats_getRxMacAuth(*args)
    def getRxMacDeauth(*args): return _vclapi.VclStats_getRxMacDeauth(*args)
    def getRxMacPsPoll(*args): return _vclapi.VclStats_getRxMacPsPoll(*args)
    def getRxMacRts(*args): return _vclapi.VclStats_getRxMacRts(*args)
    def getRxMacCts(*args): return _vclapi.VclStats_getRxMacCts(*args)
    def getRxMacAck(*args): return _vclapi.VclStats_getRxMacAck(*args)
    def getRxMacCfEnd(*args): return _vclapi.VclStats_getRxMacCfEnd(*args)
    def getRxMacCfEndAck(*args): return _vclapi.VclStats_getRxMacCfEndAck(*args)
    def getRxMacData(*args): return _vclapi.VclStats_getRxMacData(*args)
    def getRxMacDataCfAck(*args): return _vclapi.VclStats_getRxMacDataCfAck(*args)
    def getRxMacDataCfPoll(*args): return _vclapi.VclStats_getRxMacDataCfPoll(*args)
    def getRxMacDataCfAckPoll(*args): return _vclapi.VclStats_getRxMacDataCfAckPoll(*args)
    def getRxMacDataNull(*args): return _vclapi.VclStats_getRxMacDataNull(*args)
    def getRxMacCfAckNull(*args): return _vclapi.VclStats_getRxMacCfAckNull(*args)
    def getRxMacCfPollNull(*args): return _vclapi.VclStats_getRxMacCfPollNull(*args)
    def getRxMacCfAckPollNull(*args): return _vclapi.VclStats_getRxMacCfAckPollNull(*args)
    def getTxMacAssocRequestsRate(*args): return _vclapi.VclStats_getTxMacAssocRequestsRate(*args)
    def getTxMacAssocResponsesRate(*args): return _vclapi.VclStats_getTxMacAssocResponsesRate(*args)
    def getTxMacReassocRequestsRate(*args): return _vclapi.VclStats_getTxMacReassocRequestsRate(*args)
    def getTxMacReassocResponsesRate(*args): return _vclapi.VclStats_getTxMacReassocResponsesRate(*args)
    def getTxMacProbeRequestsRate(*args): return _vclapi.VclStats_getTxMacProbeRequestsRate(*args)
    def getTxMacProbeResponsesRate(*args): return _vclapi.VclStats_getTxMacProbeResponsesRate(*args)
    def getTxMacBeaconRate(*args): return _vclapi.VclStats_getTxMacBeaconRate(*args)
    def getTxMacAtimRate(*args): return _vclapi.VclStats_getTxMacAtimRate(*args)
    def getTxMacDisassocRate(*args): return _vclapi.VclStats_getTxMacDisassocRate(*args)
    def getTxMacAuthRate(*args): return _vclapi.VclStats_getTxMacAuthRate(*args)
    def getTxMacDeauthRate(*args): return _vclapi.VclStats_getTxMacDeauthRate(*args)
    def getTxMacPsPollRate(*args): return _vclapi.VclStats_getTxMacPsPollRate(*args)
    def getTxMacRtsRate(*args): return _vclapi.VclStats_getTxMacRtsRate(*args)
    def getTxMacCtsRate(*args): return _vclapi.VclStats_getTxMacCtsRate(*args)
    def getTxMacAckRate(*args): return _vclapi.VclStats_getTxMacAckRate(*args)
    def getTxMacCfEndRate(*args): return _vclapi.VclStats_getTxMacCfEndRate(*args)
    def getTxMacCfEndAckRate(*args): return _vclapi.VclStats_getTxMacCfEndAckRate(*args)
    def getTxMacDataRate(*args): return _vclapi.VclStats_getTxMacDataRate(*args)
    def getTxMacDataCfAckRate(*args): return _vclapi.VclStats_getTxMacDataCfAckRate(*args)
    def getTxMacDataCfPollRate(*args): return _vclapi.VclStats_getTxMacDataCfPollRate(*args)
    def getTxMacDataCfAckPollRate(*args): return _vclapi.VclStats_getTxMacDataCfAckPollRate(*args)
    def getTxMacDataNullRate(*args): return _vclapi.VclStats_getTxMacDataNullRate(*args)
    def getTxMacCfAckNullRate(*args): return _vclapi.VclStats_getTxMacCfAckNullRate(*args)
    def getTxMacCfPollNullRate(*args): return _vclapi.VclStats_getTxMacCfPollNullRate(*args)
    def getTxMacCfAckPollNullRate(*args): return _vclapi.VclStats_getTxMacCfAckPollNullRate(*args)
    def getRxMacAssocRequestsRate(*args): return _vclapi.VclStats_getRxMacAssocRequestsRate(*args)
    def getRxMacAssocResponsesRate(*args): return _vclapi.VclStats_getRxMacAssocResponsesRate(*args)
    def getRxMacReassocRequestsRate(*args): return _vclapi.VclStats_getRxMacReassocRequestsRate(*args)
    def getRxMacReassocResponsesRate(*args): return _vclapi.VclStats_getRxMacReassocResponsesRate(*args)
    def getRxMacProbeRequestsRate(*args): return _vclapi.VclStats_getRxMacProbeRequestsRate(*args)
    def getRxMacProbeResponsesRate(*args): return _vclapi.VclStats_getRxMacProbeResponsesRate(*args)
    def getRxMacBeaconRate(*args): return _vclapi.VclStats_getRxMacBeaconRate(*args)
    def getRxMacAtimRate(*args): return _vclapi.VclStats_getRxMacAtimRate(*args)
    def getRxMacDisassocRate(*args): return _vclapi.VclStats_getRxMacDisassocRate(*args)
    def getRxMacAuthRate(*args): return _vclapi.VclStats_getRxMacAuthRate(*args)
    def getRxMacDeauthRate(*args): return _vclapi.VclStats_getRxMacDeauthRate(*args)
    def getRxMacPsPollRate(*args): return _vclapi.VclStats_getRxMacPsPollRate(*args)
    def getRxMacRtsRate(*args): return _vclapi.VclStats_getRxMacRtsRate(*args)
    def getRxMacCtsRate(*args): return _vclapi.VclStats_getRxMacCtsRate(*args)
    def getRxMacAckRate(*args): return _vclapi.VclStats_getRxMacAckRate(*args)
    def getRxMacCfEndRate(*args): return _vclapi.VclStats_getRxMacCfEndRate(*args)
    def getRxMacCfEndAckRate(*args): return _vclapi.VclStats_getRxMacCfEndAckRate(*args)
    def getRxMacDataRate(*args): return _vclapi.VclStats_getRxMacDataRate(*args)
    def getRxMacDataCfAckRate(*args): return _vclapi.VclStats_getRxMacDataCfAckRate(*args)
    def getRxMacDataCfPollRate(*args): return _vclapi.VclStats_getRxMacDataCfPollRate(*args)
    def getRxMacDataCfAckPollRate(*args): return _vclapi.VclStats_getRxMacDataCfAckPollRate(*args)
    def getRxMacDataNullRate(*args): return _vclapi.VclStats_getRxMacDataNullRate(*args)
    def getRxMacCfAckNullRate(*args): return _vclapi.VclStats_getRxMacCfAckNullRate(*args)
    def getRxMacCfPollNullRate(*args): return _vclapi.VclStats_getRxMacCfPollNullRate(*args)
    def getRxMacCfAckPollNullRate(*args): return _vclapi.VclStats_getRxMacCfAckPollNullRate(*args)
    def getTotalUnicastProbeRequestsSent(*args): return _vclapi.VclStats_getTotalUnicastProbeRequestsSent(*args)
    def getTotalUnicastProbeResponsesReceived(*args): return _vclapi.VclStats_getTotalUnicastProbeResponsesReceived(*args)
    def getTotalBroadcastProbeRequestsSent(*args): return _vclapi.VclStats_getTotalBroadcastProbeRequestsSent(*args)
    def getTotalBroadcastProbeResponsesReceived(*args): return _vclapi.VclStats_getTotalBroadcastProbeResponsesReceived(*args)
    def getTotalOpenSystemAuthenticationSuccess(*args): return _vclapi.VclStats_getTotalOpenSystemAuthenticationSuccess(*args)
    def getTotalOpenSystemAuthenticationFailure(*args): return _vclapi.VclStats_getTotalOpenSystemAuthenticationFailure(*args)
    def getTotalSharedKeyAuthenticationHandshake1Success(*args): return _vclapi.VclStats_getTotalSharedKeyAuthenticationHandshake1Success(*args)
    def getTotalSharedKeyAuthenticationHandshake1Failure(*args): return _vclapi.VclStats_getTotalSharedKeyAuthenticationHandshake1Failure(*args)
    def getTotalSharedKeyAuthenticationHandshake2Success(*args): return _vclapi.VclStats_getTotalSharedKeyAuthenticationHandshake2Success(*args)
    def getTotalSharedKeyAuthenticationHandshake2Failure(*args): return _vclapi.VclStats_getTotalSharedKeyAuthenticationHandshake2Failure(*args)
    def getTotalAssociationHandshakeSuccess(*args): return _vclapi.VclStats_getTotalAssociationHandshakeSuccess(*args)
    def getTotalAssociationHandshakeFailure(*args): return _vclapi.VclStats_getTotalAssociationHandshakeFailure(*args)
    def getTotalEAPOLHandshakeSuccess(*args): return _vclapi.VclStats_getTotalEAPOLHandshakeSuccess(*args)
    def getTotalEAPOLHandshakeFailure(*args): return _vclapi.VclStats_getTotalEAPOLHandshakeFailure(*args)
    def getTotalDHCPDiscoverHandshakeSuccess(*args): return _vclapi.VclStats_getTotalDHCPDiscoverHandshakeSuccess(*args)
    def getTotalDHCPDiscoverHandshakeFailure(*args): return _vclapi.VclStats_getTotalDHCPDiscoverHandshakeFailure(*args)
    def getTotalDHCPRequestHandshakeSuccess(*args): return _vclapi.VclStats_getTotalDHCPRequestHandshakeSuccess(*args)
    def getTotalDHCPRequestHandshakeFailure(*args): return _vclapi.VclStats_getTotalDHCPRequestHandshakeFailure(*args)
    def getTotalARPRequestHandshakeSuccess(*args): return _vclapi.VclStats_getTotalARPRequestHandshakeSuccess(*args)
    def getTotalARPRequestHandshakeFailure(*args): return _vclapi.VclStats_getTotalARPRequestHandshakeFailure(*args)
    def getTotalPingRequestsReceived(*args): return _vclapi.VclStats_getTotalPingRequestsReceived(*args)
    def getTotalPingResponsesSent(*args): return _vclapi.VclStats_getTotalPingResponsesSent(*args)
    def getTotalARPRequestsReceived(*args): return _vclapi.VclStats_getTotalARPRequestsReceived(*args)
    def getTotalARPResponsesSent(*args): return _vclapi.VclStats_getTotalARPResponsesSent(*args)
    def getCountOfActiveClients(*args): return _vclapi.VclStats_getCountOfActiveClients(*args)
    def getCountOfActiveFlows(*args): return _vclapi.VclStats_getCountOfActiveFlows(*args)
    def getCountOf80211AuthenticatedClients(*args): return _vclapi.VclStats_getCountOf80211AuthenticatedClients(*args)
    def getCountOf80211AssociatedClients(*args): return _vclapi.VclStats_getCountOf80211AssociatedClients(*args)
    def getCountOf8021xAuthenticatedClients(*args): return _vclapi.VclStats_getCountOf8021xAuthenticatedClients(*args)
    def getCountOfDeauthenticatedClients(*args): return _vclapi.VclStats_getCountOfDeauthenticatedClients(*args)
    def getCountOfDisassociatedClients(*args): return _vclapi.VclStats_getCountOfDisassociatedClients(*args)
    def getCountOfReauthenticatedClients(*args): return _vclapi.VclStats_getCountOfReauthenticatedClients(*args)
    def getTotalUnicastProbeRequestsSentRate(*args): return _vclapi.VclStats_getTotalUnicastProbeRequestsSentRate(*args)
    def getTotalUnicastProbeResponsesReceivedRate(*args): return _vclapi.VclStats_getTotalUnicastProbeResponsesReceivedRate(*args)
    def getTotalBroadcastProbeRequestsSentRate(*args): return _vclapi.VclStats_getTotalBroadcastProbeRequestsSentRate(*args)
    def getTotalBroadcastProbeResponsesReceivedRate(*args): return _vclapi.VclStats_getTotalBroadcastProbeResponsesReceivedRate(*args)
    def getTotalOpenSystemAuthenticationSuccessRate(*args): return _vclapi.VclStats_getTotalOpenSystemAuthenticationSuccessRate(*args)
    def getTotalOpenSystemAuthenticationFailureRate(*args): return _vclapi.VclStats_getTotalOpenSystemAuthenticationFailureRate(*args)
    def getTotalSharedKeyAuthenticationHandshake1SuccessRate(*args): return _vclapi.VclStats_getTotalSharedKeyAuthenticationHandshake1SuccessRate(*args)
    def getTotalSharedKeyAuthenticationHandshake1FailureRate(*args): return _vclapi.VclStats_getTotalSharedKeyAuthenticationHandshake1FailureRate(*args)
    def getTotalSharedKeyAuthenticationHandshake2SuccessRate(*args): return _vclapi.VclStats_getTotalSharedKeyAuthenticationHandshake2SuccessRate(*args)
    def getTotalSharedKeyAuthenticationHandshake2FailureRate(*args): return _vclapi.VclStats_getTotalSharedKeyAuthenticationHandshake2FailureRate(*args)
    def getTotalAssociationHandshakeSuccessRate(*args): return _vclapi.VclStats_getTotalAssociationHandshakeSuccessRate(*args)
    def getTotalAssociationHandshakeFailureRate(*args): return _vclapi.VclStats_getTotalAssociationHandshakeFailureRate(*args)
    def getTotalEAPOLHandshakeSuccessRate(*args): return _vclapi.VclStats_getTotalEAPOLHandshakeSuccessRate(*args)
    def getTotalEAPOLHandshakeFailureRate(*args): return _vclapi.VclStats_getTotalEAPOLHandshakeFailureRate(*args)
    def getTotalDHCPDiscoverHandshakeSuccessRate(*args): return _vclapi.VclStats_getTotalDHCPDiscoverHandshakeSuccessRate(*args)
    def getTotalDHCPDiscoverHandshakeFailureRate(*args): return _vclapi.VclStats_getTotalDHCPDiscoverHandshakeFailureRate(*args)
    def getTotalDHCPRequestHandshakeSuccessRate(*args): return _vclapi.VclStats_getTotalDHCPRequestHandshakeSuccessRate(*args)
    def getTotalDHCPRequestHandshakeFailureRate(*args): return _vclapi.VclStats_getTotalDHCPRequestHandshakeFailureRate(*args)
    def getTotalARPRequestHandshakeSuccessRate(*args): return _vclapi.VclStats_getTotalARPRequestHandshakeSuccessRate(*args)
    def getTotalARPRequestHandshakeFailureRate(*args): return _vclapi.VclStats_getTotalARPRequestHandshakeFailureRate(*args)
    def getTotalPingRequestsReceivedRate(*args): return _vclapi.VclStats_getTotalPingRequestsReceivedRate(*args)
    def getTotalPingResponsesSentRate(*args): return _vclapi.VclStats_getTotalPingResponsesSentRate(*args)
    def getTotalARPRequestsReceivedRate(*args): return _vclapi.VclStats_getTotalARPRequestsReceivedRate(*args)
    def getTotalARPResponsesSentRate(*args): return _vclapi.VclStats_getTotalARPResponsesSentRate(*args)
    def getCountOfActiveClientsRate(*args): return _vclapi.VclStats_getCountOfActiveClientsRate(*args)
    def getCountOfActiveFlowsRate(*args): return _vclapi.VclStats_getCountOfActiveFlowsRate(*args)
    def getCountOf80211AuthenticatedClientsRate(*args): return _vclapi.VclStats_getCountOf80211AuthenticatedClientsRate(*args)
    def getCountOf80211AssociatedClientsRate(*args): return _vclapi.VclStats_getCountOf80211AssociatedClientsRate(*args)
    def getCountOf8021xAuthenticatedClientsRate(*args): return _vclapi.VclStats_getCountOf8021xAuthenticatedClientsRate(*args)
    def getCountOfDeauthenticatedClientsRate(*args): return _vclapi.VclStats_getCountOfDeauthenticatedClientsRate(*args)
    def getCountOfDisassociatedClientsRate(*args): return _vclapi.VclStats_getCountOfDisassociatedClientsRate(*args)
    def getCountOfReauthenticatedClientsRate(*args): return _vclapi.VclStats_getCountOfReauthenticatedClientsRate(*args)
    __swig_getmethods__["txMacFrames"] = _vclapi.VclStats_txMacFrames_get
    if _newclass:txMacFrames = property(_vclapi.VclStats_txMacFrames_get)
    __swig_getmethods__["txMacManagementFrames"] = _vclapi.VclStats_txMacManagementFrames_get
    if _newclass:txMacManagementFrames = property(_vclapi.VclStats_txMacManagementFrames_get)
    __swig_getmethods__["txMacDataFrames"] = _vclapi.VclStats_txMacDataFrames_get
    if _newclass:txMacDataFrames = property(_vclapi.VclStats_txMacDataFrames_get)
    __swig_getmethods__["txMacFramesOk"] = _vclapi.VclStats_txMacFramesOk_get
    if _newclass:txMacFramesOk = property(_vclapi.VclStats_txMacFramesOk_get)
    __swig_getmethods__["txMacUnicastFrames"] = _vclapi.VclStats_txMacUnicastFrames_get
    if _newclass:txMacUnicastFrames = property(_vclapi.VclStats_txMacUnicastFrames_get)
    __swig_getmethods__["txMacMulticastFrames"] = _vclapi.VclStats_txMacMulticastFrames_get
    if _newclass:txMacMulticastFrames = property(_vclapi.VclStats_txMacMulticastFrames_get)
    __swig_getmethods__["txMacBroadcastFrames"] = _vclapi.VclStats_txMacBroadcastFrames_get
    if _newclass:txMacBroadcastFrames = property(_vclapi.VclStats_txMacBroadcastFrames_get)
    __swig_getmethods__["txMacFailedCount"] = _vclapi.VclStats_txMacFailedCount_get
    if _newclass:txMacFailedCount = property(_vclapi.VclStats_txMacFailedCount_get)
    __swig_getmethods__["txMacShortRetryCount"] = _vclapi.VclStats_txMacShortRetryCount_get
    if _newclass:txMacShortRetryCount = property(_vclapi.VclStats_txMacShortRetryCount_get)
    __swig_getmethods__["txMacLongRetryCount"] = _vclapi.VclStats_txMacLongRetryCount_get
    if _newclass:txMacLongRetryCount = property(_vclapi.VclStats_txMacLongRetryCount_get)
    __swig_getmethods__["txMacSingleRetryCount"] = _vclapi.VclStats_txMacSingleRetryCount_get
    if _newclass:txMacSingleRetryCount = property(_vclapi.VclStats_txMacSingleRetryCount_get)
    __swig_getmethods__["txMacMultipleRetryCount"] = _vclapi.VclStats_txMacMultipleRetryCount_get
    if _newclass:txMacMultipleRetryCount = property(_vclapi.VclStats_txMacMultipleRetryCount_get)
    __swig_getmethods__["txMacTotalRetransmissions"] = _vclapi.VclStats_txMacTotalRetransmissions_get
    if _newclass:txMacTotalRetransmissions = property(_vclapi.VclStats_txMacTotalRetransmissions_get)
    __swig_getmethods__["txMacRtsSuccessCount"] = _vclapi.VclStats_txMacRtsSuccessCount_get
    if _newclass:txMacRtsSuccessCount = property(_vclapi.VclStats_txMacRtsSuccessCount_get)
    __swig_getmethods__["txMacRtsFailureCount"] = _vclapi.VclStats_txMacRtsFailureCount_get
    if _newclass:txMacRtsFailureCount = property(_vclapi.VclStats_txMacRtsFailureCount_get)
    __swig_getmethods__["txMacAckFailureCount"] = _vclapi.VclStats_txMacAckFailureCount_get
    if _newclass:txMacAckFailureCount = property(_vclapi.VclStats_txMacAckFailureCount_get)
    __swig_getmethods__["txMacOctets"] = _vclapi.VclStats_txMacOctets_get
    if _newclass:txMacOctets = property(_vclapi.VclStats_txMacOctets_get)
    __swig_getmethods__["txMacDataOctets"] = _vclapi.VclStats_txMacDataOctets_get
    if _newclass:txMacDataOctets = property(_vclapi.VclStats_txMacDataOctets_get)
    __swig_getmethods__["txMacManagementOctets"] = _vclapi.VclStats_txMacManagementOctets_get
    if _newclass:txMacManagementOctets = property(_vclapi.VclStats_txMacManagementOctets_get)
    __swig_getmethods__["txMacDataOctetsOk"] = _vclapi.VclStats_txMacDataOctetsOk_get
    if _newclass:txMacDataOctetsOk = property(_vclapi.VclStats_txMacDataOctetsOk_get)
    __swig_getmethods__["txMacManagementOctetsOk"] = _vclapi.VclStats_txMacManagementOctetsOk_get
    if _newclass:txMacManagementOctetsOk = property(_vclapi.VclStats_txMacManagementOctetsOk_get)
    __swig_getmethods__["txMacFcsError"] = _vclapi.VclStats_txMacFcsError_get
    if _newclass:txMacFcsError = property(_vclapi.VclStats_txMacFcsError_get)
    __swig_getmethods__["txPortPerTidFrames"] = _vclapi.VclStats_txPortPerTidFrames_get
    if _newclass:txPortPerTidFrames = property(_vclapi.VclStats_txPortPerTidFrames_get)
    __swig_getmethods__["txPortPerTidOctets"] = _vclapi.VclStats_txPortPerTidOctets_get
    if _newclass:txPortPerTidOctets = property(_vclapi.VclStats_txPortPerTidOctets_get)
    __swig_getmethods__["txMacTotalBlockAckRetransmissions"] = _vclapi.VclStats_txMacTotalBlockAckRetransmissions_get
    if _newclass:txMacTotalBlockAckRetransmissions = property(_vclapi.VclStats_txMacTotalBlockAckRetransmissions_get)
    __swig_getmethods__["txCurrentMinMaxRssiValues"] = _vclapi.VclStats_txCurrentMinMaxRssiValues_get
    if _newclass:txCurrentMinMaxRssiValues = property(_vclapi.VclStats_txCurrentMinMaxRssiValues_get)
    __swig_getmethods__["rxMacFrames"] = _vclapi.VclStats_rxMacFrames_get
    if _newclass:rxMacFrames = property(_vclapi.VclStats_rxMacFrames_get)
    __swig_getmethods__["rxMacFramesOk"] = _vclapi.VclStats_rxMacFramesOk_get
    if _newclass:rxMacFramesOk = property(_vclapi.VclStats_rxMacFramesOk_get)
    __swig_getmethods__["rxMacUnicast"] = _vclapi.VclStats_rxMacUnicast_get
    if _newclass:rxMacUnicast = property(_vclapi.VclStats_rxMacUnicast_get)
    __swig_getmethods__["rxMacMulticast"] = _vclapi.VclStats_rxMacMulticast_get
    if _newclass:rxMacMulticast = property(_vclapi.VclStats_rxMacMulticast_get)
    __swig_getmethods__["rxMacBroadcast"] = _vclapi.VclStats_rxMacBroadcast_get
    if _newclass:rxMacBroadcast = property(_vclapi.VclStats_rxMacBroadcast_get)
    __swig_getmethods__["rxMacDuplicateFrameOk"] = _vclapi.VclStats_rxMacDuplicateFrameOk_get
    if _newclass:rxMacDuplicateFrameOk = property(_vclapi.VclStats_rxMacDuplicateFrameOk_get)
    __swig_getmethods__["rxMacFcsError"] = _vclapi.VclStats_rxMacFcsError_get
    if _newclass:rxMacFcsError = property(_vclapi.VclStats_rxMacFcsError_get)
    __swig_getmethods__["rxMacOctets"] = _vclapi.VclStats_rxMacOctets_get
    if _newclass:rxMacOctets = property(_vclapi.VclStats_rxMacOctets_get)
    __swig_getmethods__["rxMacDataOctetsOk"] = _vclapi.VclStats_rxMacDataOctetsOk_get
    if _newclass:rxMacDataOctetsOk = property(_vclapi.VclStats_rxMacDataOctetsOk_get)
    __swig_getmethods__["rxMacManagementOctetsOk"] = _vclapi.VclStats_rxMacManagementOctetsOk_get
    if _newclass:rxMacManagementOctetsOk = property(_vclapi.VclStats_rxMacManagementOctetsOk_get)
    __swig_getmethods__["rxMacControlOctetsOk"] = _vclapi.VclStats_rxMacControlOctetsOk_get
    if _newclass:rxMacControlOctetsOk = property(_vclapi.VclStats_rxMacControlOctetsOk_get)
    __swig_getmethods__["rxMacDuplicateOctetsOk"] = _vclapi.VclStats_rxMacDuplicateOctetsOk_get
    if _newclass:rxMacDuplicateOctetsOk = property(_vclapi.VclStats_rxMacDuplicateOctetsOk_get)
    __swig_getmethods__["rxMacAckError"] = _vclapi.VclStats_rxMacAckError_get
    if _newclass:rxMacAckError = property(_vclapi.VclStats_rxMacAckError_get)
    __swig_getmethods__["rxSignatureValidFrames"] = _vclapi.VclStats_rxSignatureValidFrames_get
    if _newclass:rxSignatureValidFrames = property(_vclapi.VclStats_rxSignatureValidFrames_get)
    __swig_getmethods__["rxSignatureErrorFrames"] = _vclapi.VclStats_rxSignatureErrorFrames_get
    if _newclass:rxSignatureErrorFrames = property(_vclapi.VclStats_rxSignatureErrorFrames_get)
    __swig_getmethods__["minimumLatencyOverall"] = _vclapi.VclStats_minimumLatencyOverall_get
    if _newclass:minimumLatencyOverall = property(_vclapi.VclStats_minimumLatencyOverall_get)
    __swig_getmethods__["maximumLatencyOverall"] = _vclapi.VclStats_maximumLatencyOverall_get
    if _newclass:maximumLatencyOverall = property(_vclapi.VclStats_maximumLatencyOverall_get)
    __swig_getmethods__["averageLatencyOverall"] = _vclapi.VclStats_averageLatencyOverall_get
    if _newclass:averageLatencyOverall = property(_vclapi.VclStats_averageLatencyOverall_get)
    __swig_getmethods__["sumLatencyOverall"] = _vclapi.VclStats_sumLatencyOverall_get
    if _newclass:sumLatencyOverall = property(_vclapi.VclStats_sumLatencyOverall_get)
    __swig_getmethods__["latencyCountOverall"] = _vclapi.VclStats_latencyCountOverall_get
    if _newclass:latencyCountOverall = property(_vclapi.VclStats_latencyCountOverall_get)
    __swig_getmethods__["rxMacBlockAckResponseRetries"] = _vclapi.VclStats_rxMacBlockAckResponseRetries_get
    if _newclass:rxMacBlockAckResponseRetries = property(_vclapi.VclStats_rxMacBlockAckResponseRetries_get)
    __swig_getmethods__["rxCurrentMinMaxRssiValues"] = _vclapi.VclStats_rxCurrentMinMaxRssiValues_get
    if _newclass:rxCurrentMinMaxRssiValues = property(_vclapi.VclStats_rxCurrentMinMaxRssiValues_get)
    __swig_getmethods__["rxPortPerTidFramesOk"] = _vclapi.VclStats_rxPortPerTidFramesOk_get
    if _newclass:rxPortPerTidFramesOk = property(_vclapi.VclStats_rxPortPerTidFramesOk_get)
    __swig_getmethods__["rxPortPerTidOctetsOk"] = _vclapi.VclStats_rxPortPerTidOctetsOk_get
    if _newclass:rxPortPerTidOctetsOk = property(_vclapi.VclStats_rxPortPerTidOctetsOk_get)
    __swig_getmethods__["rxPortTidMinLatencyOverall"] = _vclapi.VclStats_rxPortTidMinLatencyOverall_get
    if _newclass:rxPortTidMinLatencyOverall = property(_vclapi.VclStats_rxPortTidMinLatencyOverall_get)
    __swig_getmethods__["rxPortTidMaxLatencyOverall"] = _vclapi.VclStats_rxPortTidMaxLatencyOverall_get
    if _newclass:rxPortTidMaxLatencyOverall = property(_vclapi.VclStats_rxPortTidMaxLatencyOverall_get)
    __swig_getmethods__["rxPortTidMaxLatencySum"] = _vclapi.VclStats_rxPortTidMaxLatencySum_get
    if _newclass:rxPortTidMaxLatencySum = property(_vclapi.VclStats_rxPortTidMaxLatencySum_get)
    __swig_getmethods__["rxPortTidMaxLatencyTotal"] = _vclapi.VclStats_rxPortTidMaxLatencyTotal_get
    if _newclass:rxPortTidMaxLatencyTotal = property(_vclapi.VclStats_rxPortTidMaxLatencyTotal_get)
    __swig_getmethods__["txPauseFrames"] = _vclapi.VclStats_txPauseFrames_get
    if _newclass:txPauseFrames = property(_vclapi.VclStats_txPauseFrames_get)
    __swig_getmethods__["txCollisions"] = _vclapi.VclStats_txCollisions_get
    if _newclass:txCollisions = property(_vclapi.VclStats_txCollisions_get)
    __swig_getmethods__["txFrames64Octets"] = _vclapi.VclStats_txFrames64Octets_get
    if _newclass:txFrames64Octets = property(_vclapi.VclStats_txFrames64Octets_get)
    __swig_getmethods__["txFrames65to127Octets"] = _vclapi.VclStats_txFrames65to127Octets_get
    if _newclass:txFrames65to127Octets = property(_vclapi.VclStats_txFrames65to127Octets_get)
    __swig_getmethods__["txFrames128to255Octets"] = _vclapi.VclStats_txFrames128to255Octets_get
    if _newclass:txFrames128to255Octets = property(_vclapi.VclStats_txFrames128to255Octets_get)
    __swig_getmethods__["txFrames256to511Octets"] = _vclapi.VclStats_txFrames256to511Octets_get
    if _newclass:txFrames256to511Octets = property(_vclapi.VclStats_txFrames256to511Octets_get)
    __swig_getmethods__["txFrames512to1023Octets"] = _vclapi.VclStats_txFrames512to1023Octets_get
    if _newclass:txFrames512to1023Octets = property(_vclapi.VclStats_txFrames512to1023Octets_get)
    __swig_getmethods__["txFrames1024to1522Octets"] = _vclapi.VclStats_txFrames1024to1522Octets_get
    if _newclass:txFrames1024to1522Octets = property(_vclapi.VclStats_txFrames1024to1522Octets_get)
    __swig_getmethods__["txFramesJumbos"] = _vclapi.VclStats_txFramesJumbos_get
    if _newclass:txFramesJumbos = property(_vclapi.VclStats_txFramesJumbos_get)
    __swig_getmethods__["txVlanFrames"] = _vclapi.VclStats_txVlanFrames_get
    if _newclass:txVlanFrames = property(_vclapi.VclStats_txVlanFrames_get)
    __swig_getmethods__["txPortPerUserPriFrames"] = _vclapi.VclStats_txPortPerUserPriFrames_get
    if _newclass:txPortPerUserPriFrames = property(_vclapi.VclStats_txPortPerUserPriFrames_get)
    __swig_getmethods__["txPortPerUserPriOctets"] = _vclapi.VclStats_txPortPerUserPriOctets_get
    if _newclass:txPortPerUserPriOctets = property(_vclapi.VclStats_txPortPerUserPriOctets_get)
    __swig_getmethods__["rxPauseFrames"] = _vclapi.VclStats_rxPauseFrames_get
    if _newclass:rxPauseFrames = property(_vclapi.VclStats_rxPauseFrames_get)
    __swig_getmethods__["rxFrames64Octets"] = _vclapi.VclStats_rxFrames64Octets_get
    if _newclass:rxFrames64Octets = property(_vclapi.VclStats_rxFrames64Octets_get)
    __swig_getmethods__["rxFrames65to127Octets"] = _vclapi.VclStats_rxFrames65to127Octets_get
    if _newclass:rxFrames65to127Octets = property(_vclapi.VclStats_rxFrames65to127Octets_get)
    __swig_getmethods__["rxFrames128to255Octets"] = _vclapi.VclStats_rxFrames128to255Octets_get
    if _newclass:rxFrames128to255Octets = property(_vclapi.VclStats_rxFrames128to255Octets_get)
    __swig_getmethods__["rxFrames256to511Octets"] = _vclapi.VclStats_rxFrames256to511Octets_get
    if _newclass:rxFrames256to511Octets = property(_vclapi.VclStats_rxFrames256to511Octets_get)
    __swig_getmethods__["rxFrames512to1023Octets"] = _vclapi.VclStats_rxFrames512to1023Octets_get
    if _newclass:rxFrames512to1023Octets = property(_vclapi.VclStats_rxFrames512to1023Octets_get)
    __swig_getmethods__["rxFrames1024to1522Octets"] = _vclapi.VclStats_rxFrames1024to1522Octets_get
    if _newclass:rxFrames1024to1522Octets = property(_vclapi.VclStats_rxFrames1024to1522Octets_get)
    __swig_getmethods__["rxFramesJumbos"] = _vclapi.VclStats_rxFramesJumbos_get
    if _newclass:rxFramesJumbos = property(_vclapi.VclStats_rxFramesJumbos_get)
    __swig_getmethods__["rxVlanFrames"] = _vclapi.VclStats_rxVlanFrames_get
    if _newclass:rxVlanFrames = property(_vclapi.VclStats_rxVlanFrames_get)
    __swig_getmethods__["rxUndersizeFrames"] = _vclapi.VclStats_rxUndersizeFrames_get
    if _newclass:rxUndersizeFrames = property(_vclapi.VclStats_rxUndersizeFrames_get)
    __swig_getmethods__["rxOversizeFrames"] = _vclapi.VclStats_rxOversizeFrames_get
    if _newclass:rxOversizeFrames = property(_vclapi.VclStats_rxOversizeFrames_get)
    __swig_getmethods__["rxFragmentFrames"] = _vclapi.VclStats_rxFragmentFrames_get
    if _newclass:rxFragmentFrames = property(_vclapi.VclStats_rxFragmentFrames_get)
    __swig_getmethods__["rxJabberFrames"] = _vclapi.VclStats_rxJabberFrames_get
    if _newclass:rxJabberFrames = property(_vclapi.VclStats_rxJabberFrames_get)
    __swig_getmethods__["rxLengthErrorFrames"] = _vclapi.VclStats_rxLengthErrorFrames_get
    if _newclass:rxLengthErrorFrames = property(_vclapi.VclStats_rxLengthErrorFrames_get)
    __swig_getmethods__["rxAlignmentErrorFrames"] = _vclapi.VclStats_rxAlignmentErrorFrames_get
    if _newclass:rxAlignmentErrorFrames = property(_vclapi.VclStats_rxAlignmentErrorFrames_get)
    __swig_getmethods__["rxMacUnicastFrames"] = _vclapi.VclStats_rxMacUnicastFrames_get
    if _newclass:rxMacUnicastFrames = property(_vclapi.VclStats_rxMacUnicastFrames_get)
    __swig_getmethods__["rxMacMulticastFrames"] = _vclapi.VclStats_rxMacMulticastFrames_get
    if _newclass:rxMacMulticastFrames = property(_vclapi.VclStats_rxMacMulticastFrames_get)
    __swig_getmethods__["rxMacBroadcastFrames"] = _vclapi.VclStats_rxMacBroadcastFrames_get
    if _newclass:rxMacBroadcastFrames = property(_vclapi.VclStats_rxMacBroadcastFrames_get)
    __swig_getmethods__["rxSignatureValid"] = _vclapi.VclStats_rxSignatureValid_get
    if _newclass:rxSignatureValid = property(_vclapi.VclStats_rxSignatureValid_get)
    __swig_getmethods__["rxSignatureError"] = _vclapi.VclStats_rxSignatureError_get
    if _newclass:rxSignatureError = property(_vclapi.VclStats_rxSignatureError_get)
    __swig_getmethods__["rxPortPerUserPriFramesOk"] = _vclapi.VclStats_rxPortPerUserPriFramesOk_get
    if _newclass:rxPortPerUserPriFramesOk = property(_vclapi.VclStats_rxPortPerUserPriFramesOk_get)
    __swig_getmethods__["rxPortPerUserPriOctetsOk"] = _vclapi.VclStats_rxPortPerUserPriOctetsOk_get
    if _newclass:rxPortPerUserPriOctetsOk = property(_vclapi.VclStats_rxPortPerUserPriOctetsOk_get)
    __swig_getmethods__["rxPortUserPriMinLatencyOverall"] = _vclapi.VclStats_rxPortUserPriMinLatencyOverall_get
    if _newclass:rxPortUserPriMinLatencyOverall = property(_vclapi.VclStats_rxPortUserPriMinLatencyOverall_get)
    __swig_getmethods__["rxPortUserPriMaxLatencyOverall"] = _vclapi.VclStats_rxPortUserPriMaxLatencyOverall_get
    if _newclass:rxPortUserPriMaxLatencyOverall = property(_vclapi.VclStats_rxPortUserPriMaxLatencyOverall_get)
    __swig_getmethods__["rxPortUserPriLatencySum"] = _vclapi.VclStats_rxPortUserPriLatencySum_get
    if _newclass:rxPortUserPriLatencySum = property(_vclapi.VclStats_rxPortUserPriLatencySum_get)
    __swig_getmethods__["rxPortUserPriLatencyTotal"] = _vclapi.VclStats_rxPortUserPriLatencyTotal_get
    if _newclass:rxPortUserPriLatencyTotal = property(_vclapi.VclStats_rxPortUserPriLatencyTotal_get)
    __swig_getmethods__["txMacFramesRate"] = _vclapi.VclStats_txMacFramesRate_get
    if _newclass:txMacFramesRate = property(_vclapi.VclStats_txMacFramesRate_get)
    __swig_getmethods__["txMacManagementFramesRate"] = _vclapi.VclStats_txMacManagementFramesRate_get
    if _newclass:txMacManagementFramesRate = property(_vclapi.VclStats_txMacManagementFramesRate_get)
    __swig_getmethods__["txMacDataFramesRate"] = _vclapi.VclStats_txMacDataFramesRate_get
    if _newclass:txMacDataFramesRate = property(_vclapi.VclStats_txMacDataFramesRate_get)
    __swig_getmethods__["txMacFramesOkRate"] = _vclapi.VclStats_txMacFramesOkRate_get
    if _newclass:txMacFramesOkRate = property(_vclapi.VclStats_txMacFramesOkRate_get)
    __swig_getmethods__["txMacUnicastFramesRate"] = _vclapi.VclStats_txMacUnicastFramesRate_get
    if _newclass:txMacUnicastFramesRate = property(_vclapi.VclStats_txMacUnicastFramesRate_get)
    __swig_getmethods__["txMacMulticastFramesRate"] = _vclapi.VclStats_txMacMulticastFramesRate_get
    if _newclass:txMacMulticastFramesRate = property(_vclapi.VclStats_txMacMulticastFramesRate_get)
    __swig_getmethods__["txMacBroadcastFramesRate"] = _vclapi.VclStats_txMacBroadcastFramesRate_get
    if _newclass:txMacBroadcastFramesRate = property(_vclapi.VclStats_txMacBroadcastFramesRate_get)
    __swig_getmethods__["txMacFailedCountRate"] = _vclapi.VclStats_txMacFailedCountRate_get
    if _newclass:txMacFailedCountRate = property(_vclapi.VclStats_txMacFailedCountRate_get)
    __swig_getmethods__["txMacShortRetryCountRate"] = _vclapi.VclStats_txMacShortRetryCountRate_get
    if _newclass:txMacShortRetryCountRate = property(_vclapi.VclStats_txMacShortRetryCountRate_get)
    __swig_getmethods__["txMacLongRetryCountRate"] = _vclapi.VclStats_txMacLongRetryCountRate_get
    if _newclass:txMacLongRetryCountRate = property(_vclapi.VclStats_txMacLongRetryCountRate_get)
    __swig_getmethods__["txMacSingleRetryCountRate"] = _vclapi.VclStats_txMacSingleRetryCountRate_get
    if _newclass:txMacSingleRetryCountRate = property(_vclapi.VclStats_txMacSingleRetryCountRate_get)
    __swig_getmethods__["txMacMultipleRetryCountRate"] = _vclapi.VclStats_txMacMultipleRetryCountRate_get
    if _newclass:txMacMultipleRetryCountRate = property(_vclapi.VclStats_txMacMultipleRetryCountRate_get)
    __swig_getmethods__["txMacTotalRetransmissionsRate"] = _vclapi.VclStats_txMacTotalRetransmissionsRate_get
    if _newclass:txMacTotalRetransmissionsRate = property(_vclapi.VclStats_txMacTotalRetransmissionsRate_get)
    __swig_getmethods__["txMacRtsSuccessCountRate"] = _vclapi.VclStats_txMacRtsSuccessCountRate_get
    if _newclass:txMacRtsSuccessCountRate = property(_vclapi.VclStats_txMacRtsSuccessCountRate_get)
    __swig_getmethods__["txMacRtsFailureCountRate"] = _vclapi.VclStats_txMacRtsFailureCountRate_get
    if _newclass:txMacRtsFailureCountRate = property(_vclapi.VclStats_txMacRtsFailureCountRate_get)
    __swig_getmethods__["txMacAckFailureCountRate"] = _vclapi.VclStats_txMacAckFailureCountRate_get
    if _newclass:txMacAckFailureCountRate = property(_vclapi.VclStats_txMacAckFailureCountRate_get)
    __swig_getmethods__["txMacOctetsRate"] = _vclapi.VclStats_txMacOctetsRate_get
    if _newclass:txMacOctetsRate = property(_vclapi.VclStats_txMacOctetsRate_get)
    __swig_getmethods__["txMacDataOctetsRate"] = _vclapi.VclStats_txMacDataOctetsRate_get
    if _newclass:txMacDataOctetsRate = property(_vclapi.VclStats_txMacDataOctetsRate_get)
    __swig_getmethods__["txMacManagementOctetsRate"] = _vclapi.VclStats_txMacManagementOctetsRate_get
    if _newclass:txMacManagementOctetsRate = property(_vclapi.VclStats_txMacManagementOctetsRate_get)
    __swig_getmethods__["txMacDataOctetsOkRate"] = _vclapi.VclStats_txMacDataOctetsOkRate_get
    if _newclass:txMacDataOctetsOkRate = property(_vclapi.VclStats_txMacDataOctetsOkRate_get)
    __swig_getmethods__["txMacManagementOctetsOkRate"] = _vclapi.VclStats_txMacManagementOctetsOkRate_get
    if _newclass:txMacManagementOctetsOkRate = property(_vclapi.VclStats_txMacManagementOctetsOkRate_get)
    __swig_getmethods__["txMacFcsErrorRate"] = _vclapi.VclStats_txMacFcsErrorRate_get
    if _newclass:txMacFcsErrorRate = property(_vclapi.VclStats_txMacFcsErrorRate_get)
    __swig_getmethods__["txPortPerTidFramesRate"] = _vclapi.VclStats_txPortPerTidFramesRate_get
    if _newclass:txPortPerTidFramesRate = property(_vclapi.VclStats_txPortPerTidFramesRate_get)
    __swig_getmethods__["txPortPerTidOctetsRate"] = _vclapi.VclStats_txPortPerTidOctetsRate_get
    if _newclass:txPortPerTidOctetsRate = property(_vclapi.VclStats_txPortPerTidOctetsRate_get)
    __swig_getmethods__["txMacTotalBlockAckRetransmissionsRate"] = _vclapi.VclStats_txMacTotalBlockAckRetransmissionsRate_get
    if _newclass:txMacTotalBlockAckRetransmissionsRate = property(_vclapi.VclStats_txMacTotalBlockAckRetransmissionsRate_get)
    __swig_getmethods__["txCurrentMinMaxRssiValuesRate"] = _vclapi.VclStats_txCurrentMinMaxRssiValuesRate_get
    if _newclass:txCurrentMinMaxRssiValuesRate = property(_vclapi.VclStats_txCurrentMinMaxRssiValuesRate_get)
    __swig_getmethods__["rxMacFramesRate"] = _vclapi.VclStats_rxMacFramesRate_get
    if _newclass:rxMacFramesRate = property(_vclapi.VclStats_rxMacFramesRate_get)
    __swig_getmethods__["rxMacFramesOkRate"] = _vclapi.VclStats_rxMacFramesOkRate_get
    if _newclass:rxMacFramesOkRate = property(_vclapi.VclStats_rxMacFramesOkRate_get)
    __swig_getmethods__["rxMacUnicastRate"] = _vclapi.VclStats_rxMacUnicastRate_get
    if _newclass:rxMacUnicastRate = property(_vclapi.VclStats_rxMacUnicastRate_get)
    __swig_getmethods__["rxMacMulticastRate"] = _vclapi.VclStats_rxMacMulticastRate_get
    if _newclass:rxMacMulticastRate = property(_vclapi.VclStats_rxMacMulticastRate_get)
    __swig_getmethods__["rxMacBroadcastRate"] = _vclapi.VclStats_rxMacBroadcastRate_get
    if _newclass:rxMacBroadcastRate = property(_vclapi.VclStats_rxMacBroadcastRate_get)
    __swig_getmethods__["rxMacDuplicateFrameOkRate"] = _vclapi.VclStats_rxMacDuplicateFrameOkRate_get
    if _newclass:rxMacDuplicateFrameOkRate = property(_vclapi.VclStats_rxMacDuplicateFrameOkRate_get)
    __swig_getmethods__["rxMacFcsErrorRate"] = _vclapi.VclStats_rxMacFcsErrorRate_get
    if _newclass:rxMacFcsErrorRate = property(_vclapi.VclStats_rxMacFcsErrorRate_get)
    __swig_getmethods__["rxMacOctetsRate"] = _vclapi.VclStats_rxMacOctetsRate_get
    if _newclass:rxMacOctetsRate = property(_vclapi.VclStats_rxMacOctetsRate_get)
    __swig_getmethods__["rxMacDataOctetsOkRate"] = _vclapi.VclStats_rxMacDataOctetsOkRate_get
    if _newclass:rxMacDataOctetsOkRate = property(_vclapi.VclStats_rxMacDataOctetsOkRate_get)
    __swig_getmethods__["rxMacManagementOctetsOkRate"] = _vclapi.VclStats_rxMacManagementOctetsOkRate_get
    if _newclass:rxMacManagementOctetsOkRate = property(_vclapi.VclStats_rxMacManagementOctetsOkRate_get)
    __swig_getmethods__["rxMacControlOctetsOkRate"] = _vclapi.VclStats_rxMacControlOctetsOkRate_get
    if _newclass:rxMacControlOctetsOkRate = property(_vclapi.VclStats_rxMacControlOctetsOkRate_get)
    __swig_getmethods__["rxMacDuplicateOctetsOkRate"] = _vclapi.VclStats_rxMacDuplicateOctetsOkRate_get
    if _newclass:rxMacDuplicateOctetsOkRate = property(_vclapi.VclStats_rxMacDuplicateOctetsOkRate_get)
    __swig_getmethods__["rxMacAckErrorRate"] = _vclapi.VclStats_rxMacAckErrorRate_get
    if _newclass:rxMacAckErrorRate = property(_vclapi.VclStats_rxMacAckErrorRate_get)
    __swig_getmethods__["rxSignatureValidFramesRate"] = _vclapi.VclStats_rxSignatureValidFramesRate_get
    if _newclass:rxSignatureValidFramesRate = property(_vclapi.VclStats_rxSignatureValidFramesRate_get)
    __swig_getmethods__["rxSignatureErrorFramesRate"] = _vclapi.VclStats_rxSignatureErrorFramesRate_get
    if _newclass:rxSignatureErrorFramesRate = property(_vclapi.VclStats_rxSignatureErrorFramesRate_get)
    __swig_getmethods__["minimumLatencyOverallRate"] = _vclapi.VclStats_minimumLatencyOverallRate_get
    if _newclass:minimumLatencyOverallRate = property(_vclapi.VclStats_minimumLatencyOverallRate_get)
    __swig_getmethods__["maximumLatencyOverallRate"] = _vclapi.VclStats_maximumLatencyOverallRate_get
    if _newclass:maximumLatencyOverallRate = property(_vclapi.VclStats_maximumLatencyOverallRate_get)
    __swig_getmethods__["averageLatencyOverallRate"] = _vclapi.VclStats_averageLatencyOverallRate_get
    if _newclass:averageLatencyOverallRate = property(_vclapi.VclStats_averageLatencyOverallRate_get)
    __swig_getmethods__["sumLatencyOverallRate"] = _vclapi.VclStats_sumLatencyOverallRate_get
    if _newclass:sumLatencyOverallRate = property(_vclapi.VclStats_sumLatencyOverallRate_get)
    __swig_getmethods__["latencyCountOverallRate"] = _vclapi.VclStats_latencyCountOverallRate_get
    if _newclass:latencyCountOverallRate = property(_vclapi.VclStats_latencyCountOverallRate_get)
    __swig_getmethods__["rxMacBlockAckResponseRetriesRate"] = _vclapi.VclStats_rxMacBlockAckResponseRetriesRate_get
    if _newclass:rxMacBlockAckResponseRetriesRate = property(_vclapi.VclStats_rxMacBlockAckResponseRetriesRate_get)
    __swig_getmethods__["rxCurrentMinMaxRssiValuesRate"] = _vclapi.VclStats_rxCurrentMinMaxRssiValuesRate_get
    if _newclass:rxCurrentMinMaxRssiValuesRate = property(_vclapi.VclStats_rxCurrentMinMaxRssiValuesRate_get)
    __swig_getmethods__["rxPortPerTidFramesOkRate"] = _vclapi.VclStats_rxPortPerTidFramesOkRate_get
    if _newclass:rxPortPerTidFramesOkRate = property(_vclapi.VclStats_rxPortPerTidFramesOkRate_get)
    __swig_getmethods__["rxPortPerTidOctetsOkRate"] = _vclapi.VclStats_rxPortPerTidOctetsOkRate_get
    if _newclass:rxPortPerTidOctetsOkRate = property(_vclapi.VclStats_rxPortPerTidOctetsOkRate_get)
    __swig_getmethods__["rxPortTidMinLatencyOverallRate"] = _vclapi.VclStats_rxPortTidMinLatencyOverallRate_get
    if _newclass:rxPortTidMinLatencyOverallRate = property(_vclapi.VclStats_rxPortTidMinLatencyOverallRate_get)
    __swig_getmethods__["rxPortTidMaxLatencyOverallRate"] = _vclapi.VclStats_rxPortTidMaxLatencyOverallRate_get
    if _newclass:rxPortTidMaxLatencyOverallRate = property(_vclapi.VclStats_rxPortTidMaxLatencyOverallRate_get)
    __swig_getmethods__["rxPortTidMaxLatencySumRate"] = _vclapi.VclStats_rxPortTidMaxLatencySumRate_get
    if _newclass:rxPortTidMaxLatencySumRate = property(_vclapi.VclStats_rxPortTidMaxLatencySumRate_get)
    __swig_getmethods__["rxPortTidMaxLatencyTotalRate"] = _vclapi.VclStats_rxPortTidMaxLatencyTotalRate_get
    if _newclass:rxPortTidMaxLatencyTotalRate = property(_vclapi.VclStats_rxPortTidMaxLatencyTotalRate_get)
    __swig_getmethods__["txPauseFramesRate"] = _vclapi.VclStats_txPauseFramesRate_get
    if _newclass:txPauseFramesRate = property(_vclapi.VclStats_txPauseFramesRate_get)
    __swig_getmethods__["txCollisionsRate"] = _vclapi.VclStats_txCollisionsRate_get
    if _newclass:txCollisionsRate = property(_vclapi.VclStats_txCollisionsRate_get)
    __swig_getmethods__["txFrames64OctetsRate"] = _vclapi.VclStats_txFrames64OctetsRate_get
    if _newclass:txFrames64OctetsRate = property(_vclapi.VclStats_txFrames64OctetsRate_get)
    __swig_getmethods__["txFrames65to127OctetsRate"] = _vclapi.VclStats_txFrames65to127OctetsRate_get
    if _newclass:txFrames65to127OctetsRate = property(_vclapi.VclStats_txFrames65to127OctetsRate_get)
    __swig_getmethods__["txFrames128to255OctetsRate"] = _vclapi.VclStats_txFrames128to255OctetsRate_get
    if _newclass:txFrames128to255OctetsRate = property(_vclapi.VclStats_txFrames128to255OctetsRate_get)
    __swig_getmethods__["txFrames256to511OctetsRate"] = _vclapi.VclStats_txFrames256to511OctetsRate_get
    if _newclass:txFrames256to511OctetsRate = property(_vclapi.VclStats_txFrames256to511OctetsRate_get)
    __swig_getmethods__["txFrames512to1023OctetsRate"] = _vclapi.VclStats_txFrames512to1023OctetsRate_get
    if _newclass:txFrames512to1023OctetsRate = property(_vclapi.VclStats_txFrames512to1023OctetsRate_get)
    __swig_getmethods__["txFrames1024to1522OctetsRate"] = _vclapi.VclStats_txFrames1024to1522OctetsRate_get
    if _newclass:txFrames1024to1522OctetsRate = property(_vclapi.VclStats_txFrames1024to1522OctetsRate_get)
    __swig_getmethods__["txFramesJumbosRate"] = _vclapi.VclStats_txFramesJumbosRate_get
    if _newclass:txFramesJumbosRate = property(_vclapi.VclStats_txFramesJumbosRate_get)
    __swig_getmethods__["txVlanFramesRate"] = _vclapi.VclStats_txVlanFramesRate_get
    if _newclass:txVlanFramesRate = property(_vclapi.VclStats_txVlanFramesRate_get)
    __swig_getmethods__["txPortPerUserPriFramesRate"] = _vclapi.VclStats_txPortPerUserPriFramesRate_get
    if _newclass:txPortPerUserPriFramesRate = property(_vclapi.VclStats_txPortPerUserPriFramesRate_get)
    __swig_getmethods__["txPortPerUserPriOctetsRate"] = _vclapi.VclStats_txPortPerUserPriOctetsRate_get
    if _newclass:txPortPerUserPriOctetsRate = property(_vclapi.VclStats_txPortPerUserPriOctetsRate_get)
    __swig_getmethods__["rxPauseFramesRate"] = _vclapi.VclStats_rxPauseFramesRate_get
    if _newclass:rxPauseFramesRate = property(_vclapi.VclStats_rxPauseFramesRate_get)
    __swig_getmethods__["rxFrames64OctetsRate"] = _vclapi.VclStats_rxFrames64OctetsRate_get
    if _newclass:rxFrames64OctetsRate = property(_vclapi.VclStats_rxFrames64OctetsRate_get)
    __swig_getmethods__["rxFrames65to127OctetsRate"] = _vclapi.VclStats_rxFrames65to127OctetsRate_get
    if _newclass:rxFrames65to127OctetsRate = property(_vclapi.VclStats_rxFrames65to127OctetsRate_get)
    __swig_getmethods__["rxFrames128to255OctetsRate"] = _vclapi.VclStats_rxFrames128to255OctetsRate_get
    if _newclass:rxFrames128to255OctetsRate = property(_vclapi.VclStats_rxFrames128to255OctetsRate_get)
    __swig_getmethods__["rxFrames256to511OctetsRate"] = _vclapi.VclStats_rxFrames256to511OctetsRate_get
    if _newclass:rxFrames256to511OctetsRate = property(_vclapi.VclStats_rxFrames256to511OctetsRate_get)
    __swig_getmethods__["rxFrames512to1023OctetsRate"] = _vclapi.VclStats_rxFrames512to1023OctetsRate_get
    if _newclass:rxFrames512to1023OctetsRate = property(_vclapi.VclStats_rxFrames512to1023OctetsRate_get)
    __swig_getmethods__["rxFrames1024to1522OctetsRate"] = _vclapi.VclStats_rxFrames1024to1522OctetsRate_get
    if _newclass:rxFrames1024to1522OctetsRate = property(_vclapi.VclStats_rxFrames1024to1522OctetsRate_get)
    __swig_getmethods__["rxFramesJumbosRate"] = _vclapi.VclStats_rxFramesJumbosRate_get
    if _newclass:rxFramesJumbosRate = property(_vclapi.VclStats_rxFramesJumbosRate_get)
    __swig_getmethods__["rxVlanFramesRate"] = _vclapi.VclStats_rxVlanFramesRate_get
    if _newclass:rxVlanFramesRate = property(_vclapi.VclStats_rxVlanFramesRate_get)
    __swig_getmethods__["rxUndersizeFramesRate"] = _vclapi.VclStats_rxUndersizeFramesRate_get
    if _newclass:rxUndersizeFramesRate = property(_vclapi.VclStats_rxUndersizeFramesRate_get)
    __swig_getmethods__["rxOversizeFramesRate"] = _vclapi.VclStats_rxOversizeFramesRate_get
    if _newclass:rxOversizeFramesRate = property(_vclapi.VclStats_rxOversizeFramesRate_get)
    __swig_getmethods__["rxFragmentFramesRate"] = _vclapi.VclStats_rxFragmentFramesRate_get
    if _newclass:rxFragmentFramesRate = property(_vclapi.VclStats_rxFragmentFramesRate_get)
    __swig_getmethods__["rxJabberFramesRate"] = _vclapi.VclStats_rxJabberFramesRate_get
    if _newclass:rxJabberFramesRate = property(_vclapi.VclStats_rxJabberFramesRate_get)
    __swig_getmethods__["rxLengthErrorFramesRate"] = _vclapi.VclStats_rxLengthErrorFramesRate_get
    if _newclass:rxLengthErrorFramesRate = property(_vclapi.VclStats_rxLengthErrorFramesRate_get)
    __swig_getmethods__["rxAlignmentErrorFramesRate"] = _vclapi.VclStats_rxAlignmentErrorFramesRate_get
    if _newclass:rxAlignmentErrorFramesRate = property(_vclapi.VclStats_rxAlignmentErrorFramesRate_get)
    __swig_getmethods__["rxMacUnicastFramesRate"] = _vclapi.VclStats_rxMacUnicastFramesRate_get
    if _newclass:rxMacUnicastFramesRate = property(_vclapi.VclStats_rxMacUnicastFramesRate_get)
    __swig_getmethods__["rxMacMulticastFramesRate"] = _vclapi.VclStats_rxMacMulticastFramesRate_get
    if _newclass:rxMacMulticastFramesRate = property(_vclapi.VclStats_rxMacMulticastFramesRate_get)
    __swig_getmethods__["rxMacBroadcastFramesRate"] = _vclapi.VclStats_rxMacBroadcastFramesRate_get
    if _newclass:rxMacBroadcastFramesRate = property(_vclapi.VclStats_rxMacBroadcastFramesRate_get)
    __swig_getmethods__["rxSignatureValidRate"] = _vclapi.VclStats_rxSignatureValidRate_get
    if _newclass:rxSignatureValidRate = property(_vclapi.VclStats_rxSignatureValidRate_get)
    __swig_getmethods__["rxSignatureErrorRate"] = _vclapi.VclStats_rxSignatureErrorRate_get
    if _newclass:rxSignatureErrorRate = property(_vclapi.VclStats_rxSignatureErrorRate_get)
    __swig_getmethods__["rxPortPerUserPriFramesOkRate"] = _vclapi.VclStats_rxPortPerUserPriFramesOkRate_get
    if _newclass:rxPortPerUserPriFramesOkRate = property(_vclapi.VclStats_rxPortPerUserPriFramesOkRate_get)
    __swig_getmethods__["rxPortPerUserPriOctetsOkRate"] = _vclapi.VclStats_rxPortPerUserPriOctetsOkRate_get
    if _newclass:rxPortPerUserPriOctetsOkRate = property(_vclapi.VclStats_rxPortPerUserPriOctetsOkRate_get)
    __swig_getmethods__["rxPortUserPriMinLatencyOverallRate"] = _vclapi.VclStats_rxPortUserPriMinLatencyOverallRate_get
    if _newclass:rxPortUserPriMinLatencyOverallRate = property(_vclapi.VclStats_rxPortUserPriMinLatencyOverallRate_get)
    __swig_getmethods__["rxPortUserPriMaxLatencyOverallRate"] = _vclapi.VclStats_rxPortUserPriMaxLatencyOverallRate_get
    if _newclass:rxPortUserPriMaxLatencyOverallRate = property(_vclapi.VclStats_rxPortUserPriMaxLatencyOverallRate_get)
    __swig_getmethods__["rxPortUserPriLatencySumRate"] = _vclapi.VclStats_rxPortUserPriLatencySumRate_get
    if _newclass:rxPortUserPriLatencySumRate = property(_vclapi.VclStats_rxPortUserPriLatencySumRate_get)
    __swig_getmethods__["rxPortUserPriLatencyTotalRate"] = _vclapi.VclStats_rxPortUserPriLatencyTotalRate_get
    if _newclass:rxPortUserPriLatencyTotalRate = property(_vclapi.VclStats_rxPortUserPriLatencyTotalRate_get)
    __swig_getmethods__["txArpRequestOk"] = _vclapi.VclStats_txArpRequestOk_get
    if _newclass:txArpRequestOk = property(_vclapi.VclStats_txArpRequestOk_get)
    __swig_getmethods__["txArpResponseOk"] = _vclapi.VclStats_txArpResponseOk_get
    if _newclass:txArpResponseOk = property(_vclapi.VclStats_txArpResponseOk_get)
    __swig_getmethods__["txDhcpRequestOk"] = _vclapi.VclStats_txDhcpRequestOk_get
    if _newclass:txDhcpRequestOk = property(_vclapi.VclStats_txDhcpRequestOk_get)
    __swig_getmethods__["txPingResponseOk"] = _vclapi.VclStats_txPingResponseOk_get
    if _newclass:txPingResponseOk = property(_vclapi.VclStats_txPingResponseOk_get)
    __swig_getmethods__["txIpMulticastPackets"] = _vclapi.VclStats_txIpMulticastPackets_get
    if _newclass:txIpMulticastPackets = property(_vclapi.VclStats_txIpMulticastPackets_get)
    __swig_getmethods__["txIpPacketsOk"] = _vclapi.VclStats_txIpPacketsOk_get
    if _newclass:txIpPacketsOk = property(_vclapi.VclStats_txIpPacketsOk_get)
    __swig_getmethods__["txIpOctetsOk"] = _vclapi.VclStats_txIpOctetsOk_get
    if _newclass:txIpOctetsOk = property(_vclapi.VclStats_txIpOctetsOk_get)
    __swig_getmethods__["txIcmpFramesOk"] = _vclapi.VclStats_txIcmpFramesOk_get
    if _newclass:txIcmpFramesOk = property(_vclapi.VclStats_txIcmpFramesOk_get)
    __swig_getmethods__["txUdpFramesOk"] = _vclapi.VclStats_txUdpFramesOk_get
    if _newclass:txUdpFramesOk = property(_vclapi.VclStats_txUdpFramesOk_get)
    __swig_getmethods__["txTcpFramesOk"] = _vclapi.VclStats_txTcpFramesOk_get
    if _newclass:txTcpFramesOk = property(_vclapi.VclStats_txTcpFramesOk_get)
    __swig_getmethods__["rxArpRequests"] = _vclapi.VclStats_rxArpRequests_get
    if _newclass:rxArpRequests = property(_vclapi.VclStats_rxArpRequests_get)
    __swig_getmethods__["rxArpResponses"] = _vclapi.VclStats_rxArpResponses_get
    if _newclass:rxArpResponses = property(_vclapi.VclStats_rxArpResponses_get)
    __swig_getmethods__["rxDhcpRequests"] = _vclapi.VclStats_rxDhcpRequests_get
    if _newclass:rxDhcpRequests = property(_vclapi.VclStats_rxDhcpRequests_get)
    __swig_getmethods__["rxIpPacketsOk"] = _vclapi.VclStats_rxIpPacketsOk_get
    if _newclass:rxIpPacketsOk = property(_vclapi.VclStats_rxIpPacketsOk_get)
    __swig_getmethods__["rxIpChecksumErrors"] = _vclapi.VclStats_rxIpChecksumErrors_get
    if _newclass:rxIpChecksumErrors = property(_vclapi.VclStats_rxIpChecksumErrors_get)
    __swig_getmethods__["rxIpOctetsOk"] = _vclapi.VclStats_rxIpOctetsOk_get
    if _newclass:rxIpOctetsOk = property(_vclapi.VclStats_rxIpOctetsOk_get)
    __swig_getmethods__["rxIcmpPacketsOk"] = _vclapi.VclStats_rxIcmpPacketsOk_get
    if _newclass:rxIcmpPacketsOk = property(_vclapi.VclStats_rxIcmpPacketsOk_get)
    __swig_getmethods__["rxIcmpChecksumErrors"] = _vclapi.VclStats_rxIcmpChecksumErrors_get
    if _newclass:rxIcmpChecksumErrors = property(_vclapi.VclStats_rxIcmpChecksumErrors_get)
    __swig_getmethods__["rxPingRequestsOk"] = _vclapi.VclStats_rxPingRequestsOk_get
    if _newclass:rxPingRequestsOk = property(_vclapi.VclStats_rxPingRequestsOk_get)
    __swig_getmethods__["rxPingResponsesOk"] = _vclapi.VclStats_rxPingResponsesOk_get
    if _newclass:rxPingResponsesOk = property(_vclapi.VclStats_rxPingResponsesOk_get)
    __swig_getmethods__["rxIpMulticastPackets"] = _vclapi.VclStats_rxIpMulticastPackets_get
    if _newclass:rxIpMulticastPackets = property(_vclapi.VclStats_rxIpMulticastPackets_get)
    __swig_getmethods__["rxUdpPacketsOk"] = _vclapi.VclStats_rxUdpPacketsOk_get
    if _newclass:rxUdpPacketsOk = property(_vclapi.VclStats_rxUdpPacketsOk_get)
    __swig_getmethods__["rxUdpChecksumErrors"] = _vclapi.VclStats_rxUdpChecksumErrors_get
    if _newclass:rxUdpChecksumErrors = property(_vclapi.VclStats_rxUdpChecksumErrors_get)
    __swig_getmethods__["rxTcpPacketsOk"] = _vclapi.VclStats_rxTcpPacketsOk_get
    if _newclass:rxTcpPacketsOk = property(_vclapi.VclStats_rxTcpPacketsOk_get)
    __swig_getmethods__["rxTcpChecksumErrors"] = _vclapi.VclStats_rxTcpChecksumErrors_get
    if _newclass:rxTcpChecksumErrors = property(_vclapi.VclStats_rxTcpChecksumErrors_get)
    __swig_getmethods__["txArpRequestOkRate"] = _vclapi.VclStats_txArpRequestOkRate_get
    if _newclass:txArpRequestOkRate = property(_vclapi.VclStats_txArpRequestOkRate_get)
    __swig_getmethods__["txArpResponseOkRate"] = _vclapi.VclStats_txArpResponseOkRate_get
    if _newclass:txArpResponseOkRate = property(_vclapi.VclStats_txArpResponseOkRate_get)
    __swig_getmethods__["txDhcpRequestOkRate"] = _vclapi.VclStats_txDhcpRequestOkRate_get
    if _newclass:txDhcpRequestOkRate = property(_vclapi.VclStats_txDhcpRequestOkRate_get)
    __swig_getmethods__["txPingResponseOkRate"] = _vclapi.VclStats_txPingResponseOkRate_get
    if _newclass:txPingResponseOkRate = property(_vclapi.VclStats_txPingResponseOkRate_get)
    __swig_getmethods__["txIpMulticastPacketsRate"] = _vclapi.VclStats_txIpMulticastPacketsRate_get
    if _newclass:txIpMulticastPacketsRate = property(_vclapi.VclStats_txIpMulticastPacketsRate_get)
    __swig_getmethods__["txIpPacketsOkRate"] = _vclapi.VclStats_txIpPacketsOkRate_get
    if _newclass:txIpPacketsOkRate = property(_vclapi.VclStats_txIpPacketsOkRate_get)
    __swig_getmethods__["txIpOctetsOkRate"] = _vclapi.VclStats_txIpOctetsOkRate_get
    if _newclass:txIpOctetsOkRate = property(_vclapi.VclStats_txIpOctetsOkRate_get)
    __swig_getmethods__["txIcmpFramesOkRate"] = _vclapi.VclStats_txIcmpFramesOkRate_get
    if _newclass:txIcmpFramesOkRate = property(_vclapi.VclStats_txIcmpFramesOkRate_get)
    __swig_getmethods__["txUdpFramesOkRate"] = _vclapi.VclStats_txUdpFramesOkRate_get
    if _newclass:txUdpFramesOkRate = property(_vclapi.VclStats_txUdpFramesOkRate_get)
    __swig_getmethods__["txTcpFramesOkRate"] = _vclapi.VclStats_txTcpFramesOkRate_get
    if _newclass:txTcpFramesOkRate = property(_vclapi.VclStats_txTcpFramesOkRate_get)
    __swig_getmethods__["rxArpRequestsRate"] = _vclapi.VclStats_rxArpRequestsRate_get
    if _newclass:rxArpRequestsRate = property(_vclapi.VclStats_rxArpRequestsRate_get)
    __swig_getmethods__["rxArpResponsesRate"] = _vclapi.VclStats_rxArpResponsesRate_get
    if _newclass:rxArpResponsesRate = property(_vclapi.VclStats_rxArpResponsesRate_get)
    __swig_getmethods__["rxDhcpRequestsRate"] = _vclapi.VclStats_rxDhcpRequestsRate_get
    if _newclass:rxDhcpRequestsRate = property(_vclapi.VclStats_rxDhcpRequestsRate_get)
    __swig_getmethods__["rxIpPacketsOkRate"] = _vclapi.VclStats_rxIpPacketsOkRate_get
    if _newclass:rxIpPacketsOkRate = property(_vclapi.VclStats_rxIpPacketsOkRate_get)
    __swig_getmethods__["rxIpChecksumErrorsRate"] = _vclapi.VclStats_rxIpChecksumErrorsRate_get
    if _newclass:rxIpChecksumErrorsRate = property(_vclapi.VclStats_rxIpChecksumErrorsRate_get)
    __swig_getmethods__["rxIpOctetsOkRate"] = _vclapi.VclStats_rxIpOctetsOkRate_get
    if _newclass:rxIpOctetsOkRate = property(_vclapi.VclStats_rxIpOctetsOkRate_get)
    __swig_getmethods__["rxIcmpPacketsOkRate"] = _vclapi.VclStats_rxIcmpPacketsOkRate_get
    if _newclass:rxIcmpPacketsOkRate = property(_vclapi.VclStats_rxIcmpPacketsOkRate_get)
    __swig_getmethods__["rxIcmpChecksumErrorsRate"] = _vclapi.VclStats_rxIcmpChecksumErrorsRate_get
    if _newclass:rxIcmpChecksumErrorsRate = property(_vclapi.VclStats_rxIcmpChecksumErrorsRate_get)
    __swig_getmethods__["rxPingRequestsOkRate"] = _vclapi.VclStats_rxPingRequestsOkRate_get
    if _newclass:rxPingRequestsOkRate = property(_vclapi.VclStats_rxPingRequestsOkRate_get)
    __swig_getmethods__["rxPingResponsesOkRate"] = _vclapi.VclStats_rxPingResponsesOkRate_get
    if _newclass:rxPingResponsesOkRate = property(_vclapi.VclStats_rxPingResponsesOkRate_get)
    __swig_getmethods__["rxIpMulticastPacketsRate"] = _vclapi.VclStats_rxIpMulticastPacketsRate_get
    if _newclass:rxIpMulticastPacketsRate = property(_vclapi.VclStats_rxIpMulticastPacketsRate_get)
    __swig_getmethods__["rxUdpPacketsOkRate"] = _vclapi.VclStats_rxUdpPacketsOkRate_get
    if _newclass:rxUdpPacketsOkRate = property(_vclapi.VclStats_rxUdpPacketsOkRate_get)
    __swig_getmethods__["rxUdpChecksumErrorsRate"] = _vclapi.VclStats_rxUdpChecksumErrorsRate_get
    if _newclass:rxUdpChecksumErrorsRate = property(_vclapi.VclStats_rxUdpChecksumErrorsRate_get)
    __swig_getmethods__["rxTcpPacketsOkRate"] = _vclapi.VclStats_rxTcpPacketsOkRate_get
    if _newclass:rxTcpPacketsOkRate = property(_vclapi.VclStats_rxTcpPacketsOkRate_get)
    __swig_getmethods__["rxTcpChecksumErrorsRate"] = _vclapi.VclStats_rxTcpChecksumErrorsRate_get
    if _newclass:rxTcpChecksumErrorsRate = property(_vclapi.VclStats_rxTcpChecksumErrorsRate_get)
    __swig_getmethods__["txMacAssocRequests"] = _vclapi.VclStats_txMacAssocRequests_get
    if _newclass:txMacAssocRequests = property(_vclapi.VclStats_txMacAssocRequests_get)
    __swig_getmethods__["txMacAssocResponses"] = _vclapi.VclStats_txMacAssocResponses_get
    if _newclass:txMacAssocResponses = property(_vclapi.VclStats_txMacAssocResponses_get)
    __swig_getmethods__["txMacReassocRequests"] = _vclapi.VclStats_txMacReassocRequests_get
    if _newclass:txMacReassocRequests = property(_vclapi.VclStats_txMacReassocRequests_get)
    __swig_getmethods__["txMacReassocResponses"] = _vclapi.VclStats_txMacReassocResponses_get
    if _newclass:txMacReassocResponses = property(_vclapi.VclStats_txMacReassocResponses_get)
    __swig_getmethods__["txMacProbeRequests"] = _vclapi.VclStats_txMacProbeRequests_get
    if _newclass:txMacProbeRequests = property(_vclapi.VclStats_txMacProbeRequests_get)
    __swig_getmethods__["txMacProbeResponses"] = _vclapi.VclStats_txMacProbeResponses_get
    if _newclass:txMacProbeResponses = property(_vclapi.VclStats_txMacProbeResponses_get)
    __swig_getmethods__["txMacBeacon"] = _vclapi.VclStats_txMacBeacon_get
    if _newclass:txMacBeacon = property(_vclapi.VclStats_txMacBeacon_get)
    __swig_getmethods__["txMacAtim"] = _vclapi.VclStats_txMacAtim_get
    if _newclass:txMacAtim = property(_vclapi.VclStats_txMacAtim_get)
    __swig_getmethods__["txMacDisassoc"] = _vclapi.VclStats_txMacDisassoc_get
    if _newclass:txMacDisassoc = property(_vclapi.VclStats_txMacDisassoc_get)
    __swig_getmethods__["txMacAuth"] = _vclapi.VclStats_txMacAuth_get
    if _newclass:txMacAuth = property(_vclapi.VclStats_txMacAuth_get)
    __swig_getmethods__["txMacDeauth"] = _vclapi.VclStats_txMacDeauth_get
    if _newclass:txMacDeauth = property(_vclapi.VclStats_txMacDeauth_get)
    __swig_getmethods__["txMacPsPoll"] = _vclapi.VclStats_txMacPsPoll_get
    if _newclass:txMacPsPoll = property(_vclapi.VclStats_txMacPsPoll_get)
    __swig_getmethods__["txMacRts"] = _vclapi.VclStats_txMacRts_get
    if _newclass:txMacRts = property(_vclapi.VclStats_txMacRts_get)
    __swig_getmethods__["txMacCts"] = _vclapi.VclStats_txMacCts_get
    if _newclass:txMacCts = property(_vclapi.VclStats_txMacCts_get)
    __swig_getmethods__["txMacAck"] = _vclapi.VclStats_txMacAck_get
    if _newclass:txMacAck = property(_vclapi.VclStats_txMacAck_get)
    __swig_getmethods__["txMacCfEnd"] = _vclapi.VclStats_txMacCfEnd_get
    if _newclass:txMacCfEnd = property(_vclapi.VclStats_txMacCfEnd_get)
    __swig_getmethods__["txMacCfEndAck"] = _vclapi.VclStats_txMacCfEndAck_get
    if _newclass:txMacCfEndAck = property(_vclapi.VclStats_txMacCfEndAck_get)
    __swig_getmethods__["txMacData"] = _vclapi.VclStats_txMacData_get
    if _newclass:txMacData = property(_vclapi.VclStats_txMacData_get)
    __swig_getmethods__["txMacDataCfAck"] = _vclapi.VclStats_txMacDataCfAck_get
    if _newclass:txMacDataCfAck = property(_vclapi.VclStats_txMacDataCfAck_get)
    __swig_getmethods__["txMacDataCfPoll"] = _vclapi.VclStats_txMacDataCfPoll_get
    if _newclass:txMacDataCfPoll = property(_vclapi.VclStats_txMacDataCfPoll_get)
    __swig_getmethods__["txMacDataCfAckPoll"] = _vclapi.VclStats_txMacDataCfAckPoll_get
    if _newclass:txMacDataCfAckPoll = property(_vclapi.VclStats_txMacDataCfAckPoll_get)
    __swig_getmethods__["txMacDataNull"] = _vclapi.VclStats_txMacDataNull_get
    if _newclass:txMacDataNull = property(_vclapi.VclStats_txMacDataNull_get)
    __swig_getmethods__["txMacCfAckNull"] = _vclapi.VclStats_txMacCfAckNull_get
    if _newclass:txMacCfAckNull = property(_vclapi.VclStats_txMacCfAckNull_get)
    __swig_getmethods__["txMacCfPollNull"] = _vclapi.VclStats_txMacCfPollNull_get
    if _newclass:txMacCfPollNull = property(_vclapi.VclStats_txMacCfPollNull_get)
    __swig_getmethods__["txMacCfAckPollNull"] = _vclapi.VclStats_txMacCfAckPollNull_get
    if _newclass:txMacCfAckPollNull = property(_vclapi.VclStats_txMacCfAckPollNull_get)
    __swig_getmethods__["rxMacAssocRequests"] = _vclapi.VclStats_rxMacAssocRequests_get
    if _newclass:rxMacAssocRequests = property(_vclapi.VclStats_rxMacAssocRequests_get)
    __swig_getmethods__["rxMacAssocResponses"] = _vclapi.VclStats_rxMacAssocResponses_get
    if _newclass:rxMacAssocResponses = property(_vclapi.VclStats_rxMacAssocResponses_get)
    __swig_getmethods__["rxMacReassocRequests"] = _vclapi.VclStats_rxMacReassocRequests_get
    if _newclass:rxMacReassocRequests = property(_vclapi.VclStats_rxMacReassocRequests_get)
    __swig_getmethods__["rxMacReassocResponses"] = _vclapi.VclStats_rxMacReassocResponses_get
    if _newclass:rxMacReassocResponses = property(_vclapi.VclStats_rxMacReassocResponses_get)
    __swig_getmethods__["rxMacProbeRequests"] = _vclapi.VclStats_rxMacProbeRequests_get
    if _newclass:rxMacProbeRequests = property(_vclapi.VclStats_rxMacProbeRequests_get)
    __swig_getmethods__["rxMacProbeResponses"] = _vclapi.VclStats_rxMacProbeResponses_get
    if _newclass:rxMacProbeResponses = property(_vclapi.VclStats_rxMacProbeResponses_get)
    __swig_getmethods__["rxMacBeacon"] = _vclapi.VclStats_rxMacBeacon_get
    if _newclass:rxMacBeacon = property(_vclapi.VclStats_rxMacBeacon_get)
    __swig_getmethods__["rxMacAtim"] = _vclapi.VclStats_rxMacAtim_get
    if _newclass:rxMacAtim = property(_vclapi.VclStats_rxMacAtim_get)
    __swig_getmethods__["rxMacDisassoc"] = _vclapi.VclStats_rxMacDisassoc_get
    if _newclass:rxMacDisassoc = property(_vclapi.VclStats_rxMacDisassoc_get)
    __swig_getmethods__["rxMacAuth"] = _vclapi.VclStats_rxMacAuth_get
    if _newclass:rxMacAuth = property(_vclapi.VclStats_rxMacAuth_get)
    __swig_getmethods__["rxMacDeauth"] = _vclapi.VclStats_rxMacDeauth_get
    if _newclass:rxMacDeauth = property(_vclapi.VclStats_rxMacDeauth_get)
    __swig_getmethods__["rxMacPsPoll"] = _vclapi.VclStats_rxMacPsPoll_get
    if _newclass:rxMacPsPoll = property(_vclapi.VclStats_rxMacPsPoll_get)
    __swig_getmethods__["rxMacRts"] = _vclapi.VclStats_rxMacRts_get
    if _newclass:rxMacRts = property(_vclapi.VclStats_rxMacRts_get)
    __swig_getmethods__["rxMacCts"] = _vclapi.VclStats_rxMacCts_get
    if _newclass:rxMacCts = property(_vclapi.VclStats_rxMacCts_get)
    __swig_getmethods__["rxMacAck"] = _vclapi.VclStats_rxMacAck_get
    if _newclass:rxMacAck = property(_vclapi.VclStats_rxMacAck_get)
    __swig_getmethods__["rxMacCfEnd"] = _vclapi.VclStats_rxMacCfEnd_get
    if _newclass:rxMacCfEnd = property(_vclapi.VclStats_rxMacCfEnd_get)
    __swig_getmethods__["rxMacCfEndAck"] = _vclapi.VclStats_rxMacCfEndAck_get
    if _newclass:rxMacCfEndAck = property(_vclapi.VclStats_rxMacCfEndAck_get)
    __swig_getmethods__["rxMacData"] = _vclapi.VclStats_rxMacData_get
    if _newclass:rxMacData = property(_vclapi.VclStats_rxMacData_get)
    __swig_getmethods__["rxMacDataCfAck"] = _vclapi.VclStats_rxMacDataCfAck_get
    if _newclass:rxMacDataCfAck = property(_vclapi.VclStats_rxMacDataCfAck_get)
    __swig_getmethods__["rxMacDataCfPoll"] = _vclapi.VclStats_rxMacDataCfPoll_get
    if _newclass:rxMacDataCfPoll = property(_vclapi.VclStats_rxMacDataCfPoll_get)
    __swig_getmethods__["rxMacDataCfAckPoll"] = _vclapi.VclStats_rxMacDataCfAckPoll_get
    if _newclass:rxMacDataCfAckPoll = property(_vclapi.VclStats_rxMacDataCfAckPoll_get)
    __swig_getmethods__["rxMacDataNull"] = _vclapi.VclStats_rxMacDataNull_get
    if _newclass:rxMacDataNull = property(_vclapi.VclStats_rxMacDataNull_get)
    __swig_getmethods__["rxMacCfAckNull"] = _vclapi.VclStats_rxMacCfAckNull_get
    if _newclass:rxMacCfAckNull = property(_vclapi.VclStats_rxMacCfAckNull_get)
    __swig_getmethods__["rxMacCfPollNull"] = _vclapi.VclStats_rxMacCfPollNull_get
    if _newclass:rxMacCfPollNull = property(_vclapi.VclStats_rxMacCfPollNull_get)
    __swig_getmethods__["rxMacCfAckPollNull"] = _vclapi.VclStats_rxMacCfAckPollNull_get
    if _newclass:rxMacCfAckPollNull = property(_vclapi.VclStats_rxMacCfAckPollNull_get)
    __swig_getmethods__["txMacAssocRequestsRate"] = _vclapi.VclStats_txMacAssocRequestsRate_get
    if _newclass:txMacAssocRequestsRate = property(_vclapi.VclStats_txMacAssocRequestsRate_get)
    __swig_getmethods__["txMacAssocResponsesRate"] = _vclapi.VclStats_txMacAssocResponsesRate_get
    if _newclass:txMacAssocResponsesRate = property(_vclapi.VclStats_txMacAssocResponsesRate_get)
    __swig_getmethods__["txMacReassocRequestsRate"] = _vclapi.VclStats_txMacReassocRequestsRate_get
    if _newclass:txMacReassocRequestsRate = property(_vclapi.VclStats_txMacReassocRequestsRate_get)
    __swig_getmethods__["txMacReassocResponsesRate"] = _vclapi.VclStats_txMacReassocResponsesRate_get
    if _newclass:txMacReassocResponsesRate = property(_vclapi.VclStats_txMacReassocResponsesRate_get)
    __swig_getmethods__["txMacProbeRequestsRate"] = _vclapi.VclStats_txMacProbeRequestsRate_get
    if _newclass:txMacProbeRequestsRate = property(_vclapi.VclStats_txMacProbeRequestsRate_get)
    __swig_getmethods__["txMacProbeResponsesRate"] = _vclapi.VclStats_txMacProbeResponsesRate_get
    if _newclass:txMacProbeResponsesRate = property(_vclapi.VclStats_txMacProbeResponsesRate_get)
    __swig_getmethods__["txMacBeaconRate"] = _vclapi.VclStats_txMacBeaconRate_get
    if _newclass:txMacBeaconRate = property(_vclapi.VclStats_txMacBeaconRate_get)
    __swig_getmethods__["txMacAtimRate"] = _vclapi.VclStats_txMacAtimRate_get
    if _newclass:txMacAtimRate = property(_vclapi.VclStats_txMacAtimRate_get)
    __swig_getmethods__["txMacDisassocRate"] = _vclapi.VclStats_txMacDisassocRate_get
    if _newclass:txMacDisassocRate = property(_vclapi.VclStats_txMacDisassocRate_get)
    __swig_getmethods__["txMacAuthRate"] = _vclapi.VclStats_txMacAuthRate_get
    if _newclass:txMacAuthRate = property(_vclapi.VclStats_txMacAuthRate_get)
    __swig_getmethods__["txMacDeauthRate"] = _vclapi.VclStats_txMacDeauthRate_get
    if _newclass:txMacDeauthRate = property(_vclapi.VclStats_txMacDeauthRate_get)
    __swig_getmethods__["txMacPsPollRate"] = _vclapi.VclStats_txMacPsPollRate_get
    if _newclass:txMacPsPollRate = property(_vclapi.VclStats_txMacPsPollRate_get)
    __swig_getmethods__["txMacRtsRate"] = _vclapi.VclStats_txMacRtsRate_get
    if _newclass:txMacRtsRate = property(_vclapi.VclStats_txMacRtsRate_get)
    __swig_getmethods__["txMacCtsRate"] = _vclapi.VclStats_txMacCtsRate_get
    if _newclass:txMacCtsRate = property(_vclapi.VclStats_txMacCtsRate_get)
    __swig_getmethods__["txMacAckRate"] = _vclapi.VclStats_txMacAckRate_get
    if _newclass:txMacAckRate = property(_vclapi.VclStats_txMacAckRate_get)
    __swig_getmethods__["txMacCfEndRate"] = _vclapi.VclStats_txMacCfEndRate_get
    if _newclass:txMacCfEndRate = property(_vclapi.VclStats_txMacCfEndRate_get)
    __swig_getmethods__["txMacCfEndAckRate"] = _vclapi.VclStats_txMacCfEndAckRate_get
    if _newclass:txMacCfEndAckRate = property(_vclapi.VclStats_txMacCfEndAckRate_get)
    __swig_getmethods__["txMacDataRate"] = _vclapi.VclStats_txMacDataRate_get
    if _newclass:txMacDataRate = property(_vclapi.VclStats_txMacDataRate_get)
    __swig_getmethods__["txMacDataCfAckRate"] = _vclapi.VclStats_txMacDataCfAckRate_get
    if _newclass:txMacDataCfAckRate = property(_vclapi.VclStats_txMacDataCfAckRate_get)
    __swig_getmethods__["txMacDataCfPollRate"] = _vclapi.VclStats_txMacDataCfPollRate_get
    if _newclass:txMacDataCfPollRate = property(_vclapi.VclStats_txMacDataCfPollRate_get)
    __swig_getmethods__["txMacDataCfAckPollRate"] = _vclapi.VclStats_txMacDataCfAckPollRate_get
    if _newclass:txMacDataCfAckPollRate = property(_vclapi.VclStats_txMacDataCfAckPollRate_get)
    __swig_getmethods__["txMacDataNullRate"] = _vclapi.VclStats_txMacDataNullRate_get
    if _newclass:txMacDataNullRate = property(_vclapi.VclStats_txMacDataNullRate_get)
    __swig_getmethods__["txMacCfAckNullRate"] = _vclapi.VclStats_txMacCfAckNullRate_get
    if _newclass:txMacCfAckNullRate = property(_vclapi.VclStats_txMacCfAckNullRate_get)
    __swig_getmethods__["txMacCfPollNullRate"] = _vclapi.VclStats_txMacCfPollNullRate_get
    if _newclass:txMacCfPollNullRate = property(_vclapi.VclStats_txMacCfPollNullRate_get)
    __swig_getmethods__["txMacCfAckPollNullRate"] = _vclapi.VclStats_txMacCfAckPollNullRate_get
    if _newclass:txMacCfAckPollNullRate = property(_vclapi.VclStats_txMacCfAckPollNullRate_get)
    __swig_getmethods__["rxMacAssocRequestsRate"] = _vclapi.VclStats_rxMacAssocRequestsRate_get
    if _newclass:rxMacAssocRequestsRate = property(_vclapi.VclStats_rxMacAssocRequestsRate_get)
    __swig_getmethods__["rxMacAssocResponsesRate"] = _vclapi.VclStats_rxMacAssocResponsesRate_get
    if _newclass:rxMacAssocResponsesRate = property(_vclapi.VclStats_rxMacAssocResponsesRate_get)
    __swig_getmethods__["rxMacReassocRequestsRate"] = _vclapi.VclStats_rxMacReassocRequestsRate_get
    if _newclass:rxMacReassocRequestsRate = property(_vclapi.VclStats_rxMacReassocRequestsRate_get)
    __swig_getmethods__["rxMacReassocResponsesRate"] = _vclapi.VclStats_rxMacReassocResponsesRate_get
    if _newclass:rxMacReassocResponsesRate = property(_vclapi.VclStats_rxMacReassocResponsesRate_get)
    __swig_getmethods__["rxMacProbeRequestsRate"] = _vclapi.VclStats_rxMacProbeRequestsRate_get
    if _newclass:rxMacProbeRequestsRate = property(_vclapi.VclStats_rxMacProbeRequestsRate_get)
    __swig_getmethods__["rxMacProbeResponsesRate"] = _vclapi.VclStats_rxMacProbeResponsesRate_get
    if _newclass:rxMacProbeResponsesRate = property(_vclapi.VclStats_rxMacProbeResponsesRate_get)
    __swig_getmethods__["rxMacBeaconRate"] = _vclapi.VclStats_rxMacBeaconRate_get
    if _newclass:rxMacBeaconRate = property(_vclapi.VclStats_rxMacBeaconRate_get)
    __swig_getmethods__["rxMacAtimRate"] = _vclapi.VclStats_rxMacAtimRate_get
    if _newclass:rxMacAtimRate = property(_vclapi.VclStats_rxMacAtimRate_get)
    __swig_getmethods__["rxMacDisassocRate"] = _vclapi.VclStats_rxMacDisassocRate_get
    if _newclass:rxMacDisassocRate = property(_vclapi.VclStats_rxMacDisassocRate_get)
    __swig_getmethods__["rxMacAuthRate"] = _vclapi.VclStats_rxMacAuthRate_get
    if _newclass:rxMacAuthRate = property(_vclapi.VclStats_rxMacAuthRate_get)
    __swig_getmethods__["rxMacDeauthRate"] = _vclapi.VclStats_rxMacDeauthRate_get
    if _newclass:rxMacDeauthRate = property(_vclapi.VclStats_rxMacDeauthRate_get)
    __swig_getmethods__["rxMacPsPollRate"] = _vclapi.VclStats_rxMacPsPollRate_get
    if _newclass:rxMacPsPollRate = property(_vclapi.VclStats_rxMacPsPollRate_get)
    __swig_getmethods__["rxMacRtsRate"] = _vclapi.VclStats_rxMacRtsRate_get
    if _newclass:rxMacRtsRate = property(_vclapi.VclStats_rxMacRtsRate_get)
    __swig_getmethods__["rxMacCtsRate"] = _vclapi.VclStats_rxMacCtsRate_get
    if _newclass:rxMacCtsRate = property(_vclapi.VclStats_rxMacCtsRate_get)
    __swig_getmethods__["rxMacAckRate"] = _vclapi.VclStats_rxMacAckRate_get
    if _newclass:rxMacAckRate = property(_vclapi.VclStats_rxMacAckRate_get)
    __swig_getmethods__["rxMacCfEndRate"] = _vclapi.VclStats_rxMacCfEndRate_get
    if _newclass:rxMacCfEndRate = property(_vclapi.VclStats_rxMacCfEndRate_get)
    __swig_getmethods__["rxMacCfEndAckRate"] = _vclapi.VclStats_rxMacCfEndAckRate_get
    if _newclass:rxMacCfEndAckRate = property(_vclapi.VclStats_rxMacCfEndAckRate_get)
    __swig_getmethods__["rxMacDataRate"] = _vclapi.VclStats_rxMacDataRate_get
    if _newclass:rxMacDataRate = property(_vclapi.VclStats_rxMacDataRate_get)
    __swig_getmethods__["rxMacDataCfAckRate"] = _vclapi.VclStats_rxMacDataCfAckRate_get
    if _newclass:rxMacDataCfAckRate = property(_vclapi.VclStats_rxMacDataCfAckRate_get)
    __swig_getmethods__["rxMacDataCfPollRate"] = _vclapi.VclStats_rxMacDataCfPollRate_get
    if _newclass:rxMacDataCfPollRate = property(_vclapi.VclStats_rxMacDataCfPollRate_get)
    __swig_getmethods__["rxMacDataCfAckPollRate"] = _vclapi.VclStats_rxMacDataCfAckPollRate_get
    if _newclass:rxMacDataCfAckPollRate = property(_vclapi.VclStats_rxMacDataCfAckPollRate_get)
    __swig_getmethods__["rxMacDataNullRate"] = _vclapi.VclStats_rxMacDataNullRate_get
    if _newclass:rxMacDataNullRate = property(_vclapi.VclStats_rxMacDataNullRate_get)
    __swig_getmethods__["rxMacCfAckNullRate"] = _vclapi.VclStats_rxMacCfAckNullRate_get
    if _newclass:rxMacCfAckNullRate = property(_vclapi.VclStats_rxMacCfAckNullRate_get)
    __swig_getmethods__["rxMacCfPollNullRate"] = _vclapi.VclStats_rxMacCfPollNullRate_get
    if _newclass:rxMacCfPollNullRate = property(_vclapi.VclStats_rxMacCfPollNullRate_get)
    __swig_getmethods__["rxMacCfAckPollNullRate"] = _vclapi.VclStats_rxMacCfAckPollNullRate_get
    if _newclass:rxMacCfAckPollNullRate = property(_vclapi.VclStats_rxMacCfAckPollNullRate_get)
    __swig_getmethods__["txMacFrameType"] = _vclapi.VclStats_txMacFrameType_get
    if _newclass:txMacFrameType = property(_vclapi.VclStats_txMacFrameType_get)
    __swig_getmethods__["rxMacFrameType"] = _vclapi.VclStats_rxMacFrameType_get
    if _newclass:rxMacFrameType = property(_vclapi.VclStats_rxMacFrameType_get)
    __swig_getmethods__["txMacFrameTypeRate"] = _vclapi.VclStats_txMacFrameTypeRate_get
    if _newclass:txMacFrameTypeRate = property(_vclapi.VclStats_txMacFrameTypeRate_get)
    __swig_getmethods__["rxMacFrameTypeRate"] = _vclapi.VclStats_rxMacFrameTypeRate_get
    if _newclass:rxMacFrameTypeRate = property(_vclapi.VclStats_rxMacFrameTypeRate_get)
    __swig_getmethods__["txPatternMatchFrames"] = _vclapi.VclStats_txPatternMatchFrames_get
    if _newclass:txPatternMatchFrames = property(_vclapi.VclStats_txPatternMatchFrames_get)
    __swig_getmethods__["txPatternMatchOctets"] = _vclapi.VclStats_txPatternMatchOctets_get
    if _newclass:txPatternMatchOctets = property(_vclapi.VclStats_txPatternMatchOctets_get)
    __swig_getmethods__["rxPatternMatchFrames"] = _vclapi.VclStats_rxPatternMatchFrames_get
    if _newclass:rxPatternMatchFrames = property(_vclapi.VclStats_rxPatternMatchFrames_get)
    __swig_getmethods__["rxPatternMatchOctets"] = _vclapi.VclStats_rxPatternMatchOctets_get
    if _newclass:rxPatternMatchOctets = property(_vclapi.VclStats_rxPatternMatchOctets_get)
    __swig_getmethods__["txPatternMatchFramesRate"] = _vclapi.VclStats_txPatternMatchFramesRate_get
    if _newclass:txPatternMatchFramesRate = property(_vclapi.VclStats_txPatternMatchFramesRate_get)
    __swig_getmethods__["txPatternMatchOctetsRate"] = _vclapi.VclStats_txPatternMatchOctetsRate_get
    if _newclass:txPatternMatchOctetsRate = property(_vclapi.VclStats_txPatternMatchOctetsRate_get)
    __swig_getmethods__["rxPatternMatchFramesRate"] = _vclapi.VclStats_rxPatternMatchFramesRate_get
    if _newclass:rxPatternMatchFramesRate = property(_vclapi.VclStats_rxPatternMatchFramesRate_get)
    __swig_getmethods__["rxPatternMatchOctetsRate"] = _vclapi.VclStats_rxPatternMatchOctetsRate_get
    if _newclass:rxPatternMatchOctetsRate = property(_vclapi.VclStats_rxPatternMatchOctetsRate_get)
    __swig_getmethods__["totalUnicastProbeRequestsSent"] = _vclapi.VclStats_totalUnicastProbeRequestsSent_get
    if _newclass:totalUnicastProbeRequestsSent = property(_vclapi.VclStats_totalUnicastProbeRequestsSent_get)
    __swig_getmethods__["totalUnicastProbeResponsesReceived"] = _vclapi.VclStats_totalUnicastProbeResponsesReceived_get
    if _newclass:totalUnicastProbeResponsesReceived = property(_vclapi.VclStats_totalUnicastProbeResponsesReceived_get)
    __swig_getmethods__["totalBroadcastProbeRequestsSent"] = _vclapi.VclStats_totalBroadcastProbeRequestsSent_get
    if _newclass:totalBroadcastProbeRequestsSent = property(_vclapi.VclStats_totalBroadcastProbeRequestsSent_get)
    __swig_getmethods__["totalBroadcastProbeResponsesReceived"] = _vclapi.VclStats_totalBroadcastProbeResponsesReceived_get
    if _newclass:totalBroadcastProbeResponsesReceived = property(_vclapi.VclStats_totalBroadcastProbeResponsesReceived_get)
    __swig_getmethods__["totalOpenSystemAuthenticationSuccess"] = _vclapi.VclStats_totalOpenSystemAuthenticationSuccess_get
    if _newclass:totalOpenSystemAuthenticationSuccess = property(_vclapi.VclStats_totalOpenSystemAuthenticationSuccess_get)
    __swig_getmethods__["totalOpenSystemAuthenticationFailure"] = _vclapi.VclStats_totalOpenSystemAuthenticationFailure_get
    if _newclass:totalOpenSystemAuthenticationFailure = property(_vclapi.VclStats_totalOpenSystemAuthenticationFailure_get)
    __swig_getmethods__["totalSharedKeyAuthenticationHandshake1Success"] = _vclapi.VclStats_totalSharedKeyAuthenticationHandshake1Success_get
    if _newclass:totalSharedKeyAuthenticationHandshake1Success = property(_vclapi.VclStats_totalSharedKeyAuthenticationHandshake1Success_get)
    __swig_getmethods__["totalSharedKeyAuthenticationHandshake1Failure"] = _vclapi.VclStats_totalSharedKeyAuthenticationHandshake1Failure_get
    if _newclass:totalSharedKeyAuthenticationHandshake1Failure = property(_vclapi.VclStats_totalSharedKeyAuthenticationHandshake1Failure_get)
    __swig_getmethods__["totalSharedKeyAuthenticationHandshake2Success"] = _vclapi.VclStats_totalSharedKeyAuthenticationHandshake2Success_get
    if _newclass:totalSharedKeyAuthenticationHandshake2Success = property(_vclapi.VclStats_totalSharedKeyAuthenticationHandshake2Success_get)
    __swig_getmethods__["totalSharedKeyAuthenticationHandshake2Failure"] = _vclapi.VclStats_totalSharedKeyAuthenticationHandshake2Failure_get
    if _newclass:totalSharedKeyAuthenticationHandshake2Failure = property(_vclapi.VclStats_totalSharedKeyAuthenticationHandshake2Failure_get)
    __swig_getmethods__["totalAssociationHandshakeSuccess"] = _vclapi.VclStats_totalAssociationHandshakeSuccess_get
    if _newclass:totalAssociationHandshakeSuccess = property(_vclapi.VclStats_totalAssociationHandshakeSuccess_get)
    __swig_getmethods__["totalAssociationHandshakeFailure"] = _vclapi.VclStats_totalAssociationHandshakeFailure_get
    if _newclass:totalAssociationHandshakeFailure = property(_vclapi.VclStats_totalAssociationHandshakeFailure_get)
    __swig_getmethods__["totalEAPOLHandshakeSuccess"] = _vclapi.VclStats_totalEAPOLHandshakeSuccess_get
    if _newclass:totalEAPOLHandshakeSuccess = property(_vclapi.VclStats_totalEAPOLHandshakeSuccess_get)
    __swig_getmethods__["totalEAPOLHandshakeFailure"] = _vclapi.VclStats_totalEAPOLHandshakeFailure_get
    if _newclass:totalEAPOLHandshakeFailure = property(_vclapi.VclStats_totalEAPOLHandshakeFailure_get)
    __swig_getmethods__["totalDHCPDiscoverHandshakeSuccess"] = _vclapi.VclStats_totalDHCPDiscoverHandshakeSuccess_get
    if _newclass:totalDHCPDiscoverHandshakeSuccess = property(_vclapi.VclStats_totalDHCPDiscoverHandshakeSuccess_get)
    __swig_getmethods__["totalDHCPDiscoverHandshakeFailure"] = _vclapi.VclStats_totalDHCPDiscoverHandshakeFailure_get
    if _newclass:totalDHCPDiscoverHandshakeFailure = property(_vclapi.VclStats_totalDHCPDiscoverHandshakeFailure_get)
    __swig_getmethods__["totalDHCPRequestHandshakeSuccess"] = _vclapi.VclStats_totalDHCPRequestHandshakeSuccess_get
    if _newclass:totalDHCPRequestHandshakeSuccess = property(_vclapi.VclStats_totalDHCPRequestHandshakeSuccess_get)
    __swig_getmethods__["totalDHCPRequestHandshakeFailure"] = _vclapi.VclStats_totalDHCPRequestHandshakeFailure_get
    if _newclass:totalDHCPRequestHandshakeFailure = property(_vclapi.VclStats_totalDHCPRequestHandshakeFailure_get)
    __swig_getmethods__["totalARPRequestHandshakeSuccess"] = _vclapi.VclStats_totalARPRequestHandshakeSuccess_get
    if _newclass:totalARPRequestHandshakeSuccess = property(_vclapi.VclStats_totalARPRequestHandshakeSuccess_get)
    __swig_getmethods__["totalARPRequestHandshakeFailure"] = _vclapi.VclStats_totalARPRequestHandshakeFailure_get
    if _newclass:totalARPRequestHandshakeFailure = property(_vclapi.VclStats_totalARPRequestHandshakeFailure_get)
    __swig_getmethods__["totalPingRequestsReceived"] = _vclapi.VclStats_totalPingRequestsReceived_get
    if _newclass:totalPingRequestsReceived = property(_vclapi.VclStats_totalPingRequestsReceived_get)
    __swig_getmethods__["totalPingResponsesSent"] = _vclapi.VclStats_totalPingResponsesSent_get
    if _newclass:totalPingResponsesSent = property(_vclapi.VclStats_totalPingResponsesSent_get)
    __swig_getmethods__["totalARPRequestsReceived"] = _vclapi.VclStats_totalARPRequestsReceived_get
    if _newclass:totalARPRequestsReceived = property(_vclapi.VclStats_totalARPRequestsReceived_get)
    __swig_getmethods__["totalARPResponsesSent"] = _vclapi.VclStats_totalARPResponsesSent_get
    if _newclass:totalARPResponsesSent = property(_vclapi.VclStats_totalARPResponsesSent_get)
    __swig_getmethods__["countOfActiveClients"] = _vclapi.VclStats_countOfActiveClients_get
    if _newclass:countOfActiveClients = property(_vclapi.VclStats_countOfActiveClients_get)
    __swig_getmethods__["countOfActiveFlows"] = _vclapi.VclStats_countOfActiveFlows_get
    if _newclass:countOfActiveFlows = property(_vclapi.VclStats_countOfActiveFlows_get)
    __swig_getmethods__["countOf80211AuthenticatedClients"] = _vclapi.VclStats_countOf80211AuthenticatedClients_get
    if _newclass:countOf80211AuthenticatedClients = property(_vclapi.VclStats_countOf80211AuthenticatedClients_get)
    __swig_getmethods__["countOf80211AssociatedClients"] = _vclapi.VclStats_countOf80211AssociatedClients_get
    if _newclass:countOf80211AssociatedClients = property(_vclapi.VclStats_countOf80211AssociatedClients_get)
    __swig_getmethods__["countOf8021xAuthenticatedClients"] = _vclapi.VclStats_countOf8021xAuthenticatedClients_get
    if _newclass:countOf8021xAuthenticatedClients = property(_vclapi.VclStats_countOf8021xAuthenticatedClients_get)
    __swig_getmethods__["countOfDeauthenticatedClients"] = _vclapi.VclStats_countOfDeauthenticatedClients_get
    if _newclass:countOfDeauthenticatedClients = property(_vclapi.VclStats_countOfDeauthenticatedClients_get)
    __swig_getmethods__["countOfDisassociatedClients"] = _vclapi.VclStats_countOfDisassociatedClients_get
    if _newclass:countOfDisassociatedClients = property(_vclapi.VclStats_countOfDisassociatedClients_get)
    __swig_getmethods__["countOfReauthenticatedClients"] = _vclapi.VclStats_countOfReauthenticatedClients_get
    if _newclass:countOfReauthenticatedClients = property(_vclapi.VclStats_countOfReauthenticatedClients_get)
    __swig_getmethods__["totalUnicastProbeRequestsSentRate"] = _vclapi.VclStats_totalUnicastProbeRequestsSentRate_get
    if _newclass:totalUnicastProbeRequestsSentRate = property(_vclapi.VclStats_totalUnicastProbeRequestsSentRate_get)
    __swig_getmethods__["totalUnicastProbeResponsesReceivedRate"] = _vclapi.VclStats_totalUnicastProbeResponsesReceivedRate_get
    if _newclass:totalUnicastProbeResponsesReceivedRate = property(_vclapi.VclStats_totalUnicastProbeResponsesReceivedRate_get)
    __swig_getmethods__["totalBroadcastProbeRequestsSentRate"] = _vclapi.VclStats_totalBroadcastProbeRequestsSentRate_get
    if _newclass:totalBroadcastProbeRequestsSentRate = property(_vclapi.VclStats_totalBroadcastProbeRequestsSentRate_get)
    __swig_getmethods__["totalBroadcastProbeResponsesReceivedRate"] = _vclapi.VclStats_totalBroadcastProbeResponsesReceivedRate_get
    if _newclass:totalBroadcastProbeResponsesReceivedRate = property(_vclapi.VclStats_totalBroadcastProbeResponsesReceivedRate_get)
    __swig_getmethods__["totalOpenSystemAuthenticationSuccessRate"] = _vclapi.VclStats_totalOpenSystemAuthenticationSuccessRate_get
    if _newclass:totalOpenSystemAuthenticationSuccessRate = property(_vclapi.VclStats_totalOpenSystemAuthenticationSuccessRate_get)
    __swig_getmethods__["totalOpenSystemAuthenticationFailureRate"] = _vclapi.VclStats_totalOpenSystemAuthenticationFailureRate_get
    if _newclass:totalOpenSystemAuthenticationFailureRate = property(_vclapi.VclStats_totalOpenSystemAuthenticationFailureRate_get)
    __swig_getmethods__["totalSharedKeyAuthenticationHandshake1SuccessRate"] = _vclapi.VclStats_totalSharedKeyAuthenticationHandshake1SuccessRate_get
    if _newclass:totalSharedKeyAuthenticationHandshake1SuccessRate = property(_vclapi.VclStats_totalSharedKeyAuthenticationHandshake1SuccessRate_get)
    __swig_getmethods__["totalSharedKeyAuthenticationHandshake1FailureRate"] = _vclapi.VclStats_totalSharedKeyAuthenticationHandshake1FailureRate_get
    if _newclass:totalSharedKeyAuthenticationHandshake1FailureRate = property(_vclapi.VclStats_totalSharedKeyAuthenticationHandshake1FailureRate_get)
    __swig_getmethods__["totalSharedKeyAuthenticationHandshake2SuccessRate"] = _vclapi.VclStats_totalSharedKeyAuthenticationHandshake2SuccessRate_get
    if _newclass:totalSharedKeyAuthenticationHandshake2SuccessRate = property(_vclapi.VclStats_totalSharedKeyAuthenticationHandshake2SuccessRate_get)
    __swig_getmethods__["totalSharedKeyAuthenticationHandshake2FailureRate"] = _vclapi.VclStats_totalSharedKeyAuthenticationHandshake2FailureRate_get
    if _newclass:totalSharedKeyAuthenticationHandshake2FailureRate = property(_vclapi.VclStats_totalSharedKeyAuthenticationHandshake2FailureRate_get)
    __swig_getmethods__["totalAssociationHandshakeSuccessRate"] = _vclapi.VclStats_totalAssociationHandshakeSuccessRate_get
    if _newclass:totalAssociationHandshakeSuccessRate = property(_vclapi.VclStats_totalAssociationHandshakeSuccessRate_get)
    __swig_getmethods__["totalAssociationHandshakeFailureRate"] = _vclapi.VclStats_totalAssociationHandshakeFailureRate_get
    if _newclass:totalAssociationHandshakeFailureRate = property(_vclapi.VclStats_totalAssociationHandshakeFailureRate_get)
    __swig_getmethods__["totalEAPOLHandshakeSuccessRate"] = _vclapi.VclStats_totalEAPOLHandshakeSuccessRate_get
    if _newclass:totalEAPOLHandshakeSuccessRate = property(_vclapi.VclStats_totalEAPOLHandshakeSuccessRate_get)
    __swig_getmethods__["totalEAPOLHandshakeFailureRate"] = _vclapi.VclStats_totalEAPOLHandshakeFailureRate_get
    if _newclass:totalEAPOLHandshakeFailureRate = property(_vclapi.VclStats_totalEAPOLHandshakeFailureRate_get)
    __swig_getmethods__["totalDHCPDiscoverHandshakeSuccessRate"] = _vclapi.VclStats_totalDHCPDiscoverHandshakeSuccessRate_get
    if _newclass:totalDHCPDiscoverHandshakeSuccessRate = property(_vclapi.VclStats_totalDHCPDiscoverHandshakeSuccessRate_get)
    __swig_getmethods__["totalDHCPDiscoverHandshakeFailureRate"] = _vclapi.VclStats_totalDHCPDiscoverHandshakeFailureRate_get
    if _newclass:totalDHCPDiscoverHandshakeFailureRate = property(_vclapi.VclStats_totalDHCPDiscoverHandshakeFailureRate_get)
    __swig_getmethods__["totalDHCPRequestHandshakeSuccessRate"] = _vclapi.VclStats_totalDHCPRequestHandshakeSuccessRate_get
    if _newclass:totalDHCPRequestHandshakeSuccessRate = property(_vclapi.VclStats_totalDHCPRequestHandshakeSuccessRate_get)
    __swig_getmethods__["totalDHCPRequestHandshakeFailureRate"] = _vclapi.VclStats_totalDHCPRequestHandshakeFailureRate_get
    if _newclass:totalDHCPRequestHandshakeFailureRate = property(_vclapi.VclStats_totalDHCPRequestHandshakeFailureRate_get)
    __swig_getmethods__["totalARPRequestHandshakeSuccessRate"] = _vclapi.VclStats_totalARPRequestHandshakeSuccessRate_get
    if _newclass:totalARPRequestHandshakeSuccessRate = property(_vclapi.VclStats_totalARPRequestHandshakeSuccessRate_get)
    __swig_getmethods__["totalARPRequestHandshakeFailureRate"] = _vclapi.VclStats_totalARPRequestHandshakeFailureRate_get
    if _newclass:totalARPRequestHandshakeFailureRate = property(_vclapi.VclStats_totalARPRequestHandshakeFailureRate_get)
    __swig_getmethods__["totalPingRequestsReceivedRate"] = _vclapi.VclStats_totalPingRequestsReceivedRate_get
    if _newclass:totalPingRequestsReceivedRate = property(_vclapi.VclStats_totalPingRequestsReceivedRate_get)
    __swig_getmethods__["totalPingResponsesSentRate"] = _vclapi.VclStats_totalPingResponsesSentRate_get
    if _newclass:totalPingResponsesSentRate = property(_vclapi.VclStats_totalPingResponsesSentRate_get)
    __swig_getmethods__["totalARPRequestsReceivedRate"] = _vclapi.VclStats_totalARPRequestsReceivedRate_get
    if _newclass:totalARPRequestsReceivedRate = property(_vclapi.VclStats_totalARPRequestsReceivedRate_get)
    __swig_getmethods__["totalARPResponsesSentRate"] = _vclapi.VclStats_totalARPResponsesSentRate_get
    if _newclass:totalARPResponsesSentRate = property(_vclapi.VclStats_totalARPResponsesSentRate_get)
    __swig_getmethods__["countOfActiveClientsRate"] = _vclapi.VclStats_countOfActiveClientsRate_get
    if _newclass:countOfActiveClientsRate = property(_vclapi.VclStats_countOfActiveClientsRate_get)
    __swig_getmethods__["countOfActiveFlowsRate"] = _vclapi.VclStats_countOfActiveFlowsRate_get
    if _newclass:countOfActiveFlowsRate = property(_vclapi.VclStats_countOfActiveFlowsRate_get)
    __swig_getmethods__["countOf80211AuthenticatedClientsRate"] = _vclapi.VclStats_countOf80211AuthenticatedClientsRate_get
    if _newclass:countOf80211AuthenticatedClientsRate = property(_vclapi.VclStats_countOf80211AuthenticatedClientsRate_get)
    __swig_getmethods__["countOf80211AssociatedClientsRate"] = _vclapi.VclStats_countOf80211AssociatedClientsRate_get
    if _newclass:countOf80211AssociatedClientsRate = property(_vclapi.VclStats_countOf80211AssociatedClientsRate_get)
    __swig_getmethods__["countOf8021xAuthenticatedClientsRate"] = _vclapi.VclStats_countOf8021xAuthenticatedClientsRate_get
    if _newclass:countOf8021xAuthenticatedClientsRate = property(_vclapi.VclStats_countOf8021xAuthenticatedClientsRate_get)
    __swig_getmethods__["countOfDeauthenticatedClientsRate"] = _vclapi.VclStats_countOfDeauthenticatedClientsRate_get
    if _newclass:countOfDeauthenticatedClientsRate = property(_vclapi.VclStats_countOfDeauthenticatedClientsRate_get)
    __swig_getmethods__["countOfDisassociatedClientsRate"] = _vclapi.VclStats_countOfDisassociatedClientsRate_get
    if _newclass:countOfDisassociatedClientsRate = property(_vclapi.VclStats_countOfDisassociatedClientsRate_get)
    __swig_getmethods__["countOfReauthenticatedClientsRate"] = _vclapi.VclStats_countOfReauthenticatedClientsRate_get
    if _newclass:countOfReauthenticatedClientsRate = property(_vclapi.VclStats_countOfReauthenticatedClientsRate_get)
    def __init__(self, *args):
        _swig_setattr(self, VclStats, 'this', _vclapi.new_VclStats(*args))
        _swig_setattr(self, VclStats, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclStats):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclStatsPtr(VclStats):
    def __init__(self, this):
        _swig_setattr(self, VclStats, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclStats, 'thisown', 0)
        _swig_setattr(self, VclStats,self.__class__,VclStats)
_vclapi.VclStats_swigregister(VclStatsPtr)

class VclStatsClient(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclStatsClient, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclStatsClient, name)
    def __repr__(self):
        return "<C VclStatsClient instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclStatsClient_setDefaults(*args)
    def read(*args): return _vclapi.VclStatsClient_read(*args)
    def resetAll(*args): return _vclapi.VclStatsClient_resetAll(*args)
    def getProbeHandshakesPerformed(*args): return _vclapi.VclStatsClient_getProbeHandshakesPerformed(*args)
    def getProbeHandshakeRetryCount(*args): return _vclapi.VclStatsClient_getProbeHandshakeRetryCount(*args)
    def getSuccessfulAuthenticationHandshakes(*args): return _vclapi.VclStatsClient_getSuccessfulAuthenticationHandshakes(*args)
    def getFailedAuthenticationHandshakes(*args): return _vclapi.VclStatsClient_getFailedAuthenticationHandshakes(*args)
    def getAuthenticationHandshakeRetryCount(*args): return _vclapi.VclStatsClient_getAuthenticationHandshakeRetryCount(*args)
    def getSuccessfulAssociationHandshakes(*args): return _vclapi.VclStatsClient_getSuccessfulAssociationHandshakes(*args)
    def getFailedAssociationHandshakes(*args): return _vclapi.VclStatsClient_getFailedAssociationHandshakes(*args)
    def getAssociationHandshakeRetryCount(*args): return _vclapi.VclStatsClient_getAssociationHandshakeRetryCount(*args)
    def getSuccessfulDhcpHandshakes(*args): return _vclapi.VclStatsClient_getSuccessfulDhcpHandshakes(*args)
    def getFailedDhcpHandshakes(*args): return _vclapi.VclStatsClient_getFailedDhcpHandshakes(*args)
    def getDhcpHandshakeRetryCount(*args): return _vclapi.VclStatsClient_getDhcpHandshakeRetryCount(*args)
    def getSuccessfulArpHandshakes(*args): return _vclapi.VclStatsClient_getSuccessfulArpHandshakes(*args)
    def getFailedArpHandshakes(*args): return _vclapi.VclStatsClient_getFailedArpHandshakes(*args)
    def getArpHandshakeRetryCount(*args): return _vclapi.VclStatsClient_getArpHandshakeRetryCount(*args)
    def getPhyBitRateOfLast80211DataPacketReceived(*args): return _vclapi.VclStatsClient_getPhyBitRateOfLast80211DataPacketReceived(*args)
    def getPhyBitRateOfLast80211ManagementPacketReceived(*args): return _vclapi.VclStatsClient_getPhyBitRateOfLast80211ManagementPacketReceived(*args)
    def getRssiOfLast80211DataPacketReceived(*args): return _vclapi.VclStatsClient_getRssiOfLast80211DataPacketReceived(*args)
    def getRssiOfLast80211ManagementPacketReceived(*args): return _vclapi.VclStatsClient_getRssiOfLast80211ManagementPacketReceived(*args)
    def getSharedKeyAuthenticationHandshake2Failure(*args): return _vclapi.VclStatsClient_getSharedKeyAuthenticationHandshake2Failure(*args)
    def getReceivedPingRequests(*args): return _vclapi.VclStatsClient_getReceivedPingRequests(*args)
    def getTransmittedPingResponses(*args): return _vclapi.VclStatsClient_getTransmittedPingResponses(*args)
    def getReceivedDeauthenticationPackets(*args): return _vclapi.VclStatsClient_getReceivedDeauthenticationPackets(*args)
    def getReceivedDisassociationPackets(*args): return _vclapi.VclStatsClient_getReceivedDisassociationPackets(*args)
    def getLastReasonCode(*args): return _vclapi.VclStatsClient_getLastReasonCode(*args)
    def getLastStatusCode(*args): return _vclapi.VclStatsClient_getLastStatusCode(*args)
    def getTxMcAssociationStartTime(*args): return _vclapi.VclStatsClient_getTxMcAssociationStartTime(*args)
    def getRxMcAssociationEndTime(*args): return _vclapi.VclStatsClient_getRxMcAssociationEndTime(*args)
    def getRxMcDeauthDisassocTime(*args): return _vclapi.VclStatsClient_getRxMcDeauthDisassocTime(*args)
    def getTxMcStartTime(*args): return _vclapi.VclStatsClient_getTxMcStartTime(*args)
    def getTxMcEndTime(*args): return _vclapi.VclStatsClient_getTxMcEndTime(*args)
    def getRxMcStartTime(*args): return _vclapi.VclStatsClient_getRxMcStartTime(*args)
    def getRxMcEndTime(*args): return _vclapi.VclStatsClient_getRxMcEndTime(*args)
    def getTgaProcessingTime(*args): return _vclapi.VclStatsClient_getTgaProcessingTime(*args)
    def getTstampProbeRsp(*args): return _vclapi.VclStatsClient_getTstampProbeRsp(*args)
    def getTstampAuth1Rsp(*args): return _vclapi.VclStatsClient_getTstampAuth1Rsp(*args)
    def getTstampAuth2Rsp(*args): return _vclapi.VclStatsClient_getTstampAuth2Rsp(*args)
    def getTstampEapReqIdentity(*args): return _vclapi.VclStatsClient_getTstampEapReqIdentity(*args)
    def getTstampEapSuccessOrFailure(*args): return _vclapi.VclStatsClient_getTstampEapSuccessOrFailure(*args)
    def getTstampEapolPairwiseKey(*args): return _vclapi.VclStatsClient_getTstampEapolPairwiseKey(*args)
    def getTstampEapolGroupKey(*args): return _vclapi.VclStatsClient_getTstampEapolGroupKey(*args)
    def getTstampMcConnectionComplete(*args): return _vclapi.VclStatsClient_getTstampMcConnectionComplete(*args)
    def getTstampAuth1Req(*args): return _vclapi.VclStatsClient_getTstampAuth1Req(*args)
    def getTstampAuth2Req(*args): return _vclapi.VclStatsClient_getTstampAuth2Req(*args)
    def getTstampAssocReq(*args): return _vclapi.VclStatsClient_getTstampAssocReq(*args)
    def getTstampAssocRsp(*args): return _vclapi.VclStatsClient_getTstampAssocRsp(*args)
    def getTstampEapRspIdentity(*args): return _vclapi.VclStatsClient_getTstampEapRspIdentity(*args)
    def getTstampDhcpDiscover(*args): return _vclapi.VclStatsClient_getTstampDhcpDiscover(*args)
    def getTstampDhcpOffer(*args): return _vclapi.VclStatsClient_getTstampDhcpOffer(*args)
    def getTstampDhcpRequest(*args): return _vclapi.VclStatsClient_getTstampDhcpRequest(*args)
    def getTstampDhcpAck(*args): return _vclapi.VclStatsClient_getTstampDhcpAck(*args)
    def getTxPerTidFramesOk(*args): return _vclapi.VclStatsClient_getTxPerTidFramesOk(*args)
    def getTxPerTidFramesErrors(*args): return _vclapi.VclStatsClient_getTxPerTidFramesErrors(*args)
    def getTxPerTidOctetsOk(*args): return _vclapi.VclStatsClient_getTxPerTidOctetsOk(*args)
    def getTxPerTidPacketQueueDelayMin(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayMin(*args)
    def getTxPerTidPacketQueueDelayMax(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayMax(*args)
    def getTxPerTidPacketQueueDelaySum(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelaySum(*args)
    def getTxPerTidPacketQueueDelayTotal(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayTotal(*args)
    def getTxPerTidPacketQueueDelayBucket(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayBucket(*args)
    def getTxPerTidPacketQueueDelayBucketTid1(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayBucketTid1(*args)
    def getTxPerTidPacketQueueDelayBucketTid2(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayBucketTid2(*args)
    def getTxPerTidPacketQueueDelayBucketTid3(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayBucketTid3(*args)
    def getTxPerTidPacketQueueDelayBucketTid4(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayBucketTid4(*args)
    def getTxPerTidPacketQueueDelayBucketTid5(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayBucketTid5(*args)
    def getTxPerTidPacketQueueDelayBucketTid6(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayBucketTid6(*args)
    def getTxPerTidPacketQueueDelayBucketTid7(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayBucketTid7(*args)
    def getTxPerTidPacketQueueDelayBucketTid8(*args): return _vclapi.VclStatsClient_getTxPerTidPacketQueueDelayBucketTid8(*args)
    def getTxPerAcFramesOk(*args): return _vclapi.VclStatsClient_getTxPerAcFramesOk(*args)
    def getTxPerAcFramesErrors(*args): return _vclapi.VclStatsClient_getTxPerAcFramesErrors(*args)
    def getTxPerAcOctetsOk(*args): return _vclapi.VclStatsClient_getTxPerAcOctetsOk(*args)
    def getTxPerAcPacketQueueDelayMin(*args): return _vclapi.VclStatsClient_getTxPerAcPacketQueueDelayMin(*args)
    def getTxPerAcPacketQueueDelayMax(*args): return _vclapi.VclStatsClient_getTxPerAcPacketQueueDelayMax(*args)
    def getTxPerAcPacketQueueDelaySum(*args): return _vclapi.VclStatsClient_getTxPerAcPacketQueueDelaySum(*args)
    def getTxPerAcPacketQueueDelayTotal(*args): return _vclapi.VclStatsClient_getTxPerAcPacketQueueDelayTotal(*args)
    def getTxPerAcPacketMediaDelaySum(*args): return _vclapi.VclStatsClient_getTxPerAcPacketMediaDelaySum(*args)
    def getTxPerAcPacketMediaDelayTotal(*args): return _vclapi.VclStatsClient_getTxPerAcPacketMediaDelayTotal(*args)
    def getTxPerAcPacketQueueDelayBucket(*args): return _vclapi.VclStatsClient_getTxPerAcPacketQueueDelayBucket(*args)
    def getTxPerAcPacketQueueDelayBucketAc1(*args): return _vclapi.VclStatsClient_getTxPerAcPacketQueueDelayBucketAc1(*args)
    def getTxPerAcPacketQueueDelayBucketAc2(*args): return _vclapi.VclStatsClient_getTxPerAcPacketQueueDelayBucketAc2(*args)
    def getTxPerAcPacketQueueDelayBucketAc3(*args): return _vclapi.VclStatsClient_getTxPerAcPacketQueueDelayBucketAc3(*args)
    def getTxPerAcPacketQueueDelayBucketAc4(*args): return _vclapi.VclStatsClient_getTxPerAcPacketQueueDelayBucketAc4(*args)
    def getRxPerTidFramesOk(*args): return _vclapi.VclStatsClient_getRxPerTidFramesOk(*args)
    def getRxPerTidOctetsOk(*args): return _vclapi.VclStatsClient_getRxPerTidOctetsOk(*args)
    def getRxPerTidPacketQueueDelayMin(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayMin(*args)
    def getRxPerTidPacketQueueDelayMax(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayMax(*args)
    def getRxPerTidPacketQueueDelaySum(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelaySum(*args)
    def getRxPerTidPacketQueueDelayTotal(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayTotal(*args)
    def getRxPerTidPacketQueueDelayBucket(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayBucket(*args)
    def getRxPerTidPacketQueueDelayBucketTid1(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayBucketTid1(*args)
    def getRxPerTidPacketQueueDelayBucketTid2(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayBucketTid2(*args)
    def getRxPerTidPacketQueueDelayBucketTid3(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayBucketTid3(*args)
    def getRxPerTidPacketQueueDelayBucketTid4(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayBucketTid4(*args)
    def getRxPerTidPacketQueueDelayBucketTid5(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayBucketTid5(*args)
    def getRxPerTidPacketQueueDelayBucketTid6(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayBucketTid6(*args)
    def getRxPerTidPacketQueueDelayBucketTid7(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayBucketTid7(*args)
    def getRxPerTidPacketQueueDelayBucketTid8(*args): return _vclapi.VclStatsClient_getRxPerTidPacketQueueDelayBucketTid8(*args)
    def getTxPerUserPriFramesOk(*args): return _vclapi.VclStatsClient_getTxPerUserPriFramesOk(*args)
    def getTxPerUserPriFramesErrors(*args): return _vclapi.VclStatsClient_getTxPerUserPriFramesErrors(*args)
    def getTxPerUserPriOctetsOk(*args): return _vclapi.VclStatsClient_getTxPerUserPriOctetsOk(*args)
    def getRxPerUserPriFramesOk(*args): return _vclapi.VclStatsClient_getRxPerUserPriFramesOk(*args)
    def getRxPerUserPriOctetsOk(*args): return _vclapi.VclStatsClient_getRxPerUserPriOctetsOk(*args)
    def getRxPerUserPriFrameLatencyMin(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyMin(*args)
    def getRxPerUserPriFrameLatencyMax(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyMax(*args)
    def getRxPerUserPriFrameLatencySum(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencySum(*args)
    def getRxPerUserPriFrameTotal(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameTotal(*args)
    def getRxPerUserPriFrameLatencyBucket(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyBucket(*args)
    def getRxPerUserPriFrameLatencyBucketUp1(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyBucketUp1(*args)
    def getRxPerUserPriFrameLatencyBucketUp2(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyBucketUp2(*args)
    def getRxPerUserPriFrameLatencyBucketUp3(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyBucketUp3(*args)
    def getRxPerUserPriFrameLatencyBucketUp4(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyBucketUp4(*args)
    def getRxPerUserPriFrameLatencyBucketUp5(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyBucketUp5(*args)
    def getRxPerUserPriFrameLatencyBucketUp6(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyBucketUp6(*args)
    def getRxPerUserPriFrameLatencyBucketUp7(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyBucketUp7(*args)
    def getRxPerUserPriFrameLatencyBucketUp8(*args): return _vclapi.VclStatsClient_getRxPerUserPriFrameLatencyBucketUp8(*args)
    __swig_getmethods__["probeHandshakesPerformed"] = _vclapi.VclStatsClient_probeHandshakesPerformed_get
    if _newclass:probeHandshakesPerformed = property(_vclapi.VclStatsClient_probeHandshakesPerformed_get)
    __swig_getmethods__["probeHandshakeRetryCount"] = _vclapi.VclStatsClient_probeHandshakeRetryCount_get
    if _newclass:probeHandshakeRetryCount = property(_vclapi.VclStatsClient_probeHandshakeRetryCount_get)
    __swig_getmethods__["successfulAuthenticationHandshakes"] = _vclapi.VclStatsClient_successfulAuthenticationHandshakes_get
    if _newclass:successfulAuthenticationHandshakes = property(_vclapi.VclStatsClient_successfulAuthenticationHandshakes_get)
    __swig_getmethods__["failedAuthenticationHandshakes"] = _vclapi.VclStatsClient_failedAuthenticationHandshakes_get
    if _newclass:failedAuthenticationHandshakes = property(_vclapi.VclStatsClient_failedAuthenticationHandshakes_get)
    __swig_getmethods__["authenticationHandshakeRetryCount"] = _vclapi.VclStatsClient_authenticationHandshakeRetryCount_get
    if _newclass:authenticationHandshakeRetryCount = property(_vclapi.VclStatsClient_authenticationHandshakeRetryCount_get)
    __swig_getmethods__["successfulAssociationHandshakes"] = _vclapi.VclStatsClient_successfulAssociationHandshakes_get
    if _newclass:successfulAssociationHandshakes = property(_vclapi.VclStatsClient_successfulAssociationHandshakes_get)
    __swig_getmethods__["failedAssociationHandshakes"] = _vclapi.VclStatsClient_failedAssociationHandshakes_get
    if _newclass:failedAssociationHandshakes = property(_vclapi.VclStatsClient_failedAssociationHandshakes_get)
    __swig_getmethods__["associationHandshakeRetryCount"] = _vclapi.VclStatsClient_associationHandshakeRetryCount_get
    if _newclass:associationHandshakeRetryCount = property(_vclapi.VclStatsClient_associationHandshakeRetryCount_get)
    __swig_getmethods__["successfulDhcpHandshakes"] = _vclapi.VclStatsClient_successfulDhcpHandshakes_get
    if _newclass:successfulDhcpHandshakes = property(_vclapi.VclStatsClient_successfulDhcpHandshakes_get)
    __swig_getmethods__["failedDhcpHandshakes"] = _vclapi.VclStatsClient_failedDhcpHandshakes_get
    if _newclass:failedDhcpHandshakes = property(_vclapi.VclStatsClient_failedDhcpHandshakes_get)
    __swig_getmethods__["dhcpHandshakeRetryCount"] = _vclapi.VclStatsClient_dhcpHandshakeRetryCount_get
    if _newclass:dhcpHandshakeRetryCount = property(_vclapi.VclStatsClient_dhcpHandshakeRetryCount_get)
    __swig_getmethods__["successfulArpHandshakes"] = _vclapi.VclStatsClient_successfulArpHandshakes_get
    if _newclass:successfulArpHandshakes = property(_vclapi.VclStatsClient_successfulArpHandshakes_get)
    __swig_getmethods__["failedArpHandshakes"] = _vclapi.VclStatsClient_failedArpHandshakes_get
    if _newclass:failedArpHandshakes = property(_vclapi.VclStatsClient_failedArpHandshakes_get)
    __swig_getmethods__["arpHandshakeRetryCount"] = _vclapi.VclStatsClient_arpHandshakeRetryCount_get
    if _newclass:arpHandshakeRetryCount = property(_vclapi.VclStatsClient_arpHandshakeRetryCount_get)
    __swig_getmethods__["phyBitRateOfLast80211DataPacketReceived"] = _vclapi.VclStatsClient_phyBitRateOfLast80211DataPacketReceived_get
    if _newclass:phyBitRateOfLast80211DataPacketReceived = property(_vclapi.VclStatsClient_phyBitRateOfLast80211DataPacketReceived_get)
    __swig_getmethods__["phyBitRateOfLast80211ManagementPacketReceived"] = _vclapi.VclStatsClient_phyBitRateOfLast80211ManagementPacketReceived_get
    if _newclass:phyBitRateOfLast80211ManagementPacketReceived = property(_vclapi.VclStatsClient_phyBitRateOfLast80211ManagementPacketReceived_get)
    __swig_getmethods__["rssiOfLast80211DataPacketReceived"] = _vclapi.VclStatsClient_rssiOfLast80211DataPacketReceived_get
    if _newclass:rssiOfLast80211DataPacketReceived = property(_vclapi.VclStatsClient_rssiOfLast80211DataPacketReceived_get)
    __swig_getmethods__["rssiOfLast80211ManagementPacketReceived"] = _vclapi.VclStatsClient_rssiOfLast80211ManagementPacketReceived_get
    if _newclass:rssiOfLast80211ManagementPacketReceived = property(_vclapi.VclStatsClient_rssiOfLast80211ManagementPacketReceived_get)
    __swig_getmethods__["sharedKeyAuthenticationHandshake2Failure"] = _vclapi.VclStatsClient_sharedKeyAuthenticationHandshake2Failure_get
    if _newclass:sharedKeyAuthenticationHandshake2Failure = property(_vclapi.VclStatsClient_sharedKeyAuthenticationHandshake2Failure_get)
    __swig_getmethods__["receivedPingRequests"] = _vclapi.VclStatsClient_receivedPingRequests_get
    if _newclass:receivedPingRequests = property(_vclapi.VclStatsClient_receivedPingRequests_get)
    __swig_getmethods__["transmittedPingResponses"] = _vclapi.VclStatsClient_transmittedPingResponses_get
    if _newclass:transmittedPingResponses = property(_vclapi.VclStatsClient_transmittedPingResponses_get)
    __swig_getmethods__["receivedDeauthenticationPackets"] = _vclapi.VclStatsClient_receivedDeauthenticationPackets_get
    if _newclass:receivedDeauthenticationPackets = property(_vclapi.VclStatsClient_receivedDeauthenticationPackets_get)
    __swig_getmethods__["receivedDisassociationPackets"] = _vclapi.VclStatsClient_receivedDisassociationPackets_get
    if _newclass:receivedDisassociationPackets = property(_vclapi.VclStatsClient_receivedDisassociationPackets_get)
    __swig_getmethods__["lastReasonCode"] = _vclapi.VclStatsClient_lastReasonCode_get
    if _newclass:lastReasonCode = property(_vclapi.VclStatsClient_lastReasonCode_get)
    __swig_getmethods__["lastStatusCode"] = _vclapi.VclStatsClient_lastStatusCode_get
    if _newclass:lastStatusCode = property(_vclapi.VclStatsClient_lastStatusCode_get)
    __swig_getmethods__["txMcAssociationStartTime"] = _vclapi.VclStatsClient_txMcAssociationStartTime_get
    if _newclass:txMcAssociationStartTime = property(_vclapi.VclStatsClient_txMcAssociationStartTime_get)
    __swig_getmethods__["rxMcAssociationEndTime"] = _vclapi.VclStatsClient_rxMcAssociationEndTime_get
    if _newclass:rxMcAssociationEndTime = property(_vclapi.VclStatsClient_rxMcAssociationEndTime_get)
    __swig_getmethods__["rxMcDeauthDisassocTime"] = _vclapi.VclStatsClient_rxMcDeauthDisassocTime_get
    if _newclass:rxMcDeauthDisassocTime = property(_vclapi.VclStatsClient_rxMcDeauthDisassocTime_get)
    __swig_getmethods__["txMcStartTime"] = _vclapi.VclStatsClient_txMcStartTime_get
    if _newclass:txMcStartTime = property(_vclapi.VclStatsClient_txMcStartTime_get)
    __swig_getmethods__["txMcEndTime"] = _vclapi.VclStatsClient_txMcEndTime_get
    if _newclass:txMcEndTime = property(_vclapi.VclStatsClient_txMcEndTime_get)
    __swig_getmethods__["rxMcStartTime"] = _vclapi.VclStatsClient_rxMcStartTime_get
    if _newclass:rxMcStartTime = property(_vclapi.VclStatsClient_rxMcStartTime_get)
    __swig_getmethods__["rxMcEndTime"] = _vclapi.VclStatsClient_rxMcEndTime_get
    if _newclass:rxMcEndTime = property(_vclapi.VclStatsClient_rxMcEndTime_get)
    __swig_getmethods__["tgaProcessingTime"] = _vclapi.VclStatsClient_tgaProcessingTime_get
    if _newclass:tgaProcessingTime = property(_vclapi.VclStatsClient_tgaProcessingTime_get)
    __swig_getmethods__["tstampProbeRsp"] = _vclapi.VclStatsClient_tstampProbeRsp_get
    if _newclass:tstampProbeRsp = property(_vclapi.VclStatsClient_tstampProbeRsp_get)
    __swig_getmethods__["tstampAuth1Rsp"] = _vclapi.VclStatsClient_tstampAuth1Rsp_get
    if _newclass:tstampAuth1Rsp = property(_vclapi.VclStatsClient_tstampAuth1Rsp_get)
    __swig_getmethods__["tstampAuth2Rsp"] = _vclapi.VclStatsClient_tstampAuth2Rsp_get
    if _newclass:tstampAuth2Rsp = property(_vclapi.VclStatsClient_tstampAuth2Rsp_get)
    __swig_getmethods__["tstampEapReqIdentity"] = _vclapi.VclStatsClient_tstampEapReqIdentity_get
    if _newclass:tstampEapReqIdentity = property(_vclapi.VclStatsClient_tstampEapReqIdentity_get)
    __swig_getmethods__["tstampEapSuccessOrFailure"] = _vclapi.VclStatsClient_tstampEapSuccessOrFailure_get
    if _newclass:tstampEapSuccessOrFailure = property(_vclapi.VclStatsClient_tstampEapSuccessOrFailure_get)
    __swig_getmethods__["tstampEapolPairwiseKey"] = _vclapi.VclStatsClient_tstampEapolPairwiseKey_get
    if _newclass:tstampEapolPairwiseKey = property(_vclapi.VclStatsClient_tstampEapolPairwiseKey_get)
    __swig_getmethods__["tstampEapolGroupKey"] = _vclapi.VclStatsClient_tstampEapolGroupKey_get
    if _newclass:tstampEapolGroupKey = property(_vclapi.VclStatsClient_tstampEapolGroupKey_get)
    __swig_getmethods__["tstampMcConnectionComplete"] = _vclapi.VclStatsClient_tstampMcConnectionComplete_get
    if _newclass:tstampMcConnectionComplete = property(_vclapi.VclStatsClient_tstampMcConnectionComplete_get)
    __swig_getmethods__["tstampAuth1Req"] = _vclapi.VclStatsClient_tstampAuth1Req_get
    if _newclass:tstampAuth1Req = property(_vclapi.VclStatsClient_tstampAuth1Req_get)
    __swig_getmethods__["tstampAuth2Req"] = _vclapi.VclStatsClient_tstampAuth2Req_get
    if _newclass:tstampAuth2Req = property(_vclapi.VclStatsClient_tstampAuth2Req_get)
    __swig_getmethods__["tstampAssocReq"] = _vclapi.VclStatsClient_tstampAssocReq_get
    if _newclass:tstampAssocReq = property(_vclapi.VclStatsClient_tstampAssocReq_get)
    __swig_getmethods__["tstampAssocRsp"] = _vclapi.VclStatsClient_tstampAssocRsp_get
    if _newclass:tstampAssocRsp = property(_vclapi.VclStatsClient_tstampAssocRsp_get)
    __swig_getmethods__["tstampEapRspIdentity"] = _vclapi.VclStatsClient_tstampEapRspIdentity_get
    if _newclass:tstampEapRspIdentity = property(_vclapi.VclStatsClient_tstampEapRspIdentity_get)
    __swig_getmethods__["tstampDhcpDiscover"] = _vclapi.VclStatsClient_tstampDhcpDiscover_get
    if _newclass:tstampDhcpDiscover = property(_vclapi.VclStatsClient_tstampDhcpDiscover_get)
    __swig_getmethods__["tstampDhcpOffer"] = _vclapi.VclStatsClient_tstampDhcpOffer_get
    if _newclass:tstampDhcpOffer = property(_vclapi.VclStatsClient_tstampDhcpOffer_get)
    __swig_getmethods__["tstampDhcpRequest"] = _vclapi.VclStatsClient_tstampDhcpRequest_get
    if _newclass:tstampDhcpRequest = property(_vclapi.VclStatsClient_tstampDhcpRequest_get)
    __swig_getmethods__["tstampDhcpAck"] = _vclapi.VclStatsClient_tstampDhcpAck_get
    if _newclass:tstampDhcpAck = property(_vclapi.VclStatsClient_tstampDhcpAck_get)
    __swig_getmethods__["txPerTidFramesOk"] = _vclapi.VclStatsClient_txPerTidFramesOk_get
    if _newclass:txPerTidFramesOk = property(_vclapi.VclStatsClient_txPerTidFramesOk_get)
    __swig_getmethods__["txPerTidFramesErrors"] = _vclapi.VclStatsClient_txPerTidFramesErrors_get
    if _newclass:txPerTidFramesErrors = property(_vclapi.VclStatsClient_txPerTidFramesErrors_get)
    __swig_getmethods__["txPerTidOctetsOk"] = _vclapi.VclStatsClient_txPerTidOctetsOk_get
    if _newclass:txPerTidOctetsOk = property(_vclapi.VclStatsClient_txPerTidOctetsOk_get)
    __swig_getmethods__["txPerTidPacketQueueDelayMin"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayMin_get
    if _newclass:txPerTidPacketQueueDelayMin = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayMin_get)
    __swig_getmethods__["txPerTidPacketQueueDelayMax"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayMax_get
    if _newclass:txPerTidPacketQueueDelayMax = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayMax_get)
    __swig_getmethods__["txPerTidPacketQueueDelaySum"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelaySum_get
    if _newclass:txPerTidPacketQueueDelaySum = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelaySum_get)
    __swig_getmethods__["txPerTidPacketQueueDelayTotal"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayTotal_get
    if _newclass:txPerTidPacketQueueDelayTotal = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayTotal_get)
    __swig_getmethods__["txPerTidPacketQueueDelayBucketTid1"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid1_get
    if _newclass:txPerTidPacketQueueDelayBucketTid1 = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid1_get)
    __swig_getmethods__["txPerTidPacketQueueDelayBucketTid2"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid2_get
    if _newclass:txPerTidPacketQueueDelayBucketTid2 = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid2_get)
    __swig_getmethods__["txPerTidPacketQueueDelayBucketTid3"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid3_get
    if _newclass:txPerTidPacketQueueDelayBucketTid3 = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid3_get)
    __swig_getmethods__["txPerTidPacketQueueDelayBucketTid4"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid4_get
    if _newclass:txPerTidPacketQueueDelayBucketTid4 = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid4_get)
    __swig_getmethods__["txPerTidPacketQueueDelayBucketTid5"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid5_get
    if _newclass:txPerTidPacketQueueDelayBucketTid5 = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid5_get)
    __swig_getmethods__["txPerTidPacketQueueDelayBucketTid6"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid6_get
    if _newclass:txPerTidPacketQueueDelayBucketTid6 = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid6_get)
    __swig_getmethods__["txPerTidPacketQueueDelayBucketTid7"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid7_get
    if _newclass:txPerTidPacketQueueDelayBucketTid7 = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid7_get)
    __swig_getmethods__["txPerTidPacketQueueDelayBucketTid8"] = _vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid8_get
    if _newclass:txPerTidPacketQueueDelayBucketTid8 = property(_vclapi.VclStatsClient_txPerTidPacketQueueDelayBucketTid8_get)
    __swig_getmethods__["txPerAcFramesOk"] = _vclapi.VclStatsClient_txPerAcFramesOk_get
    if _newclass:txPerAcFramesOk = property(_vclapi.VclStatsClient_txPerAcFramesOk_get)
    __swig_getmethods__["txPerAcFramesErrors"] = _vclapi.VclStatsClient_txPerAcFramesErrors_get
    if _newclass:txPerAcFramesErrors = property(_vclapi.VclStatsClient_txPerAcFramesErrors_get)
    __swig_getmethods__["txPerAcOctetsOk"] = _vclapi.VclStatsClient_txPerAcOctetsOk_get
    if _newclass:txPerAcOctetsOk = property(_vclapi.VclStatsClient_txPerAcOctetsOk_get)
    __swig_getmethods__["txPerAcPacketQueueDelayMin"] = _vclapi.VclStatsClient_txPerAcPacketQueueDelayMin_get
    if _newclass:txPerAcPacketQueueDelayMin = property(_vclapi.VclStatsClient_txPerAcPacketQueueDelayMin_get)
    __swig_getmethods__["txPerAcPacketQueueDelayMax"] = _vclapi.VclStatsClient_txPerAcPacketQueueDelayMax_get
    if _newclass:txPerAcPacketQueueDelayMax = property(_vclapi.VclStatsClient_txPerAcPacketQueueDelayMax_get)
    __swig_getmethods__["txPerAcPacketQueueDelaySum"] = _vclapi.VclStatsClient_txPerAcPacketQueueDelaySum_get
    if _newclass:txPerAcPacketQueueDelaySum = property(_vclapi.VclStatsClient_txPerAcPacketQueueDelaySum_get)
    __swig_getmethods__["txPerAcPacketQueueDelayTotal"] = _vclapi.VclStatsClient_txPerAcPacketQueueDelayTotal_get
    if _newclass:txPerAcPacketQueueDelayTotal = property(_vclapi.VclStatsClient_txPerAcPacketQueueDelayTotal_get)
    __swig_getmethods__["txPerAcPacketQueueDelayBucketAc1"] = _vclapi.VclStatsClient_txPerAcPacketQueueDelayBucketAc1_get
    if _newclass:txPerAcPacketQueueDelayBucketAc1 = property(_vclapi.VclStatsClient_txPerAcPacketQueueDelayBucketAc1_get)
    __swig_getmethods__["txPerAcPacketQueueDelayBucketAc2"] = _vclapi.VclStatsClient_txPerAcPacketQueueDelayBucketAc2_get
    if _newclass:txPerAcPacketQueueDelayBucketAc2 = property(_vclapi.VclStatsClient_txPerAcPacketQueueDelayBucketAc2_get)
    __swig_getmethods__["txPerAcPacketQueueDelayBucketAc3"] = _vclapi.VclStatsClient_txPerAcPacketQueueDelayBucketAc3_get
    if _newclass:txPerAcPacketQueueDelayBucketAc3 = property(_vclapi.VclStatsClient_txPerAcPacketQueueDelayBucketAc3_get)
    __swig_getmethods__["txPerAcPacketQueueDelayBucketAc4"] = _vclapi.VclStatsClient_txPerAcPacketQueueDelayBucketAc4_get
    if _newclass:txPerAcPacketQueueDelayBucketAc4 = property(_vclapi.VclStatsClient_txPerAcPacketQueueDelayBucketAc4_get)
    __swig_getmethods__["txPerAcPacketMediaDelaySum"] = _vclapi.VclStatsClient_txPerAcPacketMediaDelaySum_get
    if _newclass:txPerAcPacketMediaDelaySum = property(_vclapi.VclStatsClient_txPerAcPacketMediaDelaySum_get)
    __swig_getmethods__["txPerAcPacketMediaDelayTotal"] = _vclapi.VclStatsClient_txPerAcPacketMediaDelayTotal_get
    if _newclass:txPerAcPacketMediaDelayTotal = property(_vclapi.VclStatsClient_txPerAcPacketMediaDelayTotal_get)
    __swig_getmethods__["rxPerTidFramesOk"] = _vclapi.VclStatsClient_rxPerTidFramesOk_get
    if _newclass:rxPerTidFramesOk = property(_vclapi.VclStatsClient_rxPerTidFramesOk_get)
    __swig_getmethods__["rxPerTidOctetsOk"] = _vclapi.VclStatsClient_rxPerTidOctetsOk_get
    if _newclass:rxPerTidOctetsOk = property(_vclapi.VclStatsClient_rxPerTidOctetsOk_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayMin"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayMin_get
    if _newclass:rxPerTidPacketQueueDelayMin = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayMin_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayMax"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayMax_get
    if _newclass:rxPerTidPacketQueueDelayMax = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayMax_get)
    __swig_getmethods__["rxPerTidPacketQueueDelaySum"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelaySum_get
    if _newclass:rxPerTidPacketQueueDelaySum = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelaySum_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayTotal"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayTotal_get
    if _newclass:rxPerTidPacketQueueDelayTotal = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayTotal_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayBucketTid1"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid1_get
    if _newclass:rxPerTidPacketQueueDelayBucketTid1 = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid1_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayBucketTid2"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid2_get
    if _newclass:rxPerTidPacketQueueDelayBucketTid2 = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid2_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayBucketTid3"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid3_get
    if _newclass:rxPerTidPacketQueueDelayBucketTid3 = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid3_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayBucketTid4"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid4_get
    if _newclass:rxPerTidPacketQueueDelayBucketTid4 = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid4_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayBucketTid5"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid5_get
    if _newclass:rxPerTidPacketQueueDelayBucketTid5 = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid5_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayBucketTid6"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid6_get
    if _newclass:rxPerTidPacketQueueDelayBucketTid6 = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid6_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayBucketTid7"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid7_get
    if _newclass:rxPerTidPacketQueueDelayBucketTid7 = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid7_get)
    __swig_getmethods__["rxPerTidPacketQueueDelayBucketTid8"] = _vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid8_get
    if _newclass:rxPerTidPacketQueueDelayBucketTid8 = property(_vclapi.VclStatsClient_rxPerTidPacketQueueDelayBucketTid8_get)
    __swig_getmethods__["txPerUserPriFramesOk"] = _vclapi.VclStatsClient_txPerUserPriFramesOk_get
    if _newclass:txPerUserPriFramesOk = property(_vclapi.VclStatsClient_txPerUserPriFramesOk_get)
    __swig_getmethods__["txPerUserPriFramesErrors"] = _vclapi.VclStatsClient_txPerUserPriFramesErrors_get
    if _newclass:txPerUserPriFramesErrors = property(_vclapi.VclStatsClient_txPerUserPriFramesErrors_get)
    __swig_getmethods__["txPerUserPriOctetsOk"] = _vclapi.VclStatsClient_txPerUserPriOctetsOk_get
    if _newclass:txPerUserPriOctetsOk = property(_vclapi.VclStatsClient_txPerUserPriOctetsOk_get)
    __swig_getmethods__["rxPerUserPriFramesOk"] = _vclapi.VclStatsClient_rxPerUserPriFramesOk_get
    if _newclass:rxPerUserPriFramesOk = property(_vclapi.VclStatsClient_rxPerUserPriFramesOk_get)
    __swig_getmethods__["rxPerUserPriOctetsOk"] = _vclapi.VclStatsClient_rxPerUserPriOctetsOk_get
    if _newclass:rxPerUserPriOctetsOk = property(_vclapi.VclStatsClient_rxPerUserPriOctetsOk_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyMin"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyMin_get
    if _newclass:rxPerUserPriFrameLatencyMin = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyMin_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyMax"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyMax_get
    if _newclass:rxPerUserPriFrameLatencyMax = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyMax_get)
    __swig_getmethods__["rxPerUserPriFrameLatencySum"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencySum_get
    if _newclass:rxPerUserPriFrameLatencySum = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencySum_get)
    __swig_getmethods__["rxPerUserPriFrameTotal"] = _vclapi.VclStatsClient_rxPerUserPriFrameTotal_get
    if _newclass:rxPerUserPriFrameTotal = property(_vclapi.VclStatsClient_rxPerUserPriFrameTotal_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyBucketUp1"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp1_get
    if _newclass:rxPerUserPriFrameLatencyBucketUp1 = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp1_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyBucketUp2"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp2_get
    if _newclass:rxPerUserPriFrameLatencyBucketUp2 = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp2_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyBucketUp3"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp3_get
    if _newclass:rxPerUserPriFrameLatencyBucketUp3 = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp3_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyBucketUp4"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp4_get
    if _newclass:rxPerUserPriFrameLatencyBucketUp4 = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp4_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyBucketUp5"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp5_get
    if _newclass:rxPerUserPriFrameLatencyBucketUp5 = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp5_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyBucketUp6"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp6_get
    if _newclass:rxPerUserPriFrameLatencyBucketUp6 = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp6_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyBucketUp7"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp7_get
    if _newclass:rxPerUserPriFrameLatencyBucketUp7 = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp7_get)
    __swig_getmethods__["rxPerUserPriFrameLatencyBucketUp8"] = _vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp8_get
    if _newclass:rxPerUserPriFrameLatencyBucketUp8 = property(_vclapi.VclStatsClient_rxPerUserPriFrameLatencyBucketUp8_get)
    def __init__(self, *args):
        _swig_setattr(self, VclStatsClient, 'this', _vclapi.new_VclStatsClient(*args))
        _swig_setattr(self, VclStatsClient, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclStatsClient):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclStatsClientPtr(VclStatsClient):
    def __init__(self, this):
        _swig_setattr(self, VclStatsClient, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclStatsClient, 'thisown', 0)
        _swig_setattr(self, VclStatsClient,self.__class__,VclStatsClient)
_vclapi.VclStatsClient_swigregister(VclStatsClientPtr)

class MemoryBuffer(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, MemoryBuffer, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, MemoryBuffer, name)
    def __repr__(self):
        return "<C MemoryBuffer instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, MemoryBuffer, 'this', _vclapi.new_MemoryBuffer(*args))
        _swig_setattr(self, MemoryBuffer, 'thisown', 1)
    def getOctet1(*args): return _vclapi.MemoryBuffer_getOctet1(*args)
    def setOctet1(*args): return _vclapi.MemoryBuffer_setOctet1(*args)
    def getOctet2(*args): return _vclapi.MemoryBuffer_getOctet2(*args)
    def setOctet2(*args): return _vclapi.MemoryBuffer_setOctet2(*args)
    def getOctet4(*args): return _vclapi.MemoryBuffer_getOctet4(*args)
    def setOctet4(*args): return _vclapi.MemoryBuffer_setOctet4(*args)
    def getSize(*args): return _vclapi.MemoryBuffer_getSize(*args)
    def getRegion(*args): return _vclapi.MemoryBuffer_getRegion(*args)
    def assign(*args): return _vclapi.MemoryBuffer_assign(*args)
    def append(*args): return _vclapi.MemoryBuffer_append(*args)
    def normalize(*args): return _vclapi.MemoryBuffer_normalize(*args)
    def clear(*args): return _vclapi.MemoryBuffer_clear(*args)
    def toString(*args): return _vclapi.MemoryBuffer_toString(*args)
    def toAscii(*args): return _vclapi.MemoryBuffer_toAscii(*args)
    def dump(*args): return _vclapi.MemoryBuffer_dump(*args)
    def equals(*args): return _vclapi.MemoryBuffer_equals(*args)
    def calculateChecksum(*args): return _vclapi.MemoryBuffer_calculateChecksum(*args)
    def __del__(self, destroy=_vclapi.delete_MemoryBuffer):
        try:
            if self.thisown: destroy(self)
        except: pass

class MemoryBufferPtr(MemoryBuffer):
    def __init__(self, this):
        _swig_setattr(self, MemoryBuffer, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, MemoryBuffer, 'thisown', 0)
        _swig_setattr(self, MemoryBuffer,self.__class__,MemoryBuffer)
_vclapi.MemoryBuffer_swigregister(MemoryBufferPtr)

class Checksum(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Checksum, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Checksum, name)
    def __repr__(self):
        return "<C Checksum instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, Checksum, 'this', _vclapi.new_Checksum(*args))
        _swig_setattr(self, Checksum, 'thisown', 1)
    def clear(*args): return _vclapi.Checksum_clear(*args)
    def add(*args): return _vclapi.Checksum_add(*args)
    def getSum(*args): return _vclapi.Checksum_getSum(*args)
    def getComplement(*args): return _vclapi.Checksum_getComplement(*args)
    def toString(*args): return _vclapi.Checksum_toString(*args)
    def __del__(self, destroy=_vclapi.delete_Checksum):
        try:
            if self.thisown: destroy(self)
        except: pass

class ChecksumPtr(Checksum):
    def __init__(self, this):
        _swig_setattr(self, Checksum, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Checksum, 'thisown', 0)
        _swig_setattr(self, Checksum,self.__class__,Checksum)
_vclapi.Checksum_swigregister(ChecksumPtr)

class VclIgmpRsp(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclIgmpRsp, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclIgmpRsp, name)
    def __repr__(self):
        return "<C VclIgmpRsp instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclIgmpRsp_create(*args)
    def read(*args): return _vclapi.VclIgmpRsp_read(*args)
    def write(*args): return _vclapi.VclIgmpRsp_write(*args)
    def destroy(*args): return _vclapi.VclIgmpRsp_destroy(*args)
    def report(*args): return _vclapi.VclIgmpRsp_report(*args)
    def getName(*args): return _vclapi.VclIgmpRsp_getName(*args)
    def getIpMulticastAddress(*args): return _vclapi.VclIgmpRsp_getIpMulticastAddress(*args)
    def setIpMulticastAddress(*args): return _vclapi.VclIgmpRsp_setIpMulticastAddress(*args)
    def getMacMulticastAddress(*args): return _vclapi.VclIgmpRsp_getMacMulticastAddress(*args)
    def setMacMulticastAddress(*args): return _vclapi.VclIgmpRsp_setMacMulticastAddress(*args)
    def getPort(*args): return _vclapi.VclIgmpRsp_getPort(*args)
    def setPort(*args): return _vclapi.VclIgmpRsp_setPort(*args)
    def getDefaultClient(*args): return _vclapi.VclIgmpRsp_getDefaultClient(*args)
    def setDefaultClient(*args): return _vclapi.VclIgmpRsp_setDefaultClient(*args)
    def getLastQueryTime(*args): return _vclapi.VclIgmpRsp_getLastQueryTime(*args)
    def getLastReportTime(*args): return _vclapi.VclIgmpRsp_getLastReportTime(*args)
    def getIgmpQueryRx(*args): return _vclapi.VclIgmpRsp_getIgmpQueryRx(*args)
    def getIgmpReportTx(*args): return _vclapi.VclIgmpRsp_getIgmpReportTx(*args)
    __swig_getmethods__["name"] = _vclapi.VclIgmpRsp_name_get
    if _newclass:name = property(_vclapi.VclIgmpRsp_name_get)
    __swig_setmethods__["ipMulticastAddress"] = _vclapi.VclIgmpRsp_ipMulticastAddress_set
    __swig_getmethods__["ipMulticastAddress"] = _vclapi.VclIgmpRsp_ipMulticastAddress_get
    if _newclass:ipMulticastAddress = property(_vclapi.VclIgmpRsp_ipMulticastAddress_get, _vclapi.VclIgmpRsp_ipMulticastAddress_set)
    __swig_setmethods__["macMulticastAddress"] = _vclapi.VclIgmpRsp_macMulticastAddress_set
    __swig_getmethods__["macMulticastAddress"] = _vclapi.VclIgmpRsp_macMulticastAddress_get
    if _newclass:macMulticastAddress = property(_vclapi.VclIgmpRsp_macMulticastAddress_get, _vclapi.VclIgmpRsp_macMulticastAddress_set)
    __swig_setmethods__["port"] = _vclapi.VclIgmpRsp_port_set
    __swig_getmethods__["port"] = _vclapi.VclIgmpRsp_port_get
    if _newclass:port = property(_vclapi.VclIgmpRsp_port_get, _vclapi.VclIgmpRsp_port_set)
    __swig_setmethods__["defaultClient"] = _vclapi.VclIgmpRsp_defaultClient_set
    __swig_getmethods__["defaultClient"] = _vclapi.VclIgmpRsp_defaultClient_get
    if _newclass:defaultClient = property(_vclapi.VclIgmpRsp_defaultClient_get, _vclapi.VclIgmpRsp_defaultClient_set)
    __swig_getmethods__["lastQueryTime"] = _vclapi.VclIgmpRsp_lastQueryTime_get
    if _newclass:lastQueryTime = property(_vclapi.VclIgmpRsp_lastQueryTime_get)
    __swig_getmethods__["lastReportTime"] = _vclapi.VclIgmpRsp_lastReportTime_get
    if _newclass:lastReportTime = property(_vclapi.VclIgmpRsp_lastReportTime_get)
    __swig_getmethods__["igmpQueryRx"] = _vclapi.VclIgmpRsp_igmpQueryRx_get
    if _newclass:igmpQueryRx = property(_vclapi.VclIgmpRsp_igmpQueryRx_get)
    __swig_getmethods__["igmpReportTx"] = _vclapi.VclIgmpRsp_igmpReportTx_get
    if _newclass:igmpReportTx = property(_vclapi.VclIgmpRsp_igmpReportTx_get)
    def __init__(self, *args):
        _swig_setattr(self, VclIgmpRsp, 'this', _vclapi.new_VclIgmpRsp(*args))
        _swig_setattr(self, VclIgmpRsp, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclIgmpRsp):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclIgmpRspPtr(VclIgmpRsp):
    def __init__(self, this):
        _swig_setattr(self, VclIgmpRsp, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclIgmpRsp, 'thisown', 0)
        _swig_setattr(self, VclIgmpRsp,self.__class__,VclIgmpRsp)
_vclapi.VclIgmpRsp_swigregister(VclIgmpRspPtr)

class VclPortIf(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclPortIf, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclPortIf, name)
    def __repr__(self):
        return "<C VclPortIf instance at %s>" % (self.this,)
    def getClientIndex(*args): return _vclapi.VclPortIf_getClientIndex(*args)
    def getFlowIndex(*args): return _vclapi.VclPortIf_getFlowIndex(*args)
    def getFlowNumber(*args): return _vclapi.VclPortIf_getFlowNumber(*args)
    def sendPortMessage(*args): return _vclapi.VclPortIf_sendPortMessage(*args)
    def sendPortCommand(*args): return _vclapi.VclPortIf_sendPortCommand(*args)
    def sendPortCommandEx(*args): return _vclapi.VclPortIf_sendPortCommandEx(*args)
    def recvPortMessage(*args): return _vclapi.VclPortIf_recvPortMessage(*args)
    def recvPortMessageEx(*args): return _vclapi.VclPortIf_recvPortMessageEx(*args)
    def recvPortStats(*args): return _vclapi.VclPortIf_recvPortStats(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclPortIf, 'this', _vclapi.new_VclPortIf(*args))
        _swig_setattr(self, VclPortIf, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclPortIf):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclPortIfPtr(VclPortIf):
    def __init__(self, this):
        _swig_setattr(self, VclPortIf, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclPortIf, 'thisown', 0)
        _swig_setattr(self, VclPortIf,self.__class__,VclPortIf)
_vclapi.VclPortIf_swigregister(VclPortIfPtr)

class VclCapFile(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclCapFile, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclCapFile, name)
    def __repr__(self):
        return "<C VclCapFile instance at %s>" % (self.this,)
    def open(*args): return _vclapi.VclCapFile_open(*args)
    def close(*args): return _vclapi.VclCapFile_close(*args)
    def getIndex(*args): return _vclapi.VclCapFile_getIndex(*args)
    def setIndex(*args): return _vclapi.VclCapFile_setIndex(*args)
    def read(*args): return _vclapi.VclCapFile_read(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclCapFile, 'this', _vclapi.new_VclCapFile(*args))
        _swig_setattr(self, VclCapFile, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclCapFile):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclCapFilePtr(VclCapFile):
    def __init__(self, this):
        _swig_setattr(self, VclCapFile, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclCapFile, 'thisown', 0)
        _swig_setattr(self, VclCapFile,self.__class__,VclCapFile)
_vclapi.VclCapFile_swigregister(VclCapFilePtr)

class VclBiflowModTcp(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclBiflowModTcp, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclBiflowModTcp, name)
    def __repr__(self):
        return "<C VclBiflowModTcp instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclBiflowModTcp_setDefaults(*args)
    def readBiflow(*args): return _vclapi.VclBiflowModTcp_readBiflow(*args)
    def modifyBiflow(*args): return _vclapi.VclBiflowModTcp_modifyBiflow(*args)
    def read(*args): return _vclapi.VclBiflowModTcp_read(*args)
    def modify(*args): return _vclapi.VclBiflowModTcp_modify(*args)
    def setDefaultBiflow(*args): return _vclapi.VclBiflowModTcp_setDefaultBiflow(*args)
    def getSrcPort(*args): return _vclapi.VclBiflowModTcp_getSrcPort(*args)
    def getDestPort(*args): return _vclapi.VclBiflowModTcp_getDestPort(*args)
    def getWindow(*args): return _vclapi.VclBiflowModTcp_getWindow(*args)
    def getMss(*args): return _vclapi.VclBiflowModTcp_getMss(*args)
    def setSrcPort(*args): return _vclapi.VclBiflowModTcp_setSrcPort(*args)
    def setDestPort(*args): return _vclapi.VclBiflowModTcp_setDestPort(*args)
    def setWindow(*args): return _vclapi.VclBiflowModTcp_setWindow(*args)
    def setMss(*args): return _vclapi.VclBiflowModTcp_setMss(*args)
    __swig_setmethods__["srcPort"] = _vclapi.VclBiflowModTcp_srcPort_set
    __swig_getmethods__["srcPort"] = _vclapi.VclBiflowModTcp_srcPort_get
    if _newclass:srcPort = property(_vclapi.VclBiflowModTcp_srcPort_get, _vclapi.VclBiflowModTcp_srcPort_set)
    __swig_setmethods__["destPort"] = _vclapi.VclBiflowModTcp_destPort_set
    __swig_getmethods__["destPort"] = _vclapi.VclBiflowModTcp_destPort_get
    if _newclass:destPort = property(_vclapi.VclBiflowModTcp_destPort_get, _vclapi.VclBiflowModTcp_destPort_set)
    __swig_setmethods__["window"] = _vclapi.VclBiflowModTcp_window_set
    __swig_getmethods__["window"] = _vclapi.VclBiflowModTcp_window_get
    if _newclass:window = property(_vclapi.VclBiflowModTcp_window_get, _vclapi.VclBiflowModTcp_window_set)
    __swig_setmethods__["mss"] = _vclapi.VclBiflowModTcp_mss_set
    __swig_getmethods__["mss"] = _vclapi.VclBiflowModTcp_mss_get
    if _newclass:mss = property(_vclapi.VclBiflowModTcp_mss_get, _vclapi.VclBiflowModTcp_mss_set)
    def __init__(self, *args):
        _swig_setattr(self, VclBiflowModTcp, 'this', _vclapi.new_VclBiflowModTcp(*args))
        _swig_setattr(self, VclBiflowModTcp, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclBiflowModTcp):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclBiflowModTcpPtr(VclBiflowModTcp):
    def __init__(self, this):
        _swig_setattr(self, VclBiflowModTcp, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclBiflowModTcp, 'thisown', 0)
        _swig_setattr(self, VclBiflowModTcp,self.__class__,VclBiflowModTcp)
_vclapi.VclBiflowModTcp_swigregister(VclBiflowModTcpPtr)

class VclBiflowModQos(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclBiflowModQos, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclBiflowModQos, name)
    def __repr__(self):
        return "<C VclBiflowModQos instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclBiflowModQos_setDefaults(*args)
    def readBiflow(*args): return _vclapi.VclBiflowModQos_readBiflow(*args)
    def modifyBiflow(*args): return _vclapi.VclBiflowModQos_modifyBiflow(*args)
    def read(*args): return _vclapi.VclBiflowModQos_read(*args)
    def modify(*args): return _vclapi.VclBiflowModQos_modify(*args)
    def setDefaultBiflow(*args): return _vclapi.VclBiflowModQos_setDefaultBiflow(*args)
    def get(*args): return _vclapi.VclBiflowModQos_get(*args)
    def set(*args): return _vclapi.VclBiflowModQos_set(*args)
    def reflect(*args): return _vclapi.VclBiflowModQos_reflect(*args)
    def getPriorityTag(*args): return _vclapi.VclBiflowModQos_getPriorityTag(*args)
    def getFlowState(*args): return _vclapi.VclBiflowModQos_getFlowState(*args)
    def getTgaPriority(*args): return _vclapi.VclBiflowModQos_getTgaPriority(*args)
    def getUserPriority(*args): return _vclapi.VclBiflowModQos_getUserPriority(*args)
    def getFragThreshold(*args): return _vclapi.VclBiflowModQos_getFragThreshold(*args)
    def getAifs(*args): return _vclapi.VclBiflowModQos_getAifs(*args)
    def getCwMin(*args): return _vclapi.VclBiflowModQos_getCwMin(*args)
    def getCwMax(*args): return _vclapi.VclBiflowModQos_getCwMax(*args)
    def getRetryLimit(*args): return _vclapi.VclBiflowModQos_getRetryLimit(*args)
    def getTid(*args): return _vclapi.VclBiflowModQos_getTid(*args)
    def getAc(*args): return _vclapi.VclBiflowModQos_getAc(*args)
    def getAckPolicy(*args): return _vclapi.VclBiflowModQos_getAckPolicy(*args)
    def getAckLimit(*args): return _vclapi.VclBiflowModQos_getAckLimit(*args)
    def getDirection(*args): return _vclapi.VclBiflowModQos_getDirection(*args)
    def getAckTimeout(*args): return _vclapi.VclBiflowModQos_getAckTimeout(*args)
    def getArpDelay(*args): return _vclapi.VclBiflowModQos_getArpDelay(*args)
    def getMsduSize(*args): return _vclapi.VclBiflowModQos_getMsduSize(*args)
    def getMinPhyRate(*args): return _vclapi.VclBiflowModQos_getMinPhyRate(*args)
    def getMeanDataRate(*args): return _vclapi.VclBiflowModQos_getMeanDataRate(*args)
    def getTxopLimit(*args): return _vclapi.VclBiflowModQos_getTxopLimit(*args)
    def getBandwidth(*args): return _vclapi.VclBiflowModQos_getBandwidth(*args)
    def getClassifier(*args): return _vclapi.VclBiflowModQos_getClassifier(*args)
    def getTclasIeIncluded(*args): return _vclapi.VclBiflowModQos_getTclasIeIncluded(*args)
    def getAcParamFromBss(*args): return _vclapi.VclBiflowModQos_getAcParamFromBss(*args)
    def getFragEnable(*args): return _vclapi.VclBiflowModQos_getFragEnable(*args)
    def getPerformHs(*args): return _vclapi.VclBiflowModQos_getPerformHs(*args)
    def getMPDUAggregationEnable(*args): return _vclapi.VclBiflowModQos_getMPDUAggregationEnable(*args)
    def getAggregationAutoMax(*args): return _vclapi.VclBiflowModQos_getAggregationAutoMax(*args)
    def getMPDUAggregationLimit(*args): return _vclapi.VclBiflowModQos_getMPDUAggregationLimit(*args)
    def setPriorityTag(*args): return _vclapi.VclBiflowModQos_setPriorityTag(*args)
    def setTgaPriority(*args): return _vclapi.VclBiflowModQos_setTgaPriority(*args)
    def setUserPriority(*args): return _vclapi.VclBiflowModQos_setUserPriority(*args)
    def setFragThreshold(*args): return _vclapi.VclBiflowModQos_setFragThreshold(*args)
    def setAifs(*args): return _vclapi.VclBiflowModQos_setAifs(*args)
    def setCwMin(*args): return _vclapi.VclBiflowModQos_setCwMin(*args)
    def setCwMax(*args): return _vclapi.VclBiflowModQos_setCwMax(*args)
    def setRetryLimit(*args): return _vclapi.VclBiflowModQos_setRetryLimit(*args)
    def setTid(*args): return _vclapi.VclBiflowModQos_setTid(*args)
    def setAc(*args): return _vclapi.VclBiflowModQos_setAc(*args)
    def setAckPolicy(*args): return _vclapi.VclBiflowModQos_setAckPolicy(*args)
    def setAckLimit(*args): return _vclapi.VclBiflowModQos_setAckLimit(*args)
    def setDirection(*args): return _vclapi.VclBiflowModQos_setDirection(*args)
    def setAckTimeout(*args): return _vclapi.VclBiflowModQos_setAckTimeout(*args)
    def setMinPhyRate(*args): return _vclapi.VclBiflowModQos_setMinPhyRate(*args)
    def setMsduSize(*args): return _vclapi.VclBiflowModQos_setMsduSize(*args)
    def setMeanDataRate(*args): return _vclapi.VclBiflowModQos_setMeanDataRate(*args)
    def setTxopLimit(*args): return _vclapi.VclBiflowModQos_setTxopLimit(*args)
    def setBandwidth(*args): return _vclapi.VclBiflowModQos_setBandwidth(*args)
    def setClassifier(*args): return _vclapi.VclBiflowModQos_setClassifier(*args)
    def setTclasIeIncluded(*args): return _vclapi.VclBiflowModQos_setTclasIeIncluded(*args)
    def setAcParamFromBss(*args): return _vclapi.VclBiflowModQos_setAcParamFromBss(*args)
    def setFragEnable(*args): return _vclapi.VclBiflowModQos_setFragEnable(*args)
    def setPerformHs(*args): return _vclapi.VclBiflowModQos_setPerformHs(*args)
    def setAdmissionControl(*args): return _vclapi.VclBiflowModQos_setAdmissionControl(*args)
    def setMPDUAggregationEnable(*args): return _vclapi.VclBiflowModQos_setMPDUAggregationEnable(*args)
    def setAggregationAutoMax(*args): return _vclapi.VclBiflowModQos_setAggregationAutoMax(*args)
    def setMPDUAggregationLimit(*args): return _vclapi.VclBiflowModQos_setMPDUAggregationLimit(*args)
    def setMinimumMpduStartSpacing(*args): return _vclapi.VclBiflowModQos_setMinimumMpduStartSpacing(*args)
    __swig_setmethods__["priorityTag"] = _vclapi.VclBiflowModQos_priorityTag_set
    __swig_getmethods__["priorityTag"] = _vclapi.VclBiflowModQos_priorityTag_get
    if _newclass:priorityTag = property(_vclapi.VclBiflowModQos_priorityTag_get, _vclapi.VclBiflowModQos_priorityTag_set)
    __swig_setmethods__["flowState"] = _vclapi.VclBiflowModQos_flowState_set
    __swig_getmethods__["flowState"] = _vclapi.VclBiflowModQos_flowState_get
    if _newclass:flowState = property(_vclapi.VclBiflowModQos_flowState_get, _vclapi.VclBiflowModQos_flowState_set)
    __swig_setmethods__["tgaPriority"] = _vclapi.VclBiflowModQos_tgaPriority_set
    __swig_getmethods__["tgaPriority"] = _vclapi.VclBiflowModQos_tgaPriority_get
    if _newclass:tgaPriority = property(_vclapi.VclBiflowModQos_tgaPriority_get, _vclapi.VclBiflowModQos_tgaPriority_set)
    __swig_setmethods__["userPriority"] = _vclapi.VclBiflowModQos_userPriority_set
    __swig_getmethods__["userPriority"] = _vclapi.VclBiflowModQos_userPriority_get
    if _newclass:userPriority = property(_vclapi.VclBiflowModQos_userPriority_get, _vclapi.VclBiflowModQos_userPriority_set)
    __swig_setmethods__["fragThreshold"] = _vclapi.VclBiflowModQos_fragThreshold_set
    __swig_getmethods__["fragThreshold"] = _vclapi.VclBiflowModQos_fragThreshold_get
    if _newclass:fragThreshold = property(_vclapi.VclBiflowModQos_fragThreshold_get, _vclapi.VclBiflowModQos_fragThreshold_set)
    __swig_setmethods__["aifs"] = _vclapi.VclBiflowModQos_aifs_set
    __swig_getmethods__["aifs"] = _vclapi.VclBiflowModQos_aifs_get
    if _newclass:aifs = property(_vclapi.VclBiflowModQos_aifs_get, _vclapi.VclBiflowModQos_aifs_set)
    __swig_setmethods__["cwMin"] = _vclapi.VclBiflowModQos_cwMin_set
    __swig_getmethods__["cwMin"] = _vclapi.VclBiflowModQos_cwMin_get
    if _newclass:cwMin = property(_vclapi.VclBiflowModQos_cwMin_get, _vclapi.VclBiflowModQos_cwMin_set)
    __swig_setmethods__["cwMax"] = _vclapi.VclBiflowModQos_cwMax_set
    __swig_getmethods__["cwMax"] = _vclapi.VclBiflowModQos_cwMax_get
    if _newclass:cwMax = property(_vclapi.VclBiflowModQos_cwMax_get, _vclapi.VclBiflowModQos_cwMax_set)
    __swig_setmethods__["retryLimit"] = _vclapi.VclBiflowModQos_retryLimit_set
    __swig_getmethods__["retryLimit"] = _vclapi.VclBiflowModQos_retryLimit_get
    if _newclass:retryLimit = property(_vclapi.VclBiflowModQos_retryLimit_get, _vclapi.VclBiflowModQos_retryLimit_set)
    __swig_setmethods__["tid"] = _vclapi.VclBiflowModQos_tid_set
    __swig_getmethods__["tid"] = _vclapi.VclBiflowModQos_tid_get
    if _newclass:tid = property(_vclapi.VclBiflowModQos_tid_get, _vclapi.VclBiflowModQos_tid_set)
    __swig_setmethods__["ac"] = _vclapi.VclBiflowModQos_ac_set
    __swig_getmethods__["ac"] = _vclapi.VclBiflowModQos_ac_get
    if _newclass:ac = property(_vclapi.VclBiflowModQos_ac_get, _vclapi.VclBiflowModQos_ac_set)
    __swig_setmethods__["ackPolicy"] = _vclapi.VclBiflowModQos_ackPolicy_set
    __swig_getmethods__["ackPolicy"] = _vclapi.VclBiflowModQos_ackPolicy_get
    if _newclass:ackPolicy = property(_vclapi.VclBiflowModQos_ackPolicy_get, _vclapi.VclBiflowModQos_ackPolicy_set)
    __swig_setmethods__["ackLimit"] = _vclapi.VclBiflowModQos_ackLimit_set
    __swig_getmethods__["ackLimit"] = _vclapi.VclBiflowModQos_ackLimit_get
    if _newclass:ackLimit = property(_vclapi.VclBiflowModQos_ackLimit_get, _vclapi.VclBiflowModQos_ackLimit_set)
    __swig_setmethods__["direction"] = _vclapi.VclBiflowModQos_direction_set
    __swig_getmethods__["direction"] = _vclapi.VclBiflowModQos_direction_get
    if _newclass:direction = property(_vclapi.VclBiflowModQos_direction_get, _vclapi.VclBiflowModQos_direction_set)
    __swig_setmethods__["ackTimeout"] = _vclapi.VclBiflowModQos_ackTimeout_set
    __swig_getmethods__["ackTimeout"] = _vclapi.VclBiflowModQos_ackTimeout_get
    if _newclass:ackTimeout = property(_vclapi.VclBiflowModQos_ackTimeout_get, _vclapi.VclBiflowModQos_ackTimeout_set)
    __swig_setmethods__["arpDelay"] = _vclapi.VclBiflowModQos_arpDelay_set
    __swig_getmethods__["arpDelay"] = _vclapi.VclBiflowModQos_arpDelay_get
    if _newclass:arpDelay = property(_vclapi.VclBiflowModQos_arpDelay_get, _vclapi.VclBiflowModQos_arpDelay_set)
    __swig_setmethods__["msduSize"] = _vclapi.VclBiflowModQos_msduSize_set
    __swig_getmethods__["msduSize"] = _vclapi.VclBiflowModQos_msduSize_get
    if _newclass:msduSize = property(_vclapi.VclBiflowModQos_msduSize_get, _vclapi.VclBiflowModQos_msduSize_set)
    __swig_setmethods__["minPhyRate"] = _vclapi.VclBiflowModQos_minPhyRate_set
    __swig_getmethods__["minPhyRate"] = _vclapi.VclBiflowModQos_minPhyRate_get
    if _newclass:minPhyRate = property(_vclapi.VclBiflowModQos_minPhyRate_get, _vclapi.VclBiflowModQos_minPhyRate_set)
    __swig_setmethods__["meanDataRate"] = _vclapi.VclBiflowModQos_meanDataRate_set
    __swig_getmethods__["meanDataRate"] = _vclapi.VclBiflowModQos_meanDataRate_get
    if _newclass:meanDataRate = property(_vclapi.VclBiflowModQos_meanDataRate_get, _vclapi.VclBiflowModQos_meanDataRate_set)
    __swig_setmethods__["txopLimit"] = _vclapi.VclBiflowModQos_txopLimit_set
    __swig_getmethods__["txopLimit"] = _vclapi.VclBiflowModQos_txopLimit_get
    if _newclass:txopLimit = property(_vclapi.VclBiflowModQos_txopLimit_get, _vclapi.VclBiflowModQos_txopLimit_set)
    __swig_setmethods__["bandwidth"] = _vclapi.VclBiflowModQos_bandwidth_set
    __swig_getmethods__["bandwidth"] = _vclapi.VclBiflowModQos_bandwidth_get
    if _newclass:bandwidth = property(_vclapi.VclBiflowModQos_bandwidth_get, _vclapi.VclBiflowModQos_bandwidth_set)
    __swig_setmethods__["classifier"] = _vclapi.VclBiflowModQos_classifier_set
    __swig_getmethods__["classifier"] = _vclapi.VclBiflowModQos_classifier_get
    if _newclass:classifier = property(_vclapi.VclBiflowModQos_classifier_get, _vclapi.VclBiflowModQos_classifier_set)
    __swig_setmethods__["tclasIeIncluded"] = _vclapi.VclBiflowModQos_tclasIeIncluded_set
    __swig_getmethods__["tclasIeIncluded"] = _vclapi.VclBiflowModQos_tclasIeIncluded_get
    if _newclass:tclasIeIncluded = property(_vclapi.VclBiflowModQos_tclasIeIncluded_get, _vclapi.VclBiflowModQos_tclasIeIncluded_set)
    __swig_setmethods__["acParamFromBss"] = _vclapi.VclBiflowModQos_acParamFromBss_set
    __swig_getmethods__["acParamFromBss"] = _vclapi.VclBiflowModQos_acParamFromBss_get
    if _newclass:acParamFromBss = property(_vclapi.VclBiflowModQos_acParamFromBss_get, _vclapi.VclBiflowModQos_acParamFromBss_set)
    __swig_setmethods__["fragEnable"] = _vclapi.VclBiflowModQos_fragEnable_set
    __swig_getmethods__["fragEnable"] = _vclapi.VclBiflowModQos_fragEnable_get
    if _newclass:fragEnable = property(_vclapi.VclBiflowModQos_fragEnable_get, _vclapi.VclBiflowModQos_fragEnable_set)
    __swig_setmethods__["performHs"] = _vclapi.VclBiflowModQos_performHs_set
    __swig_getmethods__["performHs"] = _vclapi.VclBiflowModQos_performHs_get
    if _newclass:performHs = property(_vclapi.VclBiflowModQos_performHs_get, _vclapi.VclBiflowModQos_performHs_set)
    __swig_setmethods__["uapsdEnable"] = _vclapi.VclBiflowModQos_uapsdEnable_set
    __swig_getmethods__["uapsdEnable"] = _vclapi.VclBiflowModQos_uapsdEnable_get
    if _newclass:uapsdEnable = property(_vclapi.VclBiflowModQos_uapsdEnable_get, _vclapi.VclBiflowModQos_uapsdEnable_set)
    __swig_setmethods__["aggregationEnable"] = _vclapi.VclBiflowModQos_aggregationEnable_set
    __swig_getmethods__["aggregationEnable"] = _vclapi.VclBiflowModQos_aggregationEnable_get
    if _newclass:aggregationEnable = property(_vclapi.VclBiflowModQos_aggregationEnable_get, _vclapi.VclBiflowModQos_aggregationEnable_set)
    __swig_setmethods__["aggregationAutoMax"] = _vclapi.VclBiflowModQos_aggregationAutoMax_set
    __swig_getmethods__["aggregationAutoMax"] = _vclapi.VclBiflowModQos_aggregationAutoMax_get
    if _newclass:aggregationAutoMax = property(_vclapi.VclBiflowModQos_aggregationAutoMax_get, _vclapi.VclBiflowModQos_aggregationAutoMax_set)
    __swig_setmethods__["aggregationLimit"] = _vclapi.VclBiflowModQos_aggregationLimit_set
    __swig_getmethods__["aggregationLimit"] = _vclapi.VclBiflowModQos_aggregationLimit_get
    if _newclass:aggregationLimit = property(_vclapi.VclBiflowModQos_aggregationLimit_get, _vclapi.VclBiflowModQos_aggregationLimit_set)
    __swig_setmethods__["minimumMpduStartSpacing"] = _vclapi.VclBiflowModQos_minimumMpduStartSpacing_set
    __swig_getmethods__["minimumMpduStartSpacing"] = _vclapi.VclBiflowModQos_minimumMpduStartSpacing_get
    if _newclass:minimumMpduStartSpacing = property(_vclapi.VclBiflowModQos_minimumMpduStartSpacing_get, _vclapi.VclBiflowModQos_minimumMpduStartSpacing_set)
    def __init__(self, *args):
        _swig_setattr(self, VclBiflowModQos, 'this', _vclapi.new_VclBiflowModQos(*args))
        _swig_setattr(self, VclBiflowModQos, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclBiflowModQos):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclBiflowModQosPtr(VclBiflowModQos):
    def __init__(self, this):
        _swig_setattr(self, VclBiflowModQos, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclBiflowModQos, 'thisown', 0)
        _swig_setattr(self, VclBiflowModQos,self.__class__,VclBiflowModQos)
_vclapi.VclBiflowModQos_swigregister(VclBiflowModQosPtr)

class VclBiflowModIpv4(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclBiflowModIpv4, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclBiflowModIpv4, name)
    def __repr__(self):
        return "<C VclBiflowModIpv4 instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclBiflowModIpv4_setDefaults(*args)
    def readBiflow(*args): return _vclapi.VclBiflowModIpv4_readBiflow(*args)
    def modifyBiflow(*args): return _vclapi.VclBiflowModIpv4_modifyBiflow(*args)
    def read(*args): return _vclapi.VclBiflowModIpv4_read(*args)
    def modify(*args): return _vclapi.VclBiflowModIpv4_modify(*args)
    def setDefaultBiflow(*args): return _vclapi.VclBiflowModIpv4_setDefaultBiflow(*args)
    def get(*args): return _vclapi.VclBiflowModIpv4_get(*args)
    def set(*args): return _vclapi.VclBiflowModIpv4_set(*args)
    def reflect(*args): return _vclapi.VclBiflowModIpv4_reflect(*args)
    def getDscp(*args): return _vclapi.VclBiflowModIpv4_getDscp(*args)
    def getDscpMode(*args): return _vclapi.VclBiflowModIpv4_getDscpMode(*args)
    def setDscp(*args): return _vclapi.VclBiflowModIpv4_setDscp(*args)
    def setDscpMode(*args): return _vclapi.VclBiflowModIpv4_setDscpMode(*args)
    def setTtl(*args): return _vclapi.VclBiflowModIpv4_setTtl(*args)
    def setTos(*args): return _vclapi.VclBiflowModIpv4_setTos(*args)
    def setPrecedence(*args): return _vclapi.VclBiflowModIpv4_setPrecedence(*args)
    def setTosField(*args): return _vclapi.VclBiflowModIpv4_setTosField(*args)
    def getTtl(*args): return _vclapi.VclBiflowModIpv4_getTtl(*args)
    def getTos(*args): return _vclapi.VclBiflowModIpv4_getTos(*args)
    def getPrecedence(*args): return _vclapi.VclBiflowModIpv4_getPrecedence(*args)
    def getTosField(*args): return _vclapi.VclBiflowModIpv4_getTosField(*args)
    __swig_setmethods__["dscpMode"] = _vclapi.VclBiflowModIpv4_dscpMode_set
    __swig_getmethods__["dscpMode"] = _vclapi.VclBiflowModIpv4_dscpMode_get
    if _newclass:dscpMode = property(_vclapi.VclBiflowModIpv4_dscpMode_get, _vclapi.VclBiflowModIpv4_dscpMode_set)
    __swig_setmethods__["dscp"] = _vclapi.VclBiflowModIpv4_dscp_set
    __swig_getmethods__["dscp"] = _vclapi.VclBiflowModIpv4_dscp_get
    if _newclass:dscp = property(_vclapi.VclBiflowModIpv4_dscp_get, _vclapi.VclBiflowModIpv4_dscp_set)
    def __init__(self, *args):
        _swig_setattr(self, VclBiflowModIpv4, 'this', _vclapi.new_VclBiflowModIpv4(*args))
        _swig_setattr(self, VclBiflowModIpv4, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclBiflowModIpv4):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclBiflowModIpv4Ptr(VclBiflowModIpv4):
    def __init__(self, this):
        _swig_setattr(self, VclBiflowModIpv4, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclBiflowModIpv4, 'thisown', 0)
        _swig_setattr(self, VclBiflowModIpv4,self.__class__,VclBiflowModIpv4)
_vclapi.VclBiflowModIpv4_swigregister(VclBiflowModIpv4Ptr)

class VclRawClient(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclRawClient, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclRawClient, name)
    def __repr__(self):
        return "<C VclRawClient instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclRawClient_setDefaults(*args)
    def create(*args): return _vclapi.VclRawClient_create(*args)
    def destroy(*args): return _vclapi.VclRawClient_destroy(*args)
    def get(*args): return _vclapi.VclRawClient_get(*args)
    def reflect(*args): return _vclapi.VclRawClient_reflect(*args)
    def set(*args): return _vclapi.VclRawClient_set(*args)
    def read(*args): return _vclapi.VclRawClient_read(*args)
    def write(*args): return _vclapi.VclRawClient_write(*args)
    def readStatus(*args): return _vclapi.VclRawClient_readStatus(*args)
    def getName(*args): return _vclapi.VclRawClient_getName(*args)
    def getAppType(*args): return _vclapi.VclRawClient_getAppType(*args)
    def getAppKind(*args): return _vclapi.VclRawClient_getAppKind(*args)
    def getPort(*args): return _vclapi.VclRawClient_getPort(*args)
    def setPort(*args): return _vclapi.VclRawClient_setPort(*args)
    def setDataFlow(*args): return _vclapi.VclRawClient_setDataFlow(*args)
    __swig_getmethods__["name"] = _vclapi.VclRawClient_name_get
    if _newclass:name = property(_vclapi.VclRawClient_name_get)
    __swig_setmethods__["port"] = _vclapi.VclRawClient_port_set
    __swig_getmethods__["port"] = _vclapi.VclRawClient_port_get
    if _newclass:port = property(_vclapi.VclRawClient_port_get, _vclapi.VclRawClient_port_set)
    def __init__(self, *args):
        _swig_setattr(self, VclRawClient, 'this', _vclapi.new_VclRawClient(*args))
        _swig_setattr(self, VclRawClient, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclRawClient):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclRawClientPtr(VclRawClient):
    def __init__(self, this):
        _swig_setattr(self, VclRawClient, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclRawClient, 'thisown', 0)
        _swig_setattr(self, VclRawClient,self.__class__,VclRawClient)
_vclapi.VclRawClient_swigregister(VclRawClientPtr)

class VclRawServer(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclRawServer, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclRawServer, name)
    def __repr__(self):
        return "<C VclRawServer instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclRawServer_setDefaults(*args)
    def create(*args): return _vclapi.VclRawServer_create(*args)
    def destroy(*args): return _vclapi.VclRawServer_destroy(*args)
    def get(*args): return _vclapi.VclRawServer_get(*args)
    def reflect(*args): return _vclapi.VclRawServer_reflect(*args)
    def set(*args): return _vclapi.VclRawServer_set(*args)
    def read(*args): return _vclapi.VclRawServer_read(*args)
    def write(*args): return _vclapi.VclRawServer_write(*args)
    def readStatus(*args): return _vclapi.VclRawServer_readStatus(*args)
    def getName(*args): return _vclapi.VclRawServer_getName(*args)
    def getAppType(*args): return _vclapi.VclRawServer_getAppType(*args)
    def getAppKind(*args): return _vclapi.VclRawServer_getAppKind(*args)
    def getPort(*args): return _vclapi.VclRawServer_getPort(*args)
    def setPort(*args): return _vclapi.VclRawServer_setPort(*args)
    __swig_getmethods__["name"] = _vclapi.VclRawServer_name_get
    if _newclass:name = property(_vclapi.VclRawServer_name_get)
    __swig_setmethods__["port"] = _vclapi.VclRawServer_port_set
    __swig_getmethods__["port"] = _vclapi.VclRawServer_port_get
    if _newclass:port = property(_vclapi.VclRawServer_port_get, _vclapi.VclRawServer_port_set)
    def __init__(self, *args):
        _swig_setattr(self, VclRawServer, 'this', _vclapi.new_VclRawServer(*args))
        _swig_setattr(self, VclRawServer, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclRawServer):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclRawServerPtr(VclRawServer):
    def __init__(self, this):
        _swig_setattr(self, VclRawServer, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclRawServer, 'thisown', 0)
        _swig_setattr(self, VclRawServer,self.__class__,VclRawServer)
_vclapi.VclRawServer_swigregister(VclRawServerPtr)

class VclHttpClient(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclHttpClient, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclHttpClient, name)
    def __repr__(self):
        return "<C VclHttpClient instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclHttpClient_setDefaults(*args)
    def create(*args): return _vclapi.VclHttpClient_create(*args)
    def destroy(*args): return _vclapi.VclHttpClient_destroy(*args)
    def get(*args): return _vclapi.VclHttpClient_get(*args)
    def reflect(*args): return _vclapi.VclHttpClient_reflect(*args)
    def set(*args): return _vclapi.VclHttpClient_set(*args)
    def read(*args): return _vclapi.VclHttpClient_read(*args)
    def write(*args): return _vclapi.VclHttpClient_write(*args)
    def readStatus(*args): return _vclapi.VclHttpClient_readStatus(*args)
    def getName(*args): return _vclapi.VclHttpClient_getName(*args)
    def getAppType(*args): return _vclapi.VclHttpClient_getAppType(*args)
    def getAppKind(*args): return _vclapi.VclHttpClient_getAppKind(*args)
    def setPort(*args): return _vclapi.VclHttpClient_setPort(*args)
    def setOperation(*args): return _vclapi.VclHttpClient_setOperation(*args)
    def setDataFlow(*args): return _vclapi.VclHttpClient_setDataFlow(*args)
    def setContentLength(*args): return _vclapi.VclHttpClient_setContentLength(*args)
    __swig_getmethods__["name"] = _vclapi.VclHttpClient_name_get
    if _newclass:name = property(_vclapi.VclHttpClient_name_get)
    __swig_setmethods__["port"] = _vclapi.VclHttpClient_port_set
    __swig_getmethods__["port"] = _vclapi.VclHttpClient_port_get
    if _newclass:port = property(_vclapi.VclHttpClient_port_get, _vclapi.VclHttpClient_port_set)
    __swig_setmethods__["operation"] = _vclapi.VclHttpClient_operation_set
    __swig_getmethods__["operation"] = _vclapi.VclHttpClient_operation_get
    if _newclass:operation = property(_vclapi.VclHttpClient_operation_get, _vclapi.VclHttpClient_operation_set)
    __swig_setmethods__["contentLength"] = _vclapi.VclHttpClient_contentLength_set
    __swig_getmethods__["contentLength"] = _vclapi.VclHttpClient_contentLength_get
    if _newclass:contentLength = property(_vclapi.VclHttpClient_contentLength_get, _vclapi.VclHttpClient_contentLength_set)
    def __init__(self, *args):
        _swig_setattr(self, VclHttpClient, 'this', _vclapi.new_VclHttpClient(*args))
        _swig_setattr(self, VclHttpClient, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclHttpClient):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclHttpClientPtr(VclHttpClient):
    def __init__(self, this):
        _swig_setattr(self, VclHttpClient, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclHttpClient, 'thisown', 0)
        _swig_setattr(self, VclHttpClient,self.__class__,VclHttpClient)
_vclapi.VclHttpClient_swigregister(VclHttpClientPtr)

class VclHttpServer(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclHttpServer, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclHttpServer, name)
    def __repr__(self):
        return "<C VclHttpServer instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclHttpServer_setDefaults(*args)
    def create(*args): return _vclapi.VclHttpServer_create(*args)
    def destroy(*args): return _vclapi.VclHttpServer_destroy(*args)
    def get(*args): return _vclapi.VclHttpServer_get(*args)
    def reflect(*args): return _vclapi.VclHttpServer_reflect(*args)
    def set(*args): return _vclapi.VclHttpServer_set(*args)
    def read(*args): return _vclapi.VclHttpServer_read(*args)
    def write(*args): return _vclapi.VclHttpServer_write(*args)
    def readStatus(*args): return _vclapi.VclHttpServer_readStatus(*args)
    def getName(*args): return _vclapi.VclHttpServer_getName(*args)
    def getAppType(*args): return _vclapi.VclHttpServer_getAppType(*args)
    def getAppKind(*args): return _vclapi.VclHttpServer_getAppKind(*args)
    def setPort(*args): return _vclapi.VclHttpServer_setPort(*args)
    def setOperation(*args): return _vclapi.VclHttpServer_setOperation(*args)
    __swig_getmethods__["name"] = _vclapi.VclHttpServer_name_get
    if _newclass:name = property(_vclapi.VclHttpServer_name_get)
    __swig_setmethods__["port"] = _vclapi.VclHttpServer_port_set
    __swig_getmethods__["port"] = _vclapi.VclHttpServer_port_get
    if _newclass:port = property(_vclapi.VclHttpServer_port_get, _vclapi.VclHttpServer_port_set)
    __swig_setmethods__["operation"] = _vclapi.VclHttpServer_operation_set
    __swig_getmethods__["operation"] = _vclapi.VclHttpServer_operation_get
    if _newclass:operation = property(_vclapi.VclHttpServer_operation_get, _vclapi.VclHttpServer_operation_set)
    def __init__(self, *args):
        _swig_setattr(self, VclHttpServer, 'this', _vclapi.new_VclHttpServer(*args))
        _swig_setattr(self, VclHttpServer, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclHttpServer):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclHttpServerPtr(VclHttpServer):
    def __init__(self, this):
        _swig_setattr(self, VclHttpServer, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclHttpServer, 'thisown', 0)
        _swig_setattr(self, VclHttpServer,self.__class__,VclHttpServer)
_vclapi.VclHttpServer_swigregister(VclHttpServerPtr)

class VclAppSession(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclAppSession, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclAppSession, name)
    def __repr__(self):
        return "<C VclAppSession instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclAppSession_setDefaults(*args)
    def readBiflow(*args): return _vclapi.VclAppSession_readBiflow(*args)
    def modifyBiflow(*args): return _vclapi.VclAppSession_modifyBiflow(*args)
    def read(*args): return _vclapi.VclAppSession_read(*args)
    def modify(*args): return _vclapi.VclAppSession_modify(*args)
    def setDefaultBiflow(*args): return _vclapi.VclAppSession_setDefaultBiflow(*args)
    def getClientApp(*args): return _vclapi.VclAppSession_getClientApp(*args)
    def setClientApp(*args): return _vclapi.VclAppSession_setClientApp(*args)
    def getClientNetIf(*args): return _vclapi.VclAppSession_getClientNetIf(*args)
    def setClientNetIf(*args): return _vclapi.VclAppSession_setClientNetIf(*args)
    def getServerApp(*args): return _vclapi.VclAppSession_getServerApp(*args)
    def setServerApp(*args): return _vclapi.VclAppSession_setServerApp(*args)
    def getServerNetIf(*args): return _vclapi.VclAppSession_getServerNetIf(*args)
    def setServerNetIf(*args): return _vclapi.VclAppSession_setServerNetIf(*args)
    __swig_setmethods__["clientApp"] = _vclapi.VclAppSession_clientApp_set
    __swig_getmethods__["clientApp"] = _vclapi.VclAppSession_clientApp_get
    if _newclass:clientApp = property(_vclapi.VclAppSession_clientApp_get, _vclapi.VclAppSession_clientApp_set)
    __swig_setmethods__["clientNetIf"] = _vclapi.VclAppSession_clientNetIf_set
    __swig_getmethods__["clientNetIf"] = _vclapi.VclAppSession_clientNetIf_get
    if _newclass:clientNetIf = property(_vclapi.VclAppSession_clientNetIf_get, _vclapi.VclAppSession_clientNetIf_set)
    __swig_setmethods__["serverApp"] = _vclapi.VclAppSession_serverApp_set
    __swig_getmethods__["serverApp"] = _vclapi.VclAppSession_serverApp_get
    if _newclass:serverApp = property(_vclapi.VclAppSession_serverApp_get, _vclapi.VclAppSession_serverApp_set)
    __swig_setmethods__["serverNetIf"] = _vclapi.VclAppSession_serverNetIf_set
    __swig_getmethods__["serverNetIf"] = _vclapi.VclAppSession_serverNetIf_get
    if _newclass:serverNetIf = property(_vclapi.VclAppSession_serverNetIf_get, _vclapi.VclAppSession_serverNetIf_set)
    def __init__(self, *args):
        _swig_setattr(self, VclAppSession, 'this', _vclapi.new_VclAppSession(*args))
        _swig_setattr(self, VclAppSession, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclAppSession):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclAppSessionPtr(VclAppSession):
    def __init__(self, this):
        _swig_setattr(self, VclAppSession, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclAppSession, 'thisown', 0)
        _swig_setattr(self, VclAppSession,self.__class__,VclAppSession)
_vclapi.VclAppSession_swigregister(VclAppSessionPtr)

class VclFtpClient(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFtpClient, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFtpClient, name)
    def __repr__(self):
        return "<C VclFtpClient instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclFtpClient_setDefaults(*args)
    def create(*args): return _vclapi.VclFtpClient_create(*args)
    def destroy(*args): return _vclapi.VclFtpClient_destroy(*args)
    def get(*args): return _vclapi.VclFtpClient_get(*args)
    def reflect(*args): return _vclapi.VclFtpClient_reflect(*args)
    def set(*args): return _vclapi.VclFtpClient_set(*args)
    def read(*args): return _vclapi.VclFtpClient_read(*args)
    def write(*args): return _vclapi.VclFtpClient_write(*args)
    def readStatus(*args): return _vclapi.VclFtpClient_readStatus(*args)
    def getName(*args): return _vclapi.VclFtpClient_getName(*args)
    def getAppType(*args): return _vclapi.VclFtpClient_getAppType(*args)
    def getAppKind(*args): return _vclapi.VclFtpClient_getAppKind(*args)
    def setOperation(*args): return _vclapi.VclFtpClient_setOperation(*args)
    def setDataFlow(*args): return _vclapi.VclFtpClient_setDataFlow(*args)
    def setFileName(*args): return _vclapi.VclFtpClient_setFileName(*args)
    def setFileSize(*args): return _vclapi.VclFtpClient_setFileSize(*args)
    def setUserName(*args): return _vclapi.VclFtpClient_setUserName(*args)
    def setPassword(*args): return _vclapi.VclFtpClient_setPassword(*args)
    def setControlPort(*args): return _vclapi.VclFtpClient_setControlPort(*args)
    def setDataPort(*args): return _vclapi.VclFtpClient_setDataPort(*args)
    __swig_getmethods__["name"] = _vclapi.VclFtpClient_name_get
    if _newclass:name = property(_vclapi.VclFtpClient_name_get)
    __swig_setmethods__["controlPort"] = _vclapi.VclFtpClient_controlPort_set
    __swig_getmethods__["controlPort"] = _vclapi.VclFtpClient_controlPort_get
    if _newclass:controlPort = property(_vclapi.VclFtpClient_controlPort_get, _vclapi.VclFtpClient_controlPort_set)
    __swig_setmethods__["dataPort"] = _vclapi.VclFtpClient_dataPort_set
    __swig_getmethods__["dataPort"] = _vclapi.VclFtpClient_dataPort_get
    if _newclass:dataPort = property(_vclapi.VclFtpClient_dataPort_get, _vclapi.VclFtpClient_dataPort_set)
    __swig_setmethods__["operation"] = _vclapi.VclFtpClient_operation_set
    __swig_getmethods__["operation"] = _vclapi.VclFtpClient_operation_get
    if _newclass:operation = property(_vclapi.VclFtpClient_operation_get, _vclapi.VclFtpClient_operation_set)
    __swig_setmethods__["fileSize"] = _vclapi.VclFtpClient_fileSize_set
    __swig_getmethods__["fileSize"] = _vclapi.VclFtpClient_fileSize_get
    if _newclass:fileSize = property(_vclapi.VclFtpClient_fileSize_get, _vclapi.VclFtpClient_fileSize_set)
    __swig_setmethods__["fileName"] = _vclapi.VclFtpClient_fileName_set
    __swig_getmethods__["fileName"] = _vclapi.VclFtpClient_fileName_get
    if _newclass:fileName = property(_vclapi.VclFtpClient_fileName_get, _vclapi.VclFtpClient_fileName_set)
    __swig_setmethods__["userName"] = _vclapi.VclFtpClient_userName_set
    __swig_getmethods__["userName"] = _vclapi.VclFtpClient_userName_get
    if _newclass:userName = property(_vclapi.VclFtpClient_userName_get, _vclapi.VclFtpClient_userName_set)
    __swig_setmethods__["password"] = _vclapi.VclFtpClient_password_set
    __swig_getmethods__["password"] = _vclapi.VclFtpClient_password_get
    if _newclass:password = property(_vclapi.VclFtpClient_password_get, _vclapi.VclFtpClient_password_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFtpClient, 'this', _vclapi.new_VclFtpClient(*args))
        _swig_setattr(self, VclFtpClient, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFtpClient):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFtpClientPtr(VclFtpClient):
    def __init__(self, this):
        _swig_setattr(self, VclFtpClient, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFtpClient, 'thisown', 0)
        _swig_setattr(self, VclFtpClient,self.__class__,VclFtpClient)
_vclapi.VclFtpClient_swigregister(VclFtpClientPtr)

class VclFtpServer(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclFtpServer, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclFtpServer, name)
    def __repr__(self):
        return "<C VclFtpServer instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclFtpServer_setDefaults(*args)
    def create(*args): return _vclapi.VclFtpServer_create(*args)
    def destroy(*args): return _vclapi.VclFtpServer_destroy(*args)
    def get(*args): return _vclapi.VclFtpServer_get(*args)
    def reflect(*args): return _vclapi.VclFtpServer_reflect(*args)
    def set(*args): return _vclapi.VclFtpServer_set(*args)
    def read(*args): return _vclapi.VclFtpServer_read(*args)
    def write(*args): return _vclapi.VclFtpServer_write(*args)
    def readStatus(*args): return _vclapi.VclFtpServer_readStatus(*args)
    def getName(*args): return _vclapi.VclFtpServer_getName(*args)
    def getAppType(*args): return _vclapi.VclFtpServer_getAppType(*args)
    def getAppKind(*args): return _vclapi.VclFtpServer_getAppKind(*args)
    def setOperation(*args): return _vclapi.VclFtpServer_setOperation(*args)
    def setControlPort(*args): return _vclapi.VclFtpServer_setControlPort(*args)
    def setDataPort(*args): return _vclapi.VclFtpServer_setDataPort(*args)
    __swig_getmethods__["name"] = _vclapi.VclFtpServer_name_get
    if _newclass:name = property(_vclapi.VclFtpServer_name_get)
    __swig_setmethods__["controlPort"] = _vclapi.VclFtpServer_controlPort_set
    __swig_getmethods__["controlPort"] = _vclapi.VclFtpServer_controlPort_get
    if _newclass:controlPort = property(_vclapi.VclFtpServer_controlPort_get, _vclapi.VclFtpServer_controlPort_set)
    __swig_setmethods__["dataPort"] = _vclapi.VclFtpServer_dataPort_set
    __swig_getmethods__["dataPort"] = _vclapi.VclFtpServer_dataPort_get
    if _newclass:dataPort = property(_vclapi.VclFtpServer_dataPort_get, _vclapi.VclFtpServer_dataPort_set)
    __swig_setmethods__["operation"] = _vclapi.VclFtpServer_operation_set
    __swig_getmethods__["operation"] = _vclapi.VclFtpServer_operation_get
    if _newclass:operation = property(_vclapi.VclFtpServer_operation_get, _vclapi.VclFtpServer_operation_set)
    __swig_setmethods__["fileSize"] = _vclapi.VclFtpServer_fileSize_set
    __swig_getmethods__["fileSize"] = _vclapi.VclFtpServer_fileSize_get
    if _newclass:fileSize = property(_vclapi.VclFtpServer_fileSize_get, _vclapi.VclFtpServer_fileSize_set)
    __swig_setmethods__["fileName"] = _vclapi.VclFtpServer_fileName_set
    __swig_getmethods__["fileName"] = _vclapi.VclFtpServer_fileName_get
    if _newclass:fileName = property(_vclapi.VclFtpServer_fileName_get, _vclapi.VclFtpServer_fileName_set)
    __swig_setmethods__["userName"] = _vclapi.VclFtpServer_userName_set
    __swig_getmethods__["userName"] = _vclapi.VclFtpServer_userName_get
    if _newclass:userName = property(_vclapi.VclFtpServer_userName_get, _vclapi.VclFtpServer_userName_set)
    __swig_setmethods__["password"] = _vclapi.VclFtpServer_password_set
    __swig_getmethods__["password"] = _vclapi.VclFtpServer_password_get
    if _newclass:password = property(_vclapi.VclFtpServer_password_get, _vclapi.VclFtpServer_password_set)
    def __init__(self, *args):
        _swig_setattr(self, VclFtpServer, 'this', _vclapi.new_VclFtpServer(*args))
        _swig_setattr(self, VclFtpServer, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclFtpServer):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclFtpServerPtr(VclFtpServer):
    def __init__(self, this):
        _swig_setattr(self, VclFtpServer, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclFtpServer, 'thisown', 0)
        _swig_setattr(self, VclFtpServer,self.__class__,VclFtpServer)
_vclapi.VclFtpServer_swigregister(VclFtpServerPtr)

class VclSession(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclSession, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclSession, name)
    def __repr__(self):
        return "<C VclSession instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclSession_setDefaults(*args)
    def get(*args): return _vclapi.VclSession_get(*args)
    def reflect(*args): return _vclapi.VclSession_reflect(*args)
    def set(*args): return _vclapi.VclSession_set(*args)
    def getAppRoot(*args): return _vclapi.VclSession_getAppRoot(*args)
    def getFeatures(*args): return _vclapi.VclSession_getFeatures(*args)
    def getSchema(*args): return _vclapi.VclSession_getSchema(*args)
    def setAppRoot(*args): return _vclapi.VclSession_setAppRoot(*args)
    __swig_setmethods__["appRoot"] = _vclapi.VclSession_appRoot_set
    __swig_getmethods__["appRoot"] = _vclapi.VclSession_appRoot_get
    if _newclass:appRoot = property(_vclapi.VclSession_appRoot_get, _vclapi.VclSession_appRoot_set)
    def checkSegment(*args): return _vclapi.VclSession_checkSegment(*args)
    def applyKey(*args): return _vclapi.VclSession_applyKey(*args)
    def checkTest(*args): return _vclapi.VclSession_checkTest(*args)
    def checkFeature(*args): return _vclapi.VclSession_checkFeature(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclSession, 'this', _vclapi.new_VclSession(*args))
        _swig_setattr(self, VclSession, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclSession):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclSessionPtr(VclSession):
    def __init__(self, this):
        _swig_setattr(self, VclSession, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclSession, 'thisown', 0)
        _swig_setattr(self, VclSession,self.__class__,VclSession)
_vclapi.VclSession_swigregister(VclSessionPtr)

class VclTheoreticalThroughput(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclTheoreticalThroughput, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclTheoreticalThroughput, name)
    def __repr__(self):
        return "<C VclTheoreticalThroughput instance at %s>" % (self.this,)
    def get(*args): return _vclapi.VclTheoreticalThroughput_get(*args)
    def reflect(*args): return _vclapi.VclTheoreticalThroughput_reflect(*args)
    def set(*args): return _vclapi.VclTheoreticalThroughput_set(*args)
    def getBasicRates(*args): return _vclapi.VclTheoreticalThroughput_getBasicRates(*args)
    def setBasicRates(*args): return _vclapi.VclTheoreticalThroughput_setBasicRates(*args)
    def calculate(*args): return _vclapi.VclTheoreticalThroughput_calculate(*args)
    def calcMeanBackoff(*args): return _vclapi.VclTheoreticalThroughput_calcMeanBackoff(*args)
    def calcL2MediumTime(*args): return _vclapi.VclTheoreticalThroughput_calcL2MediumTime(*args)
    def getActualMpduCount(*args): return _vclapi.VclTheoreticalThroughput_getActualMpduCount(*args)
    def __init__(self, *args):
        _swig_setattr(self, VclTheoreticalThroughput, 'this', _vclapi.new_VclTheoreticalThroughput(*args))
        _swig_setattr(self, VclTheoreticalThroughput, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclTheoreticalThroughput):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclTheoreticalThroughputPtr(VclTheoreticalThroughput):
    def __init__(self, this):
        _swig_setattr(self, VclTheoreticalThroughput, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclTheoreticalThroughput, 'thisown', 0)
        _swig_setattr(self, VclTheoreticalThroughput,self.__class__,VclTheoreticalThroughput)
_vclapi.VclTheoreticalThroughput_swigregister(VclTheoreticalThroughputPtr)

class VclRoamingArea(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclRoamingArea, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclRoamingArea, name)
    def __repr__(self):
        return "<C VclRoamingArea instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclRoamingArea_create(*args)
    def write(*args): return _vclapi.VclRoamingArea_write(*args)
    def read(*args): return _vclapi.VclRoamingArea_read(*args)
    def destroy(*args): return _vclapi.VclRoamingArea_destroy(*args)
    def getNames(*args): return _vclapi.VclRoamingArea_getNames(*args)
    def setPortList(*args): return _vclapi.VclRoamingArea_setPortList(*args)
    def getPortList(*args): return _vclapi.VclRoamingArea_getPortList(*args)
    def setAnchorPort(*args): return _vclapi.VclRoamingArea_setAnchorPort(*args)
    def getAnchorPort(*args): return _vclapi.VclRoamingArea_getAnchorPort(*args)
    __swig_setmethods__["portList"] = _vclapi.VclRoamingArea_portList_set
    __swig_getmethods__["portList"] = _vclapi.VclRoamingArea_portList_get
    if _newclass:portList = property(_vclapi.VclRoamingArea_portList_get, _vclapi.VclRoamingArea_portList_set)
    __swig_setmethods__["anchorPort"] = _vclapi.VclRoamingArea_anchorPort_set
    __swig_getmethods__["anchorPort"] = _vclapi.VclRoamingArea_anchorPort_get
    if _newclass:anchorPort = property(_vclapi.VclRoamingArea_anchorPort_get, _vclapi.VclRoamingArea_anchorPort_set)
    def __init__(self, *args):
        _swig_setattr(self, VclRoamingArea, 'this', _vclapi.new_VclRoamingArea(*args))
        _swig_setattr(self, VclRoamingArea, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclRoamingArea):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclRoamingAreaPtr(VclRoamingArea):
    def __init__(self, this):
        _swig_setattr(self, VclRoamingArea, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclRoamingArea, 'thisown', 0)
        _swig_setattr(self, VclRoamingArea,self.__class__,VclRoamingArea)
_vclapi.VclRoamingArea_swigregister(VclRoamingAreaPtr)

class VclRoamingCircuit(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclRoamingCircuit, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclRoamingCircuit, name)
    def __repr__(self):
        return "<C VclRoamingCircuit instance at %s>" % (self.this,)
    def create(*args): return _vclapi.VclRoamingCircuit_create(*args)
    def write(*args): return _vclapi.VclRoamingCircuit_write(*args)
    def read(*args): return _vclapi.VclRoamingCircuit_read(*args)
    def destroy(*args): return _vclapi.VclRoamingCircuit_destroy(*args)
    def getNames(*args): return _vclapi.VclRoamingCircuit_getNames(*args)
    def startRoaming(*args): return _vclapi.VclRoamingCircuit_startRoaming(*args)
    def stopRoaming(*args): return _vclapi.VclRoamingCircuit_stopRoaming(*args)
    def setPortList(*args): return _vclapi.VclRoamingCircuit_setPortList(*args)
    def getPortList(*args): return _vclapi.VclRoamingCircuit_getPortList(*args)
    def setBssidList(*args): return _vclapi.VclRoamingCircuit_setBssidList(*args)
    def getBssidList(*args): return _vclapi.VclRoamingCircuit_getBssidList(*args)
    def setRoamingArea(*args): return _vclapi.VclRoamingCircuit_setRoamingArea(*args)
    def getRoamingArea(*args): return _vclapi.VclRoamingCircuit_getRoamingArea(*args)
    def setDwellTime(*args): return _vclapi.VclRoamingCircuit_setDwellTime(*args)
    def getDwellTime(*args): return _vclapi.VclRoamingCircuit_getDwellTime(*args)
    def setRoamingRate(*args): return _vclapi.VclRoamingCircuit_setRoamingRate(*args)
    def getRoamingRate(*args): return _vclapi.VclRoamingCircuit_getRoamingRate(*args)
    __swig_setmethods__["portList"] = _vclapi.VclRoamingCircuit_portList_set
    __swig_getmethods__["portList"] = _vclapi.VclRoamingCircuit_portList_get
    if _newclass:portList = property(_vclapi.VclRoamingCircuit_portList_get, _vclapi.VclRoamingCircuit_portList_set)
    __swig_setmethods__["bssidList"] = _vclapi.VclRoamingCircuit_bssidList_set
    __swig_getmethods__["bssidList"] = _vclapi.VclRoamingCircuit_bssidList_get
    if _newclass:bssidList = property(_vclapi.VclRoamingCircuit_bssidList_get, _vclapi.VclRoamingCircuit_bssidList_set)
    __swig_setmethods__["roamingArea"] = _vclapi.VclRoamingCircuit_roamingArea_set
    __swig_getmethods__["roamingArea"] = _vclapi.VclRoamingCircuit_roamingArea_get
    if _newclass:roamingArea = property(_vclapi.VclRoamingCircuit_roamingArea_get, _vclapi.VclRoamingCircuit_roamingArea_set)
    __swig_setmethods__["dwellTime"] = _vclapi.VclRoamingCircuit_dwellTime_set
    __swig_getmethods__["dwellTime"] = _vclapi.VclRoamingCircuit_dwellTime_get
    if _newclass:dwellTime = property(_vclapi.VclRoamingCircuit_dwellTime_get, _vclapi.VclRoamingCircuit_dwellTime_set)
    __swig_setmethods__["roamingRate"] = _vclapi.VclRoamingCircuit_roamingRate_set
    __swig_getmethods__["roamingRate"] = _vclapi.VclRoamingCircuit_roamingRate_get
    if _newclass:roamingRate = property(_vclapi.VclRoamingCircuit_roamingRate_get, _vclapi.VclRoamingCircuit_roamingRate_set)
    def __init__(self, *args):
        _swig_setattr(self, VclRoamingCircuit, 'this', _vclapi.new_VclRoamingCircuit(*args))
        _swig_setattr(self, VclRoamingCircuit, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclRoamingCircuit):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclRoamingCircuitPtr(VclRoamingCircuit):
    def __init__(self, this):
        _swig_setattr(self, VclRoamingCircuit, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclRoamingCircuit, 'thisown', 0)
        _swig_setattr(self, VclRoamingCircuit,self.__class__,VclRoamingCircuit)
_vclapi.VclRoamingCircuit_swigregister(VclRoamingCircuitPtr)

class VclRoamingStatsCapture(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclRoamingStatsCapture, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclRoamingStatsCapture, name)
    def __repr__(self):
        return "<C VclRoamingStatsCapture instance at %s>" % (self.this,)
    def open(*args): return _vclapi.VclRoamingStatsCapture_open(*args)
    def close(*args): return _vclapi.VclRoamingStatsCapture_close(*args)
    def enable(*args): return _vclapi.VclRoamingStatsCapture_enable(*args)
    def disable(*args): return _vclapi.VclRoamingStatsCapture_disable(*args)
    def clear(*args): return _vclapi.VclRoamingStatsCapture_clear(*args)
    def getRoamingAreaList(*args): return _vclapi.VclRoamingStatsCapture_getRoamingAreaList(*args)
    def setRoamingAreaList(*args): return _vclapi.VclRoamingStatsCapture_setRoamingAreaList(*args)
    def save(*args): return _vclapi.VclRoamingStatsCapture_save(*args)
    __swig_setmethods__["roamingAreaList"] = _vclapi.VclRoamingStatsCapture_roamingAreaList_set
    __swig_getmethods__["roamingAreaList"] = _vclapi.VclRoamingStatsCapture_roamingAreaList_get
    if _newclass:roamingAreaList = property(_vclapi.VclRoamingStatsCapture_roamingAreaList_get, _vclapi.VclRoamingStatsCapture_roamingAreaList_set)
    def __init__(self, *args):
        _swig_setattr(self, VclRoamingStatsCapture, 'this', _vclapi.new_VclRoamingStatsCapture(*args))
        _swig_setattr(self, VclRoamingStatsCapture, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclRoamingStatsCapture):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclRoamingStatsCapturePtr(VclRoamingStatsCapture):
    def __init__(self, this):
        _swig_setattr(self, VclRoamingStatsCapture, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclRoamingStatsCapture, 'thisown', 0)
        _swig_setattr(self, VclRoamingStatsCapture,self.__class__,VclRoamingStatsCapture)
_vclapi.VclRoamingStatsCapture_swigregister(VclRoamingStatsCapturePtr)

class VclRoamingRecord(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclRoamingRecord, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclRoamingRecord, name)
    def __repr__(self):
        return "<C VclRoamingRecord instance at %s>" % (self.this,)
    def open(*args): return _vclapi.VclRoamingRecord_open(*args)
    def close(*args): return _vclapi.VclRoamingRecord_close(*args)
    def read(*args): return _vclapi.VclRoamingRecord_read(*args)
    def setDefaults(*args): return _vclapi.VclRoamingRecord_setDefaults(*args)
    def getRoamNumber(*args): return _vclapi.VclRoamingRecord_getRoamNumber(*args)
    def getClientIndex(*args): return _vclapi.VclRoamingRecord_getClientIndex(*args)
    def getClientName(*args): return _vclapi.VclRoamingRecord_getClientName(*args)
    def getTxMcAssociationStartTime(*args): return _vclapi.VclRoamingRecord_getTxMcAssociationStartTime(*args)
    def getRxMcAssociationEndTime(*args): return _vclapi.VclRoamingRecord_getRxMcAssociationEndTime(*args)
    def getRxMcDeauthDisassocTime(*args): return _vclapi.VclRoamingRecord_getRxMcDeauthDisassocTime(*args)
    def getTxMcStartTime(*args): return _vclapi.VclRoamingRecord_getTxMcStartTime(*args)
    def getTxMcEndTime(*args): return _vclapi.VclRoamingRecord_getTxMcEndTime(*args)
    def getRxMcStartTime(*args): return _vclapi.VclRoamingRecord_getRxMcStartTime(*args)
    def getRxMcEndTime(*args): return _vclapi.VclRoamingRecord_getRxMcEndTime(*args)
    def getTgaProcessingTime(*args): return _vclapi.VclRoamingRecord_getTgaProcessingTime(*args)
    def getTstampProbeRsp(*args): return _vclapi.VclRoamingRecord_getTstampProbeRsp(*args)
    def getTstampAuth1Rsp(*args): return _vclapi.VclRoamingRecord_getTstampAuth1Rsp(*args)
    def getTstampAuth2Rsp(*args): return _vclapi.VclRoamingRecord_getTstampAuth2Rsp(*args)
    def getTstampEapReqIdentity(*args): return _vclapi.VclRoamingRecord_getTstampEapReqIdentity(*args)
    def getTstampEapSuccessOrFailure(*args): return _vclapi.VclRoamingRecord_getTstampEapSuccessOrFailure(*args)
    def getTstampEapolPairwiseKey(*args): return _vclapi.VclRoamingRecord_getTstampEapolPairwiseKey(*args)
    def getTstampEapolGroupKey(*args): return _vclapi.VclRoamingRecord_getTstampEapolGroupKey(*args)
    def getTstampMcConnectionComplete(*args): return _vclapi.VclRoamingRecord_getTstampMcConnectionComplete(*args)
    def getTstampAuth1Req(*args): return _vclapi.VclRoamingRecord_getTstampAuth1Req(*args)
    def getTstampAuth2Req(*args): return _vclapi.VclRoamingRecord_getTstampAuth2Req(*args)
    def getTstampAssocReq(*args): return _vclapi.VclRoamingRecord_getTstampAssocReq(*args)
    def getTstampAssocRsp(*args): return _vclapi.VclRoamingRecord_getTstampAssocRsp(*args)
    def getTstampEapRspIdentity(*args): return _vclapi.VclRoamingRecord_getTstampEapRspIdentity(*args)
    def getTstampDhcpDiscover(*args): return _vclapi.VclRoamingRecord_getTstampDhcpDiscover(*args)
    def getTstampDhcpOffer(*args): return _vclapi.VclRoamingRecord_getTstampDhcpOffer(*args)
    def getTstampDhcpRequest(*args): return _vclapi.VclRoamingRecord_getTstampDhcpRequest(*args)
    def getTstampDhcpAck(*args): return _vclapi.VclRoamingRecord_getTstampDhcpAck(*args)
    def getTstampNatReq(*args): return _vclapi.VclRoamingRecord_getTstampNatReq(*args)
    def getTstampNatRsp(*args): return _vclapi.VclRoamingRecord_getTstampNatRsp(*args)
    def getTstampNatArpReq(*args): return _vclapi.VclRoamingRecord_getTstampNatArpReq(*args)
    def getTstampNatArpRsp(*args): return _vclapi.VclRoamingRecord_getTstampNatArpRsp(*args)
    def getSrcBssid(*args): return _vclapi.VclRoamingRecord_getSrcBssid(*args)
    def getTargetBssid(*args): return _vclapi.VclRoamingRecord_getTargetBssid(*args)
    def getSrcChassisId(*args): return _vclapi.VclRoamingRecord_getSrcChassisId(*args)
    def getSrcSlotId(*args): return _vclapi.VclRoamingRecord_getSrcSlotId(*args)
    def getSrcPortId(*args): return _vclapi.VclRoamingRecord_getSrcPortId(*args)
    def getTargetChassisId(*args): return _vclapi.VclRoamingRecord_getTargetChassisId(*args)
    def getTargetSlotId(*args): return _vclapi.VclRoamingRecord_getTargetSlotId(*args)
    def getTargetPortId(*args): return _vclapi.VclRoamingRecord_getTargetPortId(*args)
    __swig_getmethods__["roamNumber"] = _vclapi.VclRoamingRecord_roamNumber_get
    if _newclass:roamNumber = property(_vclapi.VclRoamingRecord_roamNumber_get)
    __swig_getmethods__["clientIndex"] = _vclapi.VclRoamingRecord_clientIndex_get
    if _newclass:clientIndex = property(_vclapi.VclRoamingRecord_clientIndex_get)
    __swig_getmethods__["txMcAssociationStartTime"] = _vclapi.VclRoamingRecord_txMcAssociationStartTime_get
    if _newclass:txMcAssociationStartTime = property(_vclapi.VclRoamingRecord_txMcAssociationStartTime_get)
    __swig_getmethods__["rxMcAssociationEndTime"] = _vclapi.VclRoamingRecord_rxMcAssociationEndTime_get
    if _newclass:rxMcAssociationEndTime = property(_vclapi.VclRoamingRecord_rxMcAssociationEndTime_get)
    __swig_getmethods__["rxMcDeauthDisassocTime"] = _vclapi.VclRoamingRecord_rxMcDeauthDisassocTime_get
    if _newclass:rxMcDeauthDisassocTime = property(_vclapi.VclRoamingRecord_rxMcDeauthDisassocTime_get)
    __swig_getmethods__["txMcStartTime"] = _vclapi.VclRoamingRecord_txMcStartTime_get
    if _newclass:txMcStartTime = property(_vclapi.VclRoamingRecord_txMcStartTime_get)
    __swig_getmethods__["txMcEndTime"] = _vclapi.VclRoamingRecord_txMcEndTime_get
    if _newclass:txMcEndTime = property(_vclapi.VclRoamingRecord_txMcEndTime_get)
    __swig_getmethods__["rxMcStartTime"] = _vclapi.VclRoamingRecord_rxMcStartTime_get
    if _newclass:rxMcStartTime = property(_vclapi.VclRoamingRecord_rxMcStartTime_get)
    __swig_getmethods__["rxMcEndTime"] = _vclapi.VclRoamingRecord_rxMcEndTime_get
    if _newclass:rxMcEndTime = property(_vclapi.VclRoamingRecord_rxMcEndTime_get)
    __swig_getmethods__["tgaProcessingTime"] = _vclapi.VclRoamingRecord_tgaProcessingTime_get
    if _newclass:tgaProcessingTime = property(_vclapi.VclRoamingRecord_tgaProcessingTime_get)
    __swig_getmethods__["tstampProbeRsp"] = _vclapi.VclRoamingRecord_tstampProbeRsp_get
    if _newclass:tstampProbeRsp = property(_vclapi.VclRoamingRecord_tstampProbeRsp_get)
    __swig_getmethods__["tstampAuth1Rsp"] = _vclapi.VclRoamingRecord_tstampAuth1Rsp_get
    if _newclass:tstampAuth1Rsp = property(_vclapi.VclRoamingRecord_tstampAuth1Rsp_get)
    __swig_getmethods__["tstampAuth2Rsp"] = _vclapi.VclRoamingRecord_tstampAuth2Rsp_get
    if _newclass:tstampAuth2Rsp = property(_vclapi.VclRoamingRecord_tstampAuth2Rsp_get)
    __swig_getmethods__["tstampEapReqIdentity"] = _vclapi.VclRoamingRecord_tstampEapReqIdentity_get
    if _newclass:tstampEapReqIdentity = property(_vclapi.VclRoamingRecord_tstampEapReqIdentity_get)
    __swig_getmethods__["tstampEapSuccessOrFailure"] = _vclapi.VclRoamingRecord_tstampEapSuccessOrFailure_get
    if _newclass:tstampEapSuccessOrFailure = property(_vclapi.VclRoamingRecord_tstampEapSuccessOrFailure_get)
    __swig_getmethods__["tstampEapolPairwiseKey"] = _vclapi.VclRoamingRecord_tstampEapolPairwiseKey_get
    if _newclass:tstampEapolPairwiseKey = property(_vclapi.VclRoamingRecord_tstampEapolPairwiseKey_get)
    __swig_getmethods__["tstampEapolGroupKey"] = _vclapi.VclRoamingRecord_tstampEapolGroupKey_get
    if _newclass:tstampEapolGroupKey = property(_vclapi.VclRoamingRecord_tstampEapolGroupKey_get)
    __swig_getmethods__["tstampMcConnectionComplete"] = _vclapi.VclRoamingRecord_tstampMcConnectionComplete_get
    if _newclass:tstampMcConnectionComplete = property(_vclapi.VclRoamingRecord_tstampMcConnectionComplete_get)
    __swig_getmethods__["tstampAuth1Req"] = _vclapi.VclRoamingRecord_tstampAuth1Req_get
    if _newclass:tstampAuth1Req = property(_vclapi.VclRoamingRecord_tstampAuth1Req_get)
    __swig_getmethods__["tstampAuth2Req"] = _vclapi.VclRoamingRecord_tstampAuth2Req_get
    if _newclass:tstampAuth2Req = property(_vclapi.VclRoamingRecord_tstampAuth2Req_get)
    __swig_getmethods__["tstampAssocReq"] = _vclapi.VclRoamingRecord_tstampAssocReq_get
    if _newclass:tstampAssocReq = property(_vclapi.VclRoamingRecord_tstampAssocReq_get)
    __swig_getmethods__["tstampAssocRsp"] = _vclapi.VclRoamingRecord_tstampAssocRsp_get
    if _newclass:tstampAssocRsp = property(_vclapi.VclRoamingRecord_tstampAssocRsp_get)
    __swig_getmethods__["tstampEapRspIdentity"] = _vclapi.VclRoamingRecord_tstampEapRspIdentity_get
    if _newclass:tstampEapRspIdentity = property(_vclapi.VclRoamingRecord_tstampEapRspIdentity_get)
    __swig_getmethods__["tstampDhcpDiscover"] = _vclapi.VclRoamingRecord_tstampDhcpDiscover_get
    if _newclass:tstampDhcpDiscover = property(_vclapi.VclRoamingRecord_tstampDhcpDiscover_get)
    __swig_getmethods__["tstampDhcpOffer"] = _vclapi.VclRoamingRecord_tstampDhcpOffer_get
    if _newclass:tstampDhcpOffer = property(_vclapi.VclRoamingRecord_tstampDhcpOffer_get)
    __swig_getmethods__["tstampDhcpRequest"] = _vclapi.VclRoamingRecord_tstampDhcpRequest_get
    if _newclass:tstampDhcpRequest = property(_vclapi.VclRoamingRecord_tstampDhcpRequest_get)
    __swig_getmethods__["tstampDhcpAck"] = _vclapi.VclRoamingRecord_tstampDhcpAck_get
    if _newclass:tstampDhcpAck = property(_vclapi.VclRoamingRecord_tstampDhcpAck_get)
    __swig_getmethods__["tstampNatReq"] = _vclapi.VclRoamingRecord_tstampNatReq_get
    if _newclass:tstampNatReq = property(_vclapi.VclRoamingRecord_tstampNatReq_get)
    __swig_getmethods__["tstampNatRsp"] = _vclapi.VclRoamingRecord_tstampNatRsp_get
    if _newclass:tstampNatRsp = property(_vclapi.VclRoamingRecord_tstampNatRsp_get)
    __swig_getmethods__["tstampNatArpReq"] = _vclapi.VclRoamingRecord_tstampNatArpReq_get
    if _newclass:tstampNatArpReq = property(_vclapi.VclRoamingRecord_tstampNatArpReq_get)
    __swig_getmethods__["tstampNatArpRsp"] = _vclapi.VclRoamingRecord_tstampNatArpRsp_get
    if _newclass:tstampNatArpRsp = property(_vclapi.VclRoamingRecord_tstampNatArpRsp_get)
    __swig_getmethods__["src_bssid"] = _vclapi.VclRoamingRecord_src_bssid_get
    if _newclass:src_bssid = property(_vclapi.VclRoamingRecord_src_bssid_get)
    __swig_getmethods__["target_bssid"] = _vclapi.VclRoamingRecord_target_bssid_get
    if _newclass:target_bssid = property(_vclapi.VclRoamingRecord_target_bssid_get)
    __swig_getmethods__["src_chassis_id"] = _vclapi.VclRoamingRecord_src_chassis_id_get
    if _newclass:src_chassis_id = property(_vclapi.VclRoamingRecord_src_chassis_id_get)
    __swig_getmethods__["src_slot_id"] = _vclapi.VclRoamingRecord_src_slot_id_get
    if _newclass:src_slot_id = property(_vclapi.VclRoamingRecord_src_slot_id_get)
    __swig_getmethods__["src_port_id"] = _vclapi.VclRoamingRecord_src_port_id_get
    if _newclass:src_port_id = property(_vclapi.VclRoamingRecord_src_port_id_get)
    __swig_getmethods__["target_chassis_id"] = _vclapi.VclRoamingRecord_target_chassis_id_get
    if _newclass:target_chassis_id = property(_vclapi.VclRoamingRecord_target_chassis_id_get)
    __swig_getmethods__["target_slot_id"] = _vclapi.VclRoamingRecord_target_slot_id_get
    if _newclass:target_slot_id = property(_vclapi.VclRoamingRecord_target_slot_id_get)
    __swig_getmethods__["target_port_id"] = _vclapi.VclRoamingRecord_target_port_id_get
    if _newclass:target_port_id = property(_vclapi.VclRoamingRecord_target_port_id_get)
    def __init__(self, *args):
        _swig_setattr(self, VclRoamingRecord, 'this', _vclapi.new_VclRoamingRecord(*args))
        _swig_setattr(self, VclRoamingRecord, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclRoamingRecord):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclRoamingRecordPtr(VclRoamingRecord):
    def __init__(self, this):
        _swig_setattr(self, VclRoamingRecord, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclRoamingRecord, 'thisown', 0)
        _swig_setattr(self, VclRoamingRecord,self.__class__,VclRoamingRecord)
_vclapi.VclRoamingRecord_swigregister(VclRoamingRecordPtr)

class VclStatsRoamingInfoClient(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, VclStatsRoamingInfoClient, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, VclStatsRoamingInfoClient, name)
    def __repr__(self):
        return "<C VclStatsRoamingInfoClient instance at %s>" % (self.this,)
    def setDefaults(*args): return _vclapi.VclStatsRoamingInfoClient_setDefaults(*args)
    def read(*args): return _vclapi.VclStatsRoamingInfoClient_read(*args)
    def write(*args): return _vclapi.VclStatsRoamingInfoClient_write(*args)
    def getTxMcAssociationStartTime(*args): return _vclapi.VclStatsRoamingInfoClient_getTxMcAssociationStartTime(*args)
    def getRxMcAssociationEndTime(*args): return _vclapi.VclStatsRoamingInfoClient_getRxMcAssociationEndTime(*args)
    def getRxMcDeauthDisassocTime(*args): return _vclapi.VclStatsRoamingInfoClient_getRxMcDeauthDisassocTime(*args)
    def getTxMcStartTime(*args): return _vclapi.VclStatsRoamingInfoClient_getTxMcStartTime(*args)
    def getTxMcEndTime(*args): return _vclapi.VclStatsRoamingInfoClient_getTxMcEndTime(*args)
    def getRxMcStartTime(*args): return _vclapi.VclStatsRoamingInfoClient_getRxMcStartTime(*args)
    def getRxMcEndTime(*args): return _vclapi.VclStatsRoamingInfoClient_getRxMcEndTime(*args)
    def getTgaProcessingTime(*args): return _vclapi.VclStatsRoamingInfoClient_getTgaProcessingTime(*args)
    def getTstampProbeRsp(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampProbeRsp(*args)
    def getTstampAuth1Rsp(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampAuth1Rsp(*args)
    def getTstampAuth2Rsp(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampAuth2Rsp(*args)
    def getTstampEapReqIdentity(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampEapReqIdentity(*args)
    def getTstampEapSuccessOrFailure(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampEapSuccessOrFailure(*args)
    def getTstampEapolPairwiseKey(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampEapolPairwiseKey(*args)
    def getTstampEapolGroupKey(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampEapolGroupKey(*args)
    def getTstampMcConnectionComplete(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampMcConnectionComplete(*args)
    def getTstampAuth1Req(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampAuth1Req(*args)
    def getTstampAuth2Req(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampAuth2Req(*args)
    def getTstampAssocReq(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampAssocReq(*args)
    def getTstampAssocRsp(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampAssocRsp(*args)
    def getTstampEapRspIdentity(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampEapRspIdentity(*args)
    def getTstampDhcpDiscover(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampDhcpDiscover(*args)
    def getTstampDhcpOffer(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampDhcpOffer(*args)
    def getTstampDhcpRequest(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampDhcpRequest(*args)
    def getTstampDhcpAck(*args): return _vclapi.VclStatsRoamingInfoClient_getTstampDhcpAck(*args)
    def getRoamingDelay(*args): return _vclapi.VclStatsRoamingInfoClient_getRoamingDelay(*args)
    def getConnectionTime(*args): return _vclapi.VclStatsRoamingInfoClient_getConnectionTime(*args)
    def getNumRoams(*args): return _vclapi.VclStatsRoamingInfoClient_getNumRoams(*args)
    def getNumFailedRoams(*args): return _vclapi.VclStatsRoamingInfoClient_getNumFailedRoams(*args)
    __swig_getmethods__["txMcAssociationStartTime"] = _vclapi.VclStatsRoamingInfoClient_txMcAssociationStartTime_get
    if _newclass:txMcAssociationStartTime = property(_vclapi.VclStatsRoamingInfoClient_txMcAssociationStartTime_get)
    __swig_getmethods__["rxMcAssociationEndTime"] = _vclapi.VclStatsRoamingInfoClient_rxMcAssociationEndTime_get
    if _newclass:rxMcAssociationEndTime = property(_vclapi.VclStatsRoamingInfoClient_rxMcAssociationEndTime_get)
    __swig_getmethods__["rxMcDeauthDisassocTime"] = _vclapi.VclStatsRoamingInfoClient_rxMcDeauthDisassocTime_get
    if _newclass:rxMcDeauthDisassocTime = property(_vclapi.VclStatsRoamingInfoClient_rxMcDeauthDisassocTime_get)
    __swig_getmethods__["txMcStartTime"] = _vclapi.VclStatsRoamingInfoClient_txMcStartTime_get
    if _newclass:txMcStartTime = property(_vclapi.VclStatsRoamingInfoClient_txMcStartTime_get)
    __swig_getmethods__["txMcEndTime"] = _vclapi.VclStatsRoamingInfoClient_txMcEndTime_get
    if _newclass:txMcEndTime = property(_vclapi.VclStatsRoamingInfoClient_txMcEndTime_get)
    __swig_getmethods__["rxMcStartTime"] = _vclapi.VclStatsRoamingInfoClient_rxMcStartTime_get
    if _newclass:rxMcStartTime = property(_vclapi.VclStatsRoamingInfoClient_rxMcStartTime_get)
    __swig_getmethods__["rxMcEndTime"] = _vclapi.VclStatsRoamingInfoClient_rxMcEndTime_get
    if _newclass:rxMcEndTime = property(_vclapi.VclStatsRoamingInfoClient_rxMcEndTime_get)
    __swig_getmethods__["tgaProcessingTime"] = _vclapi.VclStatsRoamingInfoClient_tgaProcessingTime_get
    if _newclass:tgaProcessingTime = property(_vclapi.VclStatsRoamingInfoClient_tgaProcessingTime_get)
    __swig_getmethods__["tstampProbeRsp"] = _vclapi.VclStatsRoamingInfoClient_tstampProbeRsp_get
    if _newclass:tstampProbeRsp = property(_vclapi.VclStatsRoamingInfoClient_tstampProbeRsp_get)
    __swig_getmethods__["tstampAuth1Rsp"] = _vclapi.VclStatsRoamingInfoClient_tstampAuth1Rsp_get
    if _newclass:tstampAuth1Rsp = property(_vclapi.VclStatsRoamingInfoClient_tstampAuth1Rsp_get)
    __swig_getmethods__["tstampAuth2Rsp"] = _vclapi.VclStatsRoamingInfoClient_tstampAuth2Rsp_get
    if _newclass:tstampAuth2Rsp = property(_vclapi.VclStatsRoamingInfoClient_tstampAuth2Rsp_get)
    __swig_getmethods__["tstampEapReqIdentity"] = _vclapi.VclStatsRoamingInfoClient_tstampEapReqIdentity_get
    if _newclass:tstampEapReqIdentity = property(_vclapi.VclStatsRoamingInfoClient_tstampEapReqIdentity_get)
    __swig_getmethods__["tstampEapSuccessOrFailure"] = _vclapi.VclStatsRoamingInfoClient_tstampEapSuccessOrFailure_get
    if _newclass:tstampEapSuccessOrFailure = property(_vclapi.VclStatsRoamingInfoClient_tstampEapSuccessOrFailure_get)
    __swig_getmethods__["tstampEapolPairwiseKey"] = _vclapi.VclStatsRoamingInfoClient_tstampEapolPairwiseKey_get
    if _newclass:tstampEapolPairwiseKey = property(_vclapi.VclStatsRoamingInfoClient_tstampEapolPairwiseKey_get)
    __swig_getmethods__["tstampEapolGroupKey"] = _vclapi.VclStatsRoamingInfoClient_tstampEapolGroupKey_get
    if _newclass:tstampEapolGroupKey = property(_vclapi.VclStatsRoamingInfoClient_tstampEapolGroupKey_get)
    __swig_getmethods__["tstampMcConnectionComplete"] = _vclapi.VclStatsRoamingInfoClient_tstampMcConnectionComplete_get
    if _newclass:tstampMcConnectionComplete = property(_vclapi.VclStatsRoamingInfoClient_tstampMcConnectionComplete_get)
    __swig_getmethods__["tstampAuth1Req"] = _vclapi.VclStatsRoamingInfoClient_tstampAuth1Req_get
    if _newclass:tstampAuth1Req = property(_vclapi.VclStatsRoamingInfoClient_tstampAuth1Req_get)
    __swig_getmethods__["tstampAuth2Req"] = _vclapi.VclStatsRoamingInfoClient_tstampAuth2Req_get
    if _newclass:tstampAuth2Req = property(_vclapi.VclStatsRoamingInfoClient_tstampAuth2Req_get)
    __swig_getmethods__["tstampAssocReq"] = _vclapi.VclStatsRoamingInfoClient_tstampAssocReq_get
    if _newclass:tstampAssocReq = property(_vclapi.VclStatsRoamingInfoClient_tstampAssocReq_get)
    __swig_getmethods__["tstampAssocRsp"] = _vclapi.VclStatsRoamingInfoClient_tstampAssocRsp_get
    if _newclass:tstampAssocRsp = property(_vclapi.VclStatsRoamingInfoClient_tstampAssocRsp_get)
    __swig_getmethods__["tstampEapRspIdentity"] = _vclapi.VclStatsRoamingInfoClient_tstampEapRspIdentity_get
    if _newclass:tstampEapRspIdentity = property(_vclapi.VclStatsRoamingInfoClient_tstampEapRspIdentity_get)
    __swig_getmethods__["tstampDhcpDiscover"] = _vclapi.VclStatsRoamingInfoClient_tstampDhcpDiscover_get
    if _newclass:tstampDhcpDiscover = property(_vclapi.VclStatsRoamingInfoClient_tstampDhcpDiscover_get)
    __swig_getmethods__["tstampDhcpOffer"] = _vclapi.VclStatsRoamingInfoClient_tstampDhcpOffer_get
    if _newclass:tstampDhcpOffer = property(_vclapi.VclStatsRoamingInfoClient_tstampDhcpOffer_get)
    __swig_getmethods__["tstampDhcpRequest"] = _vclapi.VclStatsRoamingInfoClient_tstampDhcpRequest_get
    if _newclass:tstampDhcpRequest = property(_vclapi.VclStatsRoamingInfoClient_tstampDhcpRequest_get)
    __swig_getmethods__["tstampDhcpAck"] = _vclapi.VclStatsRoamingInfoClient_tstampDhcpAck_get
    if _newclass:tstampDhcpAck = property(_vclapi.VclStatsRoamingInfoClient_tstampDhcpAck_get)
    __swig_getmethods__["roamingDelay"] = _vclapi.VclStatsRoamingInfoClient_roamingDelay_get
    if _newclass:roamingDelay = property(_vclapi.VclStatsRoamingInfoClient_roamingDelay_get)
    __swig_getmethods__["connectionTime"] = _vclapi.VclStatsRoamingInfoClient_connectionTime_get
    if _newclass:connectionTime = property(_vclapi.VclStatsRoamingInfoClient_connectionTime_get)
    __swig_getmethods__["numRoams"] = _vclapi.VclStatsRoamingInfoClient_numRoams_get
    if _newclass:numRoams = property(_vclapi.VclStatsRoamingInfoClient_numRoams_get)
    __swig_getmethods__["numFailedRoams"] = _vclapi.VclStatsRoamingInfoClient_numFailedRoams_get
    if _newclass:numFailedRoams = property(_vclapi.VclStatsRoamingInfoClient_numFailedRoams_get)
    def __init__(self, *args):
        _swig_setattr(self, VclStatsRoamingInfoClient, 'this', _vclapi.new_VclStatsRoamingInfoClient(*args))
        _swig_setattr(self, VclStatsRoamingInfoClient, 'thisown', 1)
    def __del__(self, destroy=_vclapi.delete_VclStatsRoamingInfoClient):
        try:
            if self.thisown: destroy(self)
        except: pass

class VclStatsRoamingInfoClientPtr(VclStatsRoamingInfoClient):
    def __init__(self, this):
        _swig_setattr(self, VclStatsRoamingInfoClient, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, VclStatsRoamingInfoClient, 'thisown', 0)
        _swig_setattr(self, VclStatsRoamingInfoClient,self.__class__,VclStatsRoamingInfoClient)
_vclapi.VclStatsRoamingInfoClient_swigregister(VclStatsRoamingInfoClientPtr)


