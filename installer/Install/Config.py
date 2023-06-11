from pathlib import Path
import re

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
    outtext = text
    matched = False
    for i in get_sections.finditer(text):
        matched = True
        d = i.groupdict()
        all = d['all']
        sect = d['section']
        content = d['sectiondata']
        if sect in changes:
            newcontent = _ReplaceConfigVals(content, changes[sect])
            newall = all.replace(content, newcontent)
            outtext = outtext.replace(all, newall)
            content = newcontent
            all = newall
        if sect in additions:
            newcontent = _AddConfigVals(content, additions[sect])
            newall = all.replace(content, newcontent)
            outtext = outtext.replace(all, newall)

    if not matched:
        print('WARNING: _ModifyConfig failed to match!', changes, text.encode('iso_8859_1'))
    return outtext


def _ReplaceConfigVals(section:str, changes:dict) -> str:
    if not changes:
        return section
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
        newval = changes[name]
        if value == newval:
            continue
        oldline = name+'='+value
        newline = name+'='+newval
        newline += '\r\n;' + oldline# save the old line as a comment
        newall = all.replace(oldline, newline)
        outsect = outsect.replace(all, newall)

    if not matched:
        print('WARNING: _ReplaceConfigVals failed to match!', changes, section.encode('iso_8859_1'))
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
    newline = k+'='+v
    # beginning of section doesn't have \r\n and we want to make sure this isn't commented out
    if section.startswith(newline):
        return section
    if '\r\n'+newline+'\r\n' in section:
        return section
    if section.endswith('\r\n'+newline):
        return section
    return newline + '\r\n' + section
