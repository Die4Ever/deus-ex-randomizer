import time
import sys
from tkinter import filedialog as fd
from tkinter import font
from tkinter import *

class Bingo:

    def __init__(self,targetFile):
        self.targetFile = targetFile;
        self.board = [[None]*5 for i in range(5)]
        self.tkBoard = [[None]*5 for i in range(5)]
        self.tkBoardText = [[None]*5 for i in range(5)]
        self.initDrawnBoard()

    def closeWindow(self):
        self.win.destroy()
        self.win=None

    def windowOpen(self):
        return self.win!=None

    def initDrawnBoard(self):
        self.win = Tk()
        self.win.protocol("WM_DELETE_WINDOW",self.closeWindow)
        self.win.title("Deus Ex Randomizer Bingo Board")
        self.win.geometry("536x536")
        self.pixel = PhotoImage(width=1,height=1) #Needed to allow the button width/height to be configured in pixels
        self.font = font.Font(size=12)
        for x in range(5):
            for y in range(5):
                self.tkBoardText[x][y]=StringVar()
                self.tkBoardText[x][y].set("("+str(x)+","+str(y)+")")
                self.tkBoard[x][y]=Button(self.win,textvariable=self.tkBoardText[x][y],image=self.pixel,compound="c",width=100,height=100,wraplength=100,font=self.font)
                self.tkBoard[x][y].state=DISABLED
                self.tkBoard[x][y].grid(column=x,row=y)
                


    def drawBoard(self):
        for x in range(5):
            for y in range(5):
                boardEntry = self.board[x][y]
                if boardEntry!=None and self.tkBoard[x][y]!=None:
                    self.tkBoardText[x][y].set(boardEntry["Desc"])
                    if boardEntry["Progress"]>=boardEntry["Max"]:
                        self.tkBoard[x][y].config(bg="green")
                    else:
                        self.tkBoard[x][y].config(bg="white")
                        
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
                if line.startswith("bingoexport["):
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

lastUpdate=0

while True:
    if (time.time()>(lastUpdate+1)):
        b.readBingoFile()
        #b.printBoard()
        lastUpdate=time.time()
    if (b.windowOpen()):
        b.drawBoard()
    else:
        sys.exit(0)
    
