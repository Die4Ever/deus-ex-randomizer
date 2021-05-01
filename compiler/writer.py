from compiler.base import *

def apply_merge(a, b):
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
        aContent = a['content'].split("\n")
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
        content = a['content']

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


def inject_into(f, injects):
    classname = f['classname']
    classline = f['classline']
    content = f['content']
    comment = "// === was "+classname+" ===\n"
    #print(f['qualifiedclass'] + ' has '+ str(len(injects[f['qualifiedclass']])) +' injections, renaming to Base'+f['classname'] )
    classname = classname+'Base'
    classline = re.sub('class '+f['classname'], comment + 'class '+classname, classline, count=1)
    content = re.sub('([^a-z])(self)([^a-z])', r'\1'+f['classname']+r'(Self)\3', content, flags=re.IGNORECASE)
    return classname, classline, content


def inject_from(f, injects):
    classname = f['classname']
    classline = f['classline']
    content = f['content']
    #print(f['qualifiedclass'] + ' injects into ' + f['baseclass'] )
    comment = "// === was "+f['mod_name']+'/'+classname+" ===\n"
    classname = f['baseclass']
    classline = re.sub('class '+f['classname']+' injects '+f['baseclass'], comment + 'class '+classname+' extends '+f['baseclass']+'Base', classline, count=1)
    return classname, classline, content


def write_file(out, f, written, injects):
    if f['file'] in written:
        return
    
    if not hasattr(write_file,"last_folder"):
        write_file.last_folder=""
    folder = Path(f['file']).parent
    if folder != write_file.last_folder:
        print("Writing folder "+str(folder)[-50:])
    debug("Writing "+f['file'])
    write_file.last_folder = folder
    
    classname = f['classname']
    classline = f['classline']
    qualifiedclass = f['qualifiedclass']
    content = f['content']
    
    if qualifiedclass in injects:
        if injects[qualifiedclass][0]['operator'] == 'merges':
            content = apply_merge(f, injects[qualifiedclass][0])
        else:
            classname, classline, content = inject_into(f, injects)
    
    if f['operator'] == 'injects':
        classname, classline, content = inject_from(f, injects)

    if f['operator'] == 'merges' or f['operator'] == 'overwrites':
        debug("not writing because inheritance operator is "+f['operator'])
        return

    if classline != f['classline']:
        content = re.sub(f['classline'], classline, content, count=1)
        debug("changing from: "+f['classline']+"\n---to: "+classline)
    
    path = out + '/' + f['namespace'] + '/Classes/'
    if not exists_dir(path):
        os.makedirs(path, exist_ok=True)
    path += classname + '.uc'

    if exists(path):
        oldcontent = None
        with open(path) as file:
            oldcontent = file.read()
        if oldcontent == content:
            written[f['file']] = 1
            return

    debug("writing from: "+f['file']+" to: "+path)
    debug("")
    with open(path, 'w') as file:
        file.write(content)
    written[f['file']] = 1
