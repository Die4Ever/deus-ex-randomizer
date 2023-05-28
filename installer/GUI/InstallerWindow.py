import webbrowser
from GUI import *
from pathlib import Path
from Install import Install, IsWindows

class InstallerWindow(GUIBase):
    def initWindow(self):
        self.root = Tk()
        self.width = 350
        self.height = 500
        self.root.title("Deus Ex Randomizer Installer")
        self.root.geometry(str(self.width)+"x"+str(self.height))

        scroll = ScrollableFrame(self.root, width=self.width, height=self.height, mousescroll=1)
        self.frame = scroll.frame

        filetypes = (('DeusEx.exe', 'DeusEx.exe'),)
        initdir = getDefaultPath()
        p = fd.askopenfilename(title="Find plain DeusEx.exe", filetypes=filetypes, initialdir=initdir)
        p = Path(p)
        print(p)
        assert p.name.lower() == 'deusex.exe'
        assert p.parent.name.lower() == 'system'
        self.exe = p

        flavors = Install.DetectFlavors(self.exe)
        print(flavors)

        self.font = font.Font(size=14)
        self.linkfont = font.Font(size=12, underline=True)
        row = 0
        pad = 6

        # show the path
        l = Label(self.frame, text='Install path:\n' + str(p.parent.parent), wraplength=self.width-pad*5)
        l.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
        row += 1

        self.exevar = StringVar(master=self.frame, value='Kentie')
        if not IsWindows():
            self.exevar.set('Launch')
        self.flavors = {}

        for f in flavors:
            v = BooleanVar(master=self.frame, value=True)
            c = Checkbutton(self.frame, text="Install DXRando for "+f, variable=v)
            c.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
            self.FixColors(c)
            row+=1
            self.flavors[f] = v
            if f == 'Vanilla' and IsWindows():
                l = Label(self.frame, text="Which EXE to use for vanilla:")
                l.grid(column=1,row=row, sticky='SW', padx=pad*4, pady=pad)
                row += 1
                v = self.exevar
                r = Radiobutton(self.frame, text="Kentie", variable=v, value='Kentie')
                r.grid(column=1,row=row, sticky='SW', padx=pad*8, pady=pad)
                self.FixColors(r)
                Hovertip(r, "Kentie's Launcher stores configs and saves in your Documents folder.")
                row += 1
                r = Radiobutton(self.frame, text="Hanfling's Launch", variable=v, value='Launch')
                r.grid(column=1,row=row, sticky='SW', padx=pad*8, pady=pad)
                self.FixColors(r)
                Hovertip(r, "Hanfling's Launch stored configs and saves in the game directory.\nIf your game is in Program Files, then the game might require admin permissions to play.")
                row += 1

        # engine.dll speedup fix
        self.speedupfixval = BooleanVar(master=self.frame, value=True)
        self.speedupfix = Checkbutton(self.frame, text="Apply Engine.dll speedup fix", variable=self.speedupfixval)
        self.speedupfix.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
        self.FixColors(self.speedupfix)
        row+=1

        # TODO: option to enable telemetry? checking for updates?

        # DISCORD!
        discordLink = Label(self.frame,text='discord.gg/daQVyAp2ds',width=22,height=2,font=self.linkfont, fg="Blue", cursor="hand2")
        discordLink.bind('<Button-1>', lambda *args: webbrowser.open_new('https://discord.gg/daQVyAp2ds'))
        discordLink.grid(column=1,row=100, sticky='SW', padx=pad, pady=pad)
        myTip = Hovertip(discordLink, 'Join our Discord!')

        # install button
        self.installButton = Button(self.frame,text='Install!',width=18,height=2,font=self.font, command=self.Install)
        self.installButton.grid(column=1,row=101, sticky='SW', padx=pad, pady=pad)
        Hovertip(self.installButton, 'Dew it!')

    def Install(self):
        print(self.speedupfixval.get())
        self.installButton["state"]='disabled'

        flavors = []
        v:IntVar
        for (f,v) in self.flavors.items():
            if v.get():
                flavors.append(f)

        exetype = self.exevar.get()
        speedupfix = self.speedupfixval.get()
        flavors = Install.Install(self.exe, flavors, exetype, speedupfix)
        flavors = ', '.join(flavors)
        extra = ''
        if 'Vanilla' in flavors and IsWindows():
            extra += '\nCreated DXRando.exe'
        if 'Vanilla? Madder.' in flavors and IsWindows():
            extra += '\nCreated VMDRandomizer.exe'
        messagebox.showinfo('Installation Complete!', 'Installed DXRando for: ' + flavors + extra)
        self.closeWindow()


def main():
    InstallerWindow()


def getDefaultPath():
    checks = [
        Path("C:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
        Path("D:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
        Path.home() /'snap'/'steam'/'common'/'.local'/'share'/'Steam'/'steamapps'/'common'/'Deus Ex'/'System',
        Path.home() /'.steam'/'steam'/'SteamApps'/'common'/'Deus Ex'/'System',
    ]
    p:Path
    for p in checks:
        f:Path = p / "DeusEx.exe"
        if f.exists():
            return p
    return None
