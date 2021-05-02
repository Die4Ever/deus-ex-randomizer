from compiler.base import *

disabled = False
whitelist = []

def execute_injections(f, prev, idx, inject, classname, classline, content, injects):
    if disabled and classname not in whitelist:
        return True, classname, classline, content
    
    content = apply_merge(f, content, inject)
    return True, classname, classline, content


def handle_inheritance_operator(f, classname, classline, content, injects):
    return False, classname, classline, content


def apply_merge(a, orig_content, b):
    #Find variable definitions in b (file to be merged)
    bVars=[]
    bRest=[]
    for line in b['content'].split("\n"):
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
            
        merged.append("//=======Start of variables merged from "+b['mod_name']+'/'+b['classname']+"=======")
        merged+=bVars
        merged.append("//=======End of variables merged from "+b['mod_name']+'/'+b['classname']+"=========")
        merged+=aContent[lastVarLine+1:]

        content="\n".join(merged)

    else:
        content = orig_content

    content += "\n\n// === merged from "+b['mod_name']+'/'+b['classname']+"\n\n"
    b_content = "\n".join(bRest)
    b_content = re.sub(b['classline'], "/* "+b['classline']+" */", b_content, count=1)
    b_content_no_comments = strip_comments(b_content)

    pattern_pre = r'(function\s+([^\(]+\s+)?)'
    pattern_post = r'(\s*\()'
    r = re.compile(pattern_pre+r'([^\s\(]+)'+pattern_post, flags=re.IGNORECASE)
    for i in r.finditer(b_content_no_comments):
        debug( "merging found: " + repr(i.groups()) )
        func = i.group(3)
        content = re.sub( \
            pattern_pre + re.escape(func) + pattern_post, \
            r'\1_'+func+r'\3', \
            content, \
            flags=re.IGNORECASE \
        )
    
    return content + b_content
