from Install import CopyTo, WriteBytes, info, debug
try:
    from collections import OrderedDict
    from pathlib import Path
    import re
    import datetime
except Exception as e:
    info('ERROR: importing', e)
    raise

# use regex, because configparser doesn't support multiple entries with the same key, like Paths
get_section = re.compile(r'^\[(.+)\]$')
get_keyvalue = re.compile(r'^(.+)=(.+)$')

class Config:
    def __init__(self, data: bytes):
        if not isinstance(data, bytes):
            raise RuntimeError('Config __init__ data needs to be bytes', type(data), data)
        text = data.decode('iso_8859_1')# keep line endings correct
        self.sections: OrderedDict = _ReadConfig(text)


    def GetBinary(self) -> bytes:
        text = ''
        for (sect, lines) in self.sections.items():
            text += '[' + sect + ']\r\n'
            for line in lines:
                if line.get('text'):
                    text += line.get('text') + '\r\n'
                else:
                    text += line.get('key') + '=' + line.get('value') + '\r\n'
            text += '\r\n'
        return text.encode('iso_8859_1')


    def WriteFile(self, dest:Path):
        bin = self.GetBinary()
        if dest.exists():
            oldBin = dest.read_bytes()
            if oldBin == bin:
                return
            self.BackupFile(dest)
        WriteBytes(dest, bin)

    @staticmethod
    def BackupFile(src:Path):
        bakDate = datetime.datetime.now().strftime("%Y-%m-%d")
        bakIni = src.parent / (src.stem + ' ' + bakDate + src.suffix)
        if src.exists() and not bakIni.exists():
            CopyTo(src, bakIni)


    def ModifyConfig(self, changes:dict, additions:dict):
        # Unreal Engine 1 is case insensitive...
        lowersections = {}
        for sect in self.sections:
            lowersections[sect.lower()] = sect

        for sect in sorted(changes):
            oursect = lowersections.get(sect.lower())
            if not oursect:
                self.sections[sect] = []
                oursect = sect
                lowersections[sect.lower()] = sect
            self.ModifySection(self.sections[oursect], changes.get(sect))

        for sect in sorted(additions):
            oursect = lowersections.get(sect.lower())
            if not oursect:
                self.sections[sect] = []
                oursect = sect
                lowersections[sect.lower()] = sect
            self.AddToSection(self.sections[oursect], additions.get(sect))


    def ModifySection(self, lines: list, changes:dict):
        if not changes:
            return
        lowerchanges = {}
        for change in changes.keys():
            lowerchanges[change.lower()] = change

        tempchanges = changes.copy()
        line: dict
        i=0
        while i < len(lines): # range(len(lines)) doesn't update as you add to the list
            line = lines[i]
            i+=1
            key:str = line.get('key', '')
            changename = lowerchanges.get(key.lower())
            if changename:
                if changes[changename] == line['value']:
                    continue
                lines.insert(i, { 'text': ';' + line['key'] + '=' + line['value'] })
                i+=1
                assert isinstance(changes[changename], str)
                line['key'] = changename # fix casing?
                line['value'] = changes[changename]
                tempchanges.pop(changename)

        # add the things we wanted to change but didn't exist
        for (change, val) in tempchanges.items():
            lines.append({'key': change, 'value': val})


    def AddToSection(self, lines: list, additions:dict):
        if not additions:
            return
        for (k,val) in additions.items():
            if isinstance(val, list):
                for v in reversed(val):
                    lines.insert(0, { 'key': k, 'value': v })
            else:
                lines.insert(0, { 'key': k, 'value': val })


    def RetainConfigSections(self, names:set, changes:dict) -> dict:
        for name in names:
            if name not in self.sections:
                continue
            retain = {}
            for line in self.sections[name]:
                key = line.get('key')
                if key:
                    retain[key] = line.get('value')
            changes[name] = retain
        return changes


    def get(self, section, key):
        sect = self.sections.get(section, [])
        for line in sect:
            if line.get('key')==key:
                return line.get('value')
        return None


def _ReadConfig(text:str) -> OrderedDict:
    sections = OrderedDict()
    sections[''] = []
    currsection = ''
    for line in text.splitlines():
        if not line:
            continue

        m = get_section.match(line)
        if m:
            currsection = m.group(1)
            if currsection not in sections:
                sections[currsection] = []
            continue

        m = get_keyvalue.match(line)
        if m:
            key = m.group(1)
            value = m.group(2)
            linedata = { 'key': key, 'value': value }
        else:
            linedata = { 'text': line }

        sections[currsection].append(linedata)

    # remove empty top of file before a section is found, but only if it's actually empty, we want to keep comments and stuff
    if not sections['']:
        sections.pop('')
    return sections


def BackupSplits(splitsPath:Path):
    splits = Config(splitsPath.read_bytes())
    found_splits = CheckSplits(splits, ['PB', 'Golds', 'Avgs'])
    if found_splits:
        Config.BackupFile(splitsPath)

def CheckSplits(splits:Config, keys) -> bool:
    for sect in splits.sections.keys():
        for i in range(0, 16):
            for key in keys:
                val = splits.get(sect, key + '['+str(i)+']')
                if val and val != '0':
                    return True
    return False
