# handles ifdef so we can exclude/include code depending on compiler flags, like if we want to build on top of another mod
from compiler.base import *

def bIfdef(ifdef, cond, definitions):
    if ifdef == '#else':
        return True
    #var = re.search( r'(#\w+) (.*)$', ifdef )
    if ifdef == '#ifdef' or ifdef == '#elseif':
        return cond in definitions
    elif ifdef == '#ifndef' or ifdef == '#elseifn':
        return cond not in definitions
    
    raise RuntimeError("Unknown preprocessor "+ifdef+' '+cond)


def preprocess(content, ifdef, definitions):
    # the ?=(#\w+) is for a lookahead
    # because we want to read up until the next preprocessor directive
    # but we don't want to swallow it yet
    r = re.compile(r'(?P<ifdef>#[^\s]+)( (?P<cond>[^\s]+))?\n(?P<code>.*?)\n(?=(?P<next>#\w+))', flags=re.DOTALL)
    
    # pad the new lines so the errors coming from the compiler match the lines in the original files
    num_lines_before = 0
    num_lines_after = 1 # 1 for the #endif
    replacement = None
    num_lines = 0
    counts = {'#ifdef':0, '#ifndef':0, '#else':0, '#elseif':0, '#elseifn':0}

    for i in r.finditer(ifdef):
        counts[i.group('ifdef')] += 1

        if replacement is not None:
            num_lines_after += 1
            num_lines_after += i.group('code').count('\n')+1

        elif bIfdef(i.group('ifdef'), i.group('cond'), definitions):
            num_lines_before += 1
            replacement = i.group('code')
            num_lines = replacement.count('\n')

        elif replacement is None:
            num_lines_before += 1
            num_lines_before += i.group('code').count('\n')+1

    if num_lines_before + num_lines + num_lines_after > 200:
        # this is a strong warning to refactor the code
        raise Exception("ifdef is "+str(num_lines_before + num_lines + num_lines_after)+" lines long!")
    if counts['#ifdef'] + counts['#ifndef'] != 1:
        raise Exception("ifdef has "+str(counts['#ifdef'] + counts['#ifndef'])+" #ifdefs/#ifndefs")
    if counts['#elseif'] + counts['#elseifn'] > 20:
        # this is a strong warning to refactor the code
        raise Exception("ifdef has "+str(counts['#elseif'] + counts['#elseifn'])+" #elseifs/#elseifns")
    if counts['#else'] > 1:
        raise Exception("ifdef has "+str(counts['#else'])+" #elses")

    if replacement is None:
        replacement = ""
        num_lines_before -= 1
    
    if replacement is not None:
        replacement = ('\n'*num_lines_before) + replacement + ('\n'*num_lines_after)
        return content.replace( ifdef, replacement )
    return content


def replace_vars(content, definitions):
    r = re.compile(r'#var (\w+) ')
    content_out = content
    for i in r.finditer(content):
        if i.group(1) in definitions:
            content_out = content_out.replace( i.group(0), definitions[i.group(1)] )
        else:
            content_out = content_out.replace( i.group(0), "None" )
    return content_out


def replace_defineds(content, definitions):
    r = re.compile(r'#defined (\w+)')
    content_out = content
    for i in r.finditer(content):
        if i.group(1) in definitions:
            content_out = content_out.replace( i.group(0), 'true' )
        else:
            content_out = content_out.replace( i.group(0), 'false' )
    return content_out


def preprocessor(content, definitions):
    # TODO: doesn't yet support nested preprocessor definitions
    content = replace_vars(content, definitions)
    content = replace_defineds(content, definitions)
    content_out = content
    r = re.compile(r'((#ifdef )|(#ifndef ))(.*?)(#endif)', flags=re.DOTALL)
    for i in r.finditer(content):
        content_out = preprocess(content_out, i.group(0), definitions)
    return content_out
