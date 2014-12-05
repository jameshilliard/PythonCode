#!/usr/bin/env python
# coding=utf-8

__author__ = 'root'

import Tkinter

top = Tkinter.Tk()

hello = Tkinter.Label(top, text='Hello World!')
hello.pack()

_quit = Tkinter.Button(top, text='QUIT', command=top.quit, bg='red', fg='white')

_quit.pack(fill=Tkinter.X, expand=1)

Tkinter.mainloop()