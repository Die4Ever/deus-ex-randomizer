# shims is similar to injects, except it rewrites all the classlines of the children of baseclass to extend our shim class instead
# class FixScriptedPawn shims ScriptedPawn; becomes class FixScriptedPawn extends ScriptedPawn;
# and then the children like Robot becomes class Robot extends FixScriptedPawn;
from compiler.base import *

disabled = False
whitelist = []

def before_write(mod, f, injects):
    global whitelist, disabled
    if disabled:
        return
    shimmer = None
    baseclass = f.baseclass
    shimname = baseclass + 'Shim'
    info("shimming "+baseclass)
    for f in mod.values():
        if f.baseclass != baseclass:
            continue
        if f.operator == 'shims':
            f.modify_classline(shimname, 'extends', baseclass)
            shimmer = f
            continue
        debug("shimming between "+baseclass+' and '+f.classname)
        f.modify_classline(f.classname, f.operator, shimname)


def execute_injections(f, prev, idx, inject, injects):
    return True


def handle_inheritance_operator(f, injects):
    return False
