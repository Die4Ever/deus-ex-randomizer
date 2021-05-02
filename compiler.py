import sys
import pprint
import argparse
import re
import glob
import json
import subprocess
import os.path
import shutil
import traceback
from pathlib import Path
from timeit import default_timer as timer
from importlib import reload, invalidate_caches

import compiler.base
import compiler.preprocessor
import compiler.reader
import compiler.writer
import compiler.tester
import compiler.compiler

default_source_path = "C:/Program Files (x86)/Steam/steamapps/common/Deus Ex Backup/"
default_output_path = "C:/Program Files (x86)/Steam/steamapps/common/Deus Ex/"
pp = pprint.PrettyPrinter(indent=4)
parser = argparse.ArgumentParser(description='Deus Ex Injecting Compiler')

parser.add_argument('--source_path', help='Path to the original game source code')
parser.add_argument('--preproc_definitions', nargs='*', help='Preprocessor variables for #ifdef')
parser.add_argument('--mods_paths', nargs='*', help='List of mods folders')
parser.add_argument('--out_dir', help='Where to write files to')
parser.add_argument('--copy_local', action="store_true", help="Use this flag to make a local copy of DeusEx.u")
parser.add_argument('--verbose', action="store_true", help="Output way more to the screen")
args = parser.parse_args()
pp.pprint(args)

if args.source_path is None:
    args.source_path = input("Enter original game source code path (blank for default of "+default_source_path+"): ")

if args.source_path is None or args.source_path == '':
    args.source_path = default_source_path

if args.preproc_definitions is None:
    args.preproc_definitions = [ ]

while 1:
    f = input("Enter a variable for the preprocessor (or blank to continue): ")
    if f == '':
        break
    if args.preproc_definitions is None:
        args.preproc_definitions = [ ]
    args.preproc_definitions.append(f)

while 1:
    f = input("Enter a mod path (or blank to continue): ")
    if f == '':
        break
    if args.mods_paths is None:
        args.mods_paths = [ ]
    args.mods_paths.append(f)

if args.out_dir is None:
    args.out_dir = input("Enter output path (blank for default of "+default_output_path+"): ")

if args.out_dir is None or args.out_dir == '':
    args.out_dir = default_output_path

pp.pprint(args)
if args.mods_paths is None:
    print("no mods specified! using local directory")
    args.mods_paths = [ './' ]

if args.verbose:
    loglevel = 'debug'

rerun = ""
while rerun == "":
    try:
        print("")
        print("loading modules...")
        invalidate_caches()
        args.base = reload(compiler.base)
        args.compiler = reload(compiler.compiler)
        args.reader = reload(compiler.reader)
        args.writer = reload(compiler.writer)
        args.tester = reload(compiler.tester)
        args.preprocessor = reload(compiler.preprocessor)

        print("compiling...")
        compileResult = args.compiler.compile(args)
        if compileResult != 0:
            raise RuntimeError("Compilation failed, returned: "+str(compileResult))
        testSuccess = args.tester.runAutomatedTests(args.out_dir)

        if args.copy_local:
            if testSuccess:
                args.base.copyDeusExU(args.out_dir)
            else:
                print("Automated tests failed, DeusEx.u not copied locally")
                
    except Exception as e:
        print('\n\ncompile error: ')
        print(traceback.format_exc())
    print("\n")
    rerun = input("press enter to compile again, otherwise type exit")

print("\n\nto run this again, use this command: (coming soon)")
input("press enter to continue")
