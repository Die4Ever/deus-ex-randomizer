from compiler.base import *

disabled = False
whitelist = []

def execute_injections(f, inject, classname, classline, content, injects):
    global whitelist
    if disabled and classname not in whitelist:
        print("not injecting "+classname)
        return True, classname, classline, content
    
    if f['operator'] == 'injects':
        # don't inject self
        return True, classname, classline, content
    
    comment = "// === was "+classname+" ===\n"
    print(f['qualifiedclass'] + ' has '+ str(len(injects[f['qualifiedclass']])) +' injections, renaming to Base'+f['classname'] )
    oldclassname = classname
    classname = classname+'Base'
    classline = re.sub('class '+oldclassname, comment + 'class '+classname, classline, count=1)
    content = re.sub('([^a-z])(self)([^a-z])', r'\1'+oldclassname+r'(Self)\3', content, flags=re.IGNORECASE)
    return True, classname, classline, content


def handle_inheritance_operator(f, classname, classline, content, injects):
    global whitelist
    if disabled and f['baseclass'] not in whitelist:
        return False, classname, classline, content
    
    comment = "// === was "+f['mod_name']+'/'+classname+" ===\n"
    classname = f['baseclass']
    classline = re.sub('class '+f['classname']+' injects '+f['baseclass'], comment + 'class '+classname+' extends '+f['baseclass']+'Base', classline, count=1)
    return True, classname, classline, content
