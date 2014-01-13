#conding=utf-8
__author__ = 'royxu'

import time

import serial

import time
import serial

ser = serial.Serial(#下面这些参数根据情况修改
                    port='/dev/tty',
                    baudrate=9600,
                    parity=serial.PARITY_ODD,
                    stopbits=serial.STOPBITS_TWO,
                    bytesize=serial.SEVENBITS
)
data = ''
while ser.inWaiting() > 0:
    data += ser.read(1)
if data != '':
    print data


