import time
import sys
from tkinter import filedialog as fd
from tkinter import font
from tkinter import messagebox
from tkinter import *
from pathlib import Path

class GUIBase:
    def __init__(self):
        self.width=480
        self.height=500
        self.initWindow()
        if self.root:
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

