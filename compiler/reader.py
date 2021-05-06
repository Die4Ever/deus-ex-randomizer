# read and parse UC files
from compiler.base import *

class UnrealScriptFile():
    def __init__(self, file, preprocessor, definitions):
        self.file = file
        self.read_file(preprocessor, definitions)
    
    def read_file(self, preprocessor, definitions):
        success, self.filename, self.namespace, self.parentfolder = is_uc_file(self.file)
        if not success:
            raise RuntimeError( self.file + ' is not an unrealscript file!' )
            
        self.content = None
        with open(self.file) as f:
            self.content = f.read()
        self.content = preprocessor.preprocessor(self.content, definitions)
        self.content_no_comments = self.strip_comments(self.content)
        self.classline = self.get_class_line(self.content_no_comments)
        inheritance = re.search(r'class\s+(?P<classname>\S+)\s+(.*\s+)??((?P<operator>(injects)|(extends)|(expands)|(overwrites)|(merges)|(shims))\s+(?P<baseclass>[^\s;]+))?', self.classline, flags=re.IGNORECASE)
        self.classname = None
        self.operator = None
        self.baseclass = None
        if inheritance is not None:
            self.classname = inheritance.group('classname')
            self.operator = inheritance.group('operator')
            self.baseclass = inheritance.group('baseclass')
        else:
            RuntimeError(file+" couldn't read class definition")
        # maybe do some assertions on classnames, and verify that classname matches filename?
        self.qualifiedclass = self.namespace+'.'+self.classname
    
    def modify_classline(f, classname, operator, baseclass):
        comment = "// === was "+f.mod_name+'/'
        if f.parentfolder:
            comment += f.parentfolder+'/'
        comment += f.filename+' class '+f.classname+" ===\n"

        oldclassline = f.classline

        f.classline = re.sub('class\s+'+f.classname+'\s+'+f.operator+'\s+'+f.baseclass, comment + 'class '+classname+' '+operator+' '+baseclass, oldclassline, count=1)
        f.classname = classname
        f.operator = operator
        f.baseclass = baseclass
        f.content = re.sub(oldclassline, f.classline, f.content, count=1)
    
    @staticmethod
    def get_class_line(content):
        classline = re.search( r'(class .+?;)', content, flags=re.IGNORECASE | re.DOTALL)
        if classline is not None:
            classline = classline.group(0)
        else:
            print(content)
            raise RuntimeError('Could not find classline')
        return classline
    
    @staticmethod
    def strip_comments(content):
        content_no_comments = re.sub(r'//.*', ' ', content)
        content_no_comments = re.sub(r'/\*.*?\*/', ' ', content_no_comments, flags=re.DOTALL)
        return content_no_comments


def read_uc_file(file, preprocessor, definitions):
    f = UnrealScriptFile(file, preprocessor, definitions)
    return f


def proc_file(file, files, mod_name, injects, preprocessor, definitions):
    debug("Processing "+file+" from "+mod_name)
    if not is_uc_file(file):
        return
    
    if not hasattr(proc_file,"last_folder"):
        proc_file.last_folder=""
    folder = Path(file).parent
    if folder != proc_file.last_folder:
        print("Processing folder "+str(folder)[-50:]+" from "+mod_name)
    proc_file.last_folder = folder

    f = read_uc_file(file, preprocessor, definitions)
    if f is None:
        return

    f.mod_name = mod_name
    if f.operator not in vanilla_inheritance_keywords:
        key = f.namespace+'.'+f.baseclass
        if key not in injects:
            injects[key] = [ ]
        injects[key].append(f)
    files[f.qualifiedclass] = f
    return f

