from GUI import *
from pathlib import Path
from Install import Install

class InstallerWindow(GUIBase):
    def initWindow(self):
        self.root = Tk()
        self.root.title("Deus Ex Randomizer Installer/Launcher")
        self.root.geometry(str(self.width)+"x"+str(self.height))


def main():
    filetypes = (('DeusEx.exe', 'DeusEx.exe'),)
    initdir = getDefaultPath()
    p = fd.askopenfilename(title="Find plain DeusEx.exe", filetypes=filetypes, initialdir=initdir)
    p = Path(p)
    print(p)
    InstallerWindow()
    # TODO: options like Kentie's DeusExe vs Han's Launchbox, whether to apply the Engine.dll speedup fix or not, checking for updates...
    # option for enabling Online Features
    flavors = Install.Install(p)
    flavors = ', '.join(flavors)
    messagebox.showinfo('Installation Complete!', 'Installed: ' + flavors)


def getDefaultPath():
    checks = [
        Path("C:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
        Path("D:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
    ]
    p:Path
    for p in checks:
        f:Path = p / "DeusEx.exe"
        if f.exists():
            return p
    return None
