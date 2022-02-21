# shared code for all compiler modules
import sys
import re
import glob
import subprocess
import os.path
import shutil
import traceback
from pathlib import Path
from timeit import default_timer as timer

loglevel = 'info'
vanilla_inheritance_keywords = [None, 'extends', 'expands']

def debug(str):
    global loglevel
    if loglevel == 'debug':
        print(str)

def prependException(e, msg):
    if not e.args:
        e.args = ("",)
    e.args = (msg + " \n" + e.args[0],) + e.args[1:]

def appendException(e, msg):
    if not e.args:
        e.args = ("",)
    e.args = (e.args[0] + " \n" + msg,) + e.args[1:]

def printHeader(text):
    print("")
    print("=====================================================")
    print("            "+text)
    print("=====================================================")
    print("")

def calla(cmds):
    print("running "+repr(cmds))
    start = timer()
    proc = subprocess.Popen(cmds)
    try:
        ret = proc.wait(timeout=600)
    except Exception as e:
        proc.kill()
        print(traceback.format_exc())
        raise
    elapsed_time = timer() - start # in seconds
    print( repr(cmds) + " took " + str(elapsed_time) + " seconds and returned " + str(ret) )
    return ret

def call_read(cmd):
    proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True, universal_newlines=True)
    outs=''
    errs=''

    try:
        outs, errs = proc.communicate(timeout=600)
    except Exception as e:
        proc.kill()
        print(traceback.format_exc())
        raise
    return outs


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
