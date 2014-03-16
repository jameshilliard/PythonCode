# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file '../roaming/roamprofile.ui'
#
# Created: Thu Feb 19 03:06:40 2009
#      by: The PyQt User Interface Compiler (pyuic) 3.13
#
# WARNING! All changes made in this file will be lost!


from qt import *
from qttable import QTable


class roamprofile(QWidget):
    def __init__(self,parent = None,name = None,fl = 0):
        QWidget.__init__(self,parent,name,fl)

        if not name:
            self.setName("roamprofile")

        self.setFocusPolicy(QWidget.TabFocus)

        roamprofileLayout = QGridLayout(self,1,1,11,6,"roamprofileLayout")

        self.textLabel1_2 = QLabel(self,"textLabel1_2")

        roamprofileLayout.addWidget(self.textLabel1_2,0,0)

        self.clientgroupListBox = QListBox(self,"clientgroupListBox")
        self.clientgroupListBox.setSizePolicy(QSizePolicy(5,7,0,0,self.clientgroupListBox.sizePolicy().hasHeightForWidth()))

        roamprofileLayout.addWidget(self.clientgroupListBox,1,0)

        self.roamProfileTabWidget = QTabWidget(self,"roamProfileTabWidget")

        self.tab = QWidget(self.roamProfileTabWidget,"tab")
        tabLayout = QGridLayout(self.tab,1,1,11,6,"tabLayout")

        layout36 = QHBoxLayout(None,0,6,"layout36")

        layout35 = QGridLayout(None,1,1,0,6,"layout35")

        layout7 = QVBoxLayout(None,0,6,"layout7")
        spacer6_2 = QSpacerItem(20,20,QSizePolicy.Minimum,QSizePolicy.Expanding)
        layout7.addItem(spacer6_2)

        layout6 = QVBoxLayout(None,0,6,"layout6")

        self.moveSelectedToolButton = QToolButton(self.tab,"moveSelectedToolButton")
        self.moveSelectedToolButton.setEnabled(1)
        self.moveSelectedToolButton.setFocusPolicy(QToolButton.TabFocus)
        self.moveSelectedToolButton.setIconSet(QIconSet())
        layout6.addWidget(self.moveSelectedToolButton)

        self.moveAllToolButton = QToolButton(self.tab,"moveAllToolButton")
        self.moveAllToolButton.setEnabled(1)
        self.moveAllToolButton.setFocusPolicy(QToolButton.TabFocus)
        self.moveAllToolButton.setIconSet(QIconSet())
        layout6.addWidget(self.moveAllToolButton)
        layout7.addLayout(layout6)
        spacer5_2 = QSpacerItem(20,20,QSizePolicy.Minimum,QSizePolicy.Expanding)
        layout7.addItem(spacer5_2)

        layout35.addLayout(layout7,1,1)

        layout8 = QHBoxLayout(None,0,6,"layout8")

        layout35.addLayout(layout8,0,0)

        self.availablePortListView = QListView(self.tab,"availablePortListView")
        self.availablePortListView.addColumn(self.__tr("Available Port List"))

        layout35.addWidget(self.availablePortListView,1,0)
        layout36.addLayout(layout35)

        layout33 = QVBoxLayout(None,0,6,"layout33")

        self.selectedPortListLabel = QLabel(self.tab,"selectedPortListLabel")
        layout33.addWidget(self.selectedPortListLabel)

        layout32 = QHBoxLayout(None,0,6,"layout32")

        self.selectedPortList = QListBox(self.tab,"selectedPortList")
        layout32.addWidget(self.selectedPortList)

        layout12 = QVBoxLayout(None,0,6,"layout12")
        spacer8 = QSpacerItem(20,30,QSizePolicy.Minimum,QSizePolicy.Expanding)
        layout12.addItem(spacer8)

        layout11 = QVBoxLayout(None,0,6,"layout11")

        self.upToolButton = QToolButton(self.tab,"upToolButton")
        self.upToolButton.setFocusPolicy(QToolButton.TabFocus)
        self.upToolButton.setIconSet(QIconSet())
        layout11.addWidget(self.upToolButton)

        self.downToolButton = QToolButton(self.tab,"downToolButton")
        self.downToolButton.setFocusPolicy(QToolButton.TabFocus)
        self.downToolButton.setIconSet(QIconSet())
        layout11.addWidget(self.downToolButton)

        self.deleteSelectedToolButton = QToolButton(self.tab,"deleteSelectedToolButton")
        self.deleteSelectedToolButton.setFocusPolicy(QToolButton.TabFocus)
        self.deleteSelectedToolButton.setIconSet(QIconSet())
        layout11.addWidget(self.deleteSelectedToolButton)

        self.deleteAllToolButton = QToolButton(self.tab,"deleteAllToolButton")
        self.deleteAllToolButton.setFocusPolicy(QToolButton.TabFocus)
        self.deleteAllToolButton.setIconSet(QIconSet())
        layout11.addWidget(self.deleteAllToolButton)
        layout12.addLayout(layout11)
        spacer7_2 = QSpacerItem(20,30,QSizePolicy.Minimum,QSizePolicy.Expanding)
        layout12.addItem(spacer7_2)
        layout32.addLayout(layout12)
        layout33.addLayout(layout32)
        layout36.addLayout(layout33)

        tabLayout.addLayout(layout36,0,0)

        self.tabWidget3 = QTabWidget(self.tab,"tabWidget3")

        self.time = QWidget(self.tabWidget3,"time")
        timeLayout = QHBoxLayout(self.time,11,6,"timeLayout")

        layout18 = QVBoxLayout(None,0,6,"layout18")

        self.dwellTimeButtonGroup = QButtonGroup(self.time,"dwellTimeButtonGroup")
        self.dwellTimeButtonGroup.setEnabled(1)
        self.dwellTimeButtonGroup.setColumnLayout(0,Qt.Vertical)
        self.dwellTimeButtonGroup.layout().setSpacing(6)
        self.dwellTimeButtonGroup.layout().setMargin(11)
        dwellTimeButtonGroupLayout = QGridLayout(self.dwellTimeButtonGroup.layout())
        dwellTimeButtonGroupLayout.setAlignment(Qt.AlignTop)

        self.customDwellTimeRadioButton = QRadioButton(self.dwellTimeButtonGroup,"customDwellTimeRadioButton")
        self.customDwellTimeRadioButton.setEnabled(0)
        self.dwellTimeButtonGroup.insert( self.customDwellTimeRadioButton,1)

        dwellTimeButtonGroupLayout.addWidget(self.customDwellTimeRadioButton,1,0)

        self.fixedDwellTimeRadioButton = QRadioButton(self.dwellTimeButtonGroup,"fixedDwellTimeRadioButton")
        self.fixedDwellTimeRadioButton.setChecked(1)
        self.dwellTimeButtonGroup.insert( self.fixedDwellTimeRadioButton,0)

        dwellTimeButtonGroupLayout.addWidget(self.fixedDwellTimeRadioButton,0,0)

        self.fixedTimeSpinBox = QSpinBox(self.dwellTimeButtonGroup,"fixedTimeSpinBox")
        self.fixedTimeSpinBox.setMaxValue(100000)
        self.fixedTimeSpinBox.setMinValue(1)

        dwellTimeButtonGroupLayout.addWidget(self.fixedTimeSpinBox,0,1)

        self.customDwellOptionsGroupBox = QGroupBox(self.dwellTimeButtonGroup,"customDwellOptionsGroupBox")
        self.customDwellOptionsGroupBox.setEnabled(0)
        self.customDwellOptionsGroupBox.setColumnLayout(0,Qt.Vertical)
        self.customDwellOptionsGroupBox.layout().setSpacing(6)
        self.customDwellOptionsGroupBox.layout().setMargin(11)
        customDwellOptionsGroupBoxLayout = QGridLayout(self.customDwellOptionsGroupBox.layout())
        customDwellOptionsGroupBoxLayout.setAlignment(Qt.AlignTop)

        self.endDwellLabel = QLabel(self.customDwellOptionsGroupBox,"endDwellLabel")
        self.endDwellLabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        customDwellOptionsGroupBoxLayout.addWidget(self.endDwellLabel,1,0)

        self.dwellChangeLabel = QLabel(self.customDwellOptionsGroupBox,"dwellChangeLabel")
        self.dwellChangeLabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        customDwellOptionsGroupBoxLayout.addWidget(self.dwellChangeLabel,2,0)

        self.startDwellLabel = QLabel(self.customDwellOptionsGroupBox,"startDwellLabel")
        self.startDwellLabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        customDwellOptionsGroupBoxLayout.addWidget(self.startDwellLabel,0,0)

        self.changeStepSpinBox = QSpinBox(self.customDwellOptionsGroupBox,"changeStepSpinBox")
        self.changeStepSpinBox.setMaxValue(80)
        self.changeStepSpinBox.setMinValue(-80)

        customDwellOptionsGroupBoxLayout.addWidget(self.changeStepSpinBox,2,1)

        self.startDwellSpinBox = QSpinBox(self.customDwellOptionsGroupBox,"startDwellSpinBox")
        self.startDwellSpinBox.setMaxValue(80)

        customDwellOptionsGroupBoxLayout.addWidget(self.startDwellSpinBox,0,1)

        self.endDwellSpinBox = QSpinBox(self.customDwellOptionsGroupBox,"endDwellSpinBox")
        self.endDwellSpinBox.setMaxValue(80)

        customDwellOptionsGroupBoxLayout.addWidget(self.endDwellSpinBox,1,1)

        self.comboBox5 = QComboBox(0,self.customDwellOptionsGroupBox,"comboBox5")

        customDwellOptionsGroupBoxLayout.addWidget(self.comboBox5,0,2)

        self.comboBox6 = QComboBox(0,self.customDwellOptionsGroupBox,"comboBox6")

        customDwellOptionsGroupBoxLayout.addWidget(self.comboBox6,1,2)

        dwellTimeButtonGroupLayout.addMultiCellWidget(self.customDwellOptionsGroupBox,2,2,0,1)
        layout18.addWidget(self.dwellTimeButtonGroup)
        spacer8_2_2 = QSpacerItem(20,20,QSizePolicy.Minimum,QSizePolicy.Expanding)
        layout18.addItem(spacer8_2_2)
        timeLayout.addLayout(layout18)

        layout19 = QVBoxLayout(None,0,6,"layout19")

        self.repeatButtonGroup = QButtonGroup(self.time,"repeatButtonGroup")
        self.repeatButtonGroup.setColumnLayout(0,Qt.Vertical)
        self.repeatButtonGroup.layout().setSpacing(6)
        self.repeatButtonGroup.layout().setMargin(11)
        repeatButtonGroupLayout = QGridLayout(self.repeatButtonGroup.layout())
        repeatButtonGroupLayout.setAlignment(Qt.AlignTop)

        self.repeatCountSpinBox = QSpinBox(self.repeatButtonGroup,"repeatCountSpinBox")
        self.repeatCountSpinBox.setMaxValue(1000000)

        repeatButtonGroupLayout.addWidget(self.repeatCountSpinBox,0,3)

        self.durationRadioButton = QRadioButton(self.repeatButtonGroup,"durationRadioButton")
        self.durationRadioButton.setFocusPolicy(QRadioButton.NoFocus)
        self.repeatButtonGroup.insert( self.durationRadioButton,2)

        repeatButtonGroupLayout.addWidget(self.durationRadioButton,1,0)

        self.durationSpinBox = QSpinBox(self.repeatButtonGroup,"durationSpinBox")
        self.durationSpinBox.setMaxValue(1000000)
        self.durationSpinBox.setMinValue(1)

        repeatButtonGroupLayout.addWidget(self.durationSpinBox,1,1)

        self.timeUnitComboBox = QComboBox(0,self.repeatButtonGroup,"timeUnitComboBox")

        repeatButtonGroupLayout.addMultiCellWidget(self.timeUnitComboBox,1,1,2,3)

        self.repeatCountRadioButton = QRadioButton(self.repeatButtonGroup,"repeatCountRadioButton")
        self.repeatCountRadioButton.setChecked(1)
        self.repeatButtonGroup.insert( self.repeatCountRadioButton,1)

        repeatButtonGroupLayout.addMultiCellWidget(self.repeatCountRadioButton,0,0,0,2)
        layout19.addWidget(self.repeatButtonGroup)
        spacer8_2 = QSpacerItem(20,31,QSizePolicy.Minimum,QSizePolicy.Expanding)
        layout19.addItem(spacer8_2)
        timeLayout.addLayout(layout19)
        self.tabWidget3.insertTab(self.time,QString(""))

        self.distribution = QWidget(self.tabWidget3,"distribution")
        distributionLayout = QGridLayout(self.distribution,1,1,11,6,"distributionLayout")

        self.clientDistButtonGroup = QButtonGroup(self.distribution,"clientDistButtonGroup")
        self.clientDistButtonGroup.setColumnLayout(0,Qt.Vertical)
        self.clientDistButtonGroup.layout().setSpacing(6)
        self.clientDistButtonGroup.layout().setMargin(11)
        clientDistButtonGroupLayout = QGridLayout(self.clientDistButtonGroup.layout())
        clientDistButtonGroupLayout.setAlignment(Qt.AlignTop)

        self.clientDistRadio1 = QRadioButton(self.clientDistButtonGroup,"clientDistRadio1")
        self.clientDistRadio1.setChecked(1)
        self.clientDistButtonGroup.insert( self.clientDistRadio1,1)

        clientDistButtonGroupLayout.addWidget(self.clientDistRadio1,0,0)

        self.clientDistRadio2 = QRadioButton(self.clientDistButtonGroup,"clientDistRadio2")
        self.clientDistButtonGroup.insert( self.clientDistRadio2,2)

        clientDistButtonGroupLayout.addWidget(self.clientDistRadio2,1,0)

        distributionLayout.addWidget(self.clientDistButtonGroup,0,1)

        self.timeDistButtonGroup = QButtonGroup(self.distribution,"timeDistButtonGroup")
        self.timeDistButtonGroup.setColumnLayout(0,Qt.Vertical)
        self.timeDistButtonGroup.layout().setSpacing(6)
        self.timeDistButtonGroup.layout().setMargin(11)
        timeDistButtonGroupLayout = QGridLayout(self.timeDistButtonGroup.layout())
        timeDistButtonGroupLayout.setAlignment(Qt.AlignTop)

        self.timeDistRadio1 = QRadioButton(self.timeDistButtonGroup,"timeDistRadio1")
        self.timeDistRadio1.setChecked(1)
        self.timeDistButtonGroup.insert( self.timeDistRadio1,1)

        timeDistButtonGroupLayout.addWidget(self.timeDistRadio1,0,0)

        self.timeDistRadio2 = QRadioButton(self.timeDistButtonGroup,"timeDistRadio2")
        self.timeDistRadio2.setChecked(0)
        self.timeDistButtonGroup.insert( self.timeDistRadio2,2)

        timeDistButtonGroupLayout.addWidget(self.timeDistRadio2,1,0)

        distributionLayout.addWidget(self.timeDistButtonGroup,0,0)
        spacer7_3 = QSpacerItem(20,41,QSizePolicy.Minimum,QSizePolicy.Expanding)
        distributionLayout.addMultiCell(spacer7_3,1,1,0,1)
        self.tabWidget3.insertTab(self.distribution,QString(""))

        self.power = QWidget(self.tabWidget3,"power")
        powerLayout = QGridLayout(self.power,1,1,11,6,"powerLayout")

        self.powerProfileGroupBox = QGroupBox(self.power,"powerProfileGroupBox")
        self.powerProfileGroupBox.setEnabled(1)
        self.powerProfileGroupBox.setFocusPolicy(QGroupBox.TabFocus)
        self.powerProfileGroupBox.setCheckable(1)
        self.powerProfileGroupBox.setChecked(0)
        self.powerProfileGroupBox.setColumnLayout(0,Qt.Vertical)
        self.powerProfileGroupBox.layout().setSpacing(6)
        self.powerProfileGroupBox.layout().setMargin(11)
        powerProfileGroupBoxLayout = QGridLayout(self.powerProfileGroupBox.layout())
        powerProfileGroupBoxLayout.setAlignment(Qt.AlignTop)

        self.srcStartPrwSpinBox = QSpinBox(self.powerProfileGroupBox,"srcStartPrwSpinBox")
        self.srcStartPrwSpinBox.setMaxValue(-6)
        self.srcStartPrwSpinBox.setMinValue(-42)

        powerProfileGroupBoxLayout.addWidget(self.srcStartPrwSpinBox,0,1)

        self.srcEndPwrSpinBox = QSpinBox(self.powerProfileGroupBox,"srcEndPwrSpinBox")
        self.srcEndPwrSpinBox.setMaxValue(-6)
        self.srcEndPwrSpinBox.setMinValue(-42)

        powerProfileGroupBoxLayout.addWidget(self.srcEndPwrSpinBox,1,1)

        self.srcChangeStepSpinBox = QSpinBox(self.powerProfileGroupBox,"srcChangeStepSpinBox")
        self.srcChangeStepSpinBox.setMaxValue(20)
        self.srcChangeStepSpinBox.setMinValue(1)

        powerProfileGroupBoxLayout.addWidget(self.srcChangeStepSpinBox,2,1)

        self.endTxPowerALabel = QLabel(self.powerProfileGroupBox,"endTxPowerALabel")
        self.endTxPowerALabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        powerProfileGroupBoxLayout.addWidget(self.endTxPowerALabel,1,0)

        self.startTxPowerALabel = QLabel(self.powerProfileGroupBox,"startTxPowerALabel")
        self.startTxPowerALabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        powerProfileGroupBoxLayout.addWidget(self.startTxPowerALabel,0,0)

        self.changeStepALabel = QLabel(self.powerProfileGroupBox,"changeStepALabel")
        self.changeStepALabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        powerProfileGroupBoxLayout.addWidget(self.changeStepALabel,2,0)

        self.destStartPwrSpinBox = QSpinBox(self.powerProfileGroupBox,"destStartPwrSpinBox")
        self.destStartPwrSpinBox.setMaxValue(-6)
        self.destStartPwrSpinBox.setMinValue(-42)

        powerProfileGroupBoxLayout.addWidget(self.destStartPwrSpinBox,0,3)

        self.destEndPwrSpinBox = QSpinBox(self.powerProfileGroupBox,"destEndPwrSpinBox")
        self.destEndPwrSpinBox.setMaxValue(-6)
        self.destEndPwrSpinBox.setMinValue(-42)

        powerProfileGroupBoxLayout.addWidget(self.destEndPwrSpinBox,1,3)

        self.destChangeStepSpinBox = QSpinBox(self.powerProfileGroupBox,"destChangeStepSpinBox")
        self.destChangeStepSpinBox.setMaxValue(20)
        self.destChangeStepSpinBox.setMinValue(1)

        powerProfileGroupBoxLayout.addWidget(self.destChangeStepSpinBox,2,3)

        self.destChangeIntSpinBox = QSpinBox(self.powerProfileGroupBox,"destChangeIntSpinBox")
        self.destChangeIntSpinBox.setMaxValue(100000)
        self.destChangeIntSpinBox.setMinValue(1000)
        self.destChangeIntSpinBox.setLineStep(100)

        powerProfileGroupBoxLayout.addWidget(self.destChangeIntSpinBox,3,3)

        self.startTxPowerBLabel = QLabel(self.powerProfileGroupBox,"startTxPowerBLabel")
        self.startTxPowerBLabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        powerProfileGroupBoxLayout.addWidget(self.startTxPowerBLabel,0,2)

        self.endTxPowerbLabel = QLabel(self.powerProfileGroupBox,"endTxPowerbLabel")
        self.endTxPowerbLabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        powerProfileGroupBoxLayout.addWidget(self.endTxPowerbLabel,1,2)

        self.changeStepBLabel = QLabel(self.powerProfileGroupBox,"changeStepBLabel")
        self.changeStepBLabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        powerProfileGroupBoxLayout.addWidget(self.changeStepBLabel,2,2)

        self.changeIntBLabel = QLabel(self.powerProfileGroupBox,"changeIntBLabel")
        self.changeIntBLabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        powerProfileGroupBoxLayout.addWidget(self.changeIntBLabel,3,2)

        self.changeIntALabel = QLabel(self.powerProfileGroupBox,"changeIntALabel")
        self.changeIntALabel.setAlignment(QLabel.AlignVCenter | QLabel.AlignRight)

        powerProfileGroupBoxLayout.addWidget(self.changeIntALabel,3,0)

        self.srcChangeIntSpinBox = QSpinBox(self.powerProfileGroupBox,"srcChangeIntSpinBox")
        self.srcChangeIntSpinBox.setMaxValue(1000000)
        self.srcChangeIntSpinBox.setMinValue(1000)
        self.srcChangeIntSpinBox.setLineStep(100)

        powerProfileGroupBoxLayout.addWidget(self.srcChangeIntSpinBox,3,1)

        powerLayout.addWidget(self.powerProfileGroupBox,0,0)
        spacer10 = QSpacerItem(51,21,QSizePolicy.Expanding,QSizePolicy.Minimum)
        powerLayout.addItem(spacer10,0,1)
        spacer11 = QSpacerItem(20,21,QSizePolicy.Minimum,QSizePolicy.Expanding)
        powerLayout.addItem(spacer11,1,0)
        self.tabWidget3.insertTab(self.power,QString(""))

        self.flows = QWidget(self.tabWidget3,"flows")
        flowsLayout = QVBoxLayout(self.flows,11,6,"flowsLayout")

        layout21 = QHBoxLayout(None,0,6,"layout21")

        self.flowParametersButtonGroup = QButtonGroup(self.flows,"flowParametersButtonGroup")
        self.flowParametersButtonGroup.setEnabled(1)
        self.flowParametersButtonGroup.setColumnLayout(0,Qt.Vertical)
        self.flowParametersButtonGroup.layout().setSpacing(6)
        self.flowParametersButtonGroup.layout().setMargin(11)
        flowParametersButtonGroupLayout = QGridLayout(self.flowParametersButtonGroup.layout())
        flowParametersButtonGroupLayout.setAlignment(Qt.AlignTop)

        self.textLabel2_2 = QLabel(self.flowParametersButtonGroup,"textLabel2_2")

        flowParametersButtonGroupLayout.addWidget(self.textLabel2_2,0,0)

        self.flowPacketSizeSpinBox = QSpinBox(self.flowParametersButtonGroup,"flowPacketSizeSpinBox")
        self.flowPacketSizeSpinBox.setMaxValue(1518)
        self.flowPacketSizeSpinBox.setMinValue(88)
        self.flowPacketSizeSpinBox.setValue(256)

        flowParametersButtonGroupLayout.addWidget(self.flowPacketSizeSpinBox,0,1)

        self.textLabel3 = QLabel(self.flowParametersButtonGroup,"textLabel3")

        flowParametersButtonGroupLayout.addWidget(self.textLabel3,1,0)

        self.flowRateSpinBox = QSpinBox(self.flowParametersButtonGroup,"flowRateSpinBox")
        self.flowRateSpinBox.setMaxValue(10000)
        self.flowRateSpinBox.setMinValue(1)
        self.flowRateSpinBox.setValue(100)

        flowParametersButtonGroupLayout.addWidget(self.flowRateSpinBox,1,1)
        layout21.addWidget(self.flowParametersButtonGroup)

        self.learningFramesGroupBox = QGroupBox(self.flows,"learningFramesGroupBox")
        self.learningFramesGroupBox.setFocusPolicy(QGroupBox.TabFocus)
        self.learningFramesGroupBox.setCheckable(1)
        self.learningFramesGroupBox.setColumnLayout(0,Qt.Vertical)
        self.learningFramesGroupBox.layout().setSpacing(6)
        self.learningFramesGroupBox.layout().setMargin(11)
        learningFramesGroupBoxLayout = QGridLayout(self.learningFramesGroupBox.layout())
        learningFramesGroupBoxLayout.setAlignment(Qt.AlignTop)

        self.textLabel4 = QLabel(self.learningFramesGroupBox,"textLabel4")

        learningFramesGroupBoxLayout.addWidget(self.textLabel4,0,0)

        self.learnDestIpComboBox = QComboBox(0,self.learningFramesGroupBox,"learnDestIpComboBox")
        self.learnDestIpComboBox.setEditable(1)
        self.learnDestIpComboBox.setSizeLimit(1)

        learningFramesGroupBoxLayout.addWidget(self.learnDestIpComboBox,0,1)

        self.learnDestMacComboBox = QComboBox(0,self.learningFramesGroupBox,"learnDestMacComboBox")
        self.learnDestMacComboBox.setEditable(1)
        self.learnDestMacComboBox.setSizeLimit(1)

        learningFramesGroupBoxLayout.addWidget(self.learnDestMacComboBox,1,1)

        self.textLabel6 = QLabel(self.learningFramesGroupBox,"textLabel6")

        learningFramesGroupBoxLayout.addWidget(self.textLabel6,1,0)

        self.learningPacketRateSpinBox = QSpinBox(self.learningFramesGroupBox,"learningPacketRateSpinBox")
        self.learningPacketRateSpinBox.setMaxValue(100)
        self.learningPacketRateSpinBox.setMinValue(10)
        self.learningPacketRateSpinBox.setValue(100)

        learningFramesGroupBoxLayout.addWidget(self.learningPacketRateSpinBox,2,1)

        self.textLabel5 = QLabel(self.learningFramesGroupBox,"textLabel5")

        learningFramesGroupBoxLayout.addWidget(self.textLabel5,2,0)
        layout21.addWidget(self.learningFramesGroupBox)
        flowsLayout.addLayout(layout21)
        spacer13 = QSpacerItem(20,31,QSizePolicy.Minimum,QSizePolicy.Expanding)
        flowsLayout.addItem(spacer13)
        self.tabWidget3.insertTab(self.flows,QString(""))

        self.options = QWidget(self.tabWidget3,"options")
        optionsLayout = QGridLayout(self.options,1,1,11,6,"optionsLayout")

        layout210 = QGridLayout(None,1,1,0,6,"layout210")

        layout209 = QGridLayout(None,1,1,0,6,"layout209")

        self.fastRoamingButtonGroup = QButtonGroup(self.options,"fastRoamingButtonGroup")
        self.fastRoamingButtonGroup.setColumnLayout(0,Qt.Vertical)
        self.fastRoamingButtonGroup.layout().setSpacing(6)
        self.fastRoamingButtonGroup.layout().setMargin(11)
        fastRoamingButtonGroupLayout = QGridLayout(self.fastRoamingButtonGroup.layout())
        fastRoamingButtonGroupLayout.setAlignment(Qt.AlignTop)

        self.pmkidCheckBox = QCheckBox(self.fastRoamingButtonGroup,"pmkidCheckBox")

        fastRoamingButtonGroupLayout.addWidget(self.pmkidCheckBox,0,0)

        self.preauthCheckBox = QCheckBox(self.fastRoamingButtonGroup,"preauthCheckBox")
        self.preauthCheckBox.setEnabled(1)

        fastRoamingButtonGroupLayout.addWidget(self.preauthCheckBox,1,0)

        layout209.addWidget(self.fastRoamingButtonGroup,0,1)

        self.additionalOptionsButtonGroup = QButtonGroup(self.options,"additionalOptionsButtonGroup")
        self.additionalOptionsButtonGroup.setColumnLayout(0,Qt.Vertical)
        self.additionalOptionsButtonGroup.layout().setSpacing(6)
        self.additionalOptionsButtonGroup.layout().setMargin(11)
        additionalOptionsButtonGroupLayout = QGridLayout(self.additionalOptionsButtonGroup.layout())
        additionalOptionsButtonGroupLayout.setAlignment(Qt.AlignTop)

        self.disassociateCheckBox = QCheckBox(self.additionalOptionsButtonGroup,"disassociateCheckBox")
        self.additionalOptionsButtonGroup.insert( self.disassociateCheckBox,1)

        additionalOptionsButtonGroupLayout.addWidget(self.disassociateCheckBox,0,0)

        self.deauthCheckBox = QCheckBox(self.additionalOptionsButtonGroup,"deauthCheckBox")
        self.additionalOptionsButtonGroup.insert( self.deauthCheckBox,2)

        additionalOptionsButtonGroupLayout.addWidget(self.deauthCheckBox,1,0)

        self.reassocCheckBox = QCheckBox(self.additionalOptionsButtonGroup,"reassocCheckBox")
        self.additionalOptionsButtonGroup.insert( self.reassocCheckBox,3)

        additionalOptionsButtonGroupLayout.addWidget(self.reassocCheckBox,2,0)

        self.renewDhcpCheckBox = QCheckBox(self.additionalOptionsButtonGroup,"renewDhcpCheckBox")
        self.additionalOptionsButtonGroup.insert( self.renewDhcpCheckBox,4)

        additionalOptionsButtonGroupLayout.addWidget(self.renewDhcpCheckBox,3,0)

        self.renewDhcpOnConnCheckBox = QCheckBox(self.additionalOptionsButtonGroup,"renewDhcpOnConnCheckBox")
        self.additionalOptionsButtonGroup.insert( self.renewDhcpOnConnCheckBox,5)

        additionalOptionsButtonGroupLayout.addWidget(self.renewDhcpOnConnCheckBox,4,0)

        layout209.addWidget(self.additionalOptionsButtonGroup,0,0)

        layout210.addLayout(layout209,0,0)
        spacer12 = QSpacerItem(20,50,QSizePolicy.Minimum,QSizePolicy.Expanding)
        layout210.addItem(spacer12,1,0)

        optionsLayout.addLayout(layout210,0,0)
        self.tabWidget3.insertTab(self.options,QString(""))

        tabLayout.addWidget(self.tabWidget3,1,0)
        self.roamProfileTabWidget.insertTab(self.tab,QString(""))

        self.TabPage = QWidget(self.roamProfileTabWidget,"TabPage")
        TabPageLayout = QGridLayout(self.TabPage,1,1,11,6,"TabPageLayout")

        self.roamStepsGroupBox = QGroupBox(self.TabPage,"roamStepsGroupBox")
        self.roamStepsGroupBox.setFrameShape(QGroupBox.NoFrame)
        self.roamStepsGroupBox.setColumnLayout(0,Qt.Vertical)
        self.roamStepsGroupBox.layout().setSpacing(6)
        self.roamStepsGroupBox.layout().setMargin(0)
        roamStepsGroupBoxLayout = QGridLayout(self.roamStepsGroupBox.layout())
        roamStepsGroupBoxLayout.setAlignment(Qt.AlignTop)

        self.roamStepsTable = QTable(self.roamStepsGroupBox,"roamStepsTable")
        self.roamStepsTable.setNumCols(self.roamStepsTable.numCols() + 1)
        self.roamStepsTable.horizontalHeader().setLabel(self.roamStepsTable.numCols() - 1,self.__tr("Client Name"))
        self.roamStepsTable.setNumCols(self.roamStepsTable.numCols() + 1)
        self.roamStepsTable.horizontalHeader().setLabel(self.roamStepsTable.numCols() - 1,self.__tr("SrcPort Name, BSSID"))
        self.roamStepsTable.setNumCols(self.roamStepsTable.numCols() + 1)
        self.roamStepsTable.horizontalHeader().setLabel(self.roamStepsTable.numCols() - 1,self.__tr("DestPort Name,BSSID"))
        self.roamStepsTable.setNumCols(self.roamStepsTable.numCols() + 1)
        self.roamStepsTable.horizontalHeader().setLabel(self.roamStepsTable.numCols() - 1,self.__tr("Roam EventTime(secs)"))
        self.roamStepsTable.setNumRows(self.roamStepsTable.numRows() + 1)
        self.roamStepsTable.verticalHeader().setLabel(self.roamStepsTable.numRows() - 1,self.__tr("0"))
        self.roamStepsTable.setSizePolicy(QSizePolicy(7,7,0,0,self.roamStepsTable.sizePolicy().hasHeightForWidth()))
        self.roamStepsTable.setResizePolicy(QTable.Default)
        self.roamStepsTable.setNumRows(1)
        self.roamStepsTable.setNumCols(4)

        roamStepsGroupBoxLayout.addWidget(self.roamStepsTable,0,0)

        layout31 = QHBoxLayout(None,0,6,"layout31")

        layout23 = QHBoxLayout(None,0,6,"layout23")

        self.textLabel1_3 = QLabel(self.roamStepsGroupBox,"textLabel1_3")
        layout23.addWidget(self.textLabel1_3)

        self.numRoamsLineEdit = QLineEdit(self.roamStepsGroupBox,"numRoamsLineEdit")
        self.numRoamsLineEdit.setEnabled(0)
        layout23.addWidget(self.numRoamsLineEdit)
        layout31.addLayout(layout23)

        layout24 = QHBoxLayout(None,0,6,"layout24")

        self.textLabel2_3 = QLabel(self.roamStepsGroupBox,"textLabel2_3")
        layout24.addWidget(self.textLabel2_3)

        self.avgRoamsLineEdit = QLineEdit(self.roamStepsGroupBox,"avgRoamsLineEdit")
        self.avgRoamsLineEdit.setEnabled(0)
        layout24.addWidget(self.avgRoamsLineEdit)
        layout31.addLayout(layout24)

        layout25 = QHBoxLayout(None,0,6,"layout25")

        self.textLabel3_2 = QLabel(self.roamStepsGroupBox,"textLabel3_2")
        layout25.addWidget(self.textLabel3_2)

        self.numClientsLineEdit = QLineEdit(self.roamStepsGroupBox,"numClientsLineEdit")
        self.numClientsLineEdit.setEnabled(0)
        self.numClientsLineEdit.setFrameShape(QLineEdit.LineEditPanel)
        self.numClientsLineEdit.setFrameShadow(QLineEdit.Sunken)
        layout25.addWidget(self.numClientsLineEdit)
        layout31.addLayout(layout25)

        layout30 = QHBoxLayout(None,0,6,"layout30")

        self.autoUpdateCheckBox = QCheckBox(self.roamStepsGroupBox,"autoUpdateCheckBox")
        self.autoUpdateCheckBox.setFocusPolicy(QCheckBox.TabFocus)
        layout30.addWidget(self.autoUpdateCheckBox)

        self.applyPushButton = QPushButton(self.roamStepsGroupBox,"applyPushButton")
        self.applyPushButton.setFocusPolicy(QPushButton.TabFocus)
        layout30.addWidget(self.applyPushButton)
        layout31.addLayout(layout30)

        roamStepsGroupBoxLayout.addLayout(layout31,1,0)

        TabPageLayout.addWidget(self.roamStepsGroupBox,0,0)
        self.roamProfileTabWidget.insertTab(self.TabPage,QString(""))

        roamprofileLayout.addWidget(self.roamProfileTabWidget,1,1)

        self.languageChange()

        self.resize(QSize(846,537).expandedTo(self.minimumSizeHint()))
        self.clearWState(Qt.WState_Polished)

        self.setTabOrder(self.clientgroupListBox,self.roamProfileTabWidget)
        self.setTabOrder(self.roamProfileTabWidget,self.availablePortListView)
        self.setTabOrder(self.availablePortListView,self.moveSelectedToolButton)
        self.setTabOrder(self.moveSelectedToolButton,self.moveAllToolButton)
        self.setTabOrder(self.moveAllToolButton,self.selectedPortList)
        self.setTabOrder(self.selectedPortList,self.upToolButton)
        self.setTabOrder(self.upToolButton,self.downToolButton)
        self.setTabOrder(self.downToolButton,self.deleteSelectedToolButton)
        self.setTabOrder(self.deleteSelectedToolButton,self.deleteAllToolButton)
        self.setTabOrder(self.deleteAllToolButton,self.tabWidget3)
        self.setTabOrder(self.tabWidget3,self.timeDistRadio1)
        self.setTabOrder(self.timeDistRadio1,self.clientDistRadio1)
        self.setTabOrder(self.clientDistRadio1,self.fixedDwellTimeRadioButton)
        self.setTabOrder(self.fixedDwellTimeRadioButton,self.fixedTimeSpinBox)
        self.setTabOrder(self.fixedTimeSpinBox,self.startDwellSpinBox)
        self.setTabOrder(self.startDwellSpinBox,self.comboBox5)
        self.setTabOrder(self.comboBox5,self.endDwellSpinBox)
        self.setTabOrder(self.endDwellSpinBox,self.comboBox6)
        self.setTabOrder(self.comboBox6,self.changeStepSpinBox)
        self.setTabOrder(self.changeStepSpinBox,self.repeatCountRadioButton)
        self.setTabOrder(self.repeatCountRadioButton,self.repeatCountSpinBox)
        self.setTabOrder(self.repeatCountSpinBox,self.durationRadioButton)
        self.setTabOrder(self.durationRadioButton,self.durationSpinBox)
        self.setTabOrder(self.durationSpinBox,self.timeUnitComboBox)
        self.setTabOrder(self.timeUnitComboBox,self.numRoamsLineEdit)
        self.setTabOrder(self.numRoamsLineEdit,self.avgRoamsLineEdit)
        self.setTabOrder(self.avgRoamsLineEdit,self.numClientsLineEdit)
        self.setTabOrder(self.numClientsLineEdit,self.autoUpdateCheckBox)
        self.setTabOrder(self.autoUpdateCheckBox,self.applyPushButton)
        self.setTabOrder(self.applyPushButton,self.roamStepsTable)


    def languageChange(self):
        self.setCaption(self.__tr("Roam Profile"))
        self.textLabel1_2.setText(self.__tr("Client Group List"))
        self.moveSelectedToolButton.setText(self.__tr("Add >"))
        QToolTip.add(self.moveSelectedToolButton,self.__tr("Select"))
        self.moveAllToolButton.setText(self.__tr("Add All >>"))
        QToolTip.add(self.moveAllToolButton,self.__tr("Select All"))
        self.availablePortListView.header().setLabel(0,self.__tr("Available Port List"))
        self.selectedPortListLabel.setText(self.__tr("Selected Roam Sequence"))
        self.upToolButton.setText(self.__tr("Move Up"))
        QToolTip.add(self.upToolButton,self.__tr("Move Up"))
        self.downToolButton.setText(self.__tr("Move Down"))
        QToolTip.add(self.downToolButton,self.__tr("Move Down"))
        self.deleteSelectedToolButton.setText(self.__tr("Delete"))
        QToolTip.add(self.deleteSelectedToolButton,self.__tr("Delete"))
        self.deleteAllToolButton.setText(self.__tr("Delete All"))
        QToolTip.add(self.deleteAllToolButton,self.__tr("Delete All"))
        self.dwellTimeButtonGroup.setTitle(self.__tr("Dwell Time"))
        self.customDwellTimeRadioButton.setText(self.__tr("Custom"))
        self.fixedDwellTimeRadioButton.setText(self.__tr("Fixed Time"))
        self.fixedTimeSpinBox.setSuffix(self.__tr(" secs"))
        self.customDwellOptionsGroupBox.setTitle(self.__tr("Custom Options"))
        self.endDwellLabel.setText(self.__tr("End Dwell Time:"))
        self.dwellChangeLabel.setText(self.__tr("Change Step:"))
        self.startDwellLabel.setText(self.__tr("Start Dwell Time:"))
        self.startDwellSpinBox.setSuffix(QString.null)
        self.endDwellSpinBox.setSuffix(QString.null)
        self.comboBox5.clear()
        self.comboBox5.insertItem(self.__tr("msecs"))
        self.comboBox5.insertItem(self.__tr("secs"))
        self.comboBox6.clear()
        self.comboBox6.insertItem(self.__tr("msecs"))
        self.comboBox6.insertItem(self.__tr("secs"))
        self.repeatButtonGroup.setTitle(self.__tr("Total Roaming Duration"))
        self.durationRadioButton.setText(self.__tr("Time"))
        self.timeUnitComboBox.clear()
        self.timeUnitComboBox.insertItem(self.__tr("secs"))
        self.timeUnitComboBox.insertItem(self.__tr("mins"))
        self.timeUnitComboBox.insertItem(self.__tr("hrs"))
        self.repeatCountRadioButton.setText(self.__tr("Repeat Roam Sequence"))
        self.tabWidget3.changeTab(self.time,self.__tr("Duration"))
        self.clientDistButtonGroup.setTitle(self.__tr("Client Distribution"))
        self.clientDistRadio1.setText(self.__tr("All clients start from same AP"))
        self.clientDistRadio2.setText(self.__tr("Clients distibuted among APs"))
        self.timeDistButtonGroup.setTitle(self.__tr("Time Distribution"))
        self.timeDistRadio1.setText(self.__tr("All Client roam at same time"))
        self.timeDistRadio2.setText(self.__tr("Even Time Distribution"))
        self.tabWidget3.changeTab(self.distribution,self.__tr("Distribution"))
        self.powerProfileGroupBox.setTitle(self.__tr("Power Profile"))
        self.srcStartPrwSpinBox.setPrefix(self.__tr("Max "))
        self.srcStartPrwSpinBox.setSuffix(self.__tr(" dB"))
        self.srcStartPrwSpinBox.setSpecialValueText(self.__tr("Max"))
        self.srcEndPwrSpinBox.setPrefix(self.__tr("Max "))
        self.srcEndPwrSpinBox.setSuffix(self.__tr(" dB"))
        self.srcEndPwrSpinBox.setSpecialValueText(self.__tr("Max"))
        self.srcChangeStepSpinBox.setSuffix(self.__tr(" dB"))
        self.endTxPowerALabel.setText(self.__tr("Src Ap End Tx Power:"))
        self.startTxPowerALabel.setText(self.__tr("Src AP Start Tx Power:"))
        self.changeStepALabel.setText(self.__tr("Src AP Change Step:"))
        self.destStartPwrSpinBox.setPrefix(self.__tr("Max "))
        self.destStartPwrSpinBox.setSuffix(self.__tr(" dB"))
        self.destStartPwrSpinBox.setSpecialValueText(self.__tr("Max"))
        self.destEndPwrSpinBox.setPrefix(self.__tr("Max "))
        self.destEndPwrSpinBox.setSuffix(self.__tr(" dB"))
        self.destEndPwrSpinBox.setSpecialValueText(self.__tr("Max"))
        self.destChangeStepSpinBox.setSuffix(self.__tr(" dB"))
        self.destChangeIntSpinBox.setSuffix(self.__tr(" mSec"))
        self.startTxPowerBLabel.setText(self.__tr("Dst AP Start Tx Power:"))
        self.endTxPowerbLabel.setText(self.__tr("Dst AP End Tx Power:"))
        self.changeStepBLabel.setText(self.__tr("Dst AP Change Step:"))
        self.changeIntBLabel.setText(self.__tr("Dst AP Change Int:"))
        self.changeIntALabel.setText(self.__tr("Src AP Change Int:"))
        self.srcChangeIntSpinBox.setSuffix(self.__tr(" mSec"))
        self.tabWidget3.changeTab(self.power,self.__tr("Power"))
        self.flowParametersButtonGroup.setTitle(self.__tr("Flow Parameters"))
        self.textLabel2_2.setText(self.__tr("Packet Size"))
        self.textLabel3.setText(self.__tr("Flow Rate (Per Client)"))
        self.flowRateSpinBox.setSuffix(self.__tr(" pps"))
        self.learningFramesGroupBox.setTitle(self.__tr("Learning Frames"))
        self.textLabel4.setText(self.__tr("Dest IP address"))
        self.textLabel6.setText(self.__tr("Dest MAC Address"))
        self.learningPacketRateSpinBox.setSuffix(self.__tr(" fps"))
        self.textLabel5.setText(self.__tr("Learning Frame Rate"))
        self.tabWidget3.changeTab(self.flows,self.__tr("Flows"))
        self.fastRoamingButtonGroup.setTitle(self.__tr("Fast Roaming Options"))
        self.pmkidCheckBox.setText(self.__tr("PMKID Caching Enabled"))
        self.preauthCheckBox.setText(self.__tr("Pre-authentication Enabled"))
        self.additionalOptionsButtonGroup.setTitle(self.__tr("Client Options"))
        self.disassociateCheckBox.setText(self.__tr("Disassociate Client before Roam"))
        self.deauthCheckBox.setText(self.__tr("Deauth Client before Roam"))
        self.reassocCheckBox.setText(self.__tr("Re-Associate with New AP"))
        self.renewDhcpCheckBox.setText(self.__tr("Renew DHCP on Roam"))
        QToolTip.add(self.renewDhcpCheckBox,QString.null)
        self.renewDhcpOnConnCheckBox.setText(self.__tr("Renew DHCP on Reconnect"))
        QToolTip.add(self.renewDhcpOnConnCheckBox,QString.null)
        self.tabWidget3.changeTab(self.options,self.__tr("Options"))
        self.roamProfileTabWidget.changeTab(self.tab,self.__tr("Port Selection"))
        self.roamStepsGroupBox.setTitle(QString.null)
        self.roamStepsTable.horizontalHeader().setLabel(0,self.__tr("Client Name"))
        self.roamStepsTable.horizontalHeader().setLabel(1,self.__tr("SrcPort Name, BSSID"))
        self.roamStepsTable.horizontalHeader().setLabel(2,self.__tr("DestPort Name,BSSID"))
        self.roamStepsTable.horizontalHeader().setLabel(3,self.__tr("Roam EventTime(secs)"))
        self.roamStepsTable.verticalHeader().setLabel(0,self.__tr("0"))
        self.textLabel1_3.setText(self.__tr("Number of Roams:"))
        self.textLabel2_3.setText(self.__tr("Number of Roams/sec:"))
        self.textLabel3_2.setText(self.__tr("Number of Clients:"))
        self.autoUpdateCheckBox.setText(self.__tr("Auto Update"))
        self.applyPushButton.setText(self.__tr("Update"))
        self.roamProfileTabWidget.changeTab(self.TabPage,self.__tr("Roam Schedule"))


    def __tr(self,s,c = None):
        return qApp.translate("roamprofile",s,c)
