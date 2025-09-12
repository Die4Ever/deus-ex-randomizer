import argparse
import time
import sys
import json
import os.path
import urllib.request
import re
import threading
from tkinter import filedialog as fd
from tkinter import font
from tkinter import messagebox
from tkinter import *
from tkinter import simpledialog
from pathlib import Path
from PIL import Image, ImageDraw, ImageTk

BUTTON_BORDER_WIDTH = 4
BUTTON_BORDER_WIDTH_TOTAL=15*BUTTON_BORDER_WIDTH
BINGO_VARIABLE_CONFIG_NAME="bingoexport"
BINGO_MOD_LINE_DETECT="PlayerDataItem"
NEWLY_COMPLETED_DISPLAY_TIME=2.0
WINDOW_TITLE="Deus Ex Randomizer Bingo Board"
DEFAULT_WINDOW_WIDTH = 500
DEFAULT_WINDOW_HEIGHT = 500

MAGIC_GREEN    = "#1e641e"
BRIGHT_GREEN   = "#00CC00"
POSSIBLE_GREY  = "#505050"
IMPOSSIBLE_RED = "#300000"
NOT_NOW_BLACK  = "#000000"
TEXT_GREY      = "#c8c8c8"

def GetBorderScale():
    if os.name == 'nt': # Windows works correctly (for once)
        width=1
        height=1
    else: # Linux needs fixing
        width=2.85 # idk why these numbers
        height=1.7

    return width, height

SETTINGS_FILENAME="bingosettings.json"


