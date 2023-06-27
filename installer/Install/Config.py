from pathlib import Path
import re
import Install

# use regex, because configparser doesn't support multiple entries with the same key, like Paths
get_sections = re.compile(
    r'\s*(?P<all>' + r'^\['
        + r'(?P<section>[^\r\n\[\]]+)'
    + r'\]\s+'
        + r'(?P<sectiondata>[^\[\]]*)'
    + r')\s*',
    flags=re.MULTILINE | re.DOTALL
)

get_options = re.compile(
    r'^\s*(?P<all>'
        + r'(?P<name>[^=]+)\s*=\s*(?P<value>[^\s]+)'
    + r')\s*$',
    flags=re.MULTILINE
)

def ModifyConfig(data:bytes, changes:dict, additions:dict) -> bytes:
    text:str = data.decode('iso_8859_1')# keep line endings correct
    text = _ModifyConfig(text, changes, additions)
    return text.encode('iso_8859_1')

def _ModifyConfig(text:str, changes:dict, additions:dict) -> str:
    changes = changes.copy()
    additions = additions.copy()
    outtext = text
    matched = False
    for i in get_sections.finditer(text):
        matched = True
        d = i.groupdict()
        all = d['all']
        sect = d['section']
        content = d['sectiondata']
        if sect in changes:
            newcontent = _ReplaceConfigVals(content, changes.pop(sect))
            newall = all.replace(content, newcontent)
            outtext = outtext.replace(all, newall)
            content = newcontent
            all = newall
        if sect in additions:
            newcontent = _AddConfigVals(content, additions.pop(sect))
            newall = all.replace(content, newcontent)
            outtext = outtext.replace(all, newall)

    # add any changes we didn't match on
    leftovers = dict(**changes)
    leftovers.update(**additions)
    for k in leftovers.keys():
        outtext += '\r\n\r\n[' + k + ']\r\n'
        if k in changes:
            Install.debug(changes[k])
            outtext += _AddConfigVals('', changes[k])
        if k in additions:
            Install.debug(additions[k])
            outtext += _AddConfigVals('', additions[k])
    return outtext


def _ReplaceConfigVals(section:str, changes:dict) -> str:
    if not changes:
        return section
    changes = changes.copy()
    outsect = section
    matched = False

    for i in get_options.finditer(section):
        matched = True
        d = i.groupdict()
        name = d['name']
        if name not in changes:
            continue
        all = d['all']
        value = d['value']
        newval = changes.pop(name)
        if value == newval:
            continue
        oldline = name+'='+value
        newline = name+'='+newval
        newline += '\r\n;' + oldline# save the old line as a comment
        newall = all.replace(oldline, newline)
        outsect = outsect.replace(all, newall)

    if changes:
        outsect = _AddConfigVals(outsect, changes)
    return outsect


def _AddConfigVals(section:str, additions:dict) -> str:
    if not additions:
        return section
    for (k,v) in additions.items():
        if isinstance(v, list):
            for i in v:
                section = _AddConfigVal(section, k, i)
        else:
            section = _AddConfigVal(section, k, v)

    return section


def _AddConfigVal(section:str, k:str, v:str) -> str:
    addition = k+'='+v
    # check all the newlines
    for ending in ('\r\n', '\n', '\r'):
        # beginning of section doesn't have \r\n and we want to make sure this isn't commented out
        if section.startswith(addition + ending):
            return section
        if ending + addition + ending in section:
            return section
        if section.endswith(ending + addition):
            return section

    return addition + '\r\n' + section


def ReadConfig(text:str):
    sections = {}
    for i in get_sections.finditer(text):
        d = i.groupdict()
        sectname = d['section']
        content = d['sectiondata']
        sect = {}
        for i in get_options.finditer(content):
            d = i.groupdict()
            name = d['name']
            value = d['value']
            if name not in sect:
                sect[name] = [value]
            else:
                sect[name].append(value)

        sections[sectname] = sect
    return sections


def RetainConfigSections(names:set, orig:dict, changes:dict) -> dict:
    for name in names:
        if name not in orig:
            continue
        retain = {}
        for (k,v) in orig[name].items():
            retain[k] = v[0] # config parser makes everything a list, because of Paths
        changes[name] = retain
    return changes
