# shims is similar to injects, except it rewrites all the children of baseclass to extend our shim class instead
# class FixScriptedPawn shims ScriptedPawn; becomes class FixScriptedPawn extends ScriptedPawn;
from compiler.base import *

disabled = False
whitelist = []

def before_write(mod, f, injects):
    if disabled:
        return
    shimmer = None
    baseclass = f['baseclass']
    shimname = baseclass + 'Shim'
    print("shimming "+baseclass)
    for f in mod.values():
        if f['baseclass'] != baseclass:
            continue
        if f['operator'] == 'shims':
            write_classline(f, shimname, 'extends', baseclass)
            shimmer = f
            continue
        print("shimming between "+baseclass+' and '+f['classname'])
        write_classline(f, f['classname'], f['operator'], shimname)

def write_classline(f, classname, operator, baseclass):
    oldclassline = f['classline']
    oldclassname = f['classname']
    oldoperator = f['operator']
    oldbaseclass = f['baseclass']
    comment = "// === was "+f['mod_name']+'/'+oldclassname+" ===\n"
    newclassline = re.sub('class\s+'+oldclassname+'\s+'+oldoperator+'\s+'+oldbaseclass, comment + 'class '+classname+' '+operator+' '+baseclass, oldclassline, count=1)
    f['newclassline'] = newclassline
    f['classname'] = classname
    f['operator'] = operator
    f['baseclass'] = baseclass


def execute_injections(f, prev, idx, inject, classname, classline, content, injects):
    return True, classname, classline, content


def handle_inheritance_operator(f, classname, classline, content, injects):
    return True, classname, classline, content
