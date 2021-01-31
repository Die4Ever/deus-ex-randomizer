import sys
import pprint
import argparse
import re
import glob
import json
import subprocess
import os.path
import shutil
from pathlib import Path

pp = pprint.PrettyPrinter(indent=4)
parser = argparse.ArgumentParser(description='Deus Ex Injecting Compiler')


def calla(cmds):
    print("running "+repr(cmds))
    subprocess.Popen(cmds).wait()


def insensitive_glob(pattern):
    return (
        glob.glob(pattern, recursive=True)
        + glob.glob(pattern+'/**', recursive=True)
        + glob.glob(pattern+'/*', recursive=True)
    )


def exists(file):
    exists = os.path.isfile(file)
    # if exists:
    #     print("file already exists: " + file)
    return exists

def exists_dir(path):
    exists = os.path.isdir(path)
    # if exists:
    #     print("dir already exists: " + path)
    return exists


def strip_comments(content):
    content_no_comments = re.sub(r'//.*', ' ', content)
    content_no_comments = re.sub(r'/\*.*?\*/', ' ', content_no_comments, flags=re.DOTALL)
    return content_no_comments


def get_class_line(content):
    classline = re.search( r'(class .+?;)', content, flags=re.IGNORECASE | re.DOTALL)
    if classline is not None:
        classline = classline.group(0)
    else:
        print(content)
        raise RuntimeError('Could not find classline')
    return classline


def read_uc_file(file):
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


def proc_file(file, files, mod_name, injects=None):
    f = read_uc_file(file)
    if f is None:
        return
    f['mod_name'] = mod_name
    if f['operator'] == 'injects' or f['operator'] == 'merges':
        if f['baseclass'] not in injects:
            injects[f['namespace']+'.'+f['baseclass']] = [ ]
        injects[f['namespace']+'.'+f['baseclass']].append(f)
    files[f['qualifiedclass']] = f


def apply_merge(a, b):
    content = a['content']
    content += "\n\n// === merged from "+b['mod_name']+'/'+b['classname']+"\n\n"
    b_content = b['content']
    b_content = re.sub(b['classline'], "/* "+b['classline']+" */", b_content, count=1)
    b_content_no_comments = strip_comments(b_content)

    pattern_pre = r'(function\s+([^\(]+\s+)?)'
    pattern_post = r'(\s*\()'
    r = re.compile(pattern_pre+r'([^\s\(]+)'+pattern_post, flags=re.IGNORECASE)
    for i in r.finditer(b_content_no_comments):
        print( "merging found: " + repr(i.groups()) )
        func = i.group(3)
        content = re.sub( \
            pattern_pre + re.escape(func) + pattern_post, \
            r'\1_'+func+r'\3', \
            content, \
            flags=re.IGNORECASE \
        )
    
    return content + b_content


def inject_into(f, injects):
    classname = f['classname']
    classline = f['classline']
    comment = "// === was "+classname+" ===\n"
    #print(f['qualifiedclass'] + ' has '+ str(len(injects[f['qualifiedclass']])) +' injections, renaming to Base'+f['classname'] )
    classname = classname+'Base'
    classline = re.sub('class '+f['classname'], comment + 'class '+classname, classline, count=1)
    return classname, classline


def inject_from(f, injects):
    classname = f['classname']
    classline = f['classline']
    #print(f['qualifiedclass'] + ' injects into ' + f['baseclass'] )
    comment = "// === was "+f['mod_name']+'/'+classname+" ===\n"
    classname = f['baseclass']
    classline = re.sub('class '+f['classname']+' injects '+f['baseclass'], comment + 'class '+classname+' extends '+f['baseclass']+'Base', classline, count=1)
    return classname, classline


