# handles ifdef so we can exclude/include code depending on compiler flags, like if we want to build on top of another mod
from compiler.base import *

def bIfdef(ifdef, definitions):
    if ifdef == '#else':
        return True
    var = re.search( r'(#\w+) (.*)$', ifdef )
    if var.group(1) == '#ifdef' or var.group(1) == '#elseif':
        return var.group(2) in definitions
    elif var.group(1) == '#ifndef' or var.group(1) == '#elseifn':
        return var.group(2) not in definitions
    
    raise RuntimeError("Unknown preprocessor "+ifdef)


def preprocess(content, ifdef, definitions):
    # the ?=(#\w+) is for a lookahead
    # because we want to read up until the next preprocessor directive
    # but we don't want to swallow it yet
    r = re.compile(r'(#[^\n]+)\n(.*?)\n(?=(#\w+))', flags=re.DOTALL)
    
    # pad the new lines so the errors coming from the compiler match the lines in the original files
    num_lines_before = 0
    num_lines_after = 1 # 1 for the #endif
    replacement = None
    total_lines = ifdef.count('\n')

    if total_lines > 200:
        # this is a strong warning to refactor the code
        raise Exception("ifdef is "+str(total_lines)+" lines long!")
    
    if ifdef.count('#endif') != 1:
        raise Exception("ifdef contains "+str(ifdef.count('#endif'))+" #endif's")
    
    if ifdef.count('#ifdef') > 1:
        raise Exception("ifdef contains too many #ifdefs: "+str(ifdef.count('#ifdef')))

    for i in r.finditer(ifdef):
        if replacement is not None:
            num_lines_after += i.group(1).count('\n')+1
            num_lines_after += i.group(2).count('\n')+1

        elif bIfdef(i.group(1), definitions):
            num_lines_before += i.group(1).count('\n')+1
            replacement = i.group(2)

        elif replacement is None:
            num_lines_before += i.group(1).count('\n')+1
            num_lines_before += i.group(2).count('\n')+1

    if replacement is None:
        replacement = ""
    
    if replacement is not None:
        replacement = ('\n'*num_lines_before) + replacement + ('\n'*num_lines_after)
        return content.replace( ifdef, replacement )
    return content


def replace_vars(content, definitions):
    r = re.compile(r'#var (\w+) ')
    content_out = content
    for i in r.finditer(content):
        if i.group(1) not in definitions:
            raise RuntimeError("Unknown preprocessor variable "+i.group(0))
        content_out = content_out.replace( i.group(0), definitions[i.group(1)] )
    return content_out


def preprocessor(content, definitions):
    # TODO: doesn't yet support nested preprocessor definitions
    content = replace_vars(content, definitions)
    content_out = content
    r = re.compile(r'((#ifdef )|(#ifndef))(.*?)(#endif)', flags=re.DOTALL)
    for i in r.finditer(content):
        content_out = preprocess(content_out, i.group(0), definitions)
    return content_out
