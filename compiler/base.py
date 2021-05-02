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

def copyDeusExU(out):
    if exists(out + '/System/DeusEx.u'):
        print("DeusEx.u exists")
        shutil.copy2(out + '/System/DeusEx.u',"./DeusEx.u")
        print("DeusEx.u copied locally")