def write_file(out, f, written, injects):
    if f['file'] in written:
        return
    
    classname = f['classname']
    classline = f['classline']
    qualifiedclass = f['qualifiedclass']
    content = f['content']
    
    if qualifiedclass in injects:
        if injects[qualifiedclass][0]['operator'] == 'merges':
            content = apply_merge(f, injects[qualifiedclass][0])
        else:
            classname, classline = inject_into(f, injects)
    
    if f['operator'] == 'injects':
        classname, classline = inject_from(f, injects)

    if f['operator'] == 'merges' or f['operator'] == 'overwrites':
        print("not writing because inheritance operator is "+f['operator'])
        return

    if classline != f['classline']:
        content = re.sub(f['classline'], classline, content, count=1)
        print("changing from: "+f['classline']+"\n---to: "+classline)
    
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

    print("writing from: "+f['file']+" to: "+path)
    print("")
    with open(path, 'w') as file:
        file.write(content)
    written[f['file']] = 1

def copyDeusExU(out):
    if exists(out + '/System/DeusEx.u'):
        print("DeusEx.u exists")
        shutil.copy2(out + '/System/DeusEx.u',"./DeusEx.u")
        print("DeusEx.u copied locally")

def compile(source, mods, out):
    orig_files = {}
    mods_files = []
    injects = {}
    written = {}

    for file in insensitive_glob(source+'/*'):
        print("Processing file "+str(file))
        proc_file(file, orig_files, 'original')
    
    for mod in mods:
        mods_files.append({})
        for file in insensitive_glob(mod+'*'):
            print("Processing mod file "+str(file))
            proc_file(file, mods_files[-1], mod, injects)

    print("\nwriting files...")
    for file in orig_files.values():
        print("Writing file "+str(file['file']))
        write_file(out, file, written, injects)
    for mod in mods_files:
        for file in mod.values():
            print("Writing mod file "+str(file['file']))
            write_file(out, file, written, injects)
    
    # now we need to delete DeusEx.u otherwise it won't get recompiled, might want to consider support for other packages too
    if exists(out + '/System/DeusEx.u'):
        print("Removing old DeusEx.u")
        os.remove(out + '/System/DeusEx.u')

    # can set a custom ini file ucc make INI=ProBob.ini https://www.oldunreal.com/wiki/index.php?title=Working_with_*.uc%27s
    # I can run automated tests like ucc Core.HelloWorld
    if not exists_dir(out + '/DeusEx/Inc'):
        os.makedirs(out + '/DeusEx/Inc', exist_ok=True)
    calla([ out + '/System/ucc', 'make', '-h', '-NoBind', '-Silent' ])



parser.add_argument('--source_path', help='Path to the original game source code')
parser.add_argument('--mods_paths', nargs='*', help='List of mods folders')
parser.add_argument('--out_dir', help='Where to write files to')
parser.add_argument('--copy_local', action="store_true", help="Use this flag to make a local copy of DeusEx.u")
args = parser.parse_args()
pp.pprint(args)

if args.source_path is None:
    args.source_path = input("Enter original game source code path (blank for default of C:/Program Files (x86)/Steam/steamapps/common/Deus Ex Backup/): ")

if args.source_path is None or args.source_path == '':
    args.source_path = "C:/Program Files (x86)/Steam/steamapps/common/Deus Ex Backup/"

while 1:
    f = input("Enter a mod path (or blank to continue): ")
    if f == '':
        break
    if args.mods_paths is None:
        args.mods_paths = [ ]
    args.mods_paths.append(f)

if args.out_dir is None:
    args.out_dir = input("Enter output path (blank for default of C:/Program Files (x86)/Steam/steamapps/common/Deus Ex/): ")

if args.out_dir is None or args.out_dir == '':
    args.out_dir = "C:/Program Files (x86)/Steam/steamapps/common/Deus Ex/"

pp.pprint(args)
if args.mods_paths is None:
    print("no mods specified! using local directory")
    args.mods_paths = [ './' ]

rerun = ""
while rerun == "":
    try:
        print("\ncompiling...")
        compile(args.source_path, args.mods_paths, args.out_dir)
        if args.copy_local:
            copyDeusExU(args.out_dir)
    except Exception as e:
        print('\n\ncompile error: ')
        print(e)
    print("\n")
    rerun = input("press enter to compile again, otherwise type exit")

print("\n\nto run this again, use this command: (coming soon)")
input("press enter to continue")
