from compiler.base import *

def get_class_line(content):
    classline = re.search( r'(class .+?;)', content, flags=re.IGNORECASE | re.DOTALL)
    if classline is not None:
        classline = classline.group(0)
    else:
        print(content)
        raise RuntimeError('Could not find classline')
    return classline

def read_uc_file(file, definitions, preprocessor):
    path = list(Path(file).parts)
    if len(path) <3:
        return
    filename = path[-1]
    namespace = path[-3]
    if path[-2] != 'Classes':
        return
    if not path[-1].endswith('.uc'):
        return
    
    content=None
    with open(file) as f:
        content = f.read()
    
    content = preprocessor.preprocessor(content, definitions)

    content_no_comments = strip_comments(content)
    classline = get_class_line(content_no_comments)
    # idk if there can be any keywords before the extends/expands keyword? but this regex allows for it
    inheritance = re.search(r'class\s+(\S+)\s+(.*\s+)??(((injects)|(extends)|(expands)|(overwrites)|(merges))\s+([^\s;]+))?', classline, flags=re.IGNORECASE)
    classname = None
    operator = None
    baseclass = None
    if inheritance is not None:
        classname = inheritance.group(1)
        operator = inheritance.group(4)
        baseclass = inheritance.group(10)
    else:
        RuntimeError("couldn't read class definition")
    
    # maybe do some assertions on classnames, and verify that classname matches filename?

    return {'path':path, 'namespace':namespace, 'filename':filename, 'file':file, 'content':content, 'classline':classline, \
        'classname':classname, 'operator':operator, 'baseclass':baseclass, 'qualifiedclass':namespace+'.'+classname }


def proc_file(file, files, mod_name, injects, definitions, preprocessor):
    debug("Processing "+file+" from "+mod_name)

    f = read_uc_file(file, definitions, preprocessor)
    if f is None:
        return
    
    if not hasattr(proc_file,"last_folder"):
        proc_file.last_folder=""
    folder = Path(file).parent
    if folder != proc_file.last_folder:
        print("Processing folder "+str(folder)[-50:]+" from "+mod_name)
    proc_file.last_folder = folder

    f['mod_name'] = mod_name
    if f['operator'] == 'injects' or f['operator'] == 'merges':
        key = f['namespace']+'.'+f['baseclass']
        if key not in injects:
            injects[key] = [ ]
        injects[key].append(f)
    files[f['qualifiedclass']] = f

