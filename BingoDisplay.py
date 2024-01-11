import argparse
import time
import sys
import json
import os.path
import urllib.request
import urllib.parse
import re
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

class Bingo:

    def __init__(self,targetFile):
        self.targetFile = targetFile
        self.board = [[None]*5 for i in range(5)]
        self.tkBoard = [[None]*5 for i in range(5)]
        self.tkBoardText = [[None]*5 for i in range(5)]
        self.width=500
        self.height=500
        self.selectedMod=""
        self.prevLines=None
        self.bingoLineMatch = re.compile(
            r'bingoexport\[(?P<key>\d+)\]=\(Event="(?P<event>.*)",Desc="(?P<desc>.*)",Progress=(?P<progress>\d+),Max=(?P<max>\d+),Active=(?P<active>-?\d+)\)',
            re.IGNORECASE
        )
        self.initDrawnBoard()

    def closeWindow(self):
        self.win.destroy()
        self.win=None

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
        self.win.title(WINDOW_TITLE)
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



    def drawBoard(self):
        self.win.title(WINDOW_TITLE+" "+translateMod(self.selectedMod))
        for x in range(5):
            for y in range(5):
                self.drawTile(self.tkBoard[x][y], self.tkBoardText[x][y], self.board[x][y])

    def drawTile(self, tkTile, tkText, boardEntry):
        if boardEntry is None or tkTile is None:
            return

        desc = boardEntry["desc"]
        if boardEntry["max"]>1:
            desc=desc+"\n("+str(boardEntry["progress"])+"/"+str(boardEntry["max"])+")"

        tkText.set(desc)
        isActive = boardEntry.get('active', 1)
        if boardEntry["progress"]>=boardEntry["max"] and boardEntry["max"]>0:
            if tkTile.finished_time is None:
                tkTile.finished_time=time.time() + NEWLY_COMPLETED_DISPLAY_TIME
                tkTile.config(bg=BRIGHT_GREEN)
            elif(tkTile.finished_time>time.time()):
                tkTile.config(bg=BRIGHT_GREEN)
            else:
                tkTile.config(bg=MAGIC_GREEN)
        elif isActive == 2:# 2 is for active
            tkTile.config(bg="#505050")
        elif isActive == 1:# 1 is for maybe
            tkTile.config(bg="#303030")
        elif isActive == -1:# -1 is for impossible
            tkTile.config(bg="#300000")
        else:
            tkTile.config(bg="#000000", fg="#c8c8c8") # text color adjustment isn't working


    def printBoard(self):
        for x in range(5):
            for y in range(5):
                print(str(x)+","+str(y)+": "+str(self.board[x][y]))

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

        self.board[bingoCoord[0]][bingoCoord[1]] = bingoItem

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
        #return json.dumps(board,indent=4)
        return {"bingo":json.dumps({"bingo":board},indent=4)}

    def sendBingoState(self):
        if not os.path.isfile(JSON_DEST_FILENAME):
            return

        f = open(JSON_DEST_FILENAME,'r')
        desturl=f.readline()
        f.close()

        if (desturl==""):
            print("Make sure to specify where you want to push your json!")
            return

        bingoState = self.generateBingoStateJson()
        #print(bingoState)
        try:
            r = urllib.request.urlopen(desturl,data=urllib.parse.urlencode(bingoState).encode('utf-8'))
            #print(r.status)
            #print(r.read().decode('utf-8'))
        except Exception as e:
            print("Couldn't push JSON to "+desturl+" - "+str(e))


def saveLastUsedBingoFile(f):
    p = Path(f)
    # TODO: save last used file and reuse it for getDefaultPath()

def getDefaultPath():
    checks = [
        Path.home() / "Documents" / "Deus Ex" / "System",
        Path("C:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "Revision" / "System",
        Path("D:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "Revision" / "System",
        Path("C:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
        Path("D:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
        # Linux
        Path.home() /'snap'/'steam'/'common'/'.local'/'share'/'Steam'/'steamapps'/'common'/'Deus Ex'/'System',
        Path.home() /'.steam'/'steam'/'SteamApps'/'common'/'Deus Ex'/'System',
        Path.home() /'.local'/'share'/'Steam'/'steamapps'/'compatdata'/'6910'/'pfx'/'drive_c'/'users'/'steamuser'/'Documents'/'Deus Ex'/'System',
        Path.home() /'.local'/'share'/'Steam'/'steamapps'/'common'/'Deus Ex'/'System',
    ]
    p:Path
    for p in checks:
        f:Path = p / "DXRBingo.ini"
        if f.exists():
            return p
    for p in checks:
        if p.is_dir():
            return p
    return None

def findBingoFile():
    root = Tk()
    root.withdraw()
    filetype = (("DXRBingo File","DXRBingo.ini"),("all files","*.*"))
    initdir = getDefaultPath()
    target = fd.askopenfilename(title="Locate your DXRBingo File",filetypes=filetype, initialdir=initdir)
    root.destroy()
    return target

def translateMod(modName):
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


#####################################################################################

parser = argparse.ArgumentParser(description='DXRando Bingo Viewer')
parser.add_argument('--version', action="store_true", help='Output version')
args = parser.parse_args()

def GetVersion():
    return 'v1.0'

if args.version:
    print('DXRando Bingo Viewer version:', GetVersion(), file=sys.stderr)
    print('Python version:', sys.version_info, file=sys.stderr)
    sys.exit(0)


targetFile = findBingoFile()

if targetFile=='':
    sys.exit(0)

b = Bingo(targetFile)
saveLastUsedBingoFile(targetFile)
lastFileUpdate=0

while True:
    if (time.time()>(lastFileUpdate+1)):
        changed = b.readBingoFile()
        #b.printBoard()
        lastFileUpdate=time.time()
        b.drawBoard()
        if (changed):
            b.sendBingoState()

    b.win.update()

    if not b.isWindowOpen():
        sys.exit(0)

    time.sleep(0.01)
