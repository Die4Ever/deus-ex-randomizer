# injects means our class will take the place of the baseclass, and the baseclass will have "Base" appended to the end of its name
# class DXRHuman injects Human; will be saved as class Human extends HumanBase; and the original Human class will be saved as HumanBase
from compiler.base import *

disabled = False
whitelist = []

def before_write(mod, f, injects):
    pass

def execute_injections(f, prev, idx, inject, injects):
    global whitelist, disabled
    if disabled and f.classname not in whitelist:
        print("not injecting "+f.classname)
        return True

    if idx > 0:
        return True
    
    oldclassname = f.classname
    newclassname = oldclassname+'Base'

    debug(f.qualifiedclass + ' has '+ str(len(injects)) +' injections, renaming to '+newclassname )
    f.modify_classline(newclassname, f.operator, f.baseclass)
    f.content = re.sub('([^a-z])(self)([^a-z])', r'\1'+oldclassname+r'(Self)\3', f.content, flags=re.IGNORECASE)
    return True


def handle_inheritance_operator(f, injects):
    global whitelist, disabled
    if disabled and f.baseclass not in whitelist:
        return False
    
    qualifiedbase = f.namespace +'.'+ f.baseclass
    
    injectsnum = injects[qualifiedbase].index(f)
    # we want the first one to be named ClassnameBase2 not 0
    injectsnum += 2
    debug(f.file+" injectsnum: "+str(injectsnum))

    classname = f.baseclass
    if injectsnum-1 != len(injects[qualifiedbase]):
        classname = f.baseclass+'Base' + str(injectsnum)
    
    baseclass = f.baseclass+'Base'
    if injectsnum != 2:
        baseclass = f.baseclass+'Base' + str(injectsnum-1)
    
    f.modify_classline(classname, 'extends', baseclass)
    return True
