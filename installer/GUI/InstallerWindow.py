try:
    import webbrowser
    from GUI import *
    from pathlib import Path
    from Install import Install, IsWindows, CheckVulkan, getDefaultPath
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
        self.root.title("Deus Ex Randomizer Installer")

        dxvk_default = CheckVulkan()# this takes a second or so
        ogl2_default = dxvk_default or not IsWindows()

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
        l.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
        row += 1

        self.flavors = {}

        for f in flavors:
            row = self.InitFlavorSettings(f, row, pad)

        # engine.dll speedup fix, this is global
        self.speedupfixval = BooleanVar(master=self.frame, value=True)
        self.speedupfix = Checkbutton(self.frame, text="Apply Engine.dll speedup fix", variable=self.speedupfixval)
        self.speedupfix.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
        Hovertip(self.speedupfix, "Fixes issues with high frame rates.")
        self.FixColors(self.speedupfix)
        row+=1

        # DXVK is also global
        if IsWindows():
            self.dxvkval = BooleanVar(master=self.frame, value=dxvk_default)
            self.dxvk = Checkbutton(self.frame, text="Apply DXVK fix for modern computers", variable=self.dxvkval)
            self.dxvk.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
            Hovertip(self.dxvk, "DXVK can fix performance issues on modern systems by using Vulkan.")
            self.FixColors(self.dxvk)
            row+=1
        else:
            self.dxvkval = DummyCheckbox()

        self.ogl2val = BooleanVar(master=self.frame, value=ogl2_default)
        self.ogl2 = Checkbutton(self.frame, text="Updated OpenGL 2.0 Renderer", variable=self.ogl2val)
        Hovertip(self.ogl2, "Updated OpenGL Renderer for modern systems. An alternative to using D3D10 or D3D9.")
        self.ogl2.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
        self.FixColors(self.ogl2)
        row+=1

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
        v = BooleanVar(master=self.frame, value=True)
        c = Checkbutton(self.frame, text="Install DXRando for "+f, variable=v)
        c.grid(column=1,row=row, sticky='SW', padx=pad, pady=pad)
        self.FixColors(c)
        row+=1

        exe = StringVar(master=self.frame, value='Kentie')

        settings = { 'install': v, 'exe': exe }

        # mirrored maps
        if f in ['Vanilla', '####Vanilla? Madder.']: # TODO: VMD is commented out, needs map files and UnrealScript work
            v = BooleanVar(master=self.frame, value=True)
            settings['mirrors'] = v
            c = Checkbutton(self.frame, text="Download mirrored maps for "+f, variable=v)
            Hovertip(c, "Time to get lost again. (This will check if you already have them.)")
            c.grid(column=1,row=row, sticky='SW', padx=pad*4, pady=pad)
            self.FixColors(c)
            row+=1

        # LDDP
        if f == 'Vanilla':
            v = BooleanVar(master=self.frame, value=False)
            settings['LDDP'] = v
            c = Checkbutton(self.frame, text="Install Lay D Denton Project for "+f, variable=v)
            Hovertip(c, "What if Zelda was a girl?")
            c.grid(column=1,row=row, sticky='SW', padx=pad*4, pady=pad)
            self.FixColors(c)
            row+=1

        if f == 'Vanilla':
            l = Label(self.frame, text="Which EXE to use for vanilla:")
            l.grid(column=1,row=row, sticky='SW', padx=pad*4, pady=pad)
            row += 1

            r = Radiobutton(self.frame, text="Kentie's Launcher", variable=exe, value='Kentie')
            r.grid(column=1,row=row, sticky='SW', padx=pad*8, pady=pad)
            self.FixColors(r)
            Hovertip(r, "Kentie's Launcher stores configs and saves in your Documents folder.")
            row += 1

            r = Radiobutton(self.frame, text="Hanfling's Launch", variable=exe, value='Launch')
            r.grid(column=1,row=row, sticky='SW', padx=pad*8, pady=pad)
            self.FixColors(r)
            Hovertip(r, "Hanfling's Launch stored configs and saves in the game directory.\nIf your game is in Program Files, then the game might require admin permissions to play.")
            row += 1

        # "Zero Changes" mode fixes
        if f == 'Vanilla' and IsWindows():
            v = BooleanVar(master=self.frame, value=True)
            settings['FixVanilla'] = v
            c = Checkbutton(self.frame, text="Also apply fixes for vanilla", variable=v)
            Hovertip(c, "Also apply all the fixes for DeusEx.exe, so you can play without Randomizer's changes.\nThis is like a \"Zero Changes\" mode as opposed to DXRando's \"Zero Rando\" mode.")
            c.grid(column=1,row=row, sticky='SW', padx=pad*4, pady=pad)
            self.FixColors(c)
            row+=1

        self.flavors[f] = settings
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
        v:IntVar
        dummy = DummyCheckbox()
        for (f,v) in self.flavors.items():
            if v['install'].get():
                flavors[f] = {
                    'exetype': v.get('exe', dummy).get(),
                    'mirrors': v.get('mirrors', dummy).get(),
                    'LDDP': v.get('LDDP', dummy).get(),
                    'FixVanilla': v.get('FixVanilla', dummy).get(),
                    'downloadcallback': self.DownloadProgress,
                }

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
