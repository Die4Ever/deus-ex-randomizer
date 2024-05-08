try:
    import webbrowser
    from GUI import *
    from pathlib import Path
    from Install import Install, IsWindows, IsVanillaFixer, IsZeroRando, CheckVulkan, getDefaultPath, GetVersion
    import traceback
    import re
    from threading import Thread
    from collections import OrderedDict
except Exception as e:
    info('ERROR: importing', e)
    raise

class InstallerWindow(GUIBase):
    def CheckVulkan(self):
        self.dxvk_default = CheckVulkan()
        self.ogl2_default = self.dxvk_default or not IsWindows()


    def setgrid(self, control, advanced:bool, **gridargs):
        self.controls[control] = {'advanced': advanced, 'gridargs': gridargs}
        if self.advanced or not advanced:
            control.grid(**gridargs)


    def ShowAdvanced(self):
        self.root.geometry(str(self.width)+"x499")
        self.advancedButton.grid_forget()
        for (control, val) in self.controls.items():
            control.grid(**val['gridargs'])
        self.root.update()
        self.height = max(500, self.height)
        self.root.geometry(str(self.width)+"x"+str(self.height))
        self.scroll.ReConf()


    def initWindow(self):
        self.root = Tk()
        self.lastprogress = ''
        self.advanced = False
        self.width = 350
        self.height = 500

        self.controls = {}

        if IsVanillaFixer():
            self.root.title("DXR Vanilla Fixer " + GetVersion())
        elif IsZeroRando():
            self.root.title("DXR Zero Rando " + GetVersion() + " Installer")
        else:
            self.root.title("DXRando " + GetVersion() + " Installer")

        vulkanthread = Thread(target=self.CheckVulkan) # this takes a second or so
        vulkanthread.start()

        self.scroll = ScrollableFrame(self.root, width=self.width, height=self.height, mousescroll=1)
        self.frame = self.scroll.frame

        filetypes = (('DeusEx.exe', 'DeusEx.exe'),)
        initdir = getDefaultPath()
        self.SetShowHiddenFiles()
        p = fd.askopenfilename(title="Find plain DeusEx.exe", filetypes=filetypes, initialdir=initdir)
        if not p:
            info('no file selected')
            sys.exit(1)

        p = Path(p)
        info(p)
        assert p.name.lower() == 'deusex.exe', "You need to select DeusEx.exe"
        assert p.parent.name.lower() == 'system', "DeusEx.exe is supposed to be in the game's System folder"
        self.exe = p

        flavors = Install.DetectFlavors(self.exe)
        info(flavors)
        vulkanthread.join(30)

        self.font = font.Font(size=14)
        self.linkfont = font.Font(size=12, underline=True)
        self.row = 0
        pad = 6

        # show the path
        pathlabel = str(p.parent.parent)
        pathlabel = re.sub(r'(/|\\)(SteamApps)(/|\\)', '\g<1>\n\g<2>\g<3>', pathlabel, count=1, flags=re.IGNORECASE)
        l = Label(self.frame, text='Install path:\n' + pathlabel, wraplength=self.width - pad*16, justify='center')
        l.grid(column=1,row=self.row, sticky='SW', padx=pad*8, pady=pad)
        self.row += 1

        self.flavors = {}
        self.globalsettings = {}

        for f in flavors:
            self.InitFlavorSettings(f, pad)

        if not IsVanillaFixer():
            self.GlobalFixes(pad)

        # TODO: option to enable telemetry? checking for updates?

        # WEBSITE!
        webLink = Label(self.frame,text='Mods4Ever.com',width=22,height=2,font=self.linkfont, fg="Blue", cursor="hand2")
        webLink.bind('<Button-1>', lambda *args: webbrowser.open_new('https://mods4ever.com'))
        webLink.grid(column=1,row=100, sticky='SW', padx=pad, pady=pad)
        myTip = Hovertip(webLink, 'Check out our website and join our Discord!')

        # install button
        self.installButton = Button(self.frame,text='Install!',width=24,height=2,font=self.font, command=self.Install)
        self.installButton.grid(column=1,row=101, sticky='SW', padx=pad*4, pady=pad)
        Hovertip(self.installButton, 'Dew it!')

        # advanced button
        self.advancedButton = Button(self.frame,text='Show Advanced Options',width=20,height=1,font=self.font, command=self.ShowAdvanced)
        self.advancedButton.grid(column=1,row=102, sticky='SW', padx=pad*8, pady=pad)
        Hovertip(self.advancedButton, 'For the brave and technical')

        self.root.update()
        end_y = self.advancedButton.winfo_y() + self.advancedButton.winfo_height()
        self.height = min(self.height, end_y + pad*2)
        self.root.geometry(str(self.width)+"x"+str(self.height))
        self.scroll.ReConf()


    def InitFlavorSettings(self, f: str, pad) -> int:
        settings = {}

        if f == 'Vanilla' and IsVanillaFixer():
            settings['FixVanilla'] = self.ZeroChangesCheckbox(pad, pad)
            settings['LDDP'] = self.LDDPCheckbox(pad, pad)
            settings['exetype'] = self.ExeTypeRadios(pad, pad)
            self.GlobalFixes(pad)

        v = BooleanVar(master=self.frame, value=(not IsVanillaFixer()))
        settings['install'] = v
        c = Checkbutton(self.frame, text="Install DXRando for "+f, variable=v)
        self.setgrid(c, advanced=IsVanillaFixer(), column=1,row=self.row, sticky='SW', padx=pad, pady=pad)
        self.FixColors(c)
        self.row+=1

        # mirrored maps
        if f in ['Vanilla', '####Vanilla? Madder.']: # TODO: VMD is commented out, needs map files and UnrealScript work
            v = BooleanVar(master=self.frame, value=(not IsVanillaFixer()))
            settings['mirrors'] = v
            c = Checkbutton(self.frame, text="Download mirrored maps for "+f, variable=v)
            Hovertip(c, "Time to get lost again. (This will check if you already have them.)\nRequires DXRando.")
            self.setgrid(c, True, column=1,row=self.row, sticky='SW', padx=pad*10, pady=pad)
            self.FixColors(c)
            self.row+=1

        # Vanilla stuff
        if f == 'Vanilla':
            if not IsVanillaFixer():
                settings['exetype'] = self.ExeTypeRadios(pad*10, pad)

            v = BooleanVar(master=self.frame, value=IsVanillaFixer() or IsZeroRando())
            settings['ZeroRando'] = v
            c = Checkbutton(self.frame, text="Default to Zero Rando mode for "+f, variable=v)
            Hovertip(c, "This retains the vanilla menu experience for your first launch.\nAnd also sets Zero Rando mode as your default game mode for a new game.\nYou can change this once you get into the game with the Rando menu.")
            self.setgrid(c, advanced=IsVanillaFixer(), column=1,row=self.row, sticky='SW', padx=pad*10, pady=pad)
            self.FixColors(c)
            self.row+=1

            # separate DXRando.exe is difficult for Linux Steam users, but if you're using VanillaFixer then you probably don't want to overwrite vanilla
            v = BooleanVar(master=self.frame, value=(IsWindows() or IsVanillaFixer()))
            settings['DXRando.exe'] = v
            c = Checkbutton(self.frame, text="Create separate DXRando.exe for "+f, variable=v)
            Hovertip(c, "Overwriting the original DeusEx.exe makes it easier for Linux Steam players.\nOnly applicable if installing DXRando.")
            self.setgrid(c, advanced=IsVanillaFixer(), column=1,row=self.row, sticky='SW', padx=pad*10, pady=pad)
            self.FixColors(c)
            self.row+=1

            if not IsVanillaFixer():
                settings['LDDP'] = self.LDDPCheckbox(pad*10, pad)
                settings['FixVanilla'] = self.ZeroChangesCheckbox(pad, pad)
        # End Vanilla stuff

        self.flavors[f] = settings


    def Radios(self, label, default, padx, pad, advanced:bool, options:OrderedDict):
        var = StringVar(master=self.frame, value=default)

        l = Label(self.frame, text=label)
        self.setgrid(l, advanced, column=1,row=self.row, sticky='SW', padx=padx, pady=pad)
        self.row += 1

        for (k,v) in options.items():
            r = Radiobutton(self.frame, text=v['text'], variable=var, value=k)
            self.setgrid(r, advanced, column=1,row=self.row, sticky='SW', padx=padx+pad*6, pady=pad)
            self.FixColors(r)
            Hovertip(r, v['hover'])
            self.row += 1
        return var


    def ExeTypeRadios(self, padx, pad):
        return self.Radios('Which EXE to use for vanilla:', 'Kentie', padx, pad, advanced=True,
            options=OrderedDict(
                Kentie={ 'text': "Kentie's Launcher", 'hover': "Kentie's Launcher stores configs and saves in your Documents folder." },
                Launch={ 'text': "Hanfling's Launch", 'hover': "Hanfling's Launch stored configs and saves in the game directory.\nIf your game is in Program Files, then the game might require admin permissions to play." },
        ))

    def ZeroChangesCheckbox(self, padx, pady):
        # "Zero Changes" mode fixes
        v = BooleanVar(master=self.frame, value=True)
        c = Checkbutton(self.frame, text="DXRVanillaFixer\n  Apply compatibility fixes for DeusEx.exe", variable=v)
        Hovertip(c, "Apply all the fixes for DeusEx.exe, so you can play without Randomizer's changes.\nThis is like a \"Zero Changes\" mode as opposed to DXRando's \"Zero Rando\" mode.\nOnly has an effect when using a separate DXRando.exe for the Randomized modes\nor when not installing DXRando.")
        c.grid(column=1,row=self.row, sticky='SW', padx=padx, pady=pady)
        self.row += 1
        self.FixColors(c)
        return v

    def LDDPCheckbox(self, padx, pady):
        v = BooleanVar(master=self.frame, value=False)
        c = Checkbutton(self.frame, text="Install Lay D Denton Project for Vanilla", variable=v)
        Hovertip(c, "What if Zelda was a girl?")
        c.grid(column=1,row=self.row, sticky='SW', padx=padx, pady=pady)
        self.row += 1
        self.FixColors(c)
        return v

    def GlobalFixes(self, pad):
        # engine.dll speedup fix, this is global
        self.globalsettings['speedupfix'] = BooleanVar(master=self.frame, value=True)
        self.speedupfix = Checkbutton(self.frame, text="Apply Engine.dll speedup fix\nto support higher frame rates.", variable=self.globalsettings['speedupfix'])
        self.setgrid(self.speedupfix, True, column=1,row=self.row, sticky='SW', padx=pad, pady=pad)
        Hovertip(self.speedupfix, "Fixes issues with high frame rates.")
        self.FixColors(self.speedupfix)
        self.row+=1

        # DXVK is also global
        if IsWindows():
            self.globalsettings['dxvk'] = BooleanVar(master=self.frame, value=self.dxvk_default)
            self.dxvk = Checkbutton(self.frame, text="Apply DXVK fix for modern computers", variable=self.globalsettings['dxvk'])
            self.setgrid(self.dxvk, True, column=1,row=self.row, sticky='SW', padx=pad, pady=pad)
            Hovertip(self.dxvk, "DXVK can fix performance issues on modern systems by using Vulkan.")
            self.FixColors(self.dxvk)
            self.row+=1
        else:
            self.globalsettings['dxvk'] = DummyCheckbox()

        self.globalsettings['deus_nsf_d3d10_lighting'] = BooleanVar(master=self.frame, value=False)
        self.deus_nsf_d3d10_lighting = Checkbutton(self.frame, text="Deus_nsf D3D10 vivid lighting", variable=self.globalsettings['deus_nsf_d3d10_lighting'])
        Hovertip(self.deus_nsf_d3d10_lighting, "Tweaked D3D10 shaders for more vivid lighting.\nMay require more powerful hardware.")
        self.setgrid(self.deus_nsf_d3d10_lighting, True, column=1,row=self.row, sticky='SW', padx=pad, pady=pad)
        self.FixColors(self.deus_nsf_d3d10_lighting)
        self.row+=1

        self.globalsettings['d3d10_textures'] = self.Radios('Which EXE to use for vanilla:', 'Smooth', pad, pad, advanced=True,
            options=OrderedDict(
                Retro={ 'text': "Deus_nsf D3D10 retro texture filtering", 'hover': "Tweaked D3D10 shaders for retro texture filtering.\nMay require more powerful hardware." },
                Balanced={ 'text': "Deus_nsf D3D10 semi-retro texture filtering", 'hover': "Tweaked D3D10 shaders for semi-retro texture filtering.\nMay require more powerful hardware." },
                Smooth={ 'text': "D3D10 normal smooth texture filtering", 'hover': "Typical D3D10 shaders for texture filtering." },
        ))

        self.globalsettings['ogl2'] = BooleanVar(master=self.frame, value=self.ogl2_default)
        self.ogl2 = Checkbutton(self.frame, text="Updated OpenGL 2.0 Renderer", variable=self.globalsettings['ogl2'])
        Hovertip(self.ogl2, "Updated OpenGL Renderer for modern systems. An alternative to using D3D10 or D3D9.")
        self.setgrid(self.ogl2, True, column=1,row=self.row, sticky='SW', padx=pad, pady=pad)
        self.FixColors(self.ogl2)
        self.row+=1


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
        self.installButton["state"]='disabled'
        self.installButton['text']='Installing...'
        self.root.update()

        flavors = {}
        for (flavorName,flavor) in self.flavors.items():
            flavors[flavorName] = {
                'downloadcallback': self.DownloadProgress,
            }
            for (k,v) in flavor.items():
                flavors[flavorName][k] = v.get()

        globalsettings = {}
        for (key, val) in self.globalsettings.items():
            globalsettings[key] = val.get()

        flavors = Install.Install(self.exe, flavors, globalsettings)
        installedflavorstext = ''
        for (k,v) in flavors.items():
            if v.get('install'):
                installedflavorstext += k + ', '
        if installedflavorstext.endswith(', '):
            installedflavorstext = 'Installed DXRando for: ' + installedflavorstext[0:-2]

        if flavors.get('Vanilla', {}).get('FixVanilla'):
            installedflavorstext = 'Fixed vanilla. ' + installedflavorstext

        if not installedflavorstext: # done with something idk what
            installedflavorstext = 'Done.'

        extra = ''
        if flavors.get('Vanilla', {}).get('install') and IsWindows():
            extra += '\nCreated DXRando.exe'
        if flavors.get('Vanilla? Madder.', {}).get('install') and IsWindows():
            extra += '\nCreated VMDRandomizer.exe'
        self.root.title('DXRando Installation Complete!')
        self.root.update()
        messagebox.showinfo('Installation Complete!', installedflavorstext + extra)
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
        self.installButton['text']=newtitle
        self.root.update()


def main():
    InstallerWindow()