#########################
# region BingoViewerMain
#########################
class BingoViewerMain:
    def __init__(self):

        #Config
        self.InitConfig()
        self.LoadConfig()

        self.targetFile = self.findBingoFile()
        self.working = True

        self.reader = None
        self.display = None

        #Maintain board state here
        self.board = [[None]*5 for i in range(5)]
        self.selectedMod = ""
        self.numMods=0

        if self.targetFile=='':
            self.working=False
        else:
            self.reader = BingoReader(self.targetFile,self.config.get("selected_mod",""),self)
            self.saveLastUsedBingoFile()
            self.lastFileUpdate=0
            self.display = BingoDisplay(self)
            self.display.Start()

    def SetSelectedMod(self,mod):
        self.selectedMod = self.translateMod(mod)
        self.display.updateTitleBar(self.selectedMod)
        if (mod!=self.config.get("selected_mod","")):
            self.config["selected_mod"]=mod
            self.SaveConfig()

    def UpdateNumMods(self,numMods):
        if (self.display==None or self.display.win==None):
            return

        if (numMods==self.numMods):
            return

        self.numMods=numMods

        if (numMods>1):
            self.display.SetMenuItemSelectability("Change Selected Mod",True)
        else:
            self.display.SetMenuItemSelectability("Change Selected Mod",False)

    def UpdateBoardSquare(self,x,y,val):
        if (self.board[x][y]!=val):
            self.board[x][y]=val

    def GetBoardEntry(self,x,y):
        return self.board[x][y]

    #Called either if something changes on the board, or at startup
    def BoardUpdate(self):
        self.display.updateTitleBar(self.selectedMod)
        for x in range(5):
            for y in range(5):
                self.display.updateSquare(x,y,self.board[x][y])

        self.sendBingoState()

    def IsRunning(self):
        print('BingoViewerMain.IsRunning', (self.reader!=None), (self.display!=None), self.working)
        if (self.reader!=None):
            if (not self.reader.IsRunning()):
                return False

        if (self.display!=None):
            if (not self.display.IsRunning()):
                return False

        return self.working

    def Stop(self):
        if (self.reader!=None):
            self.reader.Stop()

        if (self.display!=None):
            self.display.Stop()

        self.SaveConfig()

    def InitConfig(self):
        self.config = dict()
        self.config["json_push_dest"]=""
        self.config["last_used_file"]=""
        self.config["selected_mod"]=""
        self.config["show_progress_bars"]=True
        self.config["win_width"]=DEFAULT_WINDOW_WIDTH
        self.config["win_height"]=DEFAULT_WINDOW_HEIGHT

    def LoadConfig(self):
        conf = ""
        found = False
        try:
            f = open(SETTINGS_FILENAME)
            conf = f.read()
            found = True
            f.close()
        except FileNotFoundError as fnf:
            print("Could not find settings file...")
        except Exception as e:
            print(str(e))

        try:
            jconf = json.loads(conf)
        except Exception as e:
            found = False

        if (found):
            #merge what was found in the file with what is default
            self.config.update(jconf)

        self.SaveConfig()


    def SaveConfig(self):
        with open(SETTINGS_FILENAME,'w') as f:
            f.write(json.dumps(self.config,indent=4))


    def saveLastUsedBingoFile(self):
        p = Path(self.targetFile)
        newPath = str(p)
        curPath = self.config.get("last_used_file","")
        if (newPath!=curPath):
            self.config["last_used_file"]=newPath
            self.SaveConfig()

    def getDefaultPath(self):
        try:
            checks = [
                Path.home() / "Documents" / "Deus Ex" / "System",
                Path("C:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "Revision" / "System",
                Path("D:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "Revision" / "System",
                Path("C:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
                Path("D:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
                # Linux
                Path.home() /'.steam'/'steam'/'steamapps'/'compatdata'/'6910'/'pfx'/'drive_c'/'users'/'steamuser'/'Documents'/'Deus Ex'/'System',
                Path.home() /'snap'/'steam'/'common'/'.local'/'share'/'Steam'/'steamapps'/'common'/'Deus Ex'/'System',
                Path.home() /'.steam'/'steam'/'SteamApps'/'common'/'Deus Ex'/'System',
                Path.home() /'.local'/'share'/'Steam'/'steamapps'/'compatdata'/'6910'/'pfx'/'drive_c'/'users'/'steamuser'/'Documents'/'Deus Ex'/'System',
                Path.home() /'.local'/'share'/'Steam'/'steamapps'/'common'/'Deus Ex'/'System',
            ]

            modified_times = {}
            for p in checks:
                try:
                    f:Path = p / "DXRBingo.ini"
                    if f.exists():
                        modified_times[p] = os.path.getmtime(f)
                except Exception as e:
                    print(e)
            sorted_paths = sorted(modified_times.keys(), key=lambda f: modified_times[f])

            if len(sorted_paths) > 0:
                return sorted_paths[-1]
            p:Path
            for p in checks:
                try:
                    if p.is_dir():
                        return p
                except Exception as e:
                    print(e)
        except Exception as e:
            print(e)
        return None

    def selectNewBingoFile(self):
        target = self.selectBingoFile()
        if (target==""): # selecting Cancel returns blank, and clearly indicates you made a mistake
            return
        #print("New file: "+target)
        self.targetFile = target
        self.selectedMod=""
        self.saveLastUsedBingoFile()
        self.lastFileUpdate=0
        self.reader.UpdateTarget(target)

    def resetSelectedMod(self):
        self.selectedMod=""
        self.lastFileUpdate=0
        self.reader.UpdateTarget(self.targetFile)

    def findBingoFile(self):
        target = ""

        last_used = self.config.get("last_used_file","")
        if (last_used!=""):
            file = Path(last_used)
            if file.is_file():
                target = last_used

        if (target==""):
            target = self.selectBingoFile()

        return target

    def selectBingoFile(self):
        root = Tk()
        root.withdraw()
        filetype = (("DXRBingo File","DXRBingo.ini"),("all files","*.*"))
        initdir = self.getDefaultPath()
        target = fd.askopenfilename(title="Locate your DXRBingo File",filetypes=filetype, initialdir=initdir)
        root.destroy()
        return target

    def translateMod(self,modName):
        if "DeusEx" in modName:
            return "[Deus Ex Randomizer - Vanilla]"
        elif "GMDXRandomizer" in modName:
            return "[GMDX Randomizer]"
        elif "RevRandomizer" in modName:
            return "[Revision Randomizer]"
        elif "VMDRandomizer" in modName:
            return "[Vanilla? Madder. Randomizer]"
        elif "HXRandomizer" in modName:
            return "[HX Randomizer]"
        else:
            return modName

    def printBoard(self):
        for x in range(5):
            for y in range(5):
                print(str(x)+","+str(y)+": "+str(self.board[x][y]))

    #region Config Get/Set

    def GetJSONPushDest(self):
        return self.config.get("json_push_dest","")

    def SetJSONPushDest(self,dest):
        self.config["json_push_dest"]=dest
        self.SaveConfig()
        self.sendBingoState()

    def GetProgressBarState(self):
        return self.config.get("show_progress_bars",True)

    def SetProgressBarState(self,state):
        self.config["show_progress_bars"]=state
        self.SaveConfig()

    def SetWindowDimensions(self,width,height):
        self.config["win_width"]=int(width)
        self.config["win_height"]=int(height)

    def GetWindowDimensions(self):
        width  = self.config.get("win_width",DEFAULT_WINDOW_WIDTH)
        height = self.config.get("win_height",DEFAULT_WINDOW_HEIGHT)

        #Window dimensions are complicated on Linux, due to the window border scale issue
        #For now, don't fetch the saved window dimensions, just return the defaults
        if os.name != 'nt':
            width=DEFAULT_WINDOW_WIDTH
            height=DEFAULT_WINDOW_HEIGHT

        #Just in case
        if (width<=0):
            width=DEFAULT_WINDOW_WIDTH
        if (height<=0):
            height=DEFAULT_WINDOW_HEIGHT

        return int(width),int(height)

    #endregion

    def generateBingoStateJson(self):
        board = []
        for y in range(5):
            for x in range(5):
                square = dict()
                square["x"]=x
                square["y"]=y
                if self.board[x][y]==None:
                    return ""
                square["name"]=self.board[x][y]["desc"]
                if self.board[x][y]["max"]>1:
                    square["name"]+="\n"+str(self.board[x][y]["progress"])+"/"+str(self.board[x][y]["max"])
                square["completed"]=self.board[x][y]["progress"] >= self.board[x][y]["max"]
                square["possible"]=self.board[x][y]["active"]!=-1
                #print(square)
                board.append(square)
        return json.dumps(board,indent=4)

    def sendBingoState(self):
        #Pull the json destination from the config
        desturl=self.GetJSONPushDest()
        if (desturl=="" or desturl==None):
            return

        bingoState = self.generateBingoStateJson()
        #print(bingoState)
        if (bingoState==""):
            return

        try:
            data = bingoState.encode('utf-8')
            r = urllib.request.urlopen(desturl,data=data)
            #print(r.status)
            #print(r.read().decode('utf-8'))
        except Exception as e:
            print("Couldn't push JSON to "+desturl+" - "+str(e))


######################
# region BingoReader
######################

class BingoReader:

    def __init__(self,targetFile,selectedMod,main):
        self.main = main
        self.targetFile = targetFile
        self.selectedMod=selectedMod
        self.numMods = 0
        self.prevLines=None
        self.bingoLineMatch = re.compile(
            r'bingoexport\[(?P<key>\d+)\]=\(Event="(?P<event>.*)",Desc="(?P<desc>.*)",Progress=(?P<progress>\d+),Max=(?P<max>\d+),Active=(?P<active>-?\d+)\)',
            re.IGNORECASE
        )

        self.running = True
        self.readerThread = threading.Thread(target=self.readerTask)
        self.readerThread.daemon=True
        self.readerThread.start()

    def IsRunning(self):
        print('BingoReader.IsRunning', self.readerThread.is_alive())
        return self.readerThread.is_alive()

    def Stop(self):
        if (self.readerThread.is_alive()):
            self.running=False

    def UpdateTarget(self,target):
        self.targetFile = target
        self.selectedMod=""
        self.prevLines=None

###############################
#    INTERNAL
###############################

    def readerTask(self):
        try:
            while(self.main.IsRunning() and self.running):
                time.sleep(0.1)
                changed = self.readBingoFile()
                self.main.UpdateNumMods(self.numMods)
                print('readerTask readBingoFile changed:', changed)
                if (changed):
                    self.main.BoardUpdate()
                    self.main.SetSelectedMod(self.selectedMod)
        except Exception as e:
            print('readerTask error', e)
        print('readerTask end', self.main.IsRunning(), self.running)

    def bingoNumberToCoord(self,bingoNumber):
        x = bingoNumber//5
        y = bingoNumber%5
        return (x,y)

    def parseBingoLine(self,bingoLine):
        bingoMatches=self.bingoLineMatch.match(bingoLine)
        if (bingoMatches==None):
            return

        bingoNumber=int(bingoMatches.group('key'))
        bingoCoord = self.bingoNumberToCoord(bingoNumber)

        bingoItem = dict()
        bingoItem["event"]=bingoMatches.group('event')
        bingoItem["desc"]=bingoMatches.group('desc')
        bingoItem["progress"]=int(bingoMatches.group('progress'))
        bingoItem["max"]=int(bingoMatches.group('max'))
        bingoItem["active"]=int(bingoMatches.group('active'))

        self.main.UpdateBoardSquare(bingoCoord[0],bingoCoord[1],bingoItem)

    def readBingoFile(self):
        allLines = dict()
        try:
            try:
                with open(self.targetFile) as file:
                    bingoFile = file.readlines()
            except Exception as e:
                print("Couldn't read file, ignoring - "+str(e));
                return False

            for line in bingoFile:
                if BINGO_MOD_LINE_DETECT in line:
                    currentMod=line.strip()
                    allLines[currentMod]=[]
                elif line.startswith(BINGO_VARIABLE_CONFIG_NAME):
                    bingoLine = line.strip()
                    allLines[currentMod].append(bingoLine)
        except Exception as e:
            print(e)
            pass

        mods=list(allLines.keys())
        self.numMods = len(mods)

        if self.selectedMod not in mods:
            self.selectedMod=""

        if not self.selectedMod:
            if self.numMods>1:
                for mod in mods:
                    if messagebox.askyesno("Select your mod","Do you want to use "+self.main.translateMod(mod)):
                        self.selectedMod=mod
                        break
            elif self.numMods==1:
                self.selectedMod=mods[0]
            else:
                print("No mods detected in file")
                return False

        if self.selectedMod:
            for line in allLines[self.selectedMod]:
                self.parseBingoLine(line)

        changed = (allLines!=self.prevLines)

        if changed:
            self.prevLines=allLines

        return changed


########################
#region BingoDisplay
########################

class BingoDisplay:

    def __init__(self,main):
        self.main = main
        self.active = False
        self.tkBoard = [[None]*5 for i in range(5)]
        self.tkBoardText = [[None]*5 for i in range(5)]
        self.tkBoardImg = [[None]*5 for i in range(5)]

        self.width,self.height = self.main.GetWindowDimensions()
        #self.width=DEFAULT_WINDOW_WIDTH
        #self.height=DEFAULT_WINDOW_HEIGHT
        self.title = WINDOW_TITLE
        self.win=None

    def IsRunning(self):
        print('BingoDisplay.IsRunning', self.isWindowOpen())
        return self.isWindowOpen()

    def Stop(self):
        if (self.win):
            self.win.quit()

    def Start(self):
        self.initDrawnBoard()
        self.bringToFront()
        self.win.mainloop()
        self.main.Stop()

    def updateTitleBar(self,mod):
        self.title = WINDOW_TITLE+" "+mod
        if (self.win):
            self.win.title(self.title)

    def updateSquare(self,x,y,boardInfo):
        self.drawTile(x, y, boardInfo)

    def SetMenuItemSelectability(self,itemName,selectable):
        newState = "disabled"
        if (selectable):
            newState = "normal"

        if (self.active==False):
            return

        if (self.menuHasItem(self.filemenu,itemName)):
            self.filemenu.entryconfigure(itemName,state=newState)

        if (self.menuHasItem(self.dispmenu,itemName)):
            self.dispmenu.entryconfigure(itemName,state=newState)

        if (self.menuHasItem(self.othermenu,itemName)):
            self.othermenu.entryconfigure(itemName,state=newState)


    ##############################################
    # Internal
    ##############################################

    def menuHasItem(self,menu,label):
        try:
            menu.index(label)
            return True
        except:
            return False

    def bringToFront(self):
        self.win.attributes('-topmost',True)
        self.win.update()
        self.win.attributes('-topmost',False)

    def closeWindow(self):
        self.win.quit()
        self.win.destroy()
        self.win=None
        self.main.Stop()

    def isWindowOpen(self):
        return self.win!=None

    def getFontSizeByWindowSize(self):
        width = min(self.width, self.height)
        return int(width / 37)

    def resize(self,event):
        if event.widget == self.win:
            widthScale,heightScale = GetBorderScale()
            self.width=event.width - BUTTON_BORDER_WIDTH_TOTAL * widthScale
            self.height=event.height - BUTTON_BORDER_WIDTH_TOTAL * heightScale

            self.main.SetWindowDimensions(self.width,self.height)

            self.font = font.Font(size=self.getFontSizeByWindowSize())

            for x in range(5):
                for y in range(5):
                    self.tkBoard[x][y].config(
                        width=self.width/5,height=self.height/5,wraplength=self.width/5,font=self.font
                    )
                    self.drawTile(x,y,self.main.GetBoardEntry(x,y))

    def SelectNewJsonPushDest(self):
        dest = self.main.GetJSONPushDest()

        #Apparently making the prompt really long is actually the most portable way to make these windows wider
        selected = simpledialog.askstring(title="JSON Push", \
                                          prompt="New JSON Push Destination             (If you don't know what this is, leave it blank)", \
                                          initialvalue=dest, \
                                          parent=self.win)
        if (selected==None):
            return

        self.main.SetJSONPushDest(selected)

    def UpdateProgressBars(self):
        newState = self.showProgressBars.get()
        self.main.SetProgressBarState(newState)
        self.main.BoardUpdate()

    def ResetWindowSize(self):
        self.width=DEFAULT_WINDOW_WIDTH
        self.height=DEFAULT_WINDOW_HEIGHT
        self.win.geometry(str(self.width+BUTTON_BORDER_WIDTH_TOTAL)+"x"+str(self.height+BUTTON_BORDER_WIDTH_TOTAL))

    def ShowAboutWindow(self):
        msg = "Deus Ex Randomizer Bingo Viewer\n\n"
        msg+= "Version: "+GetVersion()

        messagebox.showinfo(title="About",message=msg)

    def initDrawnBoard(self):
        self.win = Tk()
        self.win.protocol("WM_DELETE_WINDOW",self.closeWindow)
        self.win.bind("<Configure>",self.resize)
        self.win.title(self.title)
        self.win.geometry(str(self.width+BUTTON_BORDER_WIDTH_TOTAL)+"x"+str(self.height+BUTTON_BORDER_WIDTH_TOTAL))
        self.win.config(bg="black")

        self.showProgressBars = BooleanVar()
        self.showProgressBars.set(self.main.GetProgressBarState())

        self.menubar = Menu(self.win)

        self.filemenu = Menu(self.menubar,tearoff=0)
        self.filemenu.add_command(label="Open",command=self.main.selectNewBingoFile)
        self.filemenu.add_command(label="Change Selected Mod",command=self.main.resetSelectedMod)
        self.filemenu.add_separator()
        self.filemenu.add_command(label="Exit",command=self.closeWindow) #Not really necessary, but just kind of... seems like it should be there?

        self.dispmenu = Menu(self.menubar,tearoff=0)
        self.dispmenu.add_command(label="Reset Window Size",command=self.ResetWindowSize)
        self.dispmenu.add_checkbutton(label="Show Progress Bars", onvalue=1, offvalue=0, variable=self.showProgressBars,command=self.UpdateProgressBars)

        self.othermenu = Menu(self.menubar,tearoff=0)
        self.othermenu.add_command(label="Change JSON Push dest",command=self.SelectNewJsonPushDest)
        self.othermenu.add_separator()
        self.othermenu.add_command(label="About",command=self.ShowAboutWindow)

        #Additional things we could add:
        # - Edit colours? tkinter -> colorchooser.askcolor
        # - Connect to PlayBingo session

        self.menubar.add_cascade(label="File",menu=self.filemenu)
        self.menubar.add_cascade(label="Display",menu=self.dispmenu)
        self.menubar.add_cascade(label="Other",menu=self.othermenu)
        self.win.config(menu=self.menubar)

        self.pixel = PhotoImage() #Needed to allow the button width/height to be configured in pixels
        self.font = font.Font(size=self.getFontSizeByWindowSize())
        for x in range(5):
            for y in range(5):
                self.tkBoardText[x][y]=StringVar()
                self.tkBoardText[x][y].set("("+str(x)+","+str(y)+")")
                self.tkBoardImg[x][y] = ImageTk.PhotoImage("RGB",size=(self.width/5, self.height/5))
                self.tkBoard[x][y]=Button(self.win,
                    textvariable=self.tkBoardText[x][y],
                    image=self.tkBoardImg[x][y],compound="c",
                    width=self.width/5, height=self.height/5,
                    wraplength=self.width/5, font=self.font,fg='white',
                    activeforeground='white',
                    disabledforeground="white", bd=BUTTON_BORDER_WIDTH
                )
                #self.tkBoard[x][y]["state"]='disabled'
                self.tkBoard[x][y].finished_time=None
                self.tkBoard[x][y].grid(column=x,row=y)

        self.active=True

        self.main.BoardUpdate()


    def drawTile(self, x, y, boardEntry):
        tkTile = self.tkBoard[x][y]
        tkText = self.tkBoardText[x][y]
        if boardEntry is None or tkTile is None:
            return

        desc = boardEntry["desc"]
        if boardEntry["max"]>1:
            desc=desc+"\n("+str(boardEntry["progress"])+"/"+str(boardEntry["max"])+")"

        tkText.set(desc)

        self.UpdateButtonImage(x,y,boardEntry)

        isActive = boardEntry.get('active', 1)
        if boardEntry["progress"]>=boardEntry["max"] and boardEntry["max"]>0:
            if tkTile.finished_time is None or tkTile.finished_time>time.time():
                tkTile.config(bg=BRIGHT_GREEN)
                if (tkTile.finished_time==None):
                    tkTile.finished_time=time.time() + NEWLY_COMPLETED_DISPLAY_TIME
                    self.win.after(int(NEWLY_COMPLETED_DISPLAY_TIME+1) * 1000,self.updateFinishedTileColour,x,y)
            else:
                tkTile.config(bg=MAGIC_GREEN)
        elif isActive == 1 or isActive == 2:# 1 is for maybe (No mission mask, or Any mission), 2 is for active
            tkTile.config(bg=POSSIBLE_GREY)
            tkTile.finished_time=None
        #elif isActive == 1:# 1 is for maybe
        #    tkTile.config(bg="#303030")
        elif isActive == -1:# -1 is for impossible
            tkTile.config(bg=IMPOSSIBLE_RED)
            tkTile.finished_time=None
        else:
            tkTile.config(bg=NOT_NOW_BLACK, fg=TEXT_GREY)
            tkTile.finished_time=None

    def UpdateButtonImage(self,x,y,boardEntry):
        if (self.showProgressBars.get()):
            isActive = boardEntry.get('active', 1)
            if boardEntry["progress"]>=boardEntry["max"] and boardEntry["max"]>0:
                #finished
                img = self.UpdateButtonImageFinished(x,y,boardEntry)
            elif (isActive==1 or isActive==2):
                #possible
                img = self.UpdateButtonImagePossible(x,y,boardEntry)
            elif (isActive == -1):
                #impossible
                img = self.UpdateButtonImagePlainColour(x,y,IMPOSSIBLE_RED)
            else:
                #not this mission
                img = self.UpdateButtonImagePlainColour(x,y,NOT_NOW_BLACK)

            tkimg = ImageTk.PhotoImage(img)
            self.tkBoardImg[x][y] = tkimg
        else:
            self.tkBoardImg[x][y]=self.pixel

        self.tkBoard[x][y].config(image=self.tkBoardImg[x][y])

    def UpdateButtonImagePossible(self,x,y,boardEntry):
        progress = boardEntry["progress"]
        maximum = boardEntry["max"]
        width  = int(self.width / 5)
        height = int(self.height / 5)

        if (maximum>0):
            percent = float(progress)/float(maximum)
        else:
            percent = progress

        #Clamp the percentage between 0.0 and 1.0
        max(min(percent,1.0),0.0)

        barHeight = height * percent

        img = Image.new("RGB",(width,height))
        draw = ImageDraw.Draw(img)

        draw.rectangle([(0,height-barHeight),(width,height)],fill=MAGIC_GREEN)
        draw.rectangle([(0,0),(width,height-barHeight)],fill=POSSIBLE_GREY)
        self.tkBoard[x][y].config(activebackground=POSSIBLE_GREY)

        return img

    def UpdateButtonImageFinished(self,x,y,boardEntry):

        tkTile = self.tkBoard[x][y]

        if tkTile.finished_time is None or tkTile.finished_time>time.time():
            colour=BRIGHT_GREEN
        else:
            colour=MAGIC_GREEN

        return self.UpdateButtonImagePlainColour(x,y,colour)

    #For when we just want to make the square a certain colour and it doesn't need any fancy logic
    def UpdateButtonImagePlainColour(self,x,y,colour):
        width  = int(self.width / 5)
        height = int(self.height / 5)

        img = Image.new("RGB",(width,height))
        draw = ImageDraw.Draw(img)

        draw.rectangle([(0,0),(width,height)],fill=colour)
        self.tkBoard[x][y].config(activebackground=colour)

        return img


    def updateFinishedTileColour(self,x,y):
        self.tkBoard[x][y].config(bg=MAGIC_GREEN,activebackground=MAGIC_GREEN)
        self.UpdateButtonImage(x,y,self.main.GetBoardEntry(x,y))



#####################################################################################
# region Actually Run
#####################################################################################

parser = argparse.ArgumentParser(description='DXRando Bingo Viewer')
parser.add_argument('--version', action="store_true", help='Output version')
args = parser.parse_args()

def GetVersion():
    return 'v3.6'

if args.version:
    print('DXRando Bingo Viewer version:', GetVersion(), file=sys.stderr)
    print('Python version:', sys.version_info, file=sys.stderr)
    sys.exit(0)

main = BingoViewerMain()

main.Stop()
