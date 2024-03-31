try:
    import webbrowser
    from GUI import *
    from pathlib import Path
    from Install import Install, IsWindows, IsVanillaFixer, CheckVulkan, getDefaultPath, GetVersion
    import traceback
    import re
except Exception as e:
    info('ERROR: importing', e)
    raise

class InstallerWindow(GUIBase):
    def initWindow(self):
        self.root = Tk()
        self.width = 350
        self.height = 500
        self.lastprogress = ''
        self.root.title("Deus Ex Randomizer " + GetVersion() + " Installer")

        self.dxvk_default = CheckVulkan()# this takes a second or so
        self.ogl2_default = self.dxvk_default or not IsWindows()

        scroll = ScrollableFrame(self.root, width=self.width, height=self.height, mousescroll=1)
        self.frame = scroll.frame

        filetypes = (('DeusEx.exe', 'DeusEx.exe'),)
        initdir = getDefaultPath()
        self.SetShowHiddenFiles()
        p = fd.askopenfilename(title="Find plain DeusEx.exe", filetypes=filetypes, initialdir=initdir)
        if not p:
            info('no file selected')
            sys.exit(0)

        p = Path(p)
        info(p)
        assert p.name.lower() == 'deusex.exe'
        assert p.parent.name.lower() == 'system'
        self.exe = p

        flavors = Install.DetectFlavors(self.exe)
        info(flavors)

        self.font = font.Font(size=14)
        self.linkfont = font.Font(size=12, underline=True)
        row = 0
        pad = 6

        # show the path
        pathlabel = str(p.parent.parent)
        pathlabel = re.sub(r'(/|\\)(SteamApps)(/|\\)', '\g<1>\n\g<2>\g<3>', pathlabel, count=1, flags=re.IGNORECASE)
        l = Label(self.frame, text='Install path:\n' + pathlabel, wraplength=self.width - pad*8)
        l.grid(column=1,row=row, sticky='SW', padx=pad*4, pady=pad)
        row += 1

        self.flavors = {}

        for f in flavors:
            row = self.InitFlavorSettings(f, row, pad)

        if not IsVanillaFixer():
            row = self.GlobalFixes(row, pad)

        # TODO: option to enable telemetry? checking for updates?

        # WEBSITE!
        webLink = Label(self.frame,text='Mods4Ever.com',width=22,height=2,font=self.linkfont, fg="Blue", cursor="hand2")
        webLink.bind('<Button-1>', lambda *args: webbrowser.open_new('https://mods4ever.com'))
        webLink.grid(column=1,row=100, sticky='SW', padx=pad, pady=pad)
        myTip = Hovertip(webLink, 'Check out our website and join our Discord!')

        # install button
        self.installButton = Button(self.frame,text='Install!',width=24,height=2,font=self.font, command=self.Install)
        self.installButton.grid(column=1,row=101, sticky='SW', padx=pad, pady=pad)
        Hovertip(self.installButton, 'Dew it!')

        self.root.geometry(str(self.width)+"x"+str(self.height))


    def InitFlavorSettings(self, f: str, row, pad) -> int:
        settings = {}

        if f == 'Vanilla' and IsVanillaFixer():
            settings['FixVanilla'] = self.ZeroChangesCheckbox(row, pad, pad)
            row+=1
            settings['LDDP'] = self.LDDPCheckbox(row, pad, pad)
            row+=1
            settings['exetype'] = self.ExeTypeRadios(row, pad, pad)
            row+=3
            row = self.GlobalFixes(row, pad)

        v = BooleanVar(master=self.frame, value=(not IsVanillaFixer()))
        settings['install'] = v
        c = Checkbutton(self.frame, text="Install DXRando for "+f, variable=v)
        c.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
        self.FixColors(c)
        row+=1

        # mirrored maps
        if f in ['Vanilla', '####Vanilla? Madder.']: # TODO: VMD is commented out, needs map files and UnrealScript work
            v = BooleanVar(master=self.frame, value=(not IsVanillaFixer()))
            settings['mirrors'] = v
            c = Checkbutton(self.frame, text="Download mirrored maps for "+f, variable=v)
            Hovertip(c, "Time to get lost again. (This will check if you already have them.)\nRequires DXRando.")
            c.grid(column=1,row=row, sticky='SW', padx=pad*10, pady=pad)
            self.FixColors(c)
            row+=1

        # Vanilla stuff
        if f == 'Vanilla':
            if not IsVanillaFixer():
                settings['exetype'] = self.ExeTypeRadios(row, pad*10, pad)
                row+=3

            v = BooleanVar(master=self.frame, value=IsVanillaFixer())
            settings['ZeroRando'] = v
            c = Checkbutton(self.frame, text="Default to Zero Rando mode for "+f, variable=v)
            Hovertip(c, "This retains the vanilla menu experience for your first launch.\nAnd also sets Zero Rando mode as your default game mode for a new game.")
            c.grid(column=1,row=row, sticky='SW', padx=pad*10, pady=pad)
            self.FixColors(c)
            row+=1

            # separate DXRando.exe is difficulty for Linux Steam users, but if you're using VanillaFixer then you probably don't want to overwrite vanilla
            v = BooleanVar(master=self.frame, value=(IsWindows() or IsVanillaFixer()))
            settings['DXRando.exe'] = v
            c = Checkbutton(self.frame, text="Create separate DXRando.exe for "+f, variable=v)
            Hovertip(c, "Overwriting the original DeusEx.exe makes it easier for Linux Steam players.\nOnly applicable if installing DXRando.")
            c.grid(column=1,row=row, sticky='SW', padx=pad*10, pady=pad)
            self.FixColors(c)
            row+=1

            if not IsVanillaFixer():
                settings['FixVanilla'] = self.ZeroChangesCheckbox(row, pad, pad)
                row+=1
                settings['LDDP'] = self.LDDPCheckbox(row, pad, pad)
                row+=1
        # End Vanilla stuff

        self.flavors[f] = settings
        return row


    def ExeTypeRadios(self, row, padx, pad):
        exe = StringVar(master=self.frame, value='Kentie')

        l = Label(self.frame, text="Which EXE to use for vanilla:")
        l.grid(column=1,row=row, sticky='SW', padx=padx, pady=pad)
        row += 1

        r = Radiobutton(self.frame, text="Kentie's Launcher", variable=exe, value='Kentie')
        r.grid(column=1,row=row, sticky='SW', padx=padx+pad*6, pady=pad)
        self.FixColors(r)
        Hovertip(r, "Kentie's Launcher stores configs and saves in your Documents folder.")
        row += 1

        r = Radiobutton(self.frame, text="Hanfling's Launch", variable=exe, value='Launch')
        r.grid(column=1,row=row, sticky='SW', padx=padx+pad*6, pady=pad)
        self.FixColors(r)
        Hovertip(r, "Hanfling's Launch stored configs and saves in the game directory.\nIf your game is in Program Files, then the game might require admin permissions to play.")
        row += 1
        return exe

    def ZeroChangesCheckbox(self, row, padx, pady):
        # "Zero Changes" mode fixes
        v = BooleanVar(master=self.frame, value=True)
        c = Checkbutton(self.frame, text="  Apply compatibility fixes for DeusEx.exe\n(Zero Changes mode)", variable=v)
        Hovertip(c, "Apply all the fixes for DeusEx.exe, so you can play without Randomizer's changes.\nThis is like a \"Zero Changes\" mode as opposed to DXRando's \"Zero Rando\" mode.\nOnly has an effect when using a separate DXRando.exe for the Randomized modes\nor when not installing DXRando.")
        c.grid(column=1,row=row, sticky='SW', padx=padx, pady=pady)
        self.FixColors(c)
        return v

    def LDDPCheckbox(self, row, padx, pady):
        v = BooleanVar(master=self.frame, value=False)
        c = Checkbutton(self.frame, text="Install Lay D Denton Project for Vanilla", variable=v)
        Hovertip(c, "What if Zelda was a girl?")
        c.grid(column=1,row=row, sticky='SW', padx=padx, pady=pady)
        self.FixColors(c)
        return v

    def GlobalFixes(self, row, pad):
        # engine.dll speedup fix, this is global
        self.speedupfixval = BooleanVar(master=self.frame, value=True)
        self.speedupfix = Checkbutton(self.frame, text="Apply Engine.dll speedup fix to support higher frame rates.", variable=self.speedupfixval)
        self.speedupfix.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
        Hovertip(self.speedupfix, "Fixes issues with high frame rates.")
        self.FixColors(self.speedupfix)
        row+=1

        # DXVK is also global
        if IsWindows():
            self.dxvkval = BooleanVar(master=self.frame, value=self.dxvk_default)
            self.dxvk = Checkbutton(self.frame, text="Apply DXVK fix for modern computers", variable=self.dxvkval)
            self.dxvk.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
            Hovertip(self.dxvk, "DXVK can fix performance issues on modern systems by using Vulkan.")
            self.FixColors(self.dxvk)
            row+=1
        else:
            self.dxvkval = DummyCheckbox()

        self.ogl2val = BooleanVar(master=self.frame, value=self.ogl2_default)
        self.ogl2 = Checkbutton(self.frame, text="Updated OpenGL 2.0 Renderer", variable=self.ogl2val)
        Hovertip(self.ogl2, "Updated OpenGL Renderer for modern systems. An alternative to using D3D10 or D3D9.")
        self.ogl2.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
        self.FixColors(self.ogl2)
        row+=1
        return row


    def Install(self):
        try:
            self._Install()
        except Exception as e:
            self.root.title('DXRando Installer Error!')
            self.root.update()
            info('\n\nError!')
            info(str(e) + '\n\n' + traceback.format_exc())
            messagebox.showinfo('Error!', str(e) + '\n\n' + traceback.format_exc(5))
            exit(1)

    def _Install(self):
        self.root.title('DXRando Installing...')
        self.root.update()
        info(self.speedupfixval.get())
        self.installButton["state"]='disabled'

        flavors = {}
        for (flavorName,flavor) in self.flavors.items():
            flavors[flavorName] = {
                'downloadcallback': self.DownloadProgress,
            }
            for (k,v) in flavor.items():
                flavors[flavorName][k] = v.get()

        speedupfix = self.speedupfixval.get()
        dxvk = self.dxvkval.get()
        ogl2 = self.ogl2val.get()
        flavors = Install.Install(self.exe, flavors, speedupfix, dxvk, ogl2)
        flavorstext = ', '.join(flavors.keys())
        extra = ''
        if 'Vanilla' in flavors and IsWindows():
            extra += '\nCreated DXRando.exe'
        if 'Vanilla? Madder.' in flavors and IsWindows():
            extra += '\nCreated VMDRandomizer.exe'
        self.root.title('DXRando Installation Complete!')
        self.root.update()
        messagebox.showinfo('DXRando Installation Complete!', 'Installed DXRando for: ' + flavorstext + extra)
        self.closeWindow()


    def DownloadProgress(self, blocks:int, blocksize:int, totalsize:int, status='Downloading'):
        percent = blocks / (totalsize/blocksize) * 100
        percent = '{:.0f}%'.format(percent)
        newtitle = status + ' ' + percent
        if self.lastprogress == newtitle:
            self.root.update()
            return
        self.root.title(newtitle)
        self.lastprogress = newtitle
        self.root.update()


def main():
    InstallerWindow()
