import argparse
import time
import sys
import json
import os.path
import urllib.request
import urllib.parse
import re
import threading
from tkinter import filedialog as fd
from tkinter import font
from tkinter import messagebox
from tkinter import *
from pathlib import Path

BUTTON_BORDER_WIDTH = 4
BUTTON_BORDER_WIDTH_TOTAL=15*BUTTON_BORDER_WIDTH
MAGIC_GREEN="#1e641e"
BRIGHT_GREEN="#00CC00"
BINGO_VARIABLE_CONFIG_NAME="bingoexport"
BINGO_MOD_LINE_DETECT="PlayerDataItem"
NEWLY_COMPLETED_DISPLAY_TIME=2.8 # we only redraw every second, so this will keep it closer to about 3 seconds
WINDOW_TITLE="Deus Ex Randomizer Bingo Board"

if os.name == 'nt': # Windows works correctly (for once)
    BORDER_WIDTH_SCALE=1
    BORDER_HEIGHT_SCALE=1
else: # Linux needs fixing
    BORDER_WIDTH_SCALE=2.85 # idk why these numbers
    BORDER_HEIGHT_SCALE=1.7

JSON_DEST_FILENAME="pushjson.txt"


#########################
# region BingoViewerMain
#########################
class BingoViewerMain:
    def __init__(self):
        self.targetFile = self.findBingoFile()
        self.working = True

        self.reader = None
        self.display = None

        #Maintain board state here
        self.board = [[None]*5 for i in range(5)]
        self.selectedMod = ""

        if self.targetFile=='':
            self.working=False
        else:
            self.reader = BingoReader(self.targetFile,self)
            self.saveLastUsedBingoFile()
            self.lastFileUpdate=0
            self.display = BingoDisplay(self)
            self.display.Start()

    def SetSelectedMod(self,mod):
        self.selectedMod = self.translateMod(mod)
        self.display.updateTitleBar(self.selectedMod)

    def UpdateBoardSquare(self,x,y,val):
        if (self.board[x][y]!=val):
            self.board[x][y]=val

    #Called either if something changes on the board, or at startup
    def BoardUpdate(self):
        self.display.updateTitleBar(self.selectedMod)
        for x in range(5):
            for y in range(5):
                self.display.updateSquare(x,y,self.board[x][y])

        self.sendBingoState()

    def IsRunning(self):
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


    def saveLastUsedBingoFile(self):
        p = Path(self.targetFile)
        # TODO: save last used file and reuse it for getDefaultPath()

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

    def findBingoFile(self):
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

    def generateBingoStateJson(self):
        board = []
        for y in range(5):
            for x in range(5):
                square = dict()
                square["x"]=x
                square["y"]=y
                if self.board[x][y]==None:
                    return {}
                square["name"]=self.board[x][y]["desc"]
                if self.board[x][y]["max"]>1:
                    square["name"]+="\n"+str(self.board[x][y]["progress"])+"/"+str(self.board[x][y]["max"])
                square["completed"]=self.board[x][y]["progress"] >= self.board[x][y]["max"]
                square["possible"]=self.board[x][y]["active"]!=-1
                #print(square)
                board.append(square)
        return json.dumps(board,indent=4)

    def sendBingoState(self):
        dest = Path(self.targetFile).parent/JSON_DEST_FILENAME
        if not os.path.isfile(dest):
            return

        f = open(dest,'r')
        desturl=f.readline()
        f.close()

        if (desturl==""):
            print("Make sure to specify where you want to push your json!")
            return

        bingoState = self.generateBingoStateJson()
        #print(bingoState)
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

    def __init__(self,targetFile,main):
        self.main = main
        self.targetFile = targetFile
        self.selectedMod=""
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
        return self.readerThread.is_alive()

    def Stop(self):
        if (self.readerThread.is_alive()):
            self.running=False

