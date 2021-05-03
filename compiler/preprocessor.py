# handles ifdef so we can exclude/include code depending on compiler flags, like if we want to build on top of another mod
from compiler.base import *

def bIfdef(ifdef, definitions):
    if ifdef == '#else':
        return True
    var = re.search( r'(#\w+) (.*)$', ifdef )
    return var.group(2) in definitions


def preprocess(content, ifdef, definitions):
    # the ?=(#\w+) is for a lookahead
    # because we want to read up until the next preprocessor directive
    # but we don't want to swallow it yet
    r = re.compile(r'(#[^\n]+)\n(.*?)\n(?=(#\w+))', flags=re.DOTALL)
    
    # pad the new lines so the errors coming from the compiler match the lines in the original files
    num_lines_before = 0
    num_lines_after = 1 # 1 for the #endif
    replacement = None

    for i in r.finditer(ifdef):
        if bIfdef(i.group(1), definitions):
            num_lines_before += i.group(1).count('\n')+1
            replacement = i.group(2)
        elif replacement is None:
            num_lines_before += i.group(1).count('\n')+1
            num_lines_before += i.group(2).count('\n')+1
        else:
            num_lines_after += i.group(1).count('\n')+1
            num_lines_after += i.group(2).count('\n')+1
    
    if replacement:
        replacement = ('\n'*num_lines_before) + replacement + ('\n'*num_lines_after)
        return content.replace( ifdef, replacement )
    return content


def preprocessor(content, definitions):
    # TODO: doesn't yet support nested preprocessor definitions
    content_out = content
    r = re.compile(r'(#ifdef )(.*?)(#endif)', flags=re.DOTALL)
    for i in r.finditer(content):
        content_out = preprocess(content_out, i.group(0), definitions)
    return content_out
