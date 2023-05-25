from GUI import *

class InstallerWindow(GUIBase):
    def initWindow(self):
        self.root = Tk()
        self.root.title("Deus Ex Randomizer Installer/Launcher")
        self.root.geometry(str(self.width)+"x"+str(self.height))

def main():
    InstallerWindow()

# TODO:
# choose a folder
# determine game variant using our Install module
# ask user for options like Kentie's Launcher or Han's Launchbox, Engine.dll speedup fix...
# ability to check for updates
