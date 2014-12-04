#!/usr/bin/env python
# coding=utf-8

__author__ = 'root'

from functools import partial as pto
from Tkinter import Tk, Button, X
from tkMessageBox import showinfo, showwarning, showerror

WARN = 'warn'
CRIT = 'crit'
REGU = 'regu'

SIGNS = {'do not enter': CRIT, 'railroad crossing': WARN, '55\nspeed limit': REGU,
         'wrong way': CRIT, 'merging traffic': WARN, 'one way': REGU, }

critCB = lambda: showerror('Error', 'Error Button Pressed!')
warnCB = lambda: showwarning('Warning', 'Warning Button Pressed!')
infoCB = lambda: showinfo('Info', 'Info Button Pressed!')

top = Tk()
top.title('Road Signs')
Button(top, text='QUIT', command=top.quit(), bg='green', fg='blue').pack()

MyButton = pto(Button, top)
CritButton = pto(MyButton, command=critCB, bg='yellow', fg='pick')
WarnButton = pto(MyButton, command=warnCB, bg='goldenrod1')
CritButton = pto(MyButton, command=infoCB, bg='white')

for eachSign in SIGNS:
    signType = SIGNS[eachSign]
    cmd = '%s Button(text=%r%s).pack(fill=X, expand=True)' % (
    signType.title(), eachSign, '.upper()' if signType == CRIT else '.title()')
    eval(cmd)

top.mainloop()
