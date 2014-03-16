#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#       未命名.py
#
#       Copyright 2011 rayofox <lhu@actiontec.com>
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#
#
from Tkinter import *


class tax(Frame):
    """caloulate personal tax"""
    field_list = ["Type Your Salary:", "Local Tax Start:"]

    def __init__(self, parent=None):
        Frame.__init__(self, parent)
        self.pack(side=TOP)
        self.entries = []
        for var_value in self.field_list:
            row = Frame(self)
            row.pack(side=TOP, fill=X)
            Label(row, text=var_value, width=15, height=2).pack(side=LEFT)
            ent = Entry(row, bg='white')
            ent.pack(side=RIGHT, expand=YES, fill=X)
            ent.bind('<Return>', (lambda event: self.fetch_value()))
            self.entries.append(ent)

        self.init_btn()
        self.init_result()

    def init_btn(self):
        """init control button"""
        btn_frame = Frame(self)
        btn_frame.pack(expand=YES, fill=X)
        btn_submit = Button(btn_frame, text='Submit', command=self.fetch_value)
        btn_submit.pack(side=LEFT, expand=YES, fill=X)
        Button(btn_frame, text="Reset", command=self.clear_data).pack(side=LEFT, expand=YES, fill=X)
        Button(btn_frame, text="Quit", command=sys.exit).pack(side=LEFT, expand=YES, fill=X)

    def init_result(self):
        """init result label"""
        self.lab_result = Label(self, fg='red', font=('times', 16, 'bold'))
        self.lab_result.pack(expand=YES, fill=X)

    def fetch_value(self):
        """fetch valve and get result"""
        result = []
        try:
            for entry in self.entries:
                result.append(entry.get())

            res = self.get_result(result[0], result[1])
            self.lab_result["text"] = 'Your Salary is %s .\n Your Tax is %s .\n Your Money is %s .\n' % (
            res[0], res[1], res[2])
            self.lab_result["bg"] = 'lightyellow'
            self.lab_result["fg"] = 'red'
        except ValueError:
            self.lab_result["bg"] = 'red'
            self.lab_result["fg"] = 'black'
            self.lab_result["text"] = 'Error Occur,Please Test Again.'

    def get_result(self, salary, start):
        """caloulate tax"""
        over = float(salary) - float(start)
        tax = ""
        if over <= 500:
            tax = over * 0.05
        elif over > 500 and over <= 2000:
            tax = over * 0.1 - 25
        elif over > 2000 and over <= 5000:
            tax = over * 0.15 - 125
        elif over > 5000 and over <= 20000:
            tax = over * 0.2 - 375
        elif over > 20000 and over <= 40000:
            tax = over * 0.25 - 1375
        elif over > 40000 and over <= 60000:
            tax = over * 0.3 - 3375
        elif over > 60000 and over <= 80000:
            tax = over * 0.35 - 6375
        elif over > 80000 and over <= 100000:
            tax = over * 0.4 - 10375
        else:
            tax = over * 0.45 - 15375
        return [salary, tax, float(salary) - tax]

    def clear_data(self):
        """clear old data"""
        for entry in self.entries:
            entry.delete(0, END)
        self.lab_result["text"] = ''
        self.lab_result["bg"] = '#eeeeee'


def main():
    #start process
    root = Tk()
    root.title('Personal Income caloulate')
    root.geometry("350x200+250+50")
    per_tax = tax(root)
    root.mainloop()
    return 0


if __name__ == '__main__':
    main()

