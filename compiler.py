import sys
import pprint
import argparse
import re
import glob
import json
import subprocess
import os.path
from pathlib import Path
import tempfile
import hashlib

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
    content_no_comments = re.sub(r'/\*.*\*/', ' ', content_no_comments, flags=re.DOTALL)
    return content_no_comments


def get_class_line(content):
    #print(content_no_comments)
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

    #if path[-1] != 'DXREnemyRespawn.uc':
    #    return

    content=None
    with open(file) as f:
        content = f.read()
    
    md5 = hashlib.md5(content.encode('utf-8')).hexdigest()

    #print(file)
    content_no_comments = strip_comments(content)
    classline = get_class_line(content_no_comments)
    # idk if there can be any keywords before the extends/expands keyword? but this regex allows for it
    # maybe a new keyword could be used since injects doesn't work for DeusExLevelInfo, maybe combines or something
    injects = re.search(r'class\s+(\S+)\s+(.*\s+)??(((injects)|(extends)|(expands)|(overwrites))\s+([^\s;]+))?', content_no_comments, flags=re.IGNORECASE)
    classname = None
    operator = None
    baseclass = None
    if injects is not None:
        classname = injects.group(1)
        operator = injects.group(4)
        baseclass = injects.group(9)
        # if baseclass is not None:
        #     print("classname: "+classname+", operator: "+operator+", baseclass: "+baseclass)
        # else:
        #     print("classname: "+classname+", no inheritance")
    else:
        RuntimeError("couldn't read class definition")
    
    # maybe do some assertions on classnames, and verify that classname matches filename?

    return {'path':path, 'namespace':namespace, 'filename':filename, 'file':file, 'content':content, 'md5':md5, \
        'classline':classline, 'classname':classname, 'operator':operator, 'baseclass':baseclass, 'qualifiedclass':namespace+'.'+classname }


def proc_file(file, files, injects=None):
    f = read_uc_file(file)
    if f is None:
        return
    #print("namespace: " + f['namespace'] + ", filename: " + f['filename'] + ", file: " + f['file'] + "\nmd5: " + f['md5'] + "\n" + f['classline'] )
    if f['operator'] == 'injects':
        if f['baseclass'] not in injects:
            injects[f['namespace']+'.'+f['baseclass']] = [ ]
        injects[f['namespace']+'.'+f['baseclass']].append(f)
    files[f['qualifiedclass']] = f


def write_file(out, f, written, injects):
    if f['file'] in written:
        return
    
    classname = f['classname']
    classline = f['classline']
    content = f['content']
    
    if f['qualifiedclass'] in injects:
        #print(f['qualifiedclass'] + ' has '+ str(len(injects[f['qualifiedclass']])) +' injections, renaming to Base'+f['classname'] )
        classname = classname+'Base'
        classline = re.sub('class '+f['classname'], 'class '+classname, classline, count=1)
    
    if f['operator'] == 'injects':
        #print(f['qualifiedclass'] + ' injects into ' + f['baseclass'] )
        classname = f['baseclass']
        classline = re.sub('class '+f['classname']+' injects '+f['baseclass'], 'class '+classname+' extends '+f['baseclass']+'Base', classline, count=1)

    if classline != f['classline']:
        content = re.sub(f['classline'], classline, content, count=1)
        #print(content)
        print("changing from: "+f['classline']+"\n---to: "+classline)
    
    #print('writing '+f['file'])
    path = out + f['namespace'] + '/Classes/'
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
    with open(path, 'w') as file:
        file.write(content)
    written[f['file']] = 1


def compile(source, mods, out):
    orig_files = {}
    mods_files = []
    injects = {}
    written = {}

    for file in insensitive_glob(source+'*'):
        proc_file(file, orig_files)
    
    for mod in mods:
        mods_files.append({})
        for file in insensitive_glob(mod+'*'):
            proc_file(file, mods_files[-1], injects)
    
    #print(json.dumps(mods_files, sort_keys=True, indent=4, default=str))
    print("\nwriting files...")
    for file in orig_files.values():
        write_file(out, file, written, injects)
    for mod in mods_files:
        for file in mod.values():
            write_file(out, file, written, injects)
    
    # now we need to delete DeusEx.u otherwise it won't get recompiled, might want to consider support for other packages too
    if exists(out + '/System/DeusEx.u'):
        os.remove(out + '/System/DeusEx.u')

    # can set a custom ini file ucc make INI=ProBob.ini https://www.oldunreal.com/wiki/index.php?title=Working_with_*.uc%27s
    # I can run automated tests like ucc Core.HelloWorld
    #oldcwd = os.getcwd()
    #os.chdir(out)
    if not exists_dir(out + '/DeusEx/Inc'):
        os.makedirs(out + '/DeusEx/Inc', exist_ok=True)
    calla([ out + '/System/ucc', 'make', '-h', '-NoBind', '-Silent' ])
    #os.chdir(oldcwd)



parser.add_argument('--source_path', help='Path to the original game source code')
parser.add_argument('--mods_paths', nargs='*', help='List of mods folders')
parser.add_argument('--out_dir', help='Where to write files to')
args = parser.parse_args()
pp.pprint(args)

if args.source_path is None:
    args.source_path = input("Enter original game source code path (blank for default of C:/Program Files (x86)/Steam/steamapps/common/Deus Ex Backup): ")

if args.source_path is None or args.source_path == '':
    args.source_path = "C:/Program Files (x86)/Steam/steamapps/common/Deus Ex Backup"

while 1:
    f = input("Enter a mod path (or blank to continue): ")
    if f == '':
        break
    if args.mods_paths is None:
        args.mods_paths = [ ]
    args.mods_paths.append(f)

if args.out_dir is None:
    args.out_dir = "C:/Program Files (x86)/Steam/steamapps/common/Deus Ex/"


pp.pprint(args)
#input("continue?")
if args.mods_paths is None:
    print("no mods specified! using local directory")
    args.mods_paths = [ './' ]

compile(args.source_path, args.mods_paths, args.out_dir)

print("\n\nto run this again, use this command: (coming soon)")
