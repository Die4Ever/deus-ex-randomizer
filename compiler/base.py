# shared code for all compiler modules
import sys
import re
import glob
import subprocess
import os.path
import shutil
import traceback
from pathlib import Path
import time
from timeit import default_timer as timer

loglevel = 'info'
vanilla_inheritance_keywords = [None, 'extends', 'expands']
# text colors
WARNING = '\033[91m'
ENDCOLOR = '\033[0m'
re_error = re.compile(r'((none)|(warning)|(error)|(fail)|(out of bounds))', re.IGNORECASE)

def trace(str):
    # lower than debug
    pass


def debug(str):
    global loglevel
    if loglevel == 'debug':
        print(str)

def info(str):
    global loglevel
    # later we should make this actually separate
    if loglevel == 'debug':
        print(str)

def notice(str):
    # this might be useful if we do threading? so we can redirect to a file?
    print(str)

def prependException(e, msg):
    if not e.args:
        e.args = ("",)
    e.args = (msg + " \n" + e.args[0],) + e.args[1:]

def appendException(e, msg):
    if not e.args:
        e.args = ("",)
    e.args = (e.args[0] + " \n" + msg,) + e.args[1:]

def printError(e):
    print(WARNING+e+ENDCOLOR)

def printHeader(text):
    print("")
    print("=====================================================")
    print("            "+text)
    print("=====================================================")
    print("")


def print_colored(msg):
    msg = re_error.sub(WARNING+"\\1"+ENDCOLOR, msg)
    print(msg)


def read(pipe, outs, errs, verbose):
    o = ''
    if pipe and pipe.readable():
        o += pipe.readline()

    hasWarnings = re_error.search(o)
    if o and (verbose or hasWarnings):
        print_colored(o.strip())
    if hasWarnings:
        errs += o
    return outs+o, errs


def call(cmds, verbose=False, stdout=True, stderr=True):
    print("\nrunning "+repr(cmds))
    start = timer()
    last_print = start
    if loglevel == 'debug':
        verbose = True

    if stdout:
        stdout = subprocess.PIPE
        if stderr:
            stderr = subprocess.STDOUT
    elif stderr:
        stderr = subprocess.PIPE
        stdout = None
    else:
        stderr = None
        stdout = None

    proc = subprocess.Popen(cmds, stdout=stdout, stderr=stderr, close_fds=True, universal_newlines=True)
    outs = ''
    errs = ''
    pipe = None
    if stdout:
        pipe = proc.stdout
    elif stderr:
        pipe = proc.stderr

    try:
        while proc.returncode is None and timer() - start < 600:
            (outs, errs) = read(pipe, outs, errs, verbose)
            proc.poll()
        if proc.returncode != 0:
            raise Exception("call didn't return 0: "+repr(cmds))
    except Exception as e:
        proc.kill()
        (outs, errs) = read(pipe, outs, errs, verbose)
        proc.poll()
        print(traceback.format_exc())
        raise
    elapsed_time = timer() - start # in seconds
    print( repr(cmds) + " took " + str(elapsed_time) + " seconds and returned " + str(proc.returncode) + "\n" )
    return (proc.returncode, outs, errs)


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


def is_uc_file(file):
    path = list(Path(file).parts)
    if len(path) <3:
        return False
    filename = path[-1]
    namespace = path[-3]
    parent = None
    if len(path) > 3:
        parent = path[-4]
    if path[-2] != 'Classes':
        return False
    if not path[-1].endswith('.uc'):
        return False

    return True, filename, namespace, parent
