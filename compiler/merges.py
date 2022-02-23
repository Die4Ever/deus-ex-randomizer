# merges will append our code to the baseclass
from compiler.base import *

disabled = False
whitelist = []

def before_write(mod, f, injects):
    pass

def execute_injections(f, prev, idx, inject, injects):
    global whitelist, disabled
    if disabled and f.classname not in whitelist:
        return True

    f.content = apply_merge(f, f.content, inject)
    return True


def handle_inheritance_operator(f, injects):
    return False


def apply_merge(a, orig_content, b):
    #Find variable definitions in b (file to be merged)
    bVars=[]
    bRest=[]
    for line in b.content.split("\n"):
        if line.startswith("var "):
            bVars.append(line)
        else:
            bRest.append(line)

    if bVars!="":
        merged = []
        aContent = orig_content.split("\n")
        lastVarLine = 0

        for line in aContent:
            if line.strip().startswith("var "):
                lastVarLine = aContent.index(line)

        merged+=aContent[:lastVarLine+1]

        merged.append("//=======Start of variables merged from "+b.mod_name+'/'+b.classname+"=======")
        merged+=bVars
        merged.append("//=======End of variables merged from "+b.mod_name+'/'+b.classname+"=========")
        merged+=aContent[lastVarLine+1:]

        content="\n".join(merged)

    else:
        content = orig_content

    content += "\n\n// === merged from "+b.mod_name+'/'+b.classname+"\n\n"
    b_content = "\n".join(bRest)
    b_content = re.sub(b.classline, "/* "+b.classline+" */", b_content, count=1)
    b_content_no_comments = b.strip_comments(b_content)

    pattern_pre = r'(?P<prefix>(?P<functype>function|event)\s+(?P<types>[^\(]+\s+)?)'
    pattern_mid = r'(?P<name>[^\s\(]+)'
    pattern_post = r'(?P<end>\s*\()'
    r = re.compile(pattern_pre+pattern_mid+pattern_post, flags=re.IGNORECASE)
    for i in r.finditer(b_content_no_comments):
        debug( "merging found: " + repr(i.groupdict()) )
        prefix = i.group('prefix')
        func = i.group('name')
        end = i.group('end')
        content = re.sub( \
            pattern_pre + re.escape(func) + pattern_post, \
            prefix+'_'+func+end, \
            content, \
            flags=re.IGNORECASE \
        )

    return content + b_content
