# run this script, it accepts the arguments and user input before running the compiler/compiler.py module
# also reloads all modules for every run
import sys
#import pprint
import argparse
import re
import glob
import json
import subprocess
import os.path
import shutil
import traceback
import datetime
from pathlib import Path
from timeit import default_timer as timer
from importlib import reload, invalidate_caches

import compiler.base
import compiler.preprocessor
import compiler.reader
import compiler.writer
import compiler.tester
import compiler.compiler

parser = argparse.ArgumentParser(description='Deus Ex Injecting Compiler')

parser.add_argument('--profile', help='Which profile(s) to use from the settings file')
parser.add_argument('--verbose', action="store_true", help="Output way more to the screen")
args = parser.parse_args()
#pp.pprint(args)
print(repr(args))

if args.profile is None:
    args.profile = "all"

rerun = ""
while rerun != "exit":
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

        if rerun != "":
            args.profile = rerun

        print(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + ": compiling "+args.profile+"...")
        args.compiler.run(args)

    except Exception as e:
        args.base.printError('\n\ncompile error: ')
        if args.verbose:
            tb = traceback.TracebackException.from_exception(e, capture_locals=True)
            print("\n----------\n".join(tb.format()))
        else:
            print(traceback.format_exc())
        args.base.printError("----------------")

    print("\n")
    print( datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        + ": \npress enter to compile "+args.profile+" again")
    print("- or type in a new profile name")
    rerun = input("- otherwise type exit: ")

print("\n\nto run this again, use this command: (coming soon)")
input("press enter to continue")
