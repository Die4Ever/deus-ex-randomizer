from compiler.base import *
import importlib

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
        raise


def execute_injections(f, classname, classline, content, injects):
    write = True
    try:
        debug("execute_injections("+f['file']+") "+classline)
        for inject in injects[f['qualifiedclass']]:
            debug("execute_injections("+f['file']+") "+inject['file']+' '+inject['operator'])
            module = load_module( 'compiler.' + inject['operator'])
            write, classname, classline, content = module.execute_injections(f, inject, classname, classline, content, injects)
    except Exception as e:
        print(traceback.format_exc())
    return write, classname, classline, content

def handle_inheritance_operator(f, classname, classline, content, injects):
    try:
        if f['operator'] not in [None, 'extends', 'expands']:
            debug("handle_inheritance_operator("+f['file']+") "+f['operator'])
            module = load_module( 'compiler.' + f['operator'])
            return module.handle_inheritance_operator(f, classname, classline, content, injects)
    except Exception as e:
        print(traceback.format_exc())
    return True, classname, classline, content

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
    write = True
    
    if qualifiedclass in injects:
        write, classname, classline, content = execute_injections(f, classname, classline, content, injects)
    
    if f['operator']:
        write, classname, classline, content = handle_inheritance_operator(f, classname, classline, content, injects)

    if not write:
        debug("not writing "+f['file'])
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
