# injects means our class will take the place of the baseclass, and the baseclass will have "Base" appended to the end of its name
# class DXRHuman injects Human; will be saved as class Human extends HumanBase; and the original Human class will be saved as HumanBase
from compiler.base import *

disabled = False
whitelist = []

def before_write(mod, f, injects):
    pass

def execute_injections(f, prev, idx, inject, classname, classline, content, injects):
    global whitelist
    if disabled and classname not in whitelist:
        print("not injecting "+classname)
        return True, classname, classline, content

    if idx > 0:
        return True, classname, classline, content
    
    comment = "// === was "+classname+" ===\n"
    debug(f['qualifiedclass'] + ' has '+ str(len(injects)) +' injections, renaming to '+f['classname']+'Base' )
    oldclassname = classname
    classname = classname+'Base'
    classline = re.sub('class '+oldclassname, comment + 'class '+classname, classline, count=1)
    content = re.sub('([^a-z])(self)([^a-z])', r'\1'+oldclassname+r'(Self)\3', content, flags=re.IGNORECASE)
    return True, classname, classline, content


def handle_inheritance_operator(f, classname, classline, content, injects):
    global whitelist
    if disabled and f['baseclass'] not in whitelist:
        return False, classname, classline, content
    
    qualifiedbase = f['namespace'] +'.'+ f['baseclass']
    
    injectsnum = injects[qualifiedbase].index(f)
    # we want the first one to be named ClassnameBase2 not 0
    injectsnum += 2
    debug(f['file']+" injectsnum: "+str(injectsnum))

    comment = "// === was "+f['mod_name']+'/'+classname+" ===\n"

    classname = f['baseclass']
    if injectsnum-1 != len(injects[qualifiedbase]):
        classname = f['baseclass']+'Base' + str(injectsnum)
    
    baseclass = f['baseclass']+'Base'
    if injectsnum != 2:
        baseclass = f['baseclass']+'Base' + str(injectsnum-1)
    
    classline = re.sub('class '+f['classname']+' injects '+f['baseclass'], comment + 'class '+classname+' extends '+baseclass, classline, count=1)
    return True, classname, classline, content
