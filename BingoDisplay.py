import time
import sys
from tkinter import filedialog as fd
from tkinter import font
from tkinter import messagebox
from tkinter import *

BUTTON_BORDER_WIDTH = 4
BUTTON_BORDER_WIDTH_TOTAL=15*BUTTON_BORDER_WIDTH
MAGIC_GREEN="#1e641e"
BRIGHT_GREEN="#00FF00"
BINGO_VARIABLE_CONFIG_NAME="bingoexport"
BINGO_MOD_LINE_DETECT="PlayerDataItem"
NEWLY_COMPLETED_DISPLAY_TIME=80
WINDOW_TITLE="Deus Ex Randomizer Bingo Board"

class Bingo:

    def __init__(self,targetFile):
        self.targetFile = targetFile
        self.board = [[None]*5 for i in range(5)]
        self.tkBoard = [[None]*5 for i in range(5)]
        self.tkBoardText = [[None]*5 for i in range(5)]
        self.width=500
        self.height=500
        self.selectedMod=""
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
            self.width=event.width-BUTTON_BORDER_WIDTH_TOTAL
            self.height=event.height-BUTTON_BORDER_WIDTH_TOTAL

            self.font = font.Font(size=self.getFontSizeByWindowSize())

            for x in range(5):
                for y in range(5):
                    self.tkBoard[x][y].config(width=self.width/5,height=self.height/5,wraplength=self.width/5,font=self.font)



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
                self.tkBoard[x][y]=Button(self.win,textvariable=self.tkBoardText[x][y],image=self.pixel,compound="c",width=self.width/5,height=self.height/5,wraplength=self.width/5,font=self.font,fg='white',disabledforeground="white",bd=BUTTON_BORDER_WIDTH)
                self.tkBoard[x][y]["state"]='disabled'
                self.tkBoard[x][y].countdown=None
                self.tkBoard[x][y].grid(column=x,row=y)



    def drawBoard(self):
        self.win.title(WINDOW_TITLE+" "+translateMod(self.selectedMod))
        for x in range(5):
            for y in range(5):
                self.drawTile(self.tkBoard[x][y], self.tkBoardText[x][y], self.board[x][y])

        self.win.update()

    def drawTile(self, tkTile, tkText, boardEntry):
        if boardEntry is None or tkTile is None:
            return

        desc = boardEntry["desc"]
        if boardEntry["max"]>1:
            desc=desc+"\n("+str(boardEntry["progress"])+"/"+str(boardEntry["max"])+")"

        tkText.set(desc)
        isActive = boardEntry.get('active', 1)
        if boardEntry["progress"]>=boardEntry["max"] and boardEntry["max"]>0:
            if tkTile.countdown is None:
                tkTile.countdown=NEWLY_COMPLETED_DISPLAY_TIME
                tkTile.config(bg=BRIGHT_GREEN)
            elif(tkTile.countdown>0):
                tkTile.countdown-=1
                tkTile.config(bg=BRIGHT_GREEN)
            else:
                tkTile.config(bg=MAGIC_GREEN)
        elif isActive == 2:# 2 is for active
            tkTile.config(bg="#505050")
        elif isActive == 1:# 1 is for maybe
            tkTile.config(bg="#303030")
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
        bingoNumber = int(bingoLine.split("[")[1].split("]")[0])
        bingoCoord = self.bingoNumberToCoord(bingoNumber)
        state = "=".join(bingoLine.split("=")[1:])[1:-1]
        fields = state.split(",")
        bingoItem = dict()
        for field in fields:
            split = field.split("=")
            fieldName = split[0].lower()
            fieldVal = split[1].replace('"',"")
            if fieldVal.isdigit():
                fieldVal = int(fieldVal)
            bingoItem[fieldName]=fieldVal

        self.board[bingoCoord[0]][bingoCoord[1]] = bingoItem

    def readBingoFile(self):
        allLines = dict()
        try:
            with open(self.targetFile) as file:
                bingoFile = file.readlines()

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



def findBingoFile():
    root = Tk()
    root.withdraw()
    filetype = (("DXRBingo File","DXRBingo.ini"),("all files","*.*"))
    target = fd.askopenfilename(title="Locate your DXRBingo File",filetypes=filetype)
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


targetFile = findBingoFile()

if targetFile=='':
    sys.exit(0)

b = Bingo(targetFile)

lastFileUpdate=0

while True:
    if (time.time()>(lastFileUpdate+1)):
        b.readBingoFile()
        #b.printBoard()
        lastFileUpdate=time.time()

    if (b.isWindowOpen()):
        b.drawBoard()
    else:
        sys.exit(0)

