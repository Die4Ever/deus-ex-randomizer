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
    for i in r.finditer(ifdef):
        if bIfdef(i.group(1), definitions):
            # TODO: pad in extra blank lines so that the line numbers from compiler errors still match?
            return content.replace( ifdef, i.group(2) )
    return content


def preprocessor(content, definitions):
    # TODO: doesn't yet support nested preprocessor definitions
    content_out = content
    r = re.compile(r'(#ifdef )(.*?)(#endif)', flags=re.DOTALL)
    for i in r.finditer(content):
        content_out = preprocess(content_out, i.group(0), definitions)
    return content_out
