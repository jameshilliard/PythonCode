#!/usr/bin/env python
# coding=utf-8

__author__ = 'root'

import Tkinter

top = Tkinter.Tk()
quit = Tkinter.Button(top, text='Hello World!', command=top.quit())
quit.pack()
Tkinter.mainloop()