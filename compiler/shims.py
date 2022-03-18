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

    orig_base = f.baseclass
    info('starting shimming '+f.classline)
    f.modify_classline(f.classname, 'extends', f.baseclass)
    debug(indent(f.classline))
    baseclass = f.classname
    for i in injects:
        if i != f:
            i.modify_classline(i.classname, 'extends', baseclass)
            debug(indent(i.classline))
            baseclass = i.classname

    debug(indent('modifying children...'))
    for t in mod.values():
        if t in injects or t.baseclass != orig_base:
            continue
        debug(indent('shimming between '+t.classname+' and '+baseclass+' and '+orig_base))
        t.modify_classline(t.classname, t.operator, baseclass)
    debug('done shimming')


def execute_injections(f, prev, idx, inject, injects):
    return True


def handle_inheritance_operator(f, injects):
    return False
