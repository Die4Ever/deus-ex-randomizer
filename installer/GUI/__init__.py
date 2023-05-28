import os
import time
import sys
from tkinter import filedialog as fd
from tkinter import font
from tkinter import messagebox
from tkinter import *
from pathlib import Path
import traceback
from idlelib.tooltip import Hovertip

class GUIBase:
    def __init__(self):
        self.width=480
        self.height=500
        self.initWindow()
        if self.root:
            self.root.protocol("WM_DELETE_WINDOW",self.closeWindow)
            self.root.bind("<Configure>",self.resize)
            self.root.mainloop()

    def closeWindow(self):
        self.root.destroy()
        self.root=None

    def isWindowOpen(self) -> bool:
        return self.root!=None

    def resize(self,event):
        if event.widget == self.root:
            try:
                self.width = event.width
                self.height = event.height
            except Exception as e:
                print('ERROR: in resize:', e)

    def newInput(self, cls, label:str, tooltip:str, row:int, *args, **kargs):
        label = Label(self.win,text=label,width=22,height=2,font=self.font, anchor='e', justify='left')
        label.grid(column=0,row=row, sticky='E')
        if cls == OptionMenu:
            entry = cls(self.win, *args, **kargs)
        else:
            entry = cls(self.win, *args, width=18,font=self.font, **kargs)
        entry.grid(column=1,row=row, sticky='W')

        myTip = Hovertip(label, tooltip)
        myTip = Hovertip(entry, tooltip)
        return entry

    def FixColors(self, w):
        w.config(bg="#d9d9d9",fg="black")


# from https://stackoverflow.com/a/68701602
class ScrollableFrame:
    """
    # How to use class
    from tkinter import *
    obj = ScrollableFrame(master,height=300 # Total required height of canvas,width=400 # Total width of master)
    objframe = obj.frame
    # use objframe as the main window to make widget
    """
    def __init__ (self,master,width,height,mousescroll=0):
        self.mousescroll = mousescroll
        self.master = master
        self.height = height
        self.width = width
        self.main_frame = Frame(self.master)
        self.main_frame.pack(fill=BOTH,expand=1)

        self.scrollbar = Scrollbar(self.main_frame, orient=VERTICAL)
        self.scrollbar.pack(side=RIGHT,fill=Y)

        self.canvas = Canvas(self.main_frame,yscrollcommand=self.scrollbar.set)
        self.canvas.pack(expand=True,fill=BOTH)

        self.scrollbar.config(command=self.canvas.yview)

        self.canvas.bind('<Configure>', lambda e: self.canvas.configure(scrollregion = self.canvas.bbox("all")))

        self.frame = Frame(self.canvas,width=self.width,height=self.height)
        self.frame.pack(expand=True,fill=BOTH)
        self.canvas.create_window((0,0), window=self.frame, anchor="nw")

        self.frame.bind("<Enter>", self.entered)
        self.frame.bind("<Leave>", self.left)

    def _on_mouse_wheel(self,event):
        self.canvas.yview_scroll(-1 * int((event.delta / 120)), "units")

    def entered(self,event):
        if self.mousescroll:
            self.canvas.bind_all("<MouseWheel>", self._on_mouse_wheel)

    def left(self,event):
        if self.mousescroll:
            self.canvas.unbind_all("<MouseWheel>")


def errordialog(title, msg, e=None):
    if e:
        msg += '\n' + str(e) + '\n\n' + traceback.format_exc()
    print(title, '\n', msg)
    messagebox.showerror(title, msg)