###############################
#    INTERNAL
###############################

    def readerTask(self):
        while(self.main.IsRunning() and self.running):
            time.sleep(0.1)
            changed = self.readBingoFile()
            if (changed):
                self.main.BoardUpdate()
                self.main.SetSelectedMod(self.selectedMod)

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

        if self.selectedMod not in mods:
            self.selectedMod=""

        if not self.selectedMod:
            if len(mods)>1:
                for mod in mods:
                    if messagebox.askyesno("Select your mod","Do you want to use "+translateMod(mod)):
                        self.selectedMod=mod
                        break
            elif len(mods)==1:
                self.selectedMod=mods[0]
            else:
                print("No mods")
                sys.exit(0)

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
        self.tkBoard = [[None]*5 for i in range(5)]
        self.tkBoardText = [[None]*5 for i in range(5)]
        self.width=500
        self.height=500
        self.title = WINDOW_TITLE

    def IsRunning(self):
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
        self.win.title(self.title)

    def updateSquare(self,x,y,boardInfo):
        self.drawTile(self.tkBoard[x][y], self.tkBoardText[x][y], boardInfo)

    ##############################################
    # Internal
    ##############################################

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
            self.width=event.width - BUTTON_BORDER_WIDTH_TOTAL * BORDER_WIDTH_SCALE
            self.height=event.height - BUTTON_BORDER_WIDTH_TOTAL * BORDER_HEIGHT_SCALE

            self.font = font.Font(size=self.getFontSizeByWindowSize())

            for x in range(5):
                for y in range(5):
                    self.tkBoard[x][y].config(
                        width=self.width/5,height=self.height/5,wraplength=self.width/5,font=self.font
                    )

    def initDrawnBoard(self):
        self.win = Tk()
        self.win.protocol("WM_DELETE_WINDOW",self.closeWindow)
        self.win.bind("<Configure>",self.resize)
        self.win.title(self.title)
        self.win.geometry(str(self.width+BUTTON_BORDER_WIDTH_TOTAL)+"x"+str(self.height+BUTTON_BORDER_WIDTH_TOTAL))
        self.win.config(bg="black")
        self.pixel = PhotoImage() #Needed to allow the button width/height to be configured in pixels
        self.font = font.Font(size=self.getFontSizeByWindowSize())
        for x in range(5):
            for y in range(5):
                self.tkBoardText[x][y]=StringVar()
                self.tkBoardText[x][y].set("("+str(x)+","+str(y)+")")
                self.tkBoard[x][y]=Button(self.win,
                    textvariable=self.tkBoardText[x][y],
                    image=self.pixel,compound="c",
                    width=self.width/5, height=self.height/5,
                    wraplength=self.width/5, font=self.font,fg='white',
                    disabledforeground="white", bd=BUTTON_BORDER_WIDTH
                )
                self.tkBoard[x][y]["state"]='disabled'
                self.tkBoard[x][y].finished_time=None
                self.tkBoard[x][y].grid(column=x,row=y)

        self.main.BoardUpdate()


    def drawTile(self, tkTile, tkText, boardEntry):
        if boardEntry is None or tkTile is None:
            return

        desc = boardEntry["desc"]
        if boardEntry["max"]>1:
            desc=desc+"\n("+str(boardEntry["progress"])+"/"+str(boardEntry["max"])+")"

        tkText.set(desc)
        isActive = boardEntry.get('active', 1)
        if boardEntry["progress"]>=boardEntry["max"] and boardEntry["max"]>0:
            if tkTile.finished_time is None or tkTile.finished_time>time.time():
                tkTile.finished_time=time.time() + NEWLY_COMPLETED_DISPLAY_TIME
                tkTile.config(bg=BRIGHT_GREEN)
                self.win.after(int(NEWLY_COMPLETED_DISPLAY_TIME) * 1000,self.updateFinishedTileColour,tkTile)
            else:
                tkTile.config(bg=MAGIC_GREEN)
        elif isActive == 1 or isActive == 2:# 1 is for maybe (No mission mask, or Any mission), 2 is for active
            tkTile.config(bg="#505050")
            tkTile.finished_time=None
        #elif isActive == 1:# 1 is for maybe
        #    tkTile.config(bg="#303030")
        elif isActive == -1:# -1 is for impossible
            tkTile.config(bg="#300000")
            tkTile.finished_time=None
        else:
            tkTile.config(bg="#000000", fg="#c8c8c8") # text color adjustment isn't working
            tkTile.finished_time=None

    def updateFinishedTileColour(self,tkTile):
        tkTile.config(bg=MAGIC_GREEN)



#####################################################################################
# region Actually Run
#####################################################################################

parser = argparse.ArgumentParser(description='DXRando Bingo Viewer')
parser.add_argument('--version', action="store_true", help='Output version')
args = parser.parse_args()

def GetVersion():
    return 'v3.5'

if args.version:
    print('DXRando Bingo Viewer version:', GetVersion(), file=sys.stderr)
    print('Python version:', sys.version_info, file=sys.stderr)
    sys.exit(0)

main = BingoViewerMain()

main.Stop()
