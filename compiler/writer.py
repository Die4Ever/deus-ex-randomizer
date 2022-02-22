# calls all of the inheritance operator modules (injects.py, shims.py, merges.py) and writes out the files
# also cleans up the extra leftover files
from compiler.base import *
import importlib
import pathlib

modules = {}

def load_module(name):
    global modules
    try:
        if name not in modules and name in sys.modules:
            modules[name] = importlib.reload(sys.modules[name])
        if name not in modules:
            modules[name] = importlib.import_module(name)
        return modules[name]
    except Exception as e:
        print(traceback.format_exc())
        print('load_module('+name+')')
        raise

def before_write(mod, injects):
    for i in injects:
        inject = injects[i]
        for f in inject:
            before_write_file(mod, f, inject)


def before_write_file(mod, f, injects):
    if f.operator in vanilla_inheritance_keywords:
        return

    try:
        module = load_module( 'compiler.' + f.operator)
        module.before_write(mod, f, injects)
    except Exception as e:
        print(traceback.format_exc())
        print('before_write_file('+repr(mod)+', '+f.file+') '+f.operator)
        raise

def execute_injections(f, injects):
    write = True

    debug("execute_injections("+f.file+") "+f.classline)
    prev = f
    for idx, inject in enumerate(injects[f.qualifiedclass]):
        if f == inject or inject.operator in vanilla_inheritance_keywords:
            continue
        debug("execute_injections("+f.file+") "+inject.file+' '+inject.operator)
        try:
            module = load_module( 'compiler.' + inject.operator)
            write = module.execute_injections(f, prev, idx, inject, injects[f.qualifiedclass])
            prev = inject
        except Exception as e:
            print(traceback.format_exc())
            print('execute_injections('+f.file+') '+inject.file+' '+inject.operator)
            raise
    return write

def handle_inheritance_operator(f, injects):
    if f.operator in vanilla_inheritance_keywords:
        return True

    debug("handle_inheritance_operator("+f.file+") "+f.operator)
    module = load_module( 'compiler.' + f.operator)
    try:
        return module.handle_inheritance_operator(f, injects)
    except Exception as e:
        print(traceback.format_exc())
        print('handle_inheritance_operator('+f.file+') '+f.operator)
        raise

def write_file(out, f, written, injects):
    if f.file in written:
        return

    if not hasattr(write_file,"last_folder"):
        write_file.last_folder=""
    folder = Path(f.file).parent
    if folder != write_file.last_folder:
        info("Writing folder "+str(folder)[-50:])
    debug("Writing "+f.file)
    write_file.last_folder = folder

    write = True

    if f.qualifiedclass in injects:
        write = execute_injections(f, injects)

    if f.operator:
        write = handle_inheritance_operator(f, injects)

    if not write:
        debug("not writing "+f.file)
        return

    path = pathlib.PurePath(out, f.namespace, 'Classes')
    if not exists_dir(path):
        os.makedirs(path, exist_ok=True)
    path = path / ( f.classname+'.uc' )

    written[f.file] = 1
    written[str(path)] = 1

    if exists(path):
        oldcontent = None
        with open(path) as file:
            oldcontent = file.read()
        if oldcontent == f.content:
            return

    debug("writing from: "+f.file+" to: "+str(path))
    debug("")
    with open(path, 'w') as file:
        file.write(f.content)

def cleanup(out, written):
    for file in insensitive_glob(out+'*'):
        if not is_uc_file(file):
            continue
        path = pathlib.PurePath(file)
        if str(path) in written:
            continue
        print("cleaning up "+str(path))
        os.remove(path)

