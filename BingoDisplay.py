import time
import sys
from tkinter import filedialog as fd
from tkinter import font
from tkinter import *

BUTTON_BORDER_WIDTH = 4
BUTTON_BORDER_WIDTH_TOTAL=15*BUTTON_BORDER_WIDTH
MAGIC_GREEN="#1e641e"
BRIGHT_GREEN="#00FF00"
BINGO_VARIABLE_CONFIG_NAME="bingoexport"
NEWLY_COMPLETED_DISPLAY_TIME=80

class Bingo:

    def __init__(self,targetFile):
        self.targetFile = targetFile;
        self.board = [[None]*5 for i in range(5)]
        self.tkBoard = [[None]*5 for i in range(5)]
        self.tkBoardText = [[None]*5 for i in range(5)]
        self.width=500
        self.height=500
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
        self.win.title("Deus Ex Randomizer Bingo Board")
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
                self.tkBoard[x][y].countdown=0
                self.tkBoard[x][y].grid(column=x,row=y)



    def drawBoard(self):
        for x in range(5):
            for y in range(5):
                boardEntry = self.board[x][y]
                if boardEntry!=None and self.tkBoard[x][y]!=None:
                    desc = boardEntry["Desc"]
                    if boardEntry["Max"]>1:
                        desc=desc+"\n("+str(boardEntry["Progress"])+"/"+str(boardEntry["Max"])+")"

                    self.tkBoardText[x][y].set(desc)
                    if boardEntry["Progress"]>=boardEntry["Max"] and boardEntry["Max"]>0:
                        if self.tkBoard[x][y].cget('bg')=="black":
                            self.tkBoard[x][y].countdown=NEWLY_COMPLETED_DISPLAY_TIME
                            self.tkBoard[x][y].config(bg=BRIGHT_GREEN)
                        else:
                            if(self.tkBoard[x][y].countdown>0):
                                self.tkBoard[x][y].countdown-=1
                                self.tkBoard[x][y].config(bg=BRIGHT_GREEN)
                            else:
                                self.tkBoard[x][y].config(bg=MAGIC_GREEN)
                    else:
                        self.tkBoard[x][y].config(bg="black")

        self.win.update()

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
            fieldName = split[0]
            fieldVal = split[1].replace('"',"")
            if fieldVal.isdigit():
                fieldVal = int(fieldVal)
            bingoItem[fieldName]=fieldVal

        self.board[bingoCoord[0]][bingoCoord[1]] = bingoItem

    def readBingoFile(self):
        try:
            bingoFile = open(self.targetFile);
            for line in bingoFile:
                if line.startswith(BINGO_VARIABLE_CONFIG_NAME):
                    bingoLine = line.strip()
                    self.parseBingoLine(bingoLine)
        except Exception as e:
            pass


def findBingoFile():
    root = Tk()
    root.withdraw()
    filetype = (("DXRBingo File","DXRBingo.ini"),("all files","*.*"))
    target = fd.askopenfilename(title="Locate your DXRBingo File",filetypes=filetype)
    root.destroy()
    return target

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

